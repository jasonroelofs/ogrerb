package :ogre => [:ogre_dependencies] do |ogre|
  OGRE_VERSION = "ogre_src_v1-7-1"
  OGRE_DOWNLOAD = "#{OGRE_VERSION}.tar.bz2"

  ogre.download = "http://downloads.sourceforge.net/project/ogre/ogre/1.7/ogre_src_v1-7-1.tar.bz2?use_mirror=cdnetworks-us-2"
  ogre.download_to = OGRE_DOWNLOAD

  ogre.unpack = "tar jxvf"
  ogre.unpack_to = OGRE_VERSION

  ogre.build do |opts|

    def build(generator, prefix)
      mkdir "build" unless File.directory?("build")
      cd "build" do
        sh "cmake #{generator} ../ -DOGRE_INSTALL_PLUGINS_HEADERS=TRUE -DOGRE_BUILD_SAMPLES=FALSE -DOGRE_INSTALL_SAMPLES=FALSE -DOGRE_INSTALL_SAMPLES_SOURCE=FALSE -DCMAKE_INSTALL_PREFIX:PATH=#{prefix}"
        yield
      end
    end

    opts.mac do 
      deps = Packages.find(:ogre_dependencies)
      sh "cp -rf #{deps.build_dir}/Dependencies ../"

      build("-G Xcode", opts.prefix) do
        sh "xcodebuild"
        sh "xcodebuild -target install"
      end
    end

    opts.linux do
      build("", opts.prefix) do
        sh "make install"
      end
    end

    opts.windows do
      build("", opts.prefix) do
        sh "make install"
      end
    end

  end
end
