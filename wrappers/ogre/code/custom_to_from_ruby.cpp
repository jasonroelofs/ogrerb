#include "custom_to_from_ruby.hpp"

template<>
Rice::Object to_ruby<short unsigned int>(const short unsigned int& x) {
  return Rice::Object(INT2NUM(x));
}

template<>
Rice::Object to_ruby<Ogre::Root>(const Ogre::Root& r) {
  return Rice::Data_Object<Ogre::Root>(r.getSingletonPtr(), Rice::Data_Type<Ogre::Root>::klass(), 0, 0); 
}
