//
//  NSString+MtpExtension.h
//  MtpHelper
//
//  Copyright (c) 2017 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information.
//

#import <Foundation/Foundation.h>
#import "NSError+MtpExtension.h"


@interface NSString (MtpExtension)

- (uint16_t)toMtpTypeCode:(NSError* _Nullable * _Nullable)error;
- (nullable NSData*)toMtpData:(uint16_t)type error:(NSError* _Nullable * _Nullable)error;
+ (nullable NSString*)stringWithMtpEventCode:(uint16_t)code;

@end
