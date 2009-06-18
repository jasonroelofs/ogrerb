wrapper :ogre do |ogre|
  OGRE_VERSION = "ogre-v1-6-2"
  OGRE_DOWNLOAD = "#{OGRE_VERSION}.tar.bz2"

  ogre.download_from = "http://downloads.sourceforge.net/ogre"
  ogre.download = OGRE_DOWNLOAD
  ogre.unpack = "tar jxvf"

  ogre.patch OGRE_VERSION

  ogre.build do |prefix|
    sh "./configure --prefix=#{prefix}"
    sh "make"
    sh "make install"
  end
end
