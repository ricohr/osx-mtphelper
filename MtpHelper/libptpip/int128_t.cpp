//
//  int128_t.cpp
//  MtpHelper
//
//  Copyright (c) 2017 Ricoh Company, Ltd. All Rights Reserved.
//  See LICENSE for more information.
//

#include "int128_t.h"

void int128_t::to_uint128(uint128_t& r)
{
    r._l = _l;
    r._h = _h;
}


void uint128_t::to_int128(int128_t& r)
{
    r._l = _l;
    r._h = _h;
}
