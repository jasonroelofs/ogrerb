#ifndef __CUSTOM_TO_RUBY_H__
#define __CUSTOM_TO_RUBY_H__

#include <rice/Object.hpp>
#include <rice/Hash.hpp>
#include <rice/to_from_ruby.hpp>
#include "OIS.h"

template<>
Rice::Object to_ruby<short int>(short int const & a);

template<>
OIS::ParamList& from_ruby<OIS::ParamList&>(Rice::Object x);

#endif
