//
//  bytestream.cpp
//  MtpHelper
//
//  Copyright (c) 2017 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information.
//

#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <iconv.h>
#include <errno.h>
#include "bytestream.h"


namespace PTP {
    ByteStream::ByteStream()
    {
    }
    
    ByteStream::~ByteStream()
    {
        try {
            clear();
        } catch(...) {}
    }

    void ByteStream::clear()
    {
        _buf.clear();
    }
    
    void ByteStream::start(size_t totalLength)
    {
    }
    
    size_t ByteStream::length() const
    {
        return _buf.size();
    }

    bool ByteStream::write(const char* stream, size_t length)
    {
        _buf.append(stream, length);
        return true;
    }
    
    void ByteStream::write(const string& stream)
    {
        write(stream.c_str(), stream.length());
    }
    
    void ByteStream::write(const vector<string>& stream)
    {
        vector<string>::const_iterator it = stream.begin();
        for(; it!=stream.end(); it++) {
            write(*it);
        }
    }
    
    const char* ByteStream::peek() const
    {
        return _buf.c_str();
    }
    
    bool ByteStream::peek(uint16_t& elm) const
    {
        if(length()<2) return false;
        string r = string(peek(), 2);
        elm = (uint16_t)(uint8_t)r[0] | ((uint32_t)(uint8_t)r[1] << 8);
        return true;
    }
    
    bool ByteStream::peek(uint32_t& elm) const
    {
        if(length()<4) return false;
        string r = string(peek(), 4);
        elm = (uint32_t)(uint8_t)r[0] | ((uint32_t)(uint8_t)r[1] << 8) | ((uint32_t)(uint8_t)r[2] << 16) | ((uint32_t)(uint8_t)r[3] << 24);
        return true;
    }

    void ByteStream::read(size_t length_, string& ret)
    {
        if(length()<length_) {
            ret.assign(_buf.c_str(), _buf.size());
            _buf.clear();
        } else {
            ret.assign(_buf.substr(0, length_).c_str(), length_);
            _buf.erase(0, length_);
        }
    }

    void ByteStream::read(uint8_t& elm)
    {
        string s;
        read(1, s);
        elm = (uint8_t)s.at(0);
    }
    
    void ByteStream::read(int8_t& elm)
    {
        uint8_t e;
        read(e);
        elm = (int8_t)e;
    }
    
    void ByteStream::read(uint16_t& elm)
    {
        string s;
        read(2, s);
        elm = (uint16_t)((uint8_t)s.at(0) + ((uint8_t)s.at(1) << 8));
    }
    
    void ByteStream::read(int16_t& elm)
    {
        uint16_t e;
        read(e);
        elm = (int16_t)e;
    }
    
    void ByteStream::read(uint32_t& elm)
    {
        string s;
        read(4, s);
        elm = (uint32_t)((uint8_t)s.at(0) + ((uint8_t)s.at(1) << 8) + ((uint8_t)s.at(2) << 16) + ((uint8_t)s.at(3) << 24));
    }
    
    void ByteStream::read(int32_t& elm)
    {
        uint32_t e;
        read(e);
        elm = (int32_t)e;
    }
    
    void ByteStream::read(uint64_t& elm)
    {
        string s;
        read(8, s);
        uint32_t l = (uint32_t)((uint8_t)s.at(0) + ((uint8_t)s.at(1) << 8) + ((uint8_t)s.at(2) << 16) + ((uint8_t)s.at(3) << 24));
        uint32_t h = (uint32_t)((uint8_t)s.at(4) + ((uint8_t)s.at(5) << 8) + ((uint8_t)s.at(6) << 16) + ((uint8_t)s.at(7) << 24));
        elm = ((uint64_t)l) + ((uint64_t)h << 32);
    }
    
    void ByteStream::read(int64_t& elm)
    {
        uint64_t e;
        read(e);
        elm = (int64_t)e;
    }
    
    void ByteStream::read(uint128_t& elm)
    {
        read(elm._l);
        read(elm._h);
    }
    
    void ByteStream::read(int128_t& elm)
    {
        uint128_t e;
        read(e);
        e.to_int128(elm);
    }
    
    
    namespace String {
        void to_unicodez_str(PTP::ByteStream& stream, string& ret)
        {
            size_t length = stream.length();
            const char* s = stream.peek();
            const char* i = s;
            while(i!=(s+length)) {
                const char* j = i+1;
                if(j==(s+length)) break;
                if(((*i)=='\0') && ((*j)=='\0')) {
                    string t;
                    stream.read((j+1) - s, t);
                    ptp_to_utf8(t, ret);
                    return;
                }
                i++;
                i++;
            }
            throw "Not enough stream";
        }
        
        static void iconv(const string& src, string& ret, const char* from_code, const char* to_code)
        {
            iconv_t iv = ::iconv_open(to_code, from_code);
            if(iv==(iconv_t)-1) throw "iconv_open() failed.";
            
            char tmp[256*6];
            char* in_buf = const_cast<char*>(src.c_str());
            size_t in_len = src.size();
            char* out_buf = tmp;
            size_t out_len = sizeof(tmp);
            out_len = ::iconv(iv, &in_buf, &in_len, &out_buf, &out_len);
            ::iconv_close(iv);
            
            if(out_len==(size_t)-1) throw "iconv() failed.";
            ret.assign(tmp, out_buf - tmp);
        }
        
        void utf8_to_ptp(const string& elm, string& ret)
        {
            iconv(elm, ret, "UTF-8", "UTF-16LE");
            ret.append("\0\0", 2);
        }

        void ptp_to_utf8(const string& elm, string& ret)
        {
            iconv(elm, ret, "UTF-16LE", "UTF-8");
            if(ret.size()>0) {
                ret.erase(ret.size()-1);
            }
        }
    }
}
