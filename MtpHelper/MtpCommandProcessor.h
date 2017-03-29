//
//  MtpCommandProcessor.h
//  MtpHelper
//
//  Copyright (c) 2017 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information.
//

#import <Foundation/Foundation.h>
#import "MtpDeviceController.h"
#import "NSError+MtpExtension.h"


@interface MtpCommandProcessor : NSObject
typedef void (^mtpcomandproc_response_block_t)(NSDictionary* _Nullable data);

@property (nonatomic, nonnull) NSDictionary<NSString*, NSArray*>* supportedProps;
@property (nonatomic, nonnull) NSArray<NSString*>* deviceList;

+ (nullable MtpCommandProcessor*)processorWithDeviceController:(nonnull MtpDeviceController*)controller;
- (BOOL)execCommand:(nonnull NSArray*)args error:(NSError* _Nullable * _Nullable)error onCompleted:(nonnull mtpcomandproc_response_block_t)block;


#pragma mark -- for Categories

@property (nonatomic, nonnull) MtpDeviceController* controller;

@end
