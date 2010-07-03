wrapper :ois do |ois|
  OIS_DOWNLOAD = "ois_1.2.0.tar.gz" 
  ois.download_from = "http://downloads.sourceforge.net/wgois/#{OIS_DOWNLOAD}"
  ois.download = OIS_DOWNLOAD
  ois.unpack = "tar xzvf"
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
