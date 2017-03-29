//
//  basictypes.h
//  MtpHelper
//
//  Copyright (c) 2017 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information.
//

#pragma once

#include <vector>
#include <string>
#include <time.h>
#include <string.h>
#include "int128_t.h"
#include "bytestream.h"

using namespace std;


namespace PTP {
#define PTP_TYPE_ARRAY_OFFSET   (0x4000)
    
    template<typename T> class BaseType {
    public:
        virtual unsigned int id() const = 0;
        virtual const T& value() const = 0;
        virtual void to_ptp(string& ret) const = 0;
        static void parse(ByteStream& stream, BaseType& ret) {
            throw "Must implement this function.";
        }
    };
    
    template<typename T> class BaseTypeSimple : public BaseType<T> {
    public:
        inline const T& value() const { return _value; }
        const T& operator=(const T& from) {
            _value = from;
            return _value;
        }
        inline void to_ptp(string& ret) const { String::to_s(_value, ret); }
    protected:
        T _value;
    };
    
    template<typename T> class BaseTypeVector : public BaseType<vector<T> >, public vector<T> {
    protected:
        const vector<T>& copy_from(const vector<T>& from) {
            int i = 0;
            vector<T>::assign(from.size(), 0);
            for(typename vector<T>::const_iterator it=from.begin(); it!=from.end(); it++, i++) {
                vector<T>::operator[](i) = *it;
            }
            return value();
        }
    public:
        inline const vector<T>& value() const { return *this; }
        inline const vector<T>& operator=(const vector<T>& from) { return copy_from(from); }
        inline const BaseTypeVector& operator=(const BaseTypeVector& v) { copy_from(v.value()); return *this; }
        inline void to_ptp(string& ret) const { String::to_s(value(), ret); }
    };
    
    
#define DEFINE_SIMPLE_TYPE(_NAME_, _T_, _ID_) \
    class _NAME_ : public BaseTypeSimple<_T_> { \
    public: \
        enum { ID = _ID_, SYM = ID }; \
        inline _NAME_(_T_ v = 0) { _value = v; } \
        inline virtual ~_NAME_() {} \
        inline unsigned int id() const { return ID; } \
        static void parse(ByteStream& stream, _NAME_& ret) { \
            String::from_s(ret._value, stream); \
        } \
    }

#define DEFINE_ARRAY_TYPE(_NAME_, _T_, _ID_) \
    class _NAME_ : public BaseTypeVector<_T_> { \
    public: \
        enum { ID = _ID_, SYM = ID }; \
        inline _NAME_() { clear(); } \
        inline _NAME_(vector<_T_> v) { copy_from(v); } \
        inline virtual ~_NAME_() {} \
        inline unsigned int id() const { return ID; } \
        static void parse(ByteStream& stream, _NAME_& ret) { \
            String::from_s(*(vector<_T_>*)&ret, stream); \
        } \
    }

    class Undefined : public BaseType<int8_t> {
    public:
        enum { ID = 0x0000, SYM = ID };
        inline Undefined() {}
        inline virtual ~Undefined() {}
        inline unsigned int id() const { return ID; }
        inline const int8_t& value() const { static const int8_t zero = 0; return zero; }
        inline void to_ptp(string& ret) const {
            ret.clear();
        }
        inline static void parse(PTP::ByteStream& stream, Undefined& ret) {}
    };

    DEFINE_SIMPLE_TYPE(  SInt8,    int8_t, 0x0001);
    DEFINE_SIMPLE_TYPE(  UInt8,   uint8_t, 0x0002);
    DEFINE_SIMPLE_TYPE( SInt16,   int16_t, 0x0003);
    DEFINE_SIMPLE_TYPE( UInt16,  uint16_t, 0x0004);
    DEFINE_SIMPLE_TYPE( SInt32,   int32_t, 0x0005);
    DEFINE_SIMPLE_TYPE( UInt32,  uint32_t, 0x0006);
    DEFINE_SIMPLE_TYPE( SInt64,   int64_t, 0x0007);
    DEFINE_SIMPLE_TYPE( UInt64,  uint64_t, 0x0008);
    DEFINE_SIMPLE_TYPE(SInt128,  int128_t, 0x0009);
    DEFINE_SIMPLE_TYPE(UInt128, uint128_t, 0x000A);

    DEFINE_ARRAY_TYPE(  ArrayOfSInt8,    int8_t, PTP_TYPE_ARRAY_OFFSET + 0x0001);
    DEFINE_ARRAY_TYPE(  ArrayOfUInt8,   uint8_t, PTP_TYPE_ARRAY_OFFSET + 0x0002);
    DEFINE_ARRAY_TYPE( ArrayOfSInt16,   int16_t, PTP_TYPE_ARRAY_OFFSET + 0x0003);
    DEFINE_ARRAY_TYPE( ArrayOfUInt16,  uint16_t, PTP_TYPE_ARRAY_OFFSET + 0x0004);
    DEFINE_ARRAY_TYPE( ArrayOfSInt32,   int32_t, PTP_TYPE_ARRAY_OFFSET + 0x0005);
    DEFINE_ARRAY_TYPE( ArrayOfUInt32,  uint32_t, PTP_TYPE_ARRAY_OFFSET + 0x0006);
    DEFINE_ARRAY_TYPE( ArrayOfSInt64,   int64_t, PTP_TYPE_ARRAY_OFFSET + 0x0007);
    DEFINE_ARRAY_TYPE( ArrayOfUInt64,  uint64_t, PTP_TYPE_ARRAY_OFFSET + 0x0008);
    DEFINE_ARRAY_TYPE(ArrayOfSInt128,  int128_t, PTP_TYPE_ARRAY_OFFSET + 0x0009);
    DEFINE_ARRAY_TYPE(ArrayOfUInt128, uint128_t, PTP_TYPE_ARRAY_OFFSET + 0x000A);
    
    class UnicodeString : public BaseType<string>, public string {
    public:
        enum { ID = 0xFFFF, SYM = ID };
        inline UnicodeString(const char* v = NULL) { if(v) assign(v); }
        inline virtual ~UnicodeString() {}
        inline unsigned int id() const { return ID; }
        inline const string& value() const { return *this; }
        void to_ptp(string& ret) const;
        static void parse(PTP::ByteStream& stream, UnicodeString& ret);
    };

    class DateTime : public BaseType<struct tm> {
    public:
        enum { ID = 0xFFFF, SYM = 0xFFFE };
        inline DateTime() { memset(&_value, 0, sizeof(_value)); }
        inline DateTime(const struct tm& v) { _value = v; }
        inline virtual ~DateTime() {}
        inline unsigned int id() const { return ID; }
        inline const struct tm& value() const { return *&_value; }
        void to_ptp(string& ret) const;
        static void parse(PTP::ByteStream& stream, DateTime& ret);
    protected:
        struct tm _value;
    };
    
#undef DEFINE_SIMPLE_TYPE
#undef DEFINE_ARRAY_TYPE
}
