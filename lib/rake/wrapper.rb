#
# Ogre.rb wrapper definition helper system
# This provides a rake-ish DSL for defining how to
# setup and build a library to be ready for wrapping
#
class Wrapper
  attr_accessor :download_from, :download, :unpack, :build_block, :patches

  def initialize(name)
    @name = name
  end

  def build(&block)
    @build_block = block
  end
  
  def patch(*patches)
    @patches = patches
  end

  def process_patches
    patch_dir = ogrerb_path("wrappers", @name, "patch")
    patches.each do |patch|
      patch_file = "#{patch_dir}/#{patch}.patch"
      raise "Could not find file #{patch_file}" unless File.exists?(patch_file)
      puts "Patching #{@name} with #{patch_file}"
      sh "patch -s -N -i #{patch_file} -p0"
    end
  end
end

def ogrerb_path(*args)
  File.join(OGRE_RB_ROOT, *args)
end

def wrapper(lib)
  library = lib.to_s

  namespace library do
    wrapper = Wrapper.new(library)
    yield wrapper

    desc "Clean up #{library}"
    task :clean do
      rm_rf ogrerb_path("tmp", library)
      rm_rf ogrerb_path("tmp", "downloads", wrapper.download)
    end

    desc "Download, build, and install the #{library} library. Installs into #{OGRE_RB_ROOT}/lib/usr"
    task :setup => "ogrerb:bootstrap" do
      cd ogrerb_path("tmp") do

        # Download
        cd "downloads" do
          sh "wget #{wrapper.download_from}/#{wrapper.download}"
        end

        # Unpack
        sh "#{wrapper.unpack} downloads/#{wrapper.download}"

        # Patch / Build / install
        cd library do
          wrapper.process_patches if wrapper.patches
          wrapper.build_block.call(ogrerb_path("lib", "usr"))
        end
      end
    end

    desc "Generate, compile, and install the #{library} wrapper"
    task :build do
      ruby ogrerb_path("wrappers", library, "build_#{library}.rb") 
    end
  end
end
