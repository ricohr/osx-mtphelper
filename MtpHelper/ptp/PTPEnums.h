//------------------------------------------------------------------------------------------------------------------------------
//
// File:       PTPEnums.h
//
// Abstract:   Cocoa PTP pass-through test application.
//
// Version:    1.0
//
// Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc. ("Apple")
//             in consideration of your agreement to the following terms, and your use,
//             installation, modification or redistribution of this Apple software
//             constitutes acceptance of these terms.  If you do not agree with these
//             terms, please do not use, install, modify or redistribute this Apple
//             software.
//
//             In consideration of your agreement to abide by the following terms, and
//             subject to these terms, Apple grants you a personal, non - exclusive
//             license, under Apple's copyrights in this original Apple software ( the
//             "Apple Software" ), to use, reproduce, modify and redistribute the Apple
//             Software, with or without modifications, in source and / or binary forms;
//             provided that if you redistribute the Apple Software in its entirety and
//             without modifications, you must retain this notice and the following text
//             and disclaimers in all such redistributions of the Apple Software. Neither
//             the name, trademarks, service marks or logos of Apple Inc. may be used to
//             endorse or promote products derived from the Apple Software without specific
//             prior written permission from Apple.  Except as expressly stated in this
//             notice, no other rights or licenses, express or implied, are granted by
//             Apple herein, including but not limited to any patent rights that may be
//             infringed by your derivative works or by other works in which the Apple
//             Software may be incorporated.
//
//             The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
//             WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
//             WARRANTIES OF NON - INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
//             PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION
//             ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//
//             IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
//             CONSEQUENTIAL DAMAGES ( INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//             SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//             INTERRUPTION ) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION
//             AND / OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER
//             UNDER THEORY OF CONTRACT, TORT ( INCLUDING NEGLIGENCE ), STRICT LIABILITY OR
//             OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// Copyright ( C ) 2009 Apple Inc. All Rights Reserved.
//
//------------------------------------------------------------------------------------------------------------------------------

#pragma once

//------------------------------------------------------------------------------------------------------------------------------

typedef enum
{
    PTPOperationCodeUndefined                   = 0x1000,
    PTPOperationCodeGetDeviceInfo               = 0x1001,
    PTPOperationCodeOpenSession                 = 0x1002,
    PTPOperationCodeCloseSession                = 0x1003,
    PTPOperationCodeGetStorageIDs               = 0x1004,
    PTPOperationCodeGetStorageInfo              = 0x1005,
    PTPOperationCodeGetNumObjects               = 0x1006,
    PTPOperationCodeGetObjectHandles            = 0x1007,
    PTPOperationCodeGetObjectInfo               = 0x1008,
    PTPOperationCodeGetObject                   = 0x1009,
    PTPOperationCodeGetThumb                    = 0x100A,
    PTPOperationCodeDeleteObject                = 0x100B,
    PTPOperationCodeSendObjectInfo              = 0x100C,
    PTPOperationCodeSendObject                  = 0x100D,
    PTPOperationCodeInitiateCapture             = 0x100E,
    PTPOperationCodeFormatStore                 = 0x100F,
    PTPOperationCodeResetDevice                 = 0x1010,
    PTPOperationCodeSelfTest                    = 0x1011,
    PTPOperationCodeSetObjectProtection         = 0x1012,
    PTPOperationCodePowerDown                   = 0x1013,
    PTPOperationCodeGetDevicePropDesc           = 0x1014,
    PTPOperationCodeGetDevicePropValue          = 0x1015,
    PTPOperationCodeSetDevicePropValue          = 0x1016,
    PTPOperationCodeResetDevicePropValue        = 0x1017,
    PTPOperationCodeTerminateOpenCapture        = 0x1018,
    PTPOperationCodeMoveObject                  = 0x1019,
    PTPOperationCodeCopyObject                  = 0x101A,
    PTPOperationCodeGetPartialObject            = 0x101B,
    PTPOperationCodeInitiateOpenCapture         = 0x101C,
    
    PTPOperationCodeSetPentaxVendorMode         = 0x9001,
    PTPOperationCodeGetAllObjectInfo            = 0x9002,
    PTPOperationCodeGetUserAssignedDeviceName   = 0x9003,
    
    PTPOperationCodeSendConfigObject            = 0x99A3,
    PTPOperationCodeGetConfigObject             = 0x99A4,
} PTPOperationCode;

#define RESERVED_OPERATION_CODE(c)            (!(c & 0x9000) && (c > PTPOperationCodeInitiateOpenCapture))
#define VENDOR_SPECIFIC_OPERATION_CODE(c)     (c & 0x9000)

//------------------------------------------------------------------------------------------------------------------------------

typedef enum
{
    PTPResponseCodeUndefined                                = 0x2000,
    PTPResponseCodeOK                                       = 0x2001,
    PTPResponseCodeGeneralError                             = 0x2002,
    PTPResponseCodeSessionNotOpen                           = 0x2003,
    PTPResponseCodeInvalidTransactionID                     = 0x2004,
    PTPResponseCodeOperationNotSupported                    = 0x2005,
    PTPResponseCodeParameterNotSupported                    = 0x2006,
    PTPResponseCodeIncompleteTransfer                       = 0x2007,
    PTPResponseCodeInvalidStorageID                         = 0x2008,
    PTPResponseCodeInvalidObjectHandle                      = 0x2009,
    PTPResponseCodeDevicePropNotSupported                   = 0x200A,
    PTPResponseCodeInvalidObjectFormatCode                  = 0x200B,
    PTPResponseCodeStoreFull                                = 0x200C,
    PTPResponseCodeObjectWriteProtected                     = 0x200D,
    PTPResponseCodeStoreReadOnly                            = 0x200E,
    PTPResponseCodeAccessDenied                             = 0x200F,
    PTPResponseCodeNoThumbnailPresent                       = 0x2010,
    PTPResponseCodeSelfTestFailed                           = 0x2011,
    PTPResponseCodePartialDeletion                          = 0x2012,
    PTPResponseCodeStoreNotAvailable                        = 0x2013,
    PTPResponseCodeSpecificationByFormatUnsupported         = 0x2014,
    PTPResponseCodeNoValidObjectInfo                        = 0x2015,
    PTPResponseCodeInvalidCodeFormat                        = 0x2016,
    PTPResponseCodeUnknownVendorCode                        = 0x2017,
    PTPResponseCodeCaptureAlreadyTerminated                 = 0x2018,
    PTPResponseCodeDeviceBusy                               = 0x2019,
    PTPResponseCodeInvalidParentObject                      = 0x201A,
    PTPResponseCodeInvalidDevicePropFormat                  = 0x201B,
    PTPResponseCodeInvalidDevicePropValue                   = 0x201C,
    PTPResponseCodeInvalidParameter                         = 0x201D,
    PTPResponseCodeSessionAlreadyOpen                       = 0x201E,
    PTPResponseCodeTransactionCancelled                     = 0x201F,
    PTPResponseCodeSpecificationOfDestinationUnsupported    = 0x2020
} PTPResponseCode;

#define RESERVED_RESPONSE_CODE(c)           (!(c & 0xA000) && (c > PTPResponseCodeSpecificationOfDestinationUnsupported))
#define VENDOR_SPECIFIC_RESPONSE_CODE(c)    (c & 0xA000)

//------------------------------------------------------------------------------------------------------------------------------

typedef enum
{
    PTPEventCodeUndefined                     = 0x4000,
    PTPEventCodeCancelTransaction             = 0x4001,
    PTPEventCodeObjectAdded                   = 0x4002,
    PTPEventCodeObjectRemoved                 = 0x4003,
    PTPEventCodeStoreAdded                    = 0x4004,
    PTPEventCodeStoreRemoved                  = 0x4005,
    PTPEventCodeDevicePropChanged             = 0x4006,
    PTPEventCodeObjectInfoChanged             = 0x4007,
    PTPEventCodeDeviceInfoChanged             = 0x4008,
    PTPEventCodeRequestObjectTransfer         = 0x4009,
    PTPEventCodeStoreFull                     = 0x400A,
    PTPEventCodeDeviceReset                   = 0x400B,
    PTPEventCodeStorageInfoChanged            = 0x400C,
    PTPEventCodeCaptureComplete               = 0x400D,
    PTPEventCodeUnreportedStatus              = 0x400E,
    
    PTPEventCodeAppleDeviceUnlocked           = 0xC001,
    PTPEventCodeAppleUserAssignedNameChanged  = 0xC002
} PTPEventCode;

#define RESERVED_EVENT_CODE(c)          (!(c & 0xC000) && (c > PTPEventCodeUnreportedStatus))
#define VENDOR_SPECIFIC_EVENT_CODE(c)   (c & 0xC000)

//------------------------------------------------------------------------------------------------------------------------------

typedef enum
{
    PTPDevicePropCodeUndefined                  = 0x5000,
    PTPDevicePropCodeBatteryLevel               = 0x5001,
    PTPDevicePropCodeFunctionalMode             = 0x5002,
    PTPDevicePropCodeImageSize                  = 0x5003,
    PTPDevicePropCodeCompressionSetting         = 0x5004,
    PTPDevicePropCodeWhiteBalance               = 0x5005,
    PTPDevicePropCodeRGBGain                    = 0x5006,
    PTPDevicePropCodeFNumber                    = 0x5007,
    PTPDevicePropCodeFocalLength                = 0x5008,
    PTPDevicePropCodeFocusDistance              = 0x5009,
    PTPDevicePropCodeFocusMode                  = 0x500A,
    PTPDevicePropCodeExposureMeteringMode       = 0x500B,
    PTPDevicePropCodeFlashMode                  = 0x500C,
    PTPDevicePropCodeExposureTime               = 0x500D,
    PTPDevicePropCodeExposureProgramMode        = 0x500E,
    PTPDevicePropCodeExposureIndex              = 0x500F,
    PTPDevicePropCodeExposureBiasCompensation   = 0x5010,
    PTPDevicePropCodeDateTime                   = 0x5011,
    PTPDevicePropCodeCaptureDelay               = 0x5012,
    PTPDevicePropCodeStillCaptureMode           = 0x5013,
    PTPDevicePropCodeContrast                   = 0x5014,
    PTPDevicePropCodeSharpness                  = 0x5015,
    PTPDevicePropCodeDigitalZoom                = 0x5016,
    PTPDevicePropCodeEffectMode                 = 0x5017,
    PTPDevicePropCodeBurstNumber                = 0x5018,
    PTPDevicePropCodeBurstInterval              = 0x5019,
    PTPDevicePropCodeTimelapseNumber            = 0x501A,
    PTPDevicePropCodeTimelapseInterval          = 0x501B,
    PTPDevicePropCodeFocusMeteringMode          = 0x501C,
    PTPDevicePropCodeUploadURL                  = 0x501D,
    PTPDevicePropCodeArtist                     = 0x501E,
    PTPDevicePropCodeCopyrightInfo              = 0x501F
} PTPDevicePropCode;

//------------------------------------------------------------------------------------------------------------------------------

typedef enum
{
    PTPFocusModeUndefined         = 0x0000,
    PTPFocusModeManual            = 0x0001,
    PTPFocusModeAutomatic         = 0x0002,
    PTPFocusModeAutomaticMacro    = 0x0003
} PTPFocusMode;

// All values with Bit 15 set to 0 - Reserved
// All values with Bit 15 set to 1 - Vendor-defined

//------------------------------------------------------------------------------------------------------------------------------

typedef enum
{
    PTPExposureMeteringModeUndefined              = 0x0000,
    PTPExposureMeteringModeAverage                = 0x0001,
    PTPExposureMeteringModeCenterWeightedAverage  = 0x0002,
    PTPExposureMeteringModeMultispot              = 0x0003,
    PTPExposureMeteringModeCenterspot             = 0x0004
} PTPExposureMeteringMode;

// All values with Bit 15 set to 0 - Reserved
// All values with Bit 15 set to 1 - Vendor-defined

//------------------------------------------------------------------------------------------------------------------------------

typedef enum
{
    PTPFlashModeUndefined     = 0x0000,
    PTPFlashModeAutoFlash     = 0x0001,
    PTPFlashModeFlashOff      = 0x0002,
    PTPFlashModeFillFlash     = 0x0003,
    PTPFlashModeRedEyeAuto    = 0x0004,
    PTPFlashModeRedEyeFill    = 0x0005,
    PTPFlashModeExternalSync  = 0x0006
} PTPFlashMode;

// All values with Bit 15 set to 0 - Reserved
// All values with Bit 15 set to 1 - Vendor-defined

//------------------------------------------------------------------------------------------------------------------------------

typedef enum
{
    PTPExposureProgramModeUndefined         = 0x0000,
    PTPExposureProgramModeManual            = 0x0001,
    PTPExposureProgramModeAutomatic         = 0x0002,
    PTPExposureProgramModeAperturePriority  = 0x0003,
    PTPExposureProgramModeShutterPriority   = 0x0004,
    PTPExposureProgramModeCreative          = 0x0005,
    PTPExposureProgramModeAction            = 0x0006,
    PTPExposureProgramModePortrait          = 0x0007
} PTPExposureProgramMode;

// All values with Bit 15 set to 0 - Reserved
// All values with Bit 15 set to 1 - Vendor-defined

//------------------------------------------------------------------------------------------------------------------------------

typedef enum
{
    PTPStillCaptureModeUndefined  = 0x0000,
    PTPStillCaptureModeNormal     = 0x0001,
    PTPStillCaptureModeBurst      = 0x0002,
    PTPStillCaptureModeTimelapse  = 0x0003
} PTPStillCaptureMode;

// All values with Bit 15 set to 0 - Reserved
// All values with Bit 15 set to 1 - Vendor-defined

//------------------------------------------------------------------------------------------------------------------------------

enum PTPEffectMode
{
    PTPEffectModeUndefined      = 0x0000,
    PTPEffectModeStandardColor  = 0x0001,
    PTPEffectModeBlackAndWhite  = 0x0002,
    PTPEffectModeSepia          = 0x0003
};
//typedef unsigned short PTPEffectMode;

// All values with Bit 15 set to 0 - Reserved
// All values with Bit 15 set to 1 - Vendor-defined

//------------------------------------------------------------------------------------------------------------------------------

typedef enum
{
    PTPFocusMeteringModeUndefined   = 0x0000,
    PTPFocusMeteringModeCenterSpot  = 0x0001,
    PTPFocusMeteringModeMultiSpot   = 0x0002
} PTPFocusMeteringMode;

// All values with Bit 15 set to 0 - Reserved
// All values with Bit 15 set to 1 - Vendor-defined

//------------------------------------------------------------------------------------------------------------------------------

/*typedef enum CaptureFormat
{
}
CaptureFormat;

//------------------------------------------------------------------------------------------------------------------------------

typedef enum ImageFormat
{
}
ImageFormat;
*/

//------------------------------------------------------------------------------------------------------------------------------

typedef enum
{
    PTPFunctionalModeStandard     = 0x0000,
    PTPFunctionalModeSleepState   = 0x0001
} PTPFunctionalMode;

//------------------------------------------------------------------------------------------------------------------------------

typedef enum
{
    PTPStorageTypeUndefined       = 0x0000,
    PTPStorageTypeFixedROM        = 0x0001,
    PTPStorageTypeRemovableROM    = 0x0002,
    PTPStorageTypeFixedRAM        = 0x0003,
    PTPStorageTypeRemovableRAM    = 0x0004
} PTPStorageType;

//------------------------------------------------------------------------------------------------------------------------------

typedef enum
{
    PTPFilesystemTypeUndefined            = 0x0000,
    PTPFilesystemTypeGenericFlat          = 0x0001,
    PTPFilesystemTypeGenericHierarchical  = 0x0002,
    PTPFilesystemTypeDCF                  = 0x0003
} PTPFilesystemType;

//------------------------------------------------------------------------------------------------------------------------------

typedef enum
{
    PTPAccessCapabilityReadWrite                      = 0x0000,
    PTPAccessCapabilityReadOnlyWithoutObjectDeletion  = 0x0001,
    PTPAccessCapabilityReadOnlyWithObjectDeletion     = 0x0002
} PTPAccessCapability;

//------------------------------------------------------------------------------------------------------------------------------

typedef enum
{
    PTPProtectionStatusNoProtection   = 0x0000,
    PTPProtectionStatusReadOnly       = 0x0001
} PTPProtectionStatus;

//------------------------------------------------------------------------------------------------------------------------------

typedef enum
{
    PTPObjectFormatCodeUndefinedNonImageObject    = 0x3000,
    PTPObjectFormatCodeAssociation                = 0x3001,         // e.g., folder
    PTPObjectFormatCodeScript                     = 0x3002,         // device-model-specific script
    PTPObjectFormatCodeExecutable                 = 0x3003,         // device-model-specific binary executable
    PTPObjectFormatCodeText                       = 0x3004,
    PTPObjectFormatCodeHTML                       = 0x3005,
    PTPObjectFormatCodeDPOF                       = 0x3006,
    PTPObjectFormatCodeAIFF                       = 0x3007,
    PTPObjectFormatCodeWAV                        = 0x3008,
    PTPObjectFormatCodeMP3                        = 0x3009,
    PTPObjectFormatCodeAVI                        = 0x300A,
    PTPObjectFormatCodeMPEG                       = 0x300B,
    PTPObjectFormatCodeASF                        = 0x300C,
    PTPObjectFormatCodeUnknownImageObject         = 0x3800,
    PTPObjectFormatCodeEXIF_JPEG                  = 0x3801,
    PTPObjectFormatCodeTIFF_EP                    = 0x3802,
    PTPObjectFormatCodeFlashPix                   = 0x3803,
    PTPObjectFormatCodeBMP                        = 0x3804,
    PTPObjectFormatCodeCIFF                       = 0x3805,
    PTPObjectFormatCodeReserved1                  = 0x3806,
    PTPObjectFormatCodeGIF                        = 0x3807,
    PTPObjectFormatCodeJFIF                       = 0x3808,
    PTPObjectFormatCodePCD                        = 0x3809,
    PTPObjectFormatCodePICT                       = 0x380A,
    PTPObjectFormatCodePNG                        = 0x380B,
    PTPObjectFormatCodeReserved2                  = 0x380C,
    PTPObjectFormatCodeTIFF                       = 0x380D,
    PTPObjectFormatCodeTIFF_IT                    = 0x380E,
    PTPObjectFormatCodeJP2                        = 0x380F,         // JPEG 2000 Baseline File Format
    PTPObjectFormatCodeJPX                        = 0x3810          // JPEG 2000 Extended File Format
} PTPObjectFormatCode;

//------------------------------------------------------------------------------------------------------------------------------

typedef enum
{
    PTPAssociationTypeUndefined             = 0x0000,
    PTPAssociationTypeGenericFolder         = 0x0001,
    PTPAssociationTypeAlbum                 = 0x0002,               // Reserved
    PTPAssociationTypeTimeSequence          = 0x0003,
    PTPAssociationTypeHorizontalPanoramic   = 0x0004,
    PTPAssociationTypeVerticalPanoramic     = 0x0005,
    PTPAssociationType2DPanoramic           = 0x0006,
    PTPAssociationTypeAncillaryData         = 0x0007
} PTPAssociationType;

// All values with Bit 15 set to 0 - Reserved
// All values with Bit 15 set to 1 - Vendor-defined

//------------------------------------------------------------------------------------------------------------------------------

typedef enum
{
    PTPInitFailReasonRejectedInitiator  = 0x00000001,
    PTPInitFailReasonBusy               = 0x00000002,
    PTPInitFailReasonUnspecified        = 0x00000003
} PTPInitFailReason;

//------------------------------------------------------------------------------------------------------------------------------

typedef enum
{
    PTPDataTypeCodeUndefined          = 0x0000,
    PTPDataTypeCodeSInt8              = 0x0001,
    PTPDataTypeCodeUInt8              = 0x0002,
    PTPDataTypeCodeSInt16             = 0x0003,
    PTPDataTypeCodeUInt16             = 0x0004,
    PTPDataTypeCodeSInt32             = 0x0005,
    PTPDataTypeCodeUInt32             = 0x0006,
    PTPDataTypeCodeSInt64             = 0x0007,
    PTPDataTypeCodeUInt64             = 0x0008,
    PTPDataTypeCodeSInt128            = 0x0009,
    PTPDataTypeCodeUInt128            = 0x000A,
    PTPDataTypeCodeArrayOfSInt8       = 0x4001,
    PTPDataTypeCodeArrayOfUInt8       = 0x4002,
    PTPDataTypeCodeArrayOfSInt16      = 0x4003,
    PTPDataTypeCodeArrayOfUInt16      = 0x4004,
    PTPDataTypeCodeArrayOfSInt32      = 0x4005,
    PTPDataTypeCodeArrayOfUInt32      = 0x4006,
    PTPDataTypeCodeArrayOfSInt64      = 0x4007,
    PTPDataTypeCodeArrayOfUInt64      = 0x4008,
    PTPDataTypeCodeArrayOfSInt128     = 0x4009,
    PTPDataTypeCodeArrayOfUInt128     = 0x400A,
    PTPDataTypeCodeUnicodeString      = 0xFFFF    
} PTPDataTypeCode;

//------------------------------------------------------------------------------------------------------------------------------

typedef enum
{
    ConfigObjectType_Config = 1,
    ConfigObjectType_Firmware = 2,
} ConfigObjectType;
