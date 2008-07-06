#include "custom_to_ruby.hpp"

template<>
std::string* from_ruby<std::string*>(Rice::Object x) {
  return new std::string(from_ruby<char const*>(x));
}
