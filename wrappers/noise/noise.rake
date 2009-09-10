wrapper :noise do |noise|
  noise.download_from = "http://prdownloads.sourceforge.net/libnoise"
  noise.download  = "libnoisesrc-1.0.0.zip"
  noise.unpack = "unzip"
  noise.patch "noise_makefile"

  noise.build do |prefix|
    sh "CXXFLAGS='-O2 -fomit-frame-pointer' make all"

    # Manual install
    cp "lib/libnoise.so.0.3", File.join(prefix, "lib")
    cp "lib/libnoise.a", File.join(prefix, "lib")
    cp "lib/libnoise.la", File.join(prefix, "lib")
  end
end
