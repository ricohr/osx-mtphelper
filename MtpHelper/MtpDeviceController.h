//
//  MtpDeviceController.h
//  MtpHelper
//
//  Copyright (c) 2017 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information.
//

#import <Foundation/Foundation.h>
#import <ImageCaptureCore/ImageCaptureCore.h>
#import "NSError+MtpExtension.h"


extern const NSString* _Nonnull kMtpDeviceCtl_onSessionReadyCallback;
extern const NSString* _Nonnull kMtpDeviceCtl_onSessionCloseCallback;
extern const NSString* _Nonnull kMtpDeviceCtl_errorObject;
extern const NSString* _Nonnull kMtpDeviceCtl_requestSendPTPCommandFlag;


@interface MtpDeviceController : NSObject <ICDeviceBrowserDelegate, ICCameraDeviceDelegate>

#pragma mark -- for Applications

#define MTPDEVICECTRL_REQUEST_FAILED    ((uint16_t)-1)
typedef void (^mtpdevicectl_response_block_t)(uint16_t responseCode, NSData* _Nullable data, NSError* _Nullable error);

@property (nonatomic, readonly, nonnull) NSArray* deviceList;
@property (nonatomic) BOOL keepOpenSession;


- (void)start:(nonnull NSArray<NSString*>*)friendlyNames;

- (BOOL)getDeviceInfo:(nonnull NSString*)deviceId
                error:(NSError* _Nullable * _Nullable)error
          onCompleted:(nonnull mtpdevicectl_response_block_t)block;

- (BOOL)getDevicePropDesc:(nonnull NSString*)deviceId
                 propCode:(uint16_t)propCode
                    error:(NSError* _Nullable * _Nullable)error
              onCompleted:(nonnull mtpdevicectl_response_block_t)block;

- (BOOL)getDevicePropValue:(nonnull NSString*)deviceId
                  propCode:(uint16_t)propCode
                     error:(NSError* _Nullable * _Nullable)error
               onCompleted:(nonnull mtpdevicectl_response_block_t)block;

- (BOOL)setDevicePropValue:(nonnull NSString*)deviceId
                  propCode:(uint16_t)propCode
                      data:(nonnull NSData*)data
                     error:(NSError* _Nullable * _Nullable)error
               onCompleted:(nonnull mtpdevicectl_response_block_t)block;

- (BOOL)sendConfig:(nonnull NSString*)deviceId
        configType:(uint16_t)configType
           version:(uint32_t)version
              data:(nonnull NSData*)data
             error:(NSError* _Nullable * _Nullable)error
       onCompleted:(nonnull mtpdevicectl_response_block_t)block;

- (BOOL)getConfig:(nonnull NSString*)deviceId
       configType:(uint16_t)configType
            error:(NSError* _Nullable * _Nullable)error
      onCompleted:(nonnull mtpdevicectl_response_block_t)block;


- (void)closeSession:(nonnull NSString*)deviceId
         onCompleted:(nonnull dispatch_block_t)block;


#pragma mark -- for Categories

@property (nonatomic, nullable) NSTimer* timeoutTimer;

- (nullable ICCameraDevice*)fetchDevice:(nonnull NSString*)deviceId
                                  error:(NSError* _Nullable * _Nullable)error;
- (void)didSendPTPCommand:(nonnull NSData*)command
                   inData:(nullable NSData*)inData
                 response:(nonnull NSData*)response
                    error:(nullable NSError*)error
              contextInfo:(nonnull void*)contextInfo; // expect PTPOperationRequest#onCompleteBlock

@end
