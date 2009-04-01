#include "custom_to_from_ruby.hpp"

template<>
Rice::Object to_ruby<short unsigned int>(const short unsigned int& x) {
  return Rice::Object(INT2NUM(x));
}
