namespace :noise do

  desc "setup libnoise for wrapping"
  task :setup do
    PMS::vendor do
      working_directory(OGRE_RB_ROOT / "tmp" / "noise")
      download "http://prdownloads.sourceforge.net/libnoise/libnoisesrc-1.0.0.zip?download"
      extract
      build "make"
    end
  end

end
