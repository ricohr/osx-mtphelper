//
//  NSString+MtpExtension.mm
//  MtpHelper
//
//  Copyright (c) 2017 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information.
//

#import "NSString+MtpExtension.h"
#import "ptp/PTPEnums.h"
#import "libptpip/basictypes.h"
#import "libptpip/bytestream.h"


@implementation NSString (MtpExtension)

- (uint16_t)toMtpTypeCode:(NSError* _Nullable * _Nullable)error
{
    static NSDictionary* types;
    if (!types) {
#define NAME_TO_TYPECODE(KEY, TYPE) @#KEY: @(PTPDataTypeCode##TYPE)
        types = @{
                  NAME_TO_TYPECODE(INT8,   SInt8),
                  NAME_TO_TYPECODE(UINT8,  UInt8),
                  NAME_TO_TYPECODE(INT16,  SInt16),
                  NAME_TO_TYPECODE(UINT16, UInt16),
                  NAME_TO_TYPECODE(INT32,  SInt32),
                  NAME_TO_TYPECODE(UINT32, UInt32),
                  NAME_TO_TYPECODE(INT64,  SInt64),
                  NAME_TO_TYPECODE(UINT64, UInt64),
                  NAME_TO_TYPECODE(INT128,  SInt128),
                  NAME_TO_TYPECODE(UINT128, UInt128),
                  
                  NAME_TO_TYPECODE(AINT8,   ArrayOfSInt8),
                  NAME_TO_TYPECODE(AUINT8,  ArrayOfUInt8),
                  NAME_TO_TYPECODE(AINT16,  ArrayOfSInt16),
                  NAME_TO_TYPECODE(AUINT16, ArrayOfUInt16),
                  NAME_TO_TYPECODE(AINT32,  ArrayOfSInt32),
                  NAME_TO_TYPECODE(AUINT32, ArrayOfUInt32),
                  NAME_TO_TYPECODE(AINT64,  ArrayOfSInt64),
                  NAME_TO_TYPECODE(AUINT64, ArrayOfUInt64),
                  NAME_TO_TYPECODE(AINT128,  ArrayOfSInt128),
                  NAME_TO_TYPECODE(AUINT128, ArrayOfUInt128),
                  
                  NAME_TO_TYPECODE(STR, UnicodeString),
                  };
#undef NAME_TO_TYPECODE
    }
    
    NSNumber* num = [types objectForKey:self];
    if (num != nil) {
        return [num unsignedShortValue];
    }
    if (error) {
        *error = [NSError errorWithReason:[NSString stringWithFormat:@"Invalid type name(%@)", self]];
    }
    return 0;
}


- (nullable NSData*)toMtpData:(uint16_t)type error:(NSError* _Nullable * _Nullable)error
{
#define STR_TO_DATA(TYPE, CTYPE, CONV) PTPDataTypeCode##TYPE:\
{\
    PTP::TYPE v((CTYPE)CONV(self.UTF8String, nullptr, 0));\
    std::string s;\
    v.to_ptp(s); \
    return [NSData dataWithBytes:s.c_str() length:s.length()]; \
}
    switch (type) {
        case STR_TO_DATA(SInt8,  int8_t,   strtol);
        case STR_TO_DATA(UInt8,  uint8_t,  strtoul);
        case STR_TO_DATA(SInt16, int16_t,  strtol);
        case STR_TO_DATA(UInt16, uint16_t, strtoul);
        case STR_TO_DATA(SInt32, int32_t,  strtol);
        case STR_TO_DATA(UInt32, uint32_t, strtoul);
        case STR_TO_DATA(SInt64, int64_t,  strtoll);
        case STR_TO_DATA(UInt64, uint64,   strtoull);
        case PTPDataTypeCodeUnicodeString:
        {
            PTP::UnicodeString v(self.UTF8String);
            std::string s;
            v.to_ptp(s);
            return [NSData dataWithBytes:s.c_str() length:s.length()];
        }
    }
#undef STR_TO_DATA
    if (error) {
        *error = [NSError errorWithReason:[NSString stringWithFormat:@"Unsupported data type(%04x)", type]];
    }
    return nil;
}


+ (nullable NSString*)stringWithMtpEventCode:(uint16_t)code
{
    static NSDictionary* codes;
    if (!codes) {
        codes  = @{
                   @(PTPEventCodeObjectAdded):        @"ObjectAdded",
                   @(PTPEventCodeObjectRemoved):      @"ObjectRemoved",
                   @(PTPEventCodeDevicePropChanged):  @"DevicePropChaned",
                   @(PTPEventCodeDeviceInfoChanged):  @"DeviceInfoChanged",
                   @(PTPEventCodeStoreFull):          @"StoreFull",
                   @(PTPEventCodeStorageInfoChanged): @"StorageInfoChanged",
                   @(PTPEventCodeCaptureComplete):    @"CaptureComplete",
                   };
    }
    NSString* name = [codes objectForKey:@(code)];
    if (name) {
        return name;
    }
    return [NSString stringWithFormat:@"MtpEvent(%04x)", code];
}

@end
