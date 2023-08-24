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
#include <openssl/sha.h>
#include <ruby.h>
#include <ruby/thread.h>

using namespace std;

struct index_params 
{
	string prefix;
	int strength;
	string nonce;
	bool keep_going;
}; // index_params [struct]

/**
 * @param string 
 * @return array<uint8_t, SHA256_DIGEST_LENGTH> 
 */
static array<uint8_t, SHA256_DIGEST_LENGTH> sha256(const string &string)
{
	SHA256_CTX ctx;
	SHA256_Init(&ctx);
	SHA256_Update(&ctx, string.data(), string.size());
	array<uint8_t, SHA256_DIGEST_LENGTH> hash;
	SHA256_Final(&hash[0], &ctx);
	return hash;
}

/**
 * @param hash 
 * @param strength 
 * @return true 
 * @return false 
 */
static bool check_hash(const array<uint8_t, SHA256_DIGEST_LENGTH> &hash, int strength)
{
	int current_strength = 0;

	const auto rend = hash.rend();

	for (auto h = hash.rbegin(); h != rend; ++h) {
		if ((*h & 0x0f) != 0) {
			break;
		}
		current_strength += (*h == 0) ? 2 : 1;
		if (*h != 0) {
			break;
		}
	}

	return current_strength >= strength;
}

/**
 * @param i 
 * @return string 
 */
static string create_nonce(uint64_t i)
{
	const string chars =
		"0123456789"
		"abcdefghijklmnopqrstuvwxyz"
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ";

	string rv;

	for (int l = 0; l < 6; l++) {  
		rv += chars[i % chars.size()];
		if (i < chars.size()) {
			break;
		}
		i /= chars.size();
	}

	return {rv.rbegin(), rv.rend()};
}

/**
 * @param arg 
 * @return void* 
 */
static void *index(void *arg)
{
	index_params *params = static_cast<index_params *>(arg);

	mt19937_64 random(uint64_t(time(nullptr)));

	for (uint64_t i = random(); params->keep_going; i++) {
		const auto hash = sha256(params->prefix + " " + create_nonce(i));
		if (check_hash(hash, params->strength)) {
			params->nonce = create_nonce(i);
			break;
		}
	}

	return nullptr;
}

/**
 * @param arg 
 */
static void unblocking_func(void *arg)
{
	index_params *params = static_cast<index_params *>(arg);
	params->keep_going = false;
}

/**
 * @param self 
 * @param prefix 
 * @param strength 
 * @return VALUE 
 */
static VALUE ScoreSuffix_initialize(VALUE self, VALUE prefix, VALUE strength)
{
	rb_iv_set(self, "@prefix", prefix);
	rb_iv_set(self, "@strength", strength);
	return self;
}

/**
 * @param self 
 * @return VALUE 
 */
static VALUE ScoreSuffix_value(VALUE self)
{
	auto prefix_value = rb_iv_get(self, "@prefix");

	index_params params = {
		StringValuePtr(prefix_value),
		NUM2INT(rb_iv_get(self, "@strength")),
		"",
		true
	};

	rb_thread_call_without_gvl(index, &params, unblocking_func, &params);
	return rb_str_new2(params.nonce.c_str());
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