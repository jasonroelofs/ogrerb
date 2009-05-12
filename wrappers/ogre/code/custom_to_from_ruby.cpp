#include "custom_to_from_ruby.hpp"

template<>
Rice::Object to_ruby<short unsigned int>(const short unsigned int& x) {
  return Rice::Object(INT2NUM(x));
}

template<>
std::string* from_ruby<std::string*>(Rice::Object x) {
  return new std::string(from_ruby<char const*>(x));
}

template<>
const std::string* from_ruby<const std::string*>(Rice::Object x) {
  return new std::string(from_ruby<char const*>(x));
}

/**
 * Ogre's Singleton classes, handle to_/from_ruby conversions
 */

template<>
Rice::Object to_ruby<Ogre::Root>(const Ogre::Root& r) {
  return Rice::Data_Object<Ogre::Root>(Ogre::Root::getSingletonPtr(), Rice::Data_Type<Ogre::Root>::klass(), 0, 0); 
}

template<>
Rice::Object to_ruby<Ogre::ResourceGroupManager>(const Ogre::ResourceGroupManager& r) {
  return Rice::Data_Object<Ogre::ResourceGroupManager>(Ogre::ResourceGroupManager::getSingletonPtr(), Rice::Data_Type<Ogre::ResourceGroupManager>::klass(), 0, 0); 
}

template<>
Rice::Object to_ruby<Ogre::TextureManager>(const Ogre::TextureManager& r) {
  return Rice::Data_Object<Ogre::TextureManager>(Ogre::TextureManager::getSingletonPtr(), Rice::Data_Type<Ogre::TextureManager>::klass(), 0, 0); 
}

/**
 * End Singletons
 */


template<>
Rice::Object to_ruby<Ogre::ViewPoint >(Ogre::ViewPoint const & a) {
	return Rice::Data_Object<Ogre::ViewPoint >((Ogre::ViewPoint *)&a, Rice::Data_Type<Ogre::ViewPoint >::klass(), 0, 0);
}

template<>
Rice::Object to_ruby<Ogre::Degree >(Ogre::Degree const & a) {
	return Rice::Data_Object<Ogre::Degree >((Ogre::Degree *)&a, Rice::Data_Type<Ogre::Degree >::klass(), 0, 0);
}

