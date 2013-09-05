class Hatmaker::Alfred::YamlEnd
  def initialize(content, file_path)
    @content   = content
    @file_path = file_path
  end

  def self.load(file_path)
    content = YAML::load(File.read file_path) rescue {}
    new content, file_path
  end

  def [](key)
    @content[key]
  end

  def []=(key, value)
    @content[key] = value
    dump
  end

  def dump(opts = {})
    File.open(@file_path, 'wb') do |file|
      YAML::dump(@content, file)
      file.flush if opts[:flush]
    end
  end
end
