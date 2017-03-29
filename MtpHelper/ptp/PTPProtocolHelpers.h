//------------------------------------------------------------------------------------------------------------------------------
//
// File:       PTPProtocolHelpers.h
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
#import <Foundation/Foundation.h>
#import "PTPEnums.h"

//---------------------------------------------------------------------------------------------------------- PTPOperationRequest
/*! 
  @class PTPOperationRequest
  @abstract The OperationRequest object is used to create a PTP operation request.
*/

@class PTPOperationResponse;
typedef void (^PTPOperationRequest_onCompleteBlock_t)(NSData* inData, PTPOperationResponse* ptpResponse);

@interface PTPOperationRequest : NSObject
{
@private
    id mPrivateData;
}

/*! 
  @property operationCode
  @abstract PTP operation code.
*/
@property(assign)       unsigned short    operationCode;

/*! 
  @property transactionID
  @abstract PTP transaction ID. Image Capture Core framework ignores this value since the PTPCamera device module determines this value.
*/
@property(assign)       unsigned int      transactionID;

/*! 
  @property numberOfParameters
  @abstract Number of parameters to be sent to the device. This cannot be greater than 5.
*/
@property(assign)       unsigned short    numberOfParameters;

/*! 
  @property parameter1
  @abstract Parameter 1.
*/
@property(assign)       unsigned int      parameter1;

/*! 
  @property parameter2
  @abstract Parameter 2.
*/
@property(assign)       unsigned int      parameter2;

/*! 
  @property parameter3
  @abstract Parameter 3.
*/
@property(assign)       unsigned int      parameter3;

/*! 
  @property parameter4
  @abstract Parameter 4.
*/
@property(assign)       unsigned int      parameter4;

/*! 
  @property parameter5
  @abstract Parameter 5.
*/
@property(assign)       unsigned int      parameter5;

/*! 
  @property commandBuffer
  @abstract A serialized buffer intended to be used with -requestSendPTPCommand:... method of ICCameraDevice object.
*/
@property(readonly)     NSData*           commandBuffer;

/*
 @property context
 @abstract for application data
*/
@property(nonatomic)    PTPOperationRequest_onCompleteBlock_t onCompleteBlock;
@end

//--------------------------------------------------------------------------------------------------------- PTPOperationResponse
/*! 
  @class PTPOperationResponse
  @abstract The OperationResponse object is returned by the device in response to a PTP operation request.
*/

@interface PTPOperationResponse : NSObject
{
@private
    id mPrivateData;
}

/*! 
  @property responseCode
  @abstract PTP response code.
*/
@property(readonly)     unsigned short    responseCode;

/*! 
  @property transactionID
  @abstract PTP transaction ID.
*/
@property(readonly)     unsigned int      transactionID;

/*! 
  @property numberOfParameters
  @abstract Number of parameters received from the device. This cannot be greater than 5.
*/
@property(readonly)     unsigned short    numberOfParameters;

/*! 
  @property parameter1
  @abstract Parameter 1.
*/
@property(readonly)     unsigned int      parameter1;

/*! 
  @property parameter2
  @abstract Parameter 2.
*/
@property(readonly)     unsigned int      parameter2;

/*! 
  @property parameter3
  @abstract Parameter 3.
*/
@property(readonly)     unsigned int      parameter3;

/*! 
  @property parameter4
  @abstract Parameter 4.
*/
@property(readonly)     unsigned int      parameter4;

/*! 
  @property parameter5
  @abstract Parameter 5.
*/
@property(readonly)     unsigned int      parameter5;

/*
 NSError of request seqence error
 */
@property(nonatomic)    NSError*    requestError;

- (id)initWithData:(NSData*)data;

@end

//--------------------------------------------------------------------------------------------------------------------- PTPEvent
/*! 
  @class Event
  @abstract The PTPEvent object is sent by the device. The developer should refer to the PTP specification document, PIMA 15740:2000, for more information about when a device is likely to send PTP events.
*/

@interface PTPEvent : NSObject
{
@private
    id mPrivateData;
}

/*! 
  @property eventCode
  @abstract PTP event code.
*/
@property(readonly)     unsigned short    eventCode;

/*! 
  @property transactionID
  @abstract PTP transaction ID.
*/
@property(readonly)     unsigned int      transactionID;

/*! 
  @property numberOfParameters
  @abstract Number of parameters received from the device. This cannot be greater than 3.
*/
@property(readonly)     unsigned short    numberOfParameters;

/*! 
  @property parameter1
  @abstract Parameter 1.
*/
@property(readonly)     unsigned int      parameter1;

/*! 
  @property parameter2
  @abstract Parameter 2.
*/
@property(readonly)     unsigned int      parameter2;

/*! 
  @property parameter3
  @abstract Parameter 3.
*/
@property(readonly)     unsigned int      parameter3;

- (id)initWithData:(NSData*)data;

@end

//------------------------------------------------------------------------------------------------------------------------------
