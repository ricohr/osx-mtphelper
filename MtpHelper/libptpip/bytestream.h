//
//  bytestream.h
//  MtpHelper
//
//  Copyright (c) 2017 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information.
//

#pragma once

#include <string>
#include <vector>
#include <unistd.h>
#include "int128_t.h"

using namespace std;


namespace PTP {
    
    class ByteStream {
    protected:
        string _buf;
        
    public:
        ByteStream();
        virtual ~ByteStream();
        
        virtual void clear();
        virtual void start(size_t totalLength);
        virtual size_t length() const;
        virtual bool write(const char* stream, size_t length);
        void write(const string& stream);
        void write(const vector<string>& stream);
        const char* peek() const;
        bool peek(uint16_t& elm) const;
        bool peek(uint32_t& elm) const;
        void read(size_t length, string& ret);
        void read(uint8_t& elm);
        void read(int8_t& elm);
        void read(uint16_t& elm);
        void read(int16_t& elm);
        void read(uint32_t& elm);
        void read(int32_t& elm);
        void read(uint64_t& elm);
        void read(int64_t& elm);
        void read(uint128_t& elm);
        void read(int128_t& elm);
    };
    
    typedef bool (*inboundDataStreamListener_t)(const void* _this, const char* data, size_t length);
    class InboundDataStream : public ByteStream {
    protected:
        inboundDataStreamListener_t _streamListener;
        const void* _streamListener_self;
        int _fd;
        size_t _length;
    public:
        InboundDataStream(const void* _this = NULL, inboundDataStreamListener_t listener = NULL, int fd = -1) {
            _streamListener_self = _this;
            _streamListener = listener;
            _fd = fd;
            _length = 0;
        }
        void attachFileDescriptor(int fd) {
            _fd = fd;
        }
        void attachStreamListener(const void* _this, inboundDataStreamListener_t listener) {
            _streamListener_self = _this;
            _streamListener = listener;
        }
        virtual ~InboundDataStream() {}
        virtual bool write(const char* stream, size_t length) {
            bool result = true;
            if(_streamListener) {
                result = _streamListener(_streamListener_self, stream, length);
            }
            if(_fd>=0) {
                result &= ((size_t)::write(_fd, stream, length)==length)? true: false;
            }
            if(result) _length += length;
            return result;
        }
        virtual void clear() {
            _length = 0;
        }
        virtual void start(size_t totalLength) {
            _length = 0;
            if(_streamListener) {
                _streamListener(_streamListener_self, NULL, totalLength);
            }
        }
        virtual size_t length() const { return _length; }
    };
    
    namespace String {
        template<typename T> void simple_to_string_t(const T& elm, string& ret) {
            ret.assign(sizeof(T), 0);
            T e = elm;
            for(size_t i=0; i<sizeof(T); i++) {
                ret.at(i) = e;
                e >>= 8;
            }
        }
        inline void to_s(const uint8_t& elm, string& ret) {
            ret.assign(1, (char)elm);
        }
        inline void to_s(const int8_t& elm, string& ret) {
            ret.assign(1, (char)elm);
        }
        inline void to_s(const uint16_t& elm, string& ret) {
            simple_to_string_t<uint16_t>(elm, ret);
        }
        inline void to_s(const int16_t& elm, string& ret) {
            simple_to_string_t<int16_t>(elm,ret);
        }
        inline void to_s(const uint32_t& elm, string& ret) {
            simple_to_string_t<uint32_t>(elm, ret);
        }
        inline void to_s(const int32_t& elm, string& ret) {
            simple_to_string_t<int32_t>(elm, ret);
        }
        inline void to_s(const uint64_t& elm, string& ret) {
            simple_to_string_t<uint64_t>(elm, ret);
        }
        inline void to_s(const int64_t& elm, string& ret) {
            simple_to_string_t<int64_t>(elm, ret);
        }
        inline void to_s(const uint128_t& elm, string& ret) {
            string t;
            ret.clear();
            to_s(elm._l, t); ret.append(t);
            to_s(elm._h, t); ret.append(t);
        }
        inline void to_s(const int128_t& elm, string& ret) {
            string t;
            ret.clear();
            to_s(elm._l, t); ret.append(t);
            to_s(elm._h, t); ret.append(t);
        }

        template<typename T> void vector_to_string_t(const vector<T>& elm, string& ret) {
            to_s((uint32_t)elm.size(), ret);
            for(typename vector<T>::const_iterator it = elm.begin(); it!=elm.end(); it++) {
                string t;
                to_s(*it, t);
                ret.append(t);
            }
        }
        inline void to_s(const vector<uint8_t>& elm, string& ret) {
            vector_to_string_t<uint8_t>(elm, ret);
        }
        inline void to_s(const vector<int8_t>& elm, string& ret) {
            vector_to_string_t<int8_t>(elm, ret);
        }
        inline void to_s(const vector<uint16_t>& elm, string& ret) {
            vector_to_string_t<uint16_t>(elm, ret);
        }
        inline void to_s(const vector<int16_t>& elm, string& ret) {
            vector_to_string_t<int16_t>(elm, ret);
        }
        inline void to_s(const vector<uint32_t>& elm, string& ret) {
            vector_to_string_t<uint32_t>(elm, ret);
        }
        inline void to_s(const vector<int32_t>& elm, string& ret) {
            vector_to_string_t<int32_t>(elm, ret);
        }
        inline void to_s(const vector<uint64_t>& elm, string& ret) {
            vector_to_string_t<uint64_t>(elm, ret);
        }
        inline void to_s(const vector<int64_t>& elm, string& ret) {
            vector_to_string_t<int64_t>(elm, ret);
        }
        inline void to_s(const vector<uint128_t>& elm, string& ret) {
            vector_to_string_t<uint128_t>(elm, ret);
        }
        inline void to_s(const vector<int128_t>& elm, string& ret) {
            vector_to_string_t<int128_t>(elm, ret);
        }
        
        template<typename T> T simple_from_string_t(PTP::ByteStream& stream) {
            uint64_t r = 0;
            string s;
            stream.read(sizeof(T), s);
            for(int i=sizeof(T)-1; i>=0; i--) {
                r <<= 8;
                r |= (uint8_t)s.at(i);
            }
            return (T)r;
        }
        inline void from_s(uint8_t& elm, PTP::ByteStream& stream) {
            elm = simple_from_string_t<uint8_t>(stream);
        }
        inline void from_s(int8_t& elm, PTP::ByteStream& stream) {
            elm = simple_from_string_t<int8_t>(stream);
        }
        inline void from_s(uint16_t& elm, PTP::ByteStream& stream) {
            elm = simple_from_string_t<uint16_t>(stream);
        }
        inline void from_s(int16_t& elm, PTP::ByteStream& stream) {
            elm = simple_from_string_t<int16_t>(stream);
        }
        inline void from_s(uint32_t& elm, PTP::ByteStream& stream) {
            elm = simple_from_string_t<uint32_t>(stream);
        }
        inline void from_s(int32_t& elm, PTP::ByteStream& stream) {
            elm = simple_from_string_t<int32_t>(stream);
        }
        inline void from_s(uint64_t& elm, PTP::ByteStream& stream) {
            elm = simple_from_string_t<uint64_t>(stream);
        }
        inline void from_s(int64_t& elm, PTP::ByteStream& stream) {
            elm = simple_from_string_t<int64_t>(stream);
        }
        inline void from_s(uint128_t& elm, PTP::ByteStream& stream) {
            from_s(elm._l, stream);
            from_s(elm._h, stream);
        }
        inline void from_s(int128_t& elm, PTP::ByteStream& stream) {
            from_s(elm._l, stream);
            from_s(elm._h, stream);
        }
/*
        inline uint8_t to_uint8(PTP::ByteStream& stream) { return simple_from_string_t<uint8_t>(stream); }
        inline uint16_t to_uint16(PTP::ByteStream& stream) { return simple_from_string_t<uint16_t>(stream); }
        inline uint32_t to_uint32(PTP::ByteStream& stream) { return simple_from_string_t<uint32_t>(stream); }
  */      
        void to_unicodez_str(PTP::ByteStream& stream, string& ret);
        
        template<typename T> void vector_from_string_t(vector<T>& elm, PTP::ByteStream& stream) {
            uint32_t len = 0;
            stream.read(len);
            elm.assign(len, 0);
            for(uint32_t i=0; i<len; i++) {
                T v;
                from_s(v, stream);
                elm[i] = v;
            }
        }
        inline void from_s(vector<uint8_t>& elm, PTP::ByteStream& stream) {
            vector_from_string_t<uint8_t>(elm, stream);
        }
        inline void from_s(vector<int8_t>& elm, PTP::ByteStream& stream) {
            vector_from_string_t<int8_t>(elm, stream);
        }
        inline void from_s(vector<uint16_t>& elm, PTP::ByteStream& stream) {
            vector_from_string_t<uint16_t>(elm, stream);
        }
        inline void from_s(vector<int16_t>& elm, PTP::ByteStream& stream) {
            vector_from_string_t<int16_t>(elm, stream);
        }
        inline void from_s(vector<uint32_t>& elm, PTP::ByteStream& stream) {
            vector_from_string_t<uint32_t>(elm, stream);
        }
        inline void from_s(vector<int32_t>& elm, PTP::ByteStream& stream) {
            vector_from_string_t<int32_t>(elm, stream);
        }
        inline void from_s(vector<uint64_t>& elm, PTP::ByteStream& stream) {
            vector_from_string_t<uint64_t>(elm, stream);
        }
        inline void from_s(vector<int64_t>& elm, PTP::ByteStream& stream) {
            vector_from_string_t<int64_t>(elm, stream);
        }
        inline void from_s(vector<uint128_t>& elm, PTP::ByteStream& stream) {
            vector_from_string_t<uint128_t>(elm, stream);
        }
        inline void from_s(vector<int128_t>& elm, PTP::ByteStream& stream) {
            vector_from_string_t<int128_t>(elm, stream);
        }
        
        void utf8_to_ptp(const string& elm, string& ret);
        void ptp_to_utf8(const string& elm, string& ret);
    }
}
