#ifndef __CUSTOM_TO_RUBY_H__
#define __CUSTOM_TO_RUBY_H__

#include <rice/Object.hpp>
#include <rice/to_from_ruby.hpp>
#include <string>
#include "Ogre.h"

template<>
Rice::Object to_ruby<short unsigned int>(const short unsigned int& x);

template<>
std::string* from_ruby<std::string*>(Rice::Object x);

template<>
const std::string* from_ruby<const std::string*>(Rice::Object x);

/**
 * Ogre's Singleton classes, handle to_/from_ruby conversions
 */
template<>
Rice::Object to_ruby<Ogre::Root>(const Ogre::Root& r);

template<>
Rice::Object to_ruby<Ogre::ResourceGroupManager>(const Ogre::ResourceGroupManager& r);

template<>
Rice::Object to_ruby<Ogre::TextureManager>(const Ogre::TextureManager& r);

/**
 * End Singletons
 */


template<>
Rice::Object to_ruby<Ogre::ViewPoint >(Ogre::ViewPoint const & a);

template<>
Rice::Object to_ruby<Ogre::Degree >(Ogre::Degree const & a);

#endif
