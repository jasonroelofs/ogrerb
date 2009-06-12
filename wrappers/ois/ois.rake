wrapper :ois do |ois|
  ois.download_from = "http://downloads.sourceforge.net/wgois"
  ois.download = "ois_1.2.0.tar.gz" 
  ois.unpack = "tar xzvf"
  ois.build do |prefix|
    sh "./bootstrap"
    sh "./configure --prefix=#{prefix}"
    sh "make"
    sh "make install"
  end
end
