//
//  NSDictionary+MtpExtension.m
//  MtpHelper
//
//  Copyright (c) 2017 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information.
//

#import "NSDictionary+MtpExtension.h"

@implementation NSDictionary (MtpExtension)

- (nullable NSString*)toJSON:(NSError* _Nullable * _Nullable)error
{
    NSData* json = [NSJSONSerialization dataWithJSONObject:self
                                                   options:0
                                                     error:error];
    if (json) {
        return [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    }
    return nil;
}

@end
