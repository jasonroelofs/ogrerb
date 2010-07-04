##
# OIS 1.2.0
##
package :ois do |ois|
  OIS_VERSION = "ois_1.2.0"
  OIS_DOWNLOAD = "#{OIS_VERSION}.tar.gz" 

  ois.download = "http://downloads.sourceforge.net/wgois/#{OIS_DOWNLOAD}"
  ois.download_to = OIS_DOWNLOAD

  ois.unpack = "tar xzvf"
  ois.unpack_to = "ois"

  ois.build do |opts|
    opts.mac do
      sh "xcodebuild -project Mac/XCode-2.2/OIS.xcodeproj -configuration Release -sdk #{opts.latest_sdk}"
      sh "cp -r Mac/XCode-2.2/build/Release/OIS.Framework ~/Library/Frameworks "
    end

    opts.linux do
      sh "./bootstrap"
      sh "./configure --prefix=#{opts.prefix}"
      sh "make"
      sh "make install"
    end

    opts.windows do
      sh "./bootstrap"
      sh "./configure --prefix=#{opts.prefix}"
      sh "make"
      sh "make install"
    end
  end
end
