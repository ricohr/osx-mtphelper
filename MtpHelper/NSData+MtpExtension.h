//
//  NSData+MtpExtension.h
//  MtpHelper
//
//  Copyright (c) 2017 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information.
//

#import <Foundation/Foundation.h>
#import "NSError+MtpExtension.h"


typedef struct {
    uint32_t StorageID;
    uint16_t ObjectFormat;
    uint16_t ProtectionStatus;
    uint32_t ObjectCompressedSize;
    uint16_t ThumbFormat;
    uint32_t ThumbCompressedSize;
    uint32_t ThumbPixWidth;
    uint32_t ThumbPixHeight;
    uint32_t ImagePixWidth;
    uint32_t ImagePixHeight;
    uint32_t ImageBitDepth;
    uint32_t ParentObject;
    uint16_t AssociationType;
    uint32_t AssociationDesc;
    uint32_t SequenceNumber;
    const char* _Nonnull Filename;
    const char* _Nonnull CaptureDate;
    const char* _Nonnull ModificationDate;
    const char* _Nonnull Keywords;
} PTPObjectInfo_t;


@interface NSData (MtpExtension)

- (nullable NSDictionary*) toDeviceInfoDictionary:(NSError* _Nullable * _Nullable)error;
- (nullable NSDictionary*) toPropDescDictionary:(NSError* _Nullable * _Nullable)error;
- (nullable id) toValue:(uint16_t)type error:(NSError* _Nullable * _Nullable)error;

+ (nullable NSData*) dataWithPTPObjectInfo:(nonnull PTPObjectInfo_t*)objectInfo;
- (nullable NSArray*) toStorageIDs:(NSError* _Nullable * _Nullable)error;

@end
