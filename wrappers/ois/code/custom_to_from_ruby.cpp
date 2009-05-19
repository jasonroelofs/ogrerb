#include "custom_to_from_ruby.hpp"

template<>
Rice::Object to_ruby<short int>(short int const & a) {
  return INT2NUM(a);
}

template<>
Rice::Object to_ruby<OIS::Axis >(OIS::Axis const & a) {
	return Rice::Data_Object<OIS::Axis >((OIS::Axis *)&a, Rice::Data_Type<OIS::Axis >::klass(), 0, 0);
}

template<>
OIS::ParamList& from_ruby<OIS::ParamList&>(Rice::Object x) {
  // This has GOT to be a memory leak
  OIS::ParamList* list = new OIS::ParamList;
  Rice::Hash h(x);
  Rice::Hash::iterator it = h.begin();
  Rice::Hash::iterator end = h.end();
  std::string key;
  std::string val;

  for(; it != end; ++it) {
    key = from_ruby<std::string>(it->first);
    val = from_ruby<std::string>(it->second);

    list->insert(std::make_pair(key, val));
  }

  return *list;
}
