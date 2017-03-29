//
//  MtpCommandProcessor.m
//  MtpHelper
//
//  Copyright (c) 2017 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information.
//

#import "MtpCommandProcessor.h"
#import "NSMutableDictionary+MtpExtension.h"
#import "NSData+MtpExtension.h"
#import "NSString+MtpExtension.h"
#import "ptp/PTPEnums.h"


@implementation MtpCommandProcessor


+ (nullable MtpCommandProcessor*)processorWithDeviceController:(nonnull MtpDeviceController*)controller
{
    MtpCommandProcessor* processor = [MtpCommandProcessor new];
    if (processor) {
        processor.controller = controller;
    }
    return processor;
}


- (uint16_t)nameToPropCode:(nonnull NSString*)propName type:(nullable uint16_t*)type error:(NSError* _Nullable * _Nullable)error
{
    NSArray* prop = [self.supportedProps objectForKey:propName];
    if (!prop) {
        if (error) {
            *error = [NSError errorWithReason:[NSString stringWithFormat:@"Invalid property key(%@)", propName]];
        }
        return 0;
    }
    if (type) {
        *type = [[prop objectAtIndex:1] unsignedShortValue];
    }
    return [[prop objectAtIndex:0] unsignedShortValue];
}


- (NSArray<NSString*>*)deviceList
{
    return self.controller.deviceList;
}



#pragma mark -
#pragma mark - MTP Requests

- (BOOL)deviceList:(NSError* _Nullable * _Nullable)error
       onCompleted:(mtpcomandproc_response_block_t)block
{
    NSArray* dids = self.controller.deviceList;
    if (dids.count == 0) {
        if (error) {
            *error = [NSError errorWithReason:@"No Devices"];
        }
        return NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        block(@{@"status":@"OK", @"devices":self.controller.deviceList});
    });
    return YES;
}


- (BOOL)getDeviceInfo:(nonnull NSString*)deviceId
                error:(NSError* _Nullable * _Nullable)error
          onCompleted:(nonnull mtpcomandproc_response_block_t)block
{
    return [self.controller getDeviceInfo:deviceId
                                    error:error
                              onCompleted:^(uint16_t responseCode, NSData* data, NSError* err) {
                                  NSMutableDictionary* res = [NSMutableDictionary dictionaryWithResponseCode:responseCode];
                                  if (!err && responseCode == PTPResponseCodeOK) {
                                      NSDictionary* ent = [data toDeviceInfoDictionary:&err];
                                      if (ent) [res addEntriesFromDictionary:ent];
                                  }
                                  if (err) [res setStatusWithNSError:err];
                                  block(res);
                              }];
}


- (BOOL)getDevicePropDesc:(nonnull NSString*)deviceId
                 propName:(nonnull NSString*)propName
                    error:(NSError* _Nullable * _Nullable)error
              onCompleted:(nonnull mtpcomandproc_response_block_t)block
{
    uint16_t code = [self nameToPropCode:propName type:nil error:error];
    if (code == 0) {
        return NO;
    }
    return [self.controller getDevicePropDesc:deviceId
                                     propCode:code
                                        error:error
                                  onCompleted:^(uint16_t responseCode, NSData* data, NSError* err) {
                                      NSMutableDictionary* res = [NSMutableDictionary dictionaryWithResponseCode:responseCode];
                                      if (!err && responseCode == PTPResponseCodeOK) {
                                          NSDictionary* ent = [data toPropDescDictionary:&err];
                                          if (ent) [res addEntriesFromDictionary:ent];
                                      }
                                      if (err) [res setStatusWithNSError:err];
                                      block(res);
                                  }];
}


- (BOOL)getDevicePropValue:(nonnull NSString*)deviceId
                  propName:(nonnull NSString*)propName
                     error:(NSError* _Nullable * _Nullable)error
               onCompleted:(nonnull mtpcomandproc_response_block_t)block
{
    uint16_t type = 0;
    uint16_t code = [self nameToPropCode:propName type:&type error:error];
    if (code == 0) {
        return NO;
    }
    return [self.controller getDevicePropValue:deviceId
                                      propCode:code
                                         error:error
                                   onCompleted:^(uint16_t responseCode, NSData* data, NSError* err) {
                                       NSMutableDictionary* res = [NSMutableDictionary dictionaryWithResponseCode:responseCode];
                                       if (!err && responseCode == PTPResponseCodeOK) {
                                           id ent = [data toValue:type error:&err];
                                           if (ent) [res setObject:ent forKey:@"current"];
                                       }
                                       if (err) [res setStatusWithNSError:err];
                                       block(res);
                                   }];
}


- (BOOL)setDevicePropValue:(nonnull NSString*)deviceId
                  propName:(nonnull NSString*)propName
                 propValue:(nonnull NSString*)propValue
                     error:(NSError* _Nullable * _Nullable)error
               onCompleted:(nonnull mtpcomandproc_response_block_t)block
{
    uint16_t type = 0;
    uint16_t code = [self nameToPropCode:propName type:&type error:error];
    if (code == 0) {
        return NO;
    }
    NSData* data = [propValue toMtpData:type error:error];
    if (!data) {
        return NO;
    }
    return [self.controller setDevicePropValue:deviceId
                                      propCode:code
                                          data:data
                                         error:error
                                   onCompleted:^(uint16_t responseCode, NSData* data, NSError* err) {
                                       NSMutableDictionary* res = [NSMutableDictionary dictionaryWithResponseCode:responseCode];
                                       if (err) {
                                           [res setStatusWithNSError:err];
                                       }
                                       block(res);
                                   }];
}


static BOOL checkFileName(NSString* fileName, uint32_t* version)
{
    *version = 0;
    NSRegularExpression* re = [NSRegularExpression regularExpressionWithPattern:@"\\A..\\d_v(\\d{3})\\.frm\\z"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];
    NSTextCheckingResult* match = [re firstMatchInString:fileName
                                                 options:0
                                                   range:NSMakeRange(0, fileName.length)];
    if (match) {
        NSString* ver = [fileName substringWithRange:[match rangeAtIndex:1]];
        *version = (uint32_t)ver.integerValue;
        return YES;
    }
    return NO;
}

- (BOOL)sendConfig:(nonnull NSString*)deviceId
        configType:(uint16_t)configType
          fileName:(nonnull NSString*)filePath
             error:(NSError* _Nullable * _Nullable)error
       onCompleted:(nonnull mtpcomandproc_response_block_t)block
{
    uint32_t version = 0;
    if (configType == ConfigObjectType_Firmware) {
        if (!checkFileName([filePath lastPathComponent], &version)) {
            if (error) {
                *error = [NSError errorWithReason:@"Invalid file name"];
            }
            return NO;
        }
    }
    NSData* data = [NSData dataWithContentsOfFile:filePath options:0 error:error];
    if (!data) {
        return NO;
    }
    if (data.length == 0) {
        if (error) {
            *error = [NSError errorWithReason:@"Invalid file content"];
        }
        return NO;
    }
    return [self.controller sendConfig:deviceId
                            configType:configType
                               version:version
                                  data:data
                                 error:error
                           onCompleted:^(uint16_t responseCode, NSData* data, NSError* err) {
                               NSMutableDictionary* res = [NSMutableDictionary dictionaryWithResponseCode:responseCode];
                               if (err) {
                                   [res setStatusWithNSError:err];
                               }
                               block(res);
                           }];
}


- (BOOL)getConfig:(nonnull NSString*)deviceId
       configType:(uint16_t)configType
         fileName:(nonnull NSString*)fileName
            error:(NSError* _Nullable * _Nullable)error
      onCompleted:(nonnull mtpcomandproc_response_block_t)block
{
    return [self.controller getConfig:deviceId
                           configType:configType
                                error:error
                          onCompleted:^(uint16_t responseCode, NSData* data, NSError* err) {
                              NSMutableDictionary* res = [NSMutableDictionary dictionaryWithResponseCode:responseCode];
                              if (err) {
                                  [res setStatusWithNSError:err];
                              }
                              if (![data writeToFile:fileName options:NSDataWritingAtomic error:&err]) {
                                  [res setStatusWithNSError:err];
                              }
                              block(res);
                          }];
}


/*
 error/blockの設定条件と実行スレッド:
 - "No commands"                    error!=nil でリターン
 - "Invalid parameter count"        error!=nil でリターン
 - "Invalid property key"           error!=nil でリターン

 -- これ以降は block が main-queue で呼ばれる

 - "requestOpenSession failed" : didOpenSessionWithErrorがエラーを受けた
    => camera.userData[kMtpDeviceCtl_errorObject] に error を入れて
       camera.userData[kMtpDeviceCtl_onSessionReadyCallback] をコールバック
       => mtpdevicectl_response_block_t(-1, nil, error) でコールバック

 - "requestSendPTPCommand failed" : didSendPTPCommandがエラーを受けた
    => ptpResponse.requestError に error を入れて
       request.onCompleteBlock をコールバック
       => camera.userData[kMtpDeviceCtl_onSessionCloseCallback] へパススルー
          => mtpdevicectl_response_block_t(-1, nul, ptpResponse.requestError) でコールバック
 
 - "requestCloseSession failed" : didCloseSessionWithErrorがエラーを受けた
    => camera.userData[kMtpDeviceCtl_errorObject] に error を入れて
       camera.userData[kMtpDeviceCtl_onSessionCloseCallback] をコールバック
       => mtpdevicectl_response_block_t(-1, nil, error) でコールバック

 - readOnly-property に set しようとした
    => requestSendPTPCommand の応答が無くなる
       => onExecPTPRequestTimedOut から request.onCompleteBlock(nil, nil) でコールバック
          => mtpdevicectl_response_block_t(-1, nil, error(Operation timedout)) でコールバック
 
 - responseCode != OK
 - parse failed
 - succeed
 */
- (BOOL)execCommand:(nonnull NSArray*)args
              error:(NSError* _Nullable * _Nullable)error
        onCompleted:(nonnull mtpcomandproc_response_block_t)block
{
    if (args.count == 0) {
        if (error) {
            *error = [NSError errorWithReason:@"No commands"];
        }
        return NO;
    }
    
    NSString* command = [args objectAtIndex:0];
    NSInteger required_args = -1;
    if ([command compare:@"deviceList"] == NSOrderedSame) {
        // deviceList
        required_args = 0;
        if (args.count == required_args + 1) {
            return [self deviceList:error onCompleted:block];
        }
    } else if ([command compare:@"deviceInfo"] == NSOrderedSame) {
        // deviceInfo
        required_args = 1;
        if (args.count == required_args + 1) {
            return [self getDeviceInfo:[args objectAtIndex:1]
                                 error:error
                           onCompleted:block];
        }
    } else if ([command compare:@"desc"] == NSOrderedSame) {
        // desc
        required_args = 2;
        if (args.count == required_args + 1) {
            return [self getDevicePropDesc:[args objectAtIndex:1]
                                  propName:[args objectAtIndex:2]
                                     error:error
                               onCompleted:block];
        }
    } else if ([command compare:@"get"] == NSOrderedSame) {
        // get
        required_args = 2;
        if (args.count == required_args + 1) {
            return [self getDevicePropValue:[args objectAtIndex:1]
                                   propName:[args objectAtIndex:2]
                                      error:error
                                onCompleted:block];
        }
    } else if ([command compare:@"set"] == NSOrderedSame) {
        // set
        required_args = 3;
        if (args.count == required_args + 1) {
            return [self setDevicePropValue:[args objectAtIndex:1]
                                   propName:[args objectAtIndex:2]
                                  propValue:[args objectAtIndex:3]
                                      error:error
                                onCompleted:block];
        }
    } else if ([command compare:@"sendConfig"] == NSOrderedSame) {
        // sendConfig
        required_args = 2;
        if (args.count == required_args + 1) {
            return [self sendConfig:[args objectAtIndex:1]
                         configType:ConfigObjectType_Config
                           fileName:[args objectAtIndex:2]
                              error:error
                        onCompleted:block];
        }
    } else if ([command compare:@"getConfig"] == NSOrderedSame) {
        // getConfig
        required_args = 2;
        if (args.count == required_args + 1) {
            return [self getConfig:[args objectAtIndex:1]
                        configType:ConfigObjectType_Config
                          fileName:[args objectAtIndex:2]
                             error:error
                       onCompleted:block];
        }
    } else if ([command compare:@"firmwareUpdate"] == NSOrderedSame) {
        // firmwareUpdate
        required_args = 2;
        if (args.count == required_args + 1) {
            return [self sendConfig:[args objectAtIndex:1]
                         configType:ConfigObjectType_Firmware
                           fileName:[args objectAtIndex:2]
                              error:error
                        onCompleted:block];
        }
    }
    
    if (error) {
        if (required_args >= 0) {
            *error = [NSError errorWithReason:[NSString stringWithFormat:@"Invalid parameter count(%lu for %ld)", args.count - 1, required_args]];
        } else {
            *error = [NSError errorWithReason:@"Invalid command"];
        }
    }
    return NO;
}


@end
