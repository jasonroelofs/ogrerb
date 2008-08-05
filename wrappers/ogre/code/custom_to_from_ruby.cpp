#include "custom_to_from_ruby.hpp"

template<>
Rice::Object to_ruby<short unsigned int>(const short unsigned int& x) {
  return Rice::Object(INT2NUM(x));
}

/*
template<>
std::string* from_ruby<std::string*>(Rice::Object x) {
  return new std::string(from_ruby<char const*>(x));
}

template<>
const std::string* from_ruby<const std::string*>(Rice::Object x) {
  return new std::string(from_ruby<char const*>(x));
}
*/
