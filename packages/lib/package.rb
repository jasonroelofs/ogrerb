require 'platform'

#
# Ogre.rb wrapper definition helper system
# This provides a rake-ish DSL for defining how to
# setup and build a library to be ready for wrapping
#
class Package
  attr_accessor :download_to, :download, :unpack, :unpack_to, :build_block, :patches

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

  def copy_over(file)
    full = ogrerb_path("wrappers", @name, file)
    cp full, "."
  end

end

# Handles figuring out environment and platform variables
class Opts
  attr_accessor :prefix

  def initialize(opts = {})
    @prefix = opts.delete(:prefix)
    @build_block = opts.delete(:build)

    @build_block.call(self)
  end

  def build
    if Platform.mac?
      @mac_build.call
    elsif Platform.windows?
      @windows_build.call
    else
      @linux_build.call
    end
  end

  ##
  # Mac specific helpers
  ##

  SDK_BASE = "/Developer/SDKs"

  # Find out what the latest SDK is sitting in
  # /Developer/SDKs and return the full path to it
  def latest_sdk
    Dir["#{SDK_BASE}/MacOSX*.sdk"].sort.last
  end

  ##
  # *Nix specific helpers
  ##

  ##
  # Windows specific helpers
  ##

  ##
  # The following define build block steps for the
  # appropriate platform
  ##

  def mac(&block)
    @mac_build = block
  end

  def linux(&block)
    @linux_build = block
  end

  def windows(&block)
    @windows_build = block
  end
end


def ogrerb_path(*args)
  File.join(OGRE_RB_ROOT, *args)
end

def package(lib)
  library = lib.to_s

  namespace library do
    package = Package.new(library)
    yield package

    desc "Clean up #{library}"
    task :clean do
      rm_rf ogrerb_path("tmp", library)
      rm_f ogrerb_path("tmp", "downloads", "#{package.download_to}")
    end

    desc "Download, build, and install the #{library} library. Installs into #{OGRE_RB_ROOT}/lib/usr"
    task :setup => "ogrerb:bootstrap" do
      cd ogrerb_path("tmp") do

        # Download
        cd "downloads" do
          unless File.exists?(package.download_to)
            sh "wget #{package.download}"
          end
        end

        # Unpack
        sh "#{package.unpack} downloads/#{package.download_to}"

        cd package.unpack_to do
          # Patch / Build / install
          package.process_patches if package.patches
          Opts.new(
            :prefix => ogrerb_path("lib", "usr"),
            :build => package.build_block
          ).build
        end
      end
    end

    desc "Generate, compile, and install the #{library} wrapper. Pass CLEAN=1 to force a complete rebuild"
    task :wrap do
      ruby "#{ogrerb_path("wrappers", library, "build_#{library}.rb")} #{ENV["CLEAN"] ? "--clean" : ""}"
    end
  end
end
