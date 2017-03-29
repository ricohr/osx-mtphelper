//
//  main.m
//  MtpHelper
//
//  Copyright (c) 2017 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "MtpDeviceController.h"
#import "MtpCommandProcessor.h"
#import "NSDictionary+MtpExtension.h"
#import "NSString+MtpExtension.h"


static const char DEFAULT_SUPPORTED_PROPS[] = "{" \
"   \"friendlyNames\": [\"RICOH R Development Kit\"]," \
"   \"properties\":{" \
"       \"WhiteBalance\":[\"0x5005\",\"UINT16\"]," \
"       \"ExposureBiasCompensation\":[\"0x5010\",\"INT16\"]," \
"}}";

static const char VERSION[] = "1.0.0.0 2017.03.29";


@interface MyApplicationDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, nonnull) MtpDeviceController* deviceController;
@property (nonatomic, nonnull) MtpCommandProcessor* commandProcessor;
@property (nonatomic, nonnull) NSOperationQueue* interfaceQueue;
@property (nonatomic, nonnull) NSArray<NSString*>* args;
@property (nonatomic, nonnull, readonly) NSArray<NSString*>* friendlyNames;
@property (nonatomic, nonnull, readonly) NSArray* supportedProperties;

@end


@implementation MyApplicationDelegate : NSObject

- (id)init
{
    if (self = [super init]) {
        _deviceController = [MtpDeviceController new];
        _commandProcessor = [MtpCommandProcessor processorWithDeviceController:_deviceController];
        _interfaceQueue = [NSOperationQueue new];
        self.interfaceQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}


- (NSArray*)supportedProperties
{
    return self.commandProcessor.supportedProps.allKeys;
}


- (void)loadConfig:(NSString*)jsonPath
{
    NSError* error;
    NSData* json = [NSData dataWithContentsOfFile:jsonPath];
    if (!json) {
        json = [NSData dataWithBytes:DEFAULT_SUPPORTED_PROPS length:strlen(DEFAULT_SUPPORTED_PROPS)];
    }
    NSDictionary* conf = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingAllowFragments error:&error];
    if (!json || !conf) {
        NSLog(@"read config failed - %@", error);
        [[NSApplication sharedApplication] terminate:self];
        return;
    }
    
    _friendlyNames = [conf objectForKey:@"friendlyNames"];
    if (!_friendlyNames) _friendlyNames = @[@"RICOH R Development Kit"];

    NSMutableDictionary<NSString*, NSArray*>* props = [NSMutableDictionary new];
    NSDictionary<NSString*, NSArray<NSString*>*>* props0 = [conf objectForKey:@"properties"];
    if (props0) {
        for (NSString* name in props0.allKeys) {
            NSArray<NSString*>* item = [props0 objectForKey:name];
            if ([item isKindOfClass:[NSArray class]] && item.count==2) {
                uint16_t code = (uint16_t)strtoul([item objectAtIndex:0].UTF8String, NULL, 0);
                uint16_t type = [[item objectAtIndex:1] toMtpTypeCode:nil];
                if (code == 0 || type == 0) {
                    NSLog(@"Invalid type name(%@)", [item objectAtIndex:1]);
                    [[NSApplication sharedApplication] terminate:self];
                    return;
                }
                [props setObject:@[@(code), @(type)] forKey:name];
            }
        }
    }
    self.commandProcessor.supportedProps = props;
}


- (void)applicationWillFinishLaunching:(NSNotification*)notification
{
    [self.deviceController start:self.friendlyNames];
    if (self.args.count > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (500 *NSEC_PER_MSEC)), self.interfaceQueue.underlyingQueue, ^{
            [self interfaceProc];
        });
    } else {
        [self.interfaceQueue addOperationWithBlock:^{
            [self interfaceProc];
        }];
    }
}


- (void)interfaceProc
{
    NSArray* args;
    
    if (self.args.count == 0) {
        // exec with stdin.
        char commandBuffer[1024];
        if (!fgets(commandBuffer, sizeof(commandBuffer), stdin)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSApplication sharedApplication] terminate:self];
            });
            return;
        }
        NSString* command = [NSString stringWithUTF8String:commandBuffer];
        command = [[command componentsSeparatedByString:@"\n"] objectAtIndex:0];
        args = [command componentsSeparatedByString:@" "];
        if ((args.count == 1) && ((NSString*)[args objectAtIndex:0]).length == 0) {
            args = @[];
        }
    } else {
        // exec with command options.
        args = self.args;
    }
    
    NSError* error;
    dispatch_block_t finally = ^() {
        if (self.args.count == 0) {
            [self.interfaceQueue addOperationWithBlock:^{
                [self interfaceProc];
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSApplication sharedApplication] terminate:self];
            });
        }
    };
    BOOL ret = [self.commandProcessor execCommand:args error:&error onCompleted:^(NSDictionary* result) {
        [self.interfaceQueue addOperationWithBlock:^{
            NSError* err;
            NSString* json = [result toJSON:&err];
            if (json) {
                puts(json.UTF8String);
            } else {
                puts([NSString stringWithFormat:@"{\"status\":\"serialize failed:(%@)\"}", error].UTF8String);
            }
        }];
        finally();
    }];
    if (!ret) {
        puts([error toJson].UTF8String);
        finally();
    }
}


@end



int main(int argc, const char * argv[])
{
    setvbuf(stdout, NULL, _IONBF, 0);
    setvbuf(stderr, NULL, _IONBF, 0);
    
    @autoreleasepool {
        MyApplicationDelegate * appDelegate = [MyApplicationDelegate new];
        BOOL showProps = NO;
        NSString* jsonPath = [[[[NSBundle mainBundle] executablePath] stringByDeletingPathExtension] stringByAppendingPathExtension:@"json"];
        NSMutableArray<NSString*>* args = [NSMutableArray new];
        for (int i = 1; i < argc; i++) {
            if (strcmp(argv[i], "-v") == 0) {
                showProps = YES;
            } else if (strncmp(argv[i], "-conf:", 6) == 0) {
                jsonPath = [NSString stringWithUTF8String:argv[i] + 6];
            } else {
                [args addObject:[NSString stringWithUTF8String:argv[i]]];
            }
        }
        
        [appDelegate loadConfig:jsonPath];
        if (showProps) {
            printf("MtpHelper version %s\n", VERSION);
            printf("    Supported device properties:");
            for (NSString* name in appDelegate.supportedProperties) {
                printf(" %s", name.UTF8String);
            }
            printf("\n");
            return 1;
        }
        appDelegate.args = args;
        NSApplication * application = [NSApplication sharedApplication];
        application.delegate = appDelegate;
        [application run];
    }
    return 0;
}
