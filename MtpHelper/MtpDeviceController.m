//
//  MtpDeviceController.m
//  MtpHelper
//
//  Copyright (c) 2017 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information.
//

#import "MtpDeviceController.h"
#import "NSDictionary+MtpExtension.h"
#import "NSData+MtpExtension.h"
#import "NSString+MtpExtension.h"
#import "ptp/PTPEnums.h"
#import "ptp/PTPProtocolHelpers.h"


const NSString* _Nonnull kMtpDeviceCtl_onSessionReadyCallback = @"kMtpDeviceCtl_onSessionReadyCallback";
const NSString* _Nonnull kMtpDeviceCtl_onSessionCloseCallback = @"kMtpDeviceCtl_onSessionCloseCallback";
const NSString* _Nonnull kMtpDeviceCtl_errorObject = @"kMtpDeviceCtl_errorObject";
const NSString* _Nonnull kMtpDeviceCtl_requestSendPTPCommandFlag = @"kMtpDeviceCtl_requestSendPTPCommandFlag";
const NSString* _Nonnull kMtpDeviceCtl_lastRequestObject = @"kMtpDeviceCtl_lastRequestObject";

const NSTimeInterval kMtpDeviceCtl_timedOutForPTPRequest =  5; // in sec.
const NSTimeInterval kMtpDeviceCtl_timedOutForSendConfig = 20; // in sec.


@interface MtpDeviceController()

@property (nonatomic, nonnull) ICDeviceBrowser* deviceBrowser;
@property (nonatomic, nonnull) NSArray<NSString*>* friendlyNames;
@property (nonatomic, nonnull) NSMutableDictionary* targetDevices;
@property (nonatomic, nonnull) NSMutableArray* timedoutRequests;

@end


@implementation MtpDeviceController

- (id)init
{
    if (self = [super init]) {
        _targetDevices = [NSMutableDictionary new];
        _friendlyNames = @[];
        _keepOpenSession = YES;
        _timedoutRequests = [NSMutableArray new];
    }
    return self;
}


- (void)start:(nonnull NSArray<NSString*>*)friendlyNames
{
    self.friendlyNames = friendlyNames;
    self.deviceBrowser = [ICDeviceBrowser new];
    self.deviceBrowser.delegate = self;
    self.deviceBrowser.browsedDeviceTypeMask = (ICDeviceTypeMask)(ICDeviceTypeMaskCamera | ICDeviceLocationTypeMaskLocal);
    [self.deviceBrowser start];
}


- (nonnull NSArray*)deviceList
{
    return self.targetDevices.allKeys;
}


- (BOOL)isTargetDevice:(ICDevice*)device
{
    if ((device.type& ICDeviceTypeMaskCamera) != ICDeviceTypeCamera) {
        return NO;
    }
    for (NSString* fn in self.friendlyNames) {
        if ([device.name compare:fn] == NSOrderedSame && [device.capabilities containsObject:ICCameraDeviceCanAcceptPTPCommands]) {
            return YES;
        }
    }
    return NO;
}


- (nullable ICCameraDevice*)fetchDevice:(nonnull NSString*)deviceId error:(NSError* _Nullable * _Nullable)error
{
    ICCameraDevice* camera = [self.targetDevices objectForKey:deviceId];
    if (!camera) {
        if (error) {
            *error = [NSError errorWithReason:@"Device not found"];
        }
        return nil;
    }
    return camera;
}


- (BOOL)execPTPRequest:(nonnull NSString*)deviceId
         operationCode:(uint16_t)operationCode
    numberOfParameters:(uint16_t)numberOfParameters
            parameter1:(uint32_t)parameter1
            parameter2:(uint32_t)parameter2
            parameter3:(uint32_t)parameter3
            parameter4:(uint32_t)parameter4
            parameter5:(uint32_t)parameter5
               outData:(nullable NSData*)outData
              timedOut:(NSTimeInterval)timedOutInSec
                 error:(NSError* _Nullable * _Nullable)error
           onCompleted:(nonnull mtpdevicectl_response_block_t)block
{
    ICCameraDevice* camera = [self fetchDevice:deviceId error:error];
    if (!camera) {
        return NO;
    }
    if (!outData) {
        outData = [NSData new];
    }
    
    PTPOperationRequest* request = [PTPOperationRequest new];
    request.operationCode        = operationCode;
    request.numberOfParameters   = numberOfParameters;
    request.parameter1           = parameter1;
    request.parameter2           = parameter2;
    request.parameter3           = parameter3;
    request.parameter4           = parameter4;
    request.parameter5           = parameter5;
#define REQUEST_CLEANUP { [camera.userData removeAllObjects]; [self.timeoutTimer invalidate]; }
    
    [camera.userData setObject:request forKey:kMtpDeviceCtl_lastRequestObject];
    
    request.onCompleteBlock = ^(NSData* _Nullable inData, PTPOperationResponse* _Nullable ptpResponse) {
        // (2-1) request sent or (*) onExecPTPRequestTimedOut
        
        if (![camera.userData objectForKey:kMtpDeviceCtl_requestSendPTPCommandFlag]) {
            // (1-1e2) A timeout occurred in requestOpenSession.
            // (OnExecPTPRequestTimedOut was called before requestCloseSession)
            REQUEST_CLEANUP;
            block(MTPDEVICECTRL_REQUEST_FAILED, nil, [NSError errorWithReason:@"Operation timedout(requestOpenSession)"]);
            return;
        }
        
        // (2-1) request sent or (2-1e) onExecPTPRequestTimedOut
        [camera.userData setObject:^(){
            // (3-1) session closed
            if (ptpResponse == nil) {
                // (2-1e via 3-1) A timeout occurred in requestOpenSession
                // (OnExecPTPRequestTimedOut was called before requestCloseSession)
                [self.timedoutRequests addObject:[camera.userData objectForKey:kMtpDeviceCtl_lastRequestObject]];
                REQUEST_CLEANUP;
                block(MTPDEVICECTRL_REQUEST_FAILED, nil, [NSError errorWithReason:@"Operation timedout(requestSendPTPCommand)"]);
                return;
            }
            NSError* err = ptpResponse.requestError;
            if (!err) {
                err = [camera.userData objectForKey:kMtpDeviceCtl_errorObject];
            }
            
            // (4) return response
            REQUEST_CLEANUP;
            if (err) {
                block(MTPDEVICECTRL_REQUEST_FAILED, nil, err);
            } else {
                block(ptpResponse.responseCode, inData, nil);
            }
        } forKey:kMtpDeviceCtl_onSessionCloseCallback];
        
        // (3) close session
        if (self.keepOpenSession) {
            [self device:camera didCloseSessionWithError:nil];
        } else {
            [camera requestCloseSession];
        }
    };
    
    [camera.userData setObject:^(){
        // (1-1) sessoon opened (or failed)
        NSError* err = [camera.userData objectForKey:kMtpDeviceCtl_errorObject];
        if (err) {
            // (1-1e1) An error occurred in requestOpenSession
            // (didOpenSessionWithError -> deviceDidBecomeReady -> here)
            REQUEST_CLEANUP;
            block(MTPDEVICECTRL_REQUEST_FAILED, nil, err);
            return;
        }
        // (2) send request
        [camera.userData setObject:@YES forKey:kMtpDeviceCtl_requestSendPTPCommandFlag];
        [camera requestSendPTPCommand:request.commandBuffer
                              outData:outData
                  sendCommandDelegate:self
               didSendCommandSelector:@selector(didSendPTPCommand:inData:response:error:contextInfo:)
                          contextInfo:(__bridge void*)request];
    } forKey:kMtpDeviceCtl_onSessionReadyCallback];
    
    // (1) open session
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timedOutInSec
                                                             target:self
                                                           selector:@selector(onExecPTPRequestTimedOut:)
                                                           userInfo:request
                                                            repeats:NO];
    });
    if (camera.hasOpenSession) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self deviceDidBecomeReady:camera];
        });
    } else {
        [camera requestOpenSession];
    }
    return YES;
}


- (void)didSendPTPCommand:(nonnull NSData*)command inData:(nullable NSData*)inData response:(nonnull NSData*)response error:(nullable NSError*)error contextInfo:(nonnull void*)contextInfo
{
    PTPOperationRequest* ptpRequest = (__bridge PTPOperationRequest*)contextInfo;
    if ([self.timedoutRequests containsObject:ptpRequest]) {
        [self.timedoutRequests removeObject:ptpRequest];
        return;
    }
    PTPOperationResponse* ptpResponse = [[PTPOperationResponse alloc] initWithData:response];
    ptpResponse.requestError = error;
    ptpRequest.onCompleteBlock(inData, ptpResponse);
}


- (void)onExecPTPRequestTimedOut:(NSTimer*)timer
{
    PTPOperationRequest* request = (PTPOperationRequest*)timer.userInfo;
    [timer invalidate];
    if (request && request.onCompleteBlock) {
        request.onCompleteBlock(nil, nil);
    }
}



#pragma mark - getDeviceInfo

- (BOOL)getDeviceInfo:(nonnull NSString*)deviceId
                error:(NSError* _Nullable * _Nullable)error
          onCompleted:(nonnull mtpdevicectl_response_block_t)block
{
    return [self execPTPRequest:deviceId
                  operationCode:PTPOperationCodeGetDeviceInfo
             numberOfParameters:0
                     parameter1:0
                     parameter2:0
                     parameter3:0
                     parameter4:0
                     parameter5:0
                        outData:nil
                       timedOut:kMtpDeviceCtl_timedOutForPTPRequest
                          error:error
                    onCompleted:block];
}



#pragma mark - getDevicePropDesc

- (BOOL)getDevicePropDesc:(nonnull NSString*)deviceId
                 propCode:(uint16_t)propCode
                    error:(NSError* _Nullable * _Nullable)error
              onCompleted:(nonnull mtpdevicectl_response_block_t)block
{
    return [self execPTPRequest:deviceId
                  operationCode:PTPOperationCodeGetDevicePropDesc
             numberOfParameters:1
                     parameter1:propCode
                     parameter2:0
                     parameter3:0
                     parameter4:0
                     parameter5:0
                        outData:nil
                       timedOut:kMtpDeviceCtl_timedOutForPTPRequest
                          error:error
                    onCompleted:block];
}



#pragma mark - getDevicePropValue

- (BOOL)getDevicePropValue:(NSString*)deviceId
                  propCode:(uint16_t)propCode
                     error:(NSError* _Nullable * _Nullable)error
               onCompleted:(mtpdevicectl_response_block_t)block
{
    return [self execPTPRequest:deviceId
                  operationCode:PTPOperationCodeGetDevicePropValue
             numberOfParameters:1
                     parameter1:propCode
                     parameter2:0
                     parameter3:0
                     parameter4:0
                     parameter5:0
                        outData:nil
                       timedOut:kMtpDeviceCtl_timedOutForPTPRequest
                          error:error
                    onCompleted:block];
}



#pragma mark - setDevicePropValue

- (BOOL)setDevicePropValue:(nonnull NSString*)deviceId
                  propCode:(uint16_t)propCode
                      data:(nonnull NSData*)data
                     error:(NSError* _Nullable * _Nullable)error
               onCompleted:(nonnull mtpdevicectl_response_block_t)block
{
    return [self execPTPRequest:deviceId
                  operationCode:PTPOperationCodeSetDevicePropValue
             numberOfParameters:1
                     parameter1:propCode
                     parameter2:0
                     parameter3:0
                     parameter4:0
                     parameter5:0
                        outData:data
                       timedOut:kMtpDeviceCtl_timedOutForPTPRequest
                          error:error
                    onCompleted:block];
}



#pragma mark - sendConfig

- (BOOL)sendConfig:(nonnull NSString*)deviceId
        configType:(uint16_t)configType
           version:(uint32_t)version
              data:(nonnull NSData*)data
             error:(NSError* _Nullable * _Nullable)error
       onCompleted:(nonnull mtpdevicectl_response_block_t)block
{
    return [self execPTPRequest:deviceId
                  operationCode:PTPOperationCodeSendConfigObject
             numberOfParameters:3
                     parameter1:configType
                     parameter2:(uint32_t)data.length
                     parameter3:version
                     parameter4:0
                     parameter5:0
                        outData:data
                       timedOut:kMtpDeviceCtl_timedOutForSendConfig
                          error:error
                    onCompleted:block];
}



#pragma mark - getConfig

- (BOOL)getConfig:(nonnull NSString*)deviceId
       configType:(uint16_t)configType
            error:(NSError* _Nullable * _Nullable)error
      onCompleted:(nonnull mtpdevicectl_response_block_t)block
{
    return [self execPTPRequest:deviceId
                  operationCode:PTPOperationCodeGetConfigObject
             numberOfParameters:1
                     parameter1:configType
                     parameter2:0
                     parameter3:0
                     parameter4:0
                     parameter5:0
                        outData:nil
                       timedOut:kMtpDeviceCtl_timedOutForPTPRequest
                          error:error
                    onCompleted:block];
}



#pragma mark - closeSession

- (void)closeSession:(nonnull NSString*)deviceId
         onCompleted:(nonnull dispatch_block_t)block
{
    NSError* error;
    ICCameraDevice* camera = [self fetchDevice:deviceId error:&error];
    if (!camera) {
        return;
    }
    
    [camera.userData setObject:^(){
        if (block) block();
    } forKey:kMtpDeviceCtl_onSessionCloseCallback];
    if (camera.hasOpenSession) {
        [camera requestCloseSession];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self device:camera didCloseSessionWithError:nil];
        });
    }
}



#pragma mark -

- (void)notifyDeviceEvent:(ICDevice*)device eventName:(NSString*)eventName params:(NSArray*)params
{
    NSMutableDictionary* msg = [NSMutableDictionary dictionaryWithObjectsAndKeys:device.UUIDString, @"deviceId", nil];
    if (eventName) {
        [msg setObject:eventName forKey:@"event"];
    }
    if (params) {
        [msg setObject:params forKey:@"params"];
    }
    NSString* str = [msg toJSON:nil];
    if (str) {
        fprintf(stderr, "%s\n", str.UTF8String);
    } else {
        NSLog(@"notifyDeviceEvent: %@", msg);
    }
}



#pragma mark ICDeviceBrowserDelegate delegates

- (void)deviceBrowser:(ICDeviceBrowser*)browser didAddDevice:(ICDevice*)device moreComing:(BOOL)moreComing
{
    if ([self isTargetDevice:device]) {
        [self notifyDeviceEvent:device eventName:@"DeviceAdded" params:nil];
        [self.targetDevices setValue:(ICCameraDevice*)device forKey:device.UUIDString];
        device.delegate = self;
    } else {
        NSLog(@"   didAddDevice: %@ S/N:%@ UUID:%@", device.name, device.serialNumberString, device.UUIDString);
    }
}


- (void)deviceBrowser:(ICDeviceBrowser*)browser didRemoveDevice:(ICDevice*)device moreGoing:(BOOL)moreGoing
{
    if ([self.targetDevices.allKeys containsObject:device.UUIDString]) {
        [self notifyDeviceEvent:device eventName:@"DeviceRemoved" params:nil];
        [self.targetDevices removeObjectForKey:device.UUIDString];
    } else {
        NSLog(@"didRemoveDevice: %@ S/N:%@ UUID:%@", device.name, device.serialNumberString, device.UUIDString);
    }
}



#pragma mark -
#pragma mark ICDevice & ICCameraDevice delegates

- (void)didRemoveDevice:(ICDevice*)removedDevice
{
    //NSLog(@"  removedDevice: %@ S/N:%@ UUID:%@", removedDevice.name, removedDevice.serialNumberString, removedDevice.UUIDString);
}


- (void)device:(ICDevice*)device didOpenSessionWithError:(NSError*)error
{
    if (error) {
        NSLog(@"didOpenSessionWithError_error: %@ S/N:%@ UUID:%@ - %@", device.name, device.serialNumberString, device.UUIDString, error.description);
        ICCameraDevice* camera = (ICCameraDevice*)device;
        [camera.userData setObject:error forKey:kMtpDeviceCtl_errorObject];
        [self deviceDidBecomeReady:camera];
    }
}


- (void)deviceDidBecomeReady:(ICCameraDevice*)camera;
{
    dispatch_block_t block = (dispatch_block_t)[(NSDictionary*)camera.userData objectForKey:kMtpDeviceCtl_onSessionReadyCallback];
    if (block) {
        block();
    } else {
        NSLog(@"deviceDidBecomeReady: camera.userData has no `%@`.\n%@", kMtpDeviceCtl_onSessionReadyCallback, camera.userData);
    }
}


- (void)device:(ICDevice*)device didCloseSessionWithError:(NSError*)error
{
    if (error) {
        NSLog(@"didCloseSessionWithError: %@ S/N:%@ UUID:%@ - %@", device.name, device.serialNumberString, device.UUIDString, error.description);
        ICCameraDevice* camera = (ICCameraDevice*)device;
        [camera.userData setObject:error forKey:kMtpDeviceCtl_errorObject];
    }
    dispatch_block_t block = (dispatch_block_t)[(NSDictionary*)device.userData objectForKey:kMtpDeviceCtl_onSessionCloseCallback];
    if (block) {
        block();
    } else {
        NSLog(@"didCloseSessionWithError: camera.userData has no `%@`.\n%@", kMtpDeviceCtl_onSessionCloseCallback, device.userData);
    }
}


- (void)device:(ICDevice*)device didEncounterError:(NSError*)error
{
    NSLog(@"didEncounterError: %@ S/N:%@ UUID:%@ - %@", device.name, device.serialNumberString, device.UUIDString, error.description);
}


- (void)cameraDevice:(ICCameraDevice*)camera didReceivePTPEvent:(NSData*)eventData
{
    PTPEvent* event = [[PTPEvent alloc] initWithData:eventData];
    NSArray* arr = @[@(event.parameter1), @(event.parameter2), @(event.parameter3)];
    [self notifyDeviceEvent:camera eventName:[NSString stringWithMtpEventCode:event.eventCode] params:arr];
}


- (void)cameraDevice:(nonnull ICCameraDevice *)camera didAddItem:(nonnull ICCameraItem *)item
{
}


- (void)cameraDevice:(nonnull ICCameraDevice *)scanner didCompleteDeleteFilesWithError:(nullable NSError *)error
{
}


- (void)cameraDevice:(nonnull ICCameraDevice *)camera didReceiveMetadataForItem:(nonnull ICCameraItem *)item
{
}


- (void)cameraDevice:(nonnull ICCameraDevice *)camera didReceiveThumbnailForItem:(nonnull ICCameraItem *)item
{
}


- (void)cameraDevice:(nonnull ICCameraDevice *)camera didRemoveItem:(nonnull ICCameraItem *)item
{
}


- (void)cameraDevice:(nonnull ICCameraDevice *)camera didRenameItems:(nonnull NSArray<ICCameraItem *> *)items
{
}


- (void)cameraDeviceDidChangeCapability:(nonnull ICCameraDevice *)camera
{
}


- (void)deviceDidBecomeReadyWithCompleteContentCatalog:(nonnull ICDevice *)device
{
}


@end
