//
//  NSMutableDictionary+MtpExtension.h
//  MtpHelper
//
//  Copyright (c) 2017 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information.
//

#import <Foundation/Foundation.h>
#import "NSError+MtpExtension.h"


@interface NSMutableDictionary (MtpExtension)

+ (nullable NSMutableDictionary*)dictionaryWithResponseCode:(uint16_t)code;
- (void)setStatus:(nonnull NSString*)string;
- (void)setStatusWithNSError:(nullable NSError*)error;

@end
