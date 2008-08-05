namespace :ois do

  desc "clean up ois" 
  task :clean do
    rm_rf File.join(OGRE_RB_ROOT, "lib", "ois")
    rm_rf File.join(OGRE_RB_ROOT, "tmp", "ois")
    rm_rf File.join(OGRE_RB_ROOT, "tmp", "downloads")
  end

  desc "bootstrap the required directory structure"
  task :bootstrap do
    begin
      mkdir File.join(OGRE_RB_ROOT, "tmp", "downloads")
      mkdir File.join(OGRE_RB_ROOT, "lib", "ois")
    rescue
      # already exist
    end
  end

  desc "setup ois for wrapping"
  task :setup => :bootstrap do
    DOWNLOAD = "ois_1.2.0.tar.gz"
    cd File.join(OGRE_RB_ROOT , "tmp", "downloads") do
      sh "wget http://downloads.sourceforge.net/wgois/#{DOWNLOAD}"
      cp DOWNLOAD, ".."
    end

    cd File.join(OGRE_RB_ROOT, "tmp") do
      sh "tar xzvf #{DOWNLOAD}"
    end

    cd File.join(OGRE_RB_ROOT, "tmp", "ois") do
      sh "./bootstrap"
      sh "./configure --prefix=#{File.join(OGRE_RB_ROOT, "lib", "ois")}"
      sh "make"
      sh "make install"
    end
  end
end
