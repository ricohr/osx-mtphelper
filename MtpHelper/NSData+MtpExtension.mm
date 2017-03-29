//
//  NSData+MtpExtension.mm
//  MtpHelper
//
//  Copyright (c) 2017 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information.
//

#import "NSData+MtpExtension.h"
#import "NSString+MtpExtension.h"
#import "ptp/PTPEnums.h"
#import "basictypes.h"
#import "bytestream.h"


@implementation NSData (MtpExtension)


static BOOL valueToStream(PTP::ByteStream& bs, uint16_t type, id value, NSError* _Nullable * _Nullable error)
{
    if (error && *error) {
        return NO;
    }
#define STREAM_FROM_X(TYPE, OBJC_OP) \
    PTPDataTypeCode##TYPE: { PTP::TYPE v(((NSNumber*)value).OBJC_OP); std::string s; v.to_ptp(s); bs.write(s.c_str(), s.size()); return YES; }
#define STREAM_FROM_X2(TYPE, OBJC_OP, CAST) \
    PTPDataTypeCode##TYPE: { PTP::TYPE v((CAST)((NSNumber*)value).OBJC_OP); std::string s; v.to_ptp(s); bs.write(s.c_str(), s.size()); return YES; }
    
    switch (type) {
        case STREAM_FROM_X(SInt8,  charValue);
        case STREAM_FROM_X(UInt8,  unsignedCharValue);
        case STREAM_FROM_X(SInt16, shortValue);
        case STREAM_FROM_X(UInt16, unsignedShortValue);
        case STREAM_FROM_X2(SInt32, longValue, int32_t);
        case STREAM_FROM_X2(UInt32, unsignedLongValue, uint32_t);
        case STREAM_FROM_X(SInt64, longLongValue);
        case STREAM_FROM_X(UInt64, unsignedLongLongValue);
        case PTPDataTypeCodeUnicodeString:
        {
            NSString* str = (NSString*)value;
            PTP::UnicodeString v(str.UTF8String);
            std::string s; v.to_ptp(s);
            bs.write(s.c_str(), s.size());
            return YES;
        }
    }
    if (error) {
        *error = [NSError errorWithReason:[NSString stringWithFormat:@"Unsupported data type(%04x)", type]];
    }
    return NO;
}

static id streamToValue(PTP::ByteStream& bs, uint16_t type, NSError* _Nullable * _Nullable error)
{
    if (error && *error) {
        return nil;
    }
#define STREAM_TO_X(TYPE) \
    PTPDataTypeCode##TYPE: { PTP::TYPE v; PTP::TYPE::parse(bs, v); return @(v.value()); }
#define STREAM_TO_ARR(TYPE) \
    PTPDataTypeCodeArrayOf##TYPE: { \
        NSMutableArray* arr = [NSMutableArray new]; \
        PTP::UInt32 len; PTP::UInt32::parse(bs, len); \
        for (uint32_t i = 0; i < len.value(); ++i) { \
            PTP::TYPE data; \
            PTP::TYPE::parse(bs, data); \
            [arr addObject:@(data.value())]; \
        } \
        return arr; \
    }
    switch (type) {
        case STREAM_TO_X(SInt8);
        case STREAM_TO_X(UInt8);
        case STREAM_TO_X(SInt16);
        case STREAM_TO_X(UInt16);
        case STREAM_TO_X(SInt32);
        case STREAM_TO_X(UInt32);
        case STREAM_TO_X(SInt64);
        case STREAM_TO_X(UInt64);
        case STREAM_TO_ARR(SInt8);
        case STREAM_TO_ARR(UInt8);
        case STREAM_TO_ARR(SInt16);
        case STREAM_TO_ARR(UInt16);
        case STREAM_TO_ARR(SInt32);
        case STREAM_TO_ARR(UInt32);
        case STREAM_TO_ARR(SInt64);
        case STREAM_TO_ARR(UInt64);
        case PTPDataTypeCodeUnicodeString:
        {
            PTP::UnicodeString str;
            PTP::UnicodeString::parse(bs, str); // Exception is NOT raised.
            return @(str.value().c_str());
        }
    }
    if (error) {
        *error = [NSError errorWithReason:[NSString stringWithFormat:@"Unsupported data type(%04x)", type]];
    }
    return nil;
}

static id streamToValueAndSetDict(PTP::ByteStream& bs, uint16_t type, NSMutableDictionary<NSString*,id>* dict, NSString* key, NSError* _Nullable * _Nullable error)
{
    id obj = streamToValue(bs, type, error);
    if (obj && key.UTF8String[0]!='.') {
        [dict setObject:obj forKey:key];
    }
    return obj;
}


- (nullable NSDictionary*) toPropDescDictionary:(NSError* _Nullable * _Nullable)error
{
    PTP::ByteStream bs;
    bs.write((const char*)self.bytes, self.length);
    NSMutableDictionary<NSString*,id>* res = [NSMutableDictionary new];
    
    streamToValueAndSetDict(bs, PTPDataTypeCodeUInt16, res, @".device_property_code", error);
    uint16_t type = [streamToValueAndSetDict(bs, PTPDataTypeCodeUInt16, res, @".data_type", error) unsignedShortValue];
    streamToValueAndSetDict(bs, PTPDataTypeCodeUInt8, res,  @"get_set", error);
    streamToValueAndSetDict(bs, type, res, @"factory_default_value", error);
    streamToValueAndSetDict(bs, type, res, @"current", error);
    uint8_t from_flag = [streamToValueAndSetDict(bs, PTPDataTypeCodeUInt8, res, @".from_flag", error) unsignedCharValue];
    if (from_flag==0x01) {
        // Range
        streamToValueAndSetDict(bs, type, res, @"min", error);
        streamToValueAndSetDict(bs, type, res, @"max", error);
        streamToValueAndSetDict(bs, type, res, @"step", error);
    } else if (from_flag==0x02) {
        // Enum
        NSMutableArray<NSNumber*>* arr = [NSMutableArray new];
        uint16_t count = [streamToValueAndSetDict(bs, PTPDataTypeCodeUInt16, res, @".number_of_values", error) unsignedShortValue];
        for (uint16_t i=0; i<count; i++) {
            id obj = streamToValue(bs, type, error);
            if (obj) {
                [arr addObject:obj];
            }
        }
        [res setObject:arr forKey:@"values"];
    }
    
    return res;
}


- (nullable NSDictionary*) toDeviceInfoDictionary:(NSError* _Nullable * _Nullable)error
{
    PTP::ByteStream bs;
    bs.write((const char*)self.bytes, self.length);
    NSMutableDictionary<NSString*,id>* res = [NSMutableDictionary new];

    streamToValueAndSetDict(bs, PTPDataTypeCodeUInt16,        res, @"StandardVersion", error);
    streamToValueAndSetDict(bs, PTPDataTypeCodeUInt32,        res, @"VenderExtensionId", error);
    streamToValueAndSetDict(bs, PTPDataTypeCodeUInt16,        res, @"VenderExtensionVersion", error);
    streamToValueAndSetDict(bs, PTPDataTypeCodeUnicodeString, res, @".vendor_extension_desc", error);
    streamToValueAndSetDict(bs, PTPDataTypeCodeUInt16,        res, @"FunctionalMode", error);
    streamToValueAndSetDict(bs, PTPDataTypeCodeArrayOfUInt16, res, @".operations_supported", error);
    streamToValueAndSetDict(bs, PTPDataTypeCodeArrayOfUInt16, res, @".events_supported", error);
    streamToValueAndSetDict(bs, PTPDataTypeCodeArrayOfUInt16, res, @".device_properties_supported", error);
    streamToValueAndSetDict(bs, PTPDataTypeCodeArrayOfUInt16, res, @".capture_formats", error);
    streamToValueAndSetDict(bs, PTPDataTypeCodeArrayOfUInt16, res, @".image_formats", error);
    streamToValueAndSetDict(bs, PTPDataTypeCodeUnicodeString, res, @"Manufacturer", error);
    streamToValueAndSetDict(bs, PTPDataTypeCodeUnicodeString, res, @"Model", error);
    streamToValueAndSetDict(bs, PTPDataTypeCodeUnicodeString, res, @"DeviceVersion", error);
    streamToValueAndSetDict(bs, PTPDataTypeCodeUnicodeString, res, @"SerialNumber", error);
    return res;
}


- (nullable id) toValue:(uint16_t)type error:(NSError* _Nullable * _Nullable)error
{
    PTP::ByteStream bs;
    bs.write((const char*)self.bytes, self.length);
    return streamToValue(bs, type, error);
}


+ (nullable NSData*)dataWithPTPObjectInfo:(nonnull PTPObjectInfo_t*)objectInfo
{
    NSError* error;
    PTP::ByteStream bs;
    
    valueToStream(bs, PTPDataTypeCodeUInt32, @(objectInfo->StorageID), &error);
    valueToStream(bs, PTPDataTypeCodeUInt16, @(objectInfo->ObjectFormat), &error);
    valueToStream(bs, PTPDataTypeCodeUInt16, @(objectInfo->ProtectionStatus), &error);
    valueToStream(bs, PTPDataTypeCodeUInt32, @(objectInfo->ObjectCompressedSize), &error);
    
    valueToStream(bs, PTPDataTypeCodeUInt16, @(objectInfo->ThumbFormat), &error);
    valueToStream(bs, PTPDataTypeCodeUInt32, @(objectInfo->ThumbCompressedSize), &error);
    valueToStream(bs, PTPDataTypeCodeUInt32, @(objectInfo->ThumbPixWidth), &error);
    valueToStream(bs, PTPDataTypeCodeUInt32, @(objectInfo->ThumbPixHeight), &error);

    valueToStream(bs, PTPDataTypeCodeUInt32, @(objectInfo->ImagePixWidth), &error);
    valueToStream(bs, PTPDataTypeCodeUInt32, @(objectInfo->ImagePixHeight), &error);
    valueToStream(bs, PTPDataTypeCodeUInt32, @(objectInfo->ImageBitDepth), &error);
    valueToStream(bs, PTPDataTypeCodeUInt32, @(objectInfo->ParentObject), &error);

    valueToStream(bs, PTPDataTypeCodeUInt16, @(objectInfo->AssociationType), &error);
    valueToStream(bs, PTPDataTypeCodeUInt32, @(objectInfo->AssociationDesc), &error);
    valueToStream(bs, PTPDataTypeCodeUInt32, @(objectInfo->SequenceNumber), &error);
    valueToStream(bs, PTPDataTypeCodeUnicodeString, @(objectInfo->Filename ? objectInfo->Filename : ""), &error);

    valueToStream(bs, PTPDataTypeCodeUnicodeString, @(objectInfo->CaptureDate ? objectInfo->CaptureDate : ""), &error);
    valueToStream(bs, PTPDataTypeCodeUnicodeString, @(objectInfo->ModificationDate ? objectInfo->ModificationDate : ""), &error);
    valueToStream(bs, PTPDataTypeCodeUnicodeString, @(objectInfo->Keywords ? objectInfo->Keywords : ""), &error);
    
    if (error) {
        return nil;
    }
    return [NSData dataWithBytes:bs.peek() length:bs.length()];
}


- (nullable NSArray*) toStorageIDs:(NSError* _Nullable * _Nullable)error
{
    PTP::ByteStream bs;
    bs.write((const char*)self.bytes, self.length);
    
    NSMutableArray* arr = [NSMutableArray new];
    NSUInteger num = [streamToValue(bs, PTPDataTypeCodeUInt32, error) unsignedIntegerValue];
    while (bs.length()>0 && num > 0) {
        id obj = streamToValue(bs, PTPDataTypeCodeUInt32, error);
        [arr addObject:obj];
        --num;
    }
    return arr;
}


@end
