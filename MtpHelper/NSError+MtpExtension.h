//
//  NSError+MtpExtension.h
//  MtpHelper
//
//  Copyright (c) 2017 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information.
//

#import <Foundation/Foundation.h>


@interface NSError (MtpExtension)

+ (nullable NSError*)errorWithReason:(nonnull NSString*)reason;
- (nullable NSString*)toJson;
- (nonnull NSString*)statusMessage;

@end
