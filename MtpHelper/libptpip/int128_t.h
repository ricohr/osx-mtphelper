//
//  int128_t.h
//  MtpHelper
//
//  Copyright (c) 2017 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information.
//

#pragma once

#include <stdint.h>

class uint128_t;

class int128_t {
public:
    int64_t     _h;
    uint64_t    _l;
public:
    int128_t(int64_t l = 0) {
        _l = (uint64_t)l;
        _h = (l>=0) ? 0: -1;
    }
    inline virtual ~int128_t() {}
    int128_t operator=(const int128_t& v) { _h = v._h; _l = v._l; return *this; }
    int128_t operator=(const uint64_t& v) { _h = 0; _l = v; return *this; }
    void to_uint128(uint128_t& r);
};

class uint128_t {
public:
    uint64_t    _h;
    uint64_t    _l;
public:
    uint128_t(uint64_t l = 0) { _h = 0; _l = l; } 
    uint128_t(uint64_t h, uint64_t l) { _h = h; _l = l; } 
    inline virtual ~uint128_t() {}
    uint128_t operator=(const uint128_t& v) { _h = v._h; _l = v._l; return *this; }
    uint128_t operator=(const uint64_t& v) { _h = 0; _l = v; return *this; }
    void to_int128(int128_t& r);
};
