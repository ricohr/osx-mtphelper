//------------------------------------------------------------------------------------------------------------------------------
//
// File:       PTPProtocolHelpers.m
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
#import "PTPProtocolHelpers.h"

//------------------------------------------------------------------------------------------------------------------------------

static short
PTPReadShort( unsigned char** buf )
{
    SInt16 value = (SInt16)CFSwapInt16LittleToHost(*(UInt16*)(*buf));
    (*buf) += 2;
    return value;
}

//------------------------------------------------------------------------------------------------------------------------------

static void
PTPWriteShort( unsigned char** buf, short value )
{
    *(SInt16*)(*buf) = (SInt16)CFSwapInt16HostToLittle( value );
    (*buf) += 2;
}

//------------------------------------------------------------------------------------------------------------------------------

static unsigned short
PTPReadUnsignedShort( unsigned char** buf )
{
    unsigned short value = CFSwapInt16LittleToHost(*(unsigned short*)(*buf));
    (*buf) += 2;
    return value;
}

//------------------------------------------------------------------------------------------------------------------------------

static void
PTPWriteUnsignedShort( unsigned char** buf, unsigned short value )
{
    *(unsigned short*)(*buf) = CFSwapInt16HostToLittle( value );
    (*buf) += 2;
}

//------------------------------------------------------------------------------------------------------------------------------

static int
PTPReadInt( unsigned char** buf )
{
    int value = (int)CFSwapInt32LittleToHost(*(int*)(*buf));
    (*buf) += 4;
    return value;
}

//------------------------------------------------------------------------------------------------------------------------------

static void
PTPWriteInt( unsigned char** buf, int value )
{
    *(int*)(*buf) = (int)CFSwapInt32HostToLittle( value );
    (*buf) += 4;
}

//------------------------------------------------------------------------------------------------------------------------------

static unsigned int
PTPReadUnsignedInt( unsigned char** buf )
{
    int value = CFSwapInt32LittleToHost(*(int*)(*buf));
    (*buf) += 4;
    return value;
}

//------------------------------------------------------------------------------------------------------------------------------

static void
PTPWriteUnsignedInt( unsigned char** buf, unsigned int value )
{
    *(unsigned int*)(*buf) = CFSwapInt32HostToLittle( value );
    (*buf) += 4;
}

//------------------------------------------------------------------------------------------------------------------------------

static long long
PTPReadLongLong( unsigned char** buf )
{
    long long value = (long long)CFSwapInt64LittleToHost(*(long long*)(*buf));
    (*buf) += 8;
    return value;
}

//------------------------------------------------------------------------------------------------------------------------------

static void
PTPWriteLongLong( unsigned char** buf, long long value )
{
    *(long long*)(*buf) = (long long)CFSwapInt64HostToLittle( value );
    (*buf) += 8;
}

//------------------------------------------------------------------------------------------------------------------------------

static unsigned long long
PTPReadUnsignedLongLong( unsigned char** buf )
{
    unsigned long long value = CFSwapInt64LittleToHost(*(unsigned long long*)(*buf));
    (*buf) += 8;
    return value;
}

//------------------------------------------------------------------------------------------------------------------------------

static void
PTPWriteUnsignedLongLong( unsigned char** buf, unsigned long long value )
{
    *(unsigned long long*)(*buf) = CFSwapInt64HostToLittle( value );
    (*buf) += 8;
}

//----------------------------------------------------------------------------------------------- PTPOperationRequestPrivateData

@interface PTPOperationRequestPrivateData : NSObject
{
    unsigned short    mOperationCode;
    unsigned int      mTransactionID;
    unsigned short    mNumberOfParameters;
    unsigned int*     mParameters;
}

@property   unsigned short  operationCode;
@property   unsigned int    transactionID;
@property   unsigned short  numberOfParameters;
@property   unsigned int*   parameters;
@end

//------------------------------------------------------------------------------------------------------------------------------

@implementation PTPOperationRequestPrivateData
@synthesize operationCode       = mOperationCode;
@synthesize transactionID       = mTransactionID;
@synthesize numberOfParameters  = mNumberOfParameters;
@synthesize parameters          = mParameters;

- (id)init
{
    if ( ( self = [super init] ) )
    {
        mParameters = (unsigned int*)calloc( 5, sizeof( unsigned int ) );
    }
    
    return self;
}

- (void)dealloc
{
    free( mParameters );
    //[super dealloc];
}

- (void)finalize
{
    free( mParameters );
    [super finalize];
}
@end

//------------------------------------------------------------------------------------------------------------------------------

#define requestIvars ((PTPOperationRequestPrivateData*)mPrivateData)

//---------------------------------------------------------------------------------------------------------- PTPOperationRequest

@implementation PTPOperationRequest

- (id)init
{
    if ( ( self = [super init] ) )
    {
        mPrivateData = [[PTPOperationRequestPrivateData alloc] init];
        
        if ( mPrivateData == NULL )
        {
            //[self release];
            self = NULL;
        }
    }
    
    return self;
}

- (unsigned short)operationCode       { return requestIvars.operationCode; }
- (unsigned int)transactionID         { return requestIvars.transactionID; }
- (unsigned short)numberOfParameters  { return requestIvars.numberOfParameters; }
- (unsigned int)parameter1            { return requestIvars.parameters[0]; }
- (unsigned int)parameter2            { return requestIvars.parameters[1]; }
- (unsigned int)parameter3            { return requestIvars.parameters[2]; }
- (unsigned int)parameter4            { return requestIvars.parameters[3]; }
- (unsigned int)parameter5            { return requestIvars.parameters[4]; }

- (void)setOperationCode:(unsigned short)code     { requestIvars.operationCode = code; }
- (void)setTransactionID:(unsigned int)transID    { requestIvars.transactionID = transID; }
- (void)setNumberOfParameters:(unsigned short)num { requestIvars.numberOfParameters = num; }
- (void)setParameter1:(unsigned int)param         { requestIvars.parameters[0] = param; }
- (void)setParameter2:(unsigned int)param         { requestIvars.parameters[1] = param; }
- (void)setParameter3:(unsigned int)param         { requestIvars.parameters[2] = param; }
- (void)setParameter4:(unsigned int)param         { requestIvars.parameters[3] = param; }
- (void)setParameter5:(unsigned int)param         { requestIvars.parameters[4] = param; }

- (NSData*)commandBuffer
{
    int             i;
	unsigned int    len     = 12 + 4*requestIvars.numberOfParameters;
    unsigned char*  buffer  = (unsigned char*)calloc(len, 1);
    unsigned char*  buf     = buffer;
    
	PTPWriteUnsignedInt( &buf, len );
	PTPWriteUnsignedShort( &buf, 1 );    // command block code
	PTPWriteUnsignedShort( &buf, requestIvars.operationCode );
	PTPWriteUnsignedInt( &buf, requestIvars.transactionID );      // ignored by ImageCaptureCore framework
    
    for ( i = 0; i < requestIvars.numberOfParameters; ++i )
        PTPWriteUnsignedInt( &buf, requestIvars.parameters[i] );
        
    return [NSData dataWithBytesNoCopy:buffer length:len freeWhenDone:YES];
}

- (NSString*)description
{
    NSMutableString*  s = [NSMutableString stringWithFormat:@"\n%@ <%p>:\n", [self class], self];

    [s appendFormat:@"  operationCode       : 0x%04x\n", requestIvars.operationCode];
    [s appendFormat:@"  transactionID       : 0x%08x\n", requestIvars.transactionID];
    [s appendFormat:@"  numberOfParameters  : %d\n", requestIvars.numberOfParameters];
    if ( requestIvars.numberOfParameters )
    {
        int i = 1;

        [s appendFormat:@"  parameters          : 0x%08X\n", requestIvars.parameters[0]];
        while ( i < requestIvars.numberOfParameters )
        {
            [s appendFormat:@"  parameters          : 0x%08X\n", requestIvars.parameters[i]];
            ++i;
        }
    }

    [s appendFormat:@"\n"];
    return s;
}

@end

//---------------------------------------------------------------------------------------------- PTPOperationResponsePrivateData

@interface PTPOperationResponsePrivateData : NSObject
{
    unsigned short    mResponseCode;
    unsigned int      mTransactionID;
    unsigned short    mNumberOfParameters;
    unsigned int*     mParameters;
}

@property   unsigned short  responseCode;
@property   unsigned int    transactionID;
@property   unsigned short  numberOfParameters;
@property   unsigned int*   parameters;
@end

//------------------------------------------------------------------------------------------------------------------------------

@implementation PTPOperationResponsePrivateData
@synthesize responseCode        = mResponseCode;
@synthesize transactionID       = mTransactionID;
@synthesize numberOfParameters  = mNumberOfParameters;
@synthesize parameters          = mParameters;

- (id)init
{
    if ( ( self = [super init] ) )
    {
        mParameters = (unsigned int*)calloc( 5, sizeof( unsigned int ) );
    }
    
    return self;
}

- (void)dealloc
{
    free( mParameters );
    //[super dealloc];
}

- (void)finalize
{
    free( mParameters );
    [super finalize];
}
@end

//------------------------------------------------------------------------------------------------------------------------------

#define responseIvars ((PTPOperationResponsePrivateData*)mPrivateData)

//--------------------------------------------------------------------------------------------------------- PTPOperationResponse

@implementation PTPOperationResponse

- (id)initWithData:(NSData*)data
{
    NSUInteger dataLength = [data length];
    
    if ( ( data == NULL ) || ( dataLength < 12 ) || ( dataLength > 32 ) )
        return NULL;
    else
    {
        unsigned char*  buffer  = (unsigned char*)[data bytes];
        unsigned int    size    = CFSwapInt32LittleToHost(*(unsigned int*)buffer);
        unsigned short  type    = CFSwapInt16LittleToHost(*(unsigned short*)(buffer+4));

        if ( size < 12 || size > 32 || type != 3 )
            return NULL;
        else 
        {
            if ( ( self = [super init] ) )
            {
                mPrivateData = [[PTPOperationResponsePrivateData alloc] init];
                
                if ( mPrivateData == NULL )
                {
                    //[self release];
                    self = NULL;
                }
                else
                {
                    unsigned char*  buf = buffer + 6;
                    int             i;
                    
                    responseIvars.responseCode        = PTPReadUnsignedShort( &buf );
                    responseIvars.transactionID       = PTPReadUnsignedInt( &buf );
                    responseIvars.numberOfParameters  = (size-12) >> 2;
                    
                    for ( i = 0; i < responseIvars.numberOfParameters; ++i )
                        responseIvars.parameters[i] = PTPReadUnsignedInt( &buf );
                }
            }
            
            return self;
        }
    }
}

- (unsigned short)responseCode        { return responseIvars.responseCode; }
- (unsigned int)transactionID         { return responseIvars.transactionID; }
- (unsigned short)numberOfParameters  { return responseIvars.numberOfParameters; }
- (unsigned int)parameter1            { return responseIvars.parameters[0]; }
- (unsigned int)parameter2            { return responseIvars.parameters[1]; }
- (unsigned int)parameter3            { return responseIvars.parameters[2]; }
- (unsigned int)parameter4            { return responseIvars.parameters[3]; }
- (unsigned int)parameter5            { return responseIvars.parameters[4]; }

- (NSString*)description
{
    NSMutableString*  s = [NSMutableString stringWithFormat:@"\n%@ <%p>:\n", [self class], self];

    [s appendFormat:@"  responseCode        : 0x%04x\n", responseIvars.responseCode];
    [s appendFormat:@"  transactionID       : 0x%08x\n", responseIvars.transactionID];
    [s appendFormat:@"  numberOfParameters  : %d\n", responseIvars.numberOfParameters];
    if ( responseIvars.numberOfParameters )
    {
        int i = 1;

        [s appendFormat:@"  parameters          : 0x%08X\n", responseIvars.parameters[0]];
        while ( i < responseIvars.numberOfParameters )
        {
            [s appendFormat:@"  parameters          : 0x%08X\n", responseIvars.parameters[i]];
            ++i;
        }
    }

    [s appendFormat:@"\n"];
    return s;
}

@end

//---------------------------------------------------------------------------------------------------------- PTPEventPrivateData

@interface PTPEventPrivateData : NSObject
{
    unsigned short    mEventCode;
    unsigned int      mTransactionID;
    unsigned short    mNumberOfParameters;
    unsigned int*     mParameters;
}

@property   unsigned short  eventCode;
@property   unsigned int    transactionID;
@property   unsigned short  numberOfParameters;
@property   unsigned int*   parameters;
@end

//------------------------------------------------------------------------------------------------------------------------------

@implementation PTPEventPrivateData
@synthesize eventCode           = mEventCode;
@synthesize transactionID       = mTransactionID;
@synthesize numberOfParameters  = mNumberOfParameters;
@synthesize parameters          = mParameters;

- (id)init
{
    if ( ( self = [super init] ) )
    {
        mParameters = (unsigned int*)calloc( 3, sizeof( unsigned int ) );
    }
    
    return self;
}

- (void)dealloc
{
    free( mParameters );
    //[super dealloc];
}

- (void)finalize
{
    free( mParameters );
    [super finalize];
}
@end

//------------------------------------------------------------------------------------------------------------------------------

#define eventIvars ((PTPEventPrivateData*)mPrivateData)

//--------------------------------------------------------------------------------------------------------------------- PTPEvent

@implementation PTPEvent

- (id)initWithData:(NSData*)data
{
    NSUInteger dataLength = [data length];
    
    if ( ( data == NULL ) || ( dataLength < 12 ) || ( dataLength > 24 ) )
        return NULL;
    else
    {
        unsigned char*  buffer  = (unsigned char*)[data bytes];
        unsigned int    size    = CFSwapInt32LittleToHost(*(unsigned int*)buffer);
        unsigned short  type    = CFSwapInt16LittleToHost(*(unsigned short*)(buffer+4));

        if ( size < 12 || size > 24 || type != 4 )
            return NULL;
        else 
        {
            if ( ( self = [super init] ) )
            {
                mPrivateData = [[PTPEventPrivateData alloc] init];
                
                if ( mPrivateData == NULL )
                {
                    //[self release];
                    self = NULL;
                }
                else
                {
                    unsigned char*  buf = buffer + 6;
                    int             i;
                    
                    eventIvars.eventCode          = PTPReadUnsignedShort( &buf );
                    eventIvars.transactionID      = PTPReadUnsignedInt( &buf );
                    eventIvars.numberOfParameters = (size-12) >> 2;
                    
                    for ( i = 0; i < eventIvars.numberOfParameters; ++i )
                        eventIvars.parameters[i] = PTPReadUnsignedInt( &buf );
                }
            }
            
            return self;
        }
    }
}

- (unsigned short)eventCode           { return eventIvars.eventCode; }
- (unsigned int)transactionID         { return eventIvars.transactionID; }
- (unsigned short)numberOfParameters  { return eventIvars.numberOfParameters; }
- (unsigned int)parameter1            { return eventIvars.parameters[0]; }
- (unsigned int)parameter2            { return eventIvars.parameters[1]; }
- (unsigned int)parameter3            { return eventIvars.parameters[2]; }

- (NSString*)description
{
    NSMutableString*  s = [NSMutableString stringWithFormat:@"\n%@ <%p>:\n", [self class], self];

    [s appendFormat:@"  eventCode           : 0x%04x\n", eventIvars.eventCode];
    [s appendFormat:@"  transactionID       : 0x%08x\n", eventIvars.transactionID];
    [s appendFormat:@"  numberOfParameters  : %d\n", eventIvars.numberOfParameters];
    if ( eventIvars.numberOfParameters )
    {
        int i = 1;

        [s appendFormat:@"  parameters          : 0x%08X\n", eventIvars.parameters[0]];
        while ( i < eventIvars.numberOfParameters )
        {
            [s appendFormat:@"  parameters          : 0x%08X\n", eventIvars.parameters[i]];
            ++i;
        }
    }

    [s appendFormat:@"\n"];
    return s;
}

@end


//------------------------------------------------------------------------------------------------------------------------------
