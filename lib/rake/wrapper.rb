class Platform
  def self.mac?
    RUBY_PLATFORM =~ /darwin/
  end

  def self.linux?
    !self.mac? && !self.windows?
  end

  def self.windows?
    RUBY_PLATFORM =~ /(mswin|cygwin)/
  end
end

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
    Dir["#{SDK_BASE}/*.sdk"].sort.last
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

def wrapper(lib)
  library = lib.to_s

  namespace library do
    wrapper = Wrapper.new(library)
    yield wrapper

    desc "Clean up #{library}"
    task :clean do
      rm_rf ogrerb_path("tmp", library)
      rm ogrerb_path("tmp", "downloads", "#{library}*")
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
          Opts.new(
            :prefix => ogrerb_path("lib", "usr"),
            :build => wrapper.build_block
          ).build
        end
      end
    end

    desc "Generate, compile, and install the #{library} wrapper. Pass CLEAN=1 to force a complete rebuild"
    task :build do
      ruby "#{ogrerb_path("wrappers", library, "build_#{library}.rb")} #{ENV["CLEAN"] ? "--clean" : ""}"
    end
  end
end
