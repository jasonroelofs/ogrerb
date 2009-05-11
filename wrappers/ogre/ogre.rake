namespace :ogre do

  OGRE_VERSION = "ogre-v1-6-2"
  OGRE_DOWNLOAD = "#{OGRE_VERSION}.tar.bz2"

  desc "clean up ogre libs" 
  task :clean do
    rm_rf File.join(OGRE_RB_ROOT, "lib", "ogre", "bin")
    rm_rf File.join(OGRE_RB_ROOT, "lib", "ogre", "include")
    rm_rf File.join(OGRE_RB_ROOT, "lib", "ogre", "lib")
    rm_rf File.join(OGRE_RB_ROOT, "tmp", "ogre")
    rm_rf File.join(OGRE_RB_ROOT, "tmp", "downloads", OGRE_DOWNLOAD)
    rm_rf File.join(OGRE_RB_ROOT, "tmp", OGRE_DOWNLOAD)
  end

  desc "bootstrap the required directory structure"
  task :bootstrap do
    mkdir_p File.join(OGRE_RB_ROOT, "tmp", "downloads")
    mkdir_p File.join(OGRE_RB_ROOT, "lib", "ogre")
  end

  desc "setup libnoise for wrapping"
  task :setup => :bootstrap do
    cd File.join(OGRE_RB_ROOT , "tmp", "downloads") do
      break if File.exists?(OGRE_DOWNLOAD)
      sh "wget http://downloads.sourceforge.net/ogre/#{OGRE_DOWNLOAD}"
      cp OGRE_DOWNLOAD, ".."
    end

    cd File.join(OGRE_RB_ROOT, "tmp") do
      system "tar jxvf #{OGRE_DOWNLOAD}"
    end

    cd File.join(OGRE_RB_ROOT, "tmp", "ogre") do
      install_to = File.join(OGRE_RB_ROOT, "lib", "ogre")
      cmd = "patch -s -N -i  #{File.join(OGRE_RB_ROOT, "wrappers", "ogre", "patch", OGRE_VERSION + ".patch")} -p0"
      puts "Patch command: #{cmd.inspect}"
      sh cmd
      sh "./configure --prefix=#{install_to} && make && make install"
    end
  end
end
