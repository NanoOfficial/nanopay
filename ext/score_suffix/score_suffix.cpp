/**
 * @file score_suffix.cpp
 * @author Krisna Pranav
 * @brief score suffix
 * @version 1.0
 * @date 2023-08-24
 * 
 * @copyright Copyright (c) 2023 Krisna Pranav, NanoBlocksDevelopers 
 * 
 */

#include <array>
#include <random>
#include <vector>
// #include <ruby/ruby.h>
#include <ruby/ruby.h>
#include <ruby/thread.h>
#include <openssl/sha.h>

using namespace std;

struct index_params
{
    string prefix;
    int strength;
    string nonce;
    bool keep_going;
}; // index params [struct]

/**
 * @param string 
 * @return array<uint8_t, SHA256_DIGEST_LENGTH> 
 */
static array<uint8_t, SHA256_DIGEST_LENGTH> sha256(const string &string)
{
    SHA256_CTX ctx;
    SHA256_Init(&ctx);
    SHA224_Update(&ctx, string.data(), string.size());

    array<uint8_t, SHA256_DIGEST_LENGTH> hash;
    SHA256_Final(&hash[0], &ctx);

    return hash;
}

extern "C"
void Init_score_suffix()
{
    VALUE module = rb_define_module("NanoPay");
    VALUE score_suffix = rb_define_class_under(
        module,
        "ScoreSuffix",
        rb_cObject
    );

    rb_define_method(
        score_suffix,
        "initialize",
        reinterpret_cast<VALUE(*)(...)>(ScoreSuffix_initialize),
        2
    );

    rb_define_method(
        score_suffix,
        "value",
        reinterpret_cast<VALUE(*)(...)>(ScoreSuffix_value),
        0
    );
}