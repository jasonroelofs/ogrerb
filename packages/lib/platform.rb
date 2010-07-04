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
