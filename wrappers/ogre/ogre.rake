wrapper :ogre do |ogre|
  OGRE_VERSION = "ogre_src_v1-7-1"
  OGRE_DOWNLOAD = "#{OGRE_VERSION}.tar.bz2"

  ogre.download_from = "http://downloads.sourceforge.net/project/ogre/ogre/1.7/ogre_src_v1-7-1.tar.bz2?use_mirror=cdnetworks-us-2"
  ogre.download = OGRE_DOWNLOAD
  ogre.unpack = "tar jxvf"

  ogre.build do |prefix|
    mkdir "build" unless File.directory?("build")
    cd "build" do
      # -DCMAKE_INSTALL_PREFIX:PATH=
      generator = PLATFORM =~ /darwin/ ? "-G Xcode" : ""
      use_prefix = PLATFORM =~ /darwin/ ? "~/Library/Frameworks" : prefix
      sh "cmake #{generator} ../#{OGRE_VERSION} -DOGRE_INSTALL_PLUGINS_HEADERS=TRUE -DCMAKE_INSTALL_PREFIX:PATH=#{use_prefix}"

      if PLATFORM =~ /darwin/
        sh "xcodebuild"
      else
        sh "make"
        sh "make install"
      end
    end
  end
end
