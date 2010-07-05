package :ogre_dependencies do |ogre_deps|
  DEPS_VERSION = "OgreDependencies_OSX_20091230"
  FILE_NAME = "#{DEPS_VERSION}.zip"

  ogre_deps.download = "http://downloads.sourceforge.net/project/ogre/ogre-dependencies-mac/1.7/#{FILE_NAME}?use_mirror=surfnet"
  ogre_deps.download_to = FILE_NAME

  ogre_deps.unpack = "unzip -o"
  ogre_deps.unpack_to = DEPS_VERSION

  # We don't wrap this package
  ogre_deps.wrapper = false

  # No build step
end
