wrapper :ois do |ois|
  ois.download_from = "http://downloads.sourceforge.net/wgois"
  ois.download = "ois_1.2.0.tar.gz" 
  ois.unpack = "tar xzvf"
  ois.build do |opts|
    opts.mac do
      sh "xcodebuild -project Mac/XCode-2.2/OIS.xcodeproj -configuration Release -sdk #{opts.latest_sdk}"
      sh "cp -R Mac/XCode-2.2/build/Release/OIS.Framework ~/Library/Frameworks "
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
