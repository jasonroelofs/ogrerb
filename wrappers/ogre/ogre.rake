wrapper :ogre do |ogre|
  OGRE_VERSION = "ogre-v1-7-1"
  OGRE_DOWNLOAD = "#{OGRE_VERSION}.tar.bz2"

  ogre.download_from = "http://downloads.sourceforge.net/ogre"
  ogre.download = OGRE_DOWNLOAD
  ogre.unpack = "tar jxvf"

  ogre.patch OGRE_VERSION

  ogre.build do |prefix|
    sh "mkdir build"
    cd "build" do
      # -DCMAKE_INSTALL_PREFIX:PATH=
      generator = PLATFORM =~ /darwin/ ? "-G Xcode" : ""
      sh "cmake #{generator} ../"

      if PLATFORM =~ /darwin/
        sh "cmakexbuild"
      else
        sh "make"
        sh "make install"
      end
    end
  end
end
