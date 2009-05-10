namespace :ogre do

  OGRE_DOWNLOAD = "ogre-v1-6-2.tar.bz2"

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
      sh "wget http://downloads.sourceforge.net/ogre/#{OGRE_DOWNLOAD}"
      cp OGRE_DOWNLOAD, ".."
    end

    cd File.join(OGRE_RB_ROOT, "tmp") do
      sh "tar jxvf #{OGRE_DOWNLOAD}"
    end

    cd File.join(OGRE_RB_ROOT, "tmp", "ogre") do
      install_to = File.join(OGRE_RB_ROOT, "lib", "ogre")
      sh "./configure --prefix=#{install_to} && make && make install"
    end
  end
end
