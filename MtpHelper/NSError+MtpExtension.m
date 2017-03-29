//
//  NSError+MtpExtension.m
//  MtpHelper
//
//  Copyright (c) 2017 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information.
//

#import "NSError+MtpExtension.h"


@implementation NSError (MtpExtension)

+ (nullable NSError*)errorWithReason:(nonnull NSString*)reason
{
    return [[NSError alloc] initWithDomain:@"jp.co.jrits.mtphelper"
                                      code:0
                                  userInfo:@{@"reason":reason}];
}


- (nullable NSString*)toJson
{
    NSData* json = [NSJSONSerialization dataWithJSONObject:@{@"status":self.statusMessage}
                                                   options:0
                                                     error:nil];
    return [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
}


- (nonnull NSString*)statusMessage
{
    if ([self.userInfo isKindOfClass:[NSDictionary class]]) {
        NSString* reason = [self.userInfo objectForKey:@"reason"];
        if (!reason) {
            NSError* err = (NSError*)[self.userInfo objectForKey:NSUnderlyingErrorKey];
            if (err && [err.domain compare:NSPOSIXErrorDomain] == NSOrderedSame) {
                reason = [NSString stringWithUTF8String:strerror((int)err.code)];
            }
        }
        if (reason) {
            return reason;
        }
    }
    return [NSString stringWithFormat:@"FAILED(%@)", self.description];
}

@end
