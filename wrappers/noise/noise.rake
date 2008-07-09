namespace :noise do

  desc "clean up libnoise" 
  task :clean do
    rm_rf File.join(OGRE_RB_ROOT, "lib", "noise")
    rm_rf File.join(OGRE_RB_ROOT, "tmp", "noise")
    rm_rf File.join(OGRE_RB_ROOT, "tmp", "downloads")
  end

  desc "bootstrap the required directory structure"
  task :bootstrap do
    begin
      mkdir File.join(OGRE_RB_ROOT, "tmp", "downloads")
      mkdir File.join(OGRE_RB_ROOT, "lib", "noise")
    rescue
      # already exist
    end
  end

  desc "setup libnoise for wrapping"
  task :setup => :bootstrap do
    cd File.join(OGRE_RB_ROOT , "tmp", "downloads") do
      sh "wget http://prdownloads.sourceforge.net/libnoise/libnoisesrc-1.0.0.zip?download"
      cp "libnoisesrc-1.0.0.zip", ".."
    end

    cd File.join(OGRE_RB_ROOT, "tmp") do
      sh "unzip libnoisesrc-1.0.0.zip"
    end

    cd File.join(OGRE_RB_ROOT, "tmp", "noise") do
      sh "CXXFLAGS='-O2 -fomit-frame-pointer' make clean all"
      cp Dir["lib/libnoise.so*"], File.join(OGRE_RB_ROOT, "lib", "noise")
      cp "lib/libnoise.so.0.3", File.join(OGRE_RB_ROOT, "lib", "noise", "libnoise.so")
      cp "lib/libnoise.so.0.3", File.join(OGRE_RB_ROOT, "lib", "noise", "libnoise.so.0")
    end
  end
end
