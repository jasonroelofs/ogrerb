#ifndef __CUSTOM_TO_RUBY_H__
#define __CUSTOM_TO_RUBY_H__

#include <rice/Object.hpp>
#include <rice/String.hpp>
#include <rice/to_from_ruby.hpp>
#include <string>

template<>
std::string* from_ruby<std::string*>(Rice::Object x);

#endif
