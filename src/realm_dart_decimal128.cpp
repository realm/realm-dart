#include "realm_dart.hpp"
#include "realm-core/src/external/IntelRDFPMathLib20U2/LIBRARY/src/bid_conf.h"
#include "realm-core/src/external/IntelRDFPMathLib20U2/LIBRARY/src/bid_functions.h"

namespace {
realm_decimal128_t to_decimal128(const BID_UINT128& value)
{
    realm_decimal128_t result;
    memcpy(&result, &value, sizeof(BID_UINT128));
    return result;
}

BID_UINT128 to_BID_UINT128(const realm_decimal128_t& value)
{
    BID_UINT128 result;
    memcpy(&result, &value, sizeof(BID_UINT128));
    return result;
}
}

RLM_API realm_decimal128_t realm_dart_decimal128_from_string(const char* string) {
    unsigned int flags = 0;
    BID_UINT128 result;
    bid128_from_string(&result, const_cast<char*>(string), &flags);
    return to_decimal128(result);
}

// This buffer is reused between calls, hence it is thread local
thread_local char _decimal128_to_string_buffer[34];
RLM_API realm_string_t realm_dart_decimal128_to_string(realm_decimal128_t x) {
    auto x_bid = to_BID_UINT128(x);
    unsigned int flags = 0;
    bid128_to_string(_decimal128_to_string_buffer, &x_bid, &flags);
    return realm_string_t{ _decimal128_to_string_buffer, strlen(_decimal128_to_string_buffer) };
}

RLM_API realm_decimal128_t realm_dart_decimal128_nan() {
    BID_UINT128 result;
    bid128_nan(&result, "+NaN");
    return to_decimal128(result);
}

RLM_API bool realm_dart_decimal128_is_nan(realm_decimal128_t x) {
    auto x_bid = to_BID_UINT128(x);
    int result;
    bid128_isNaN(&result, &x_bid);
    return result;
}

RLM_API realm_decimal128_t realm_dart_decimal128_from_int64(int64_t x) {
    BID_UINT128 result;
    BID_SINT64 y = x;
    bid128_from_int64(&result, &y);
    return to_decimal128(result);
}

RLM_API int64_t realm_dart_decimal128_to_int64(realm_decimal128_t x) {
    auto x_bid = to_BID_UINT128(x);
    BID_SINT64 result;
    unsigned int flags = 0;
    bid128_to_int64_int(&result, &x_bid, &flags);
    return result;
}

RLM_API realm_decimal128_t realm_dart_decimal128_copy(realm_decimal128_t x) {
    return x; // work-around to Dart FFI issue
}

RLM_API realm_decimal128_t realm_dart_decimal128_negate(realm_decimal128_t x) {
    auto x_bid = to_BID_UINT128(x);
    BID_UINT128 result;
    bid128_negate(&result, &x_bid);
    return to_decimal128(result);
}

RLM_API realm_decimal128_t realm_dart_decimal128_add(realm_decimal128_t x, realm_decimal128_t y) {
    auto l = to_BID_UINT128(x);
    auto r = to_BID_UINT128(y);
    BID_UINT128 result;
    unsigned int flags = 0;
    bid128_add(&result, &l, &r, &flags);
    return to_decimal128(result);
}

RLM_API realm_decimal128_t realm_dart_decimal128_subtract(realm_decimal128_t x, realm_decimal128_t y) {
    auto l = to_BID_UINT128(x);
    auto r = to_BID_UINT128(y);
    BID_UINT128 result;
    unsigned int flags = 0;
    bid128_sub(&result, &l, &r, &flags);
    return to_decimal128(result);
}

RLM_API realm_decimal128_t realm_dart_decimal128_multiply(realm_decimal128_t x, realm_decimal128_t y) {
    auto l = to_BID_UINT128(x);
    auto r = to_BID_UINT128(y);
    BID_UINT128 result;
    unsigned int flags = 0;
    bid128_mul(&result, &l, &r, &flags);
    return to_decimal128(result);
}

RLM_API realm_decimal128_t realm_dart_decimal128_divide(realm_decimal128_t x, realm_decimal128_t y) {
    auto l = to_BID_UINT128(x);
    auto r = to_BID_UINT128(y);
    BID_UINT128 result;
    unsigned int flags = 0;
    bid128_div(&result, &l, &r, &flags);
    return to_decimal128(result);
}

RLM_API bool realm_dart_decimal128_equal(realm_decimal128_t x, realm_decimal128_t y) {
    auto l = to_BID_UINT128(x);
    auto r = to_BID_UINT128(y);
    int result;
    unsigned int flags = 0;
    bid128_quiet_equal(&result, &l, &r, &flags);
    return result;
}

RLM_API bool realm_dart_decimal128_less_than(realm_decimal128_t x, realm_decimal128_t y) {
    auto l = to_BID_UINT128(x);
    auto r = to_BID_UINT128(y);
    int result;
    unsigned int flags = 0;
    bid128_quiet_less(&result, &l, &r, &flags);
    return result;
}

RLM_API bool realm_dart_decimal128_greater_than(realm_decimal128_t x, realm_decimal128_t y) {
    auto l = to_BID_UINT128(x);
    auto r = to_BID_UINT128(y);
    int result;
    unsigned int flags = 0;
    bid128_quiet_greater(&result, &l, &r, &flags);
    return result;
}

RLM_API int realm_dart_decimal128_compare_to(realm_decimal128_t x, realm_decimal128_t y) {
    auto l = to_BID_UINT128(x);
    auto r = to_BID_UINT128(y);
    int lr, rl;
    bid128_totalOrder(&lr, &l, &r);
    bid128_totalOrder(&rl, &r, &l);
    if (lr && rl) return 0;
    if (lr) return -1;
    if (rl) return 1;
    return 0;
}
