namespace :noise do

  desc "clean up libnoise" 
  task :clean do
    rm_rf File.join(OGRE_RB_ROOT, "lib", "noise")
    rm_rf File.join(OGRE_RB_ROOT, "tmp", "noise")
    sh "rm -f #{File.join(OGRE_RB_ROOT, "tmp", "downloads", "libnoise*")}"
    sh "rm -f #{File.join(OGRE_RB_ROOT, "tmp", "libnoise*")}"
    rm_rf File.join(OGRE_RB_ROOT, "tmp", "COPYING.txt")
  end

  desc "bootstrap the required directory structure"
  task :bootstrap => :clean do
    mkdir_p File.join(OGRE_RB_ROOT, "tmp", "downloads")
    mkdir_p File.join(OGRE_RB_ROOT, "lib", "noise")
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
      sh "CXXFLAGS='-O2 -fomit-frame-pointer' make all"
      cp Dir["lib/libnoise.so*"], File.join(OGRE_RB_ROOT, "lib", "noise")
      cp "lib/libnoise.so.0.3", File.join(OGRE_RB_ROOT, "lib", "noise", "libnoise.so")
      cp "lib/libnoise.so.0.3", File.join(OGRE_RB_ROOT, "lib", "noise", "libnoise.so.0")
    end
  end
end
