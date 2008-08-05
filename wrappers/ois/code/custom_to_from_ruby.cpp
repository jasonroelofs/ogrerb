#include "custom_to_from_ruby.hpp"

template<>
Rice::Object to_ruby<short int>(short int const & a) {
  return INT2NUM(a);
}
