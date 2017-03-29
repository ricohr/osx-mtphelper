//
//  NSDictionary+MtpExtension.h
//  MtpHelper
//
//  Copyright (c) 2017 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (MtpExtension)

- (nullable NSString*)toJSON:(NSError* _Nullable * _Nullable)error;

@end
