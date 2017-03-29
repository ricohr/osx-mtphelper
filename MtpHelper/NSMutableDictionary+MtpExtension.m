//
//  NSMutableDictionary+MtpExtension.m
//  MtpHelper
//
//  Copyright (c) 2017 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information.
//

#import "NSMutableDictionary+MtpExtension.h"
#import "ptp/PTPEnums.h"


@implementation NSMutableDictionary (MtpExtension)

+ (nullable NSMutableDictionary*)dictionaryWithResponseCode:(uint16_t)code
{
    NSMutableDictionary* dict = [NSMutableDictionary new];
    if (dict) {
        if (code == PTPResponseCodeOK) {
            [dict setStatus:@"OK"];
        } else {
            [dict setStatus:[NSString stringWithFormat:@"FAILED(%04X)", code]];
        }
    }
    return dict;
}


- (void)setStatus:(nonnull NSString*)string
{
    [self setObject:string forKey:@"status"];
}


- (void)setStatusWithNSError:(nullable NSError*)error
{
    if (!error) {
        return;
    }
    [self setStatus:error.statusMessage];
}

@end
