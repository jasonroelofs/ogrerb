#ifndef __CUSTOM_TO_RUBY_H__
#define __CUSTOM_TO_RUBY_H__

#include <rice/Object.hpp>
#include <rice/to_from_ruby.hpp>
#include "Ogre.h"

template<>
Rice::Object to_ruby<short unsigned int>(const short unsigned int& x);

template<>
Rice::Object to_ruby<Ogre::Root>(const Ogre::Root& r);

#endif
