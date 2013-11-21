# encoding: utf-8
def version_to_number(version) ; return version.split('.').map { |i| i.rjust(3, '0') }.join.to_i ; end
def load_and_install_local_gem(gem_name) ; load_gem gem_name, Dir[File.join(File.dirname(__FILE__), 'gem-cache', "#{gem_name}*.gem")].first, false ; end
def load_and_install_remote_gem(gem_name) ; load_gem gem_name, gem_name, true ; end
def load_gem(gem_name, gem_to_install, remote)
  begin
    gem gem_name
  rescue Gem::LoadError
    write_status({ :installing => true }) if remote

    begin
      unless remote
        with_captured_output(Proc.new { Gem::GemRunner.new.run ['install', gem_to_install, '--no-ri', '--no-rdoc'] })
      else
        with_redirected_output('install_local.txt') do
          Gem::GemRunner.new.run ['install', gem_to_install, '--no-ri', '--no-rdoc']
        end
      end

      Gem.clear_paths

      @installed = true
    rescue Gem::SystemExitException => e
      "Exited: #{e.exit_code}"
    end

    write_status({ :installing => false }) if remote
  end
end
def update_remote_gem(gem_name)
  begin
    with_redirected_output('update_gem.txt') do
      Gem::GemRunner.new.run ['update', gem_name, '--no-ri', '--no-rdoc']
    end

    output = get_redirected_output('update_gem.txt')

    if output =~ /successfully installed #{gem_name}-(\d+(?:\.\d+)*)/im
      return $1
    else
      return false
    end
  ensure
    delete_redirected_output('update_gem.txt')
  end
end

def check_prerequisites
  raise 'FFMPEG not found. Please install it.' unless !(`which ffmpeg` || '').empty? || File.exists?("/usr/local/bin/ffmpeg")
  raise 'RVM not found. Please install it.' unless !(`which rvm` || '').empty? || (File.exists?("/usr/local/rvm") || File.exists?(File.expand_path('~/.rvm')))
end

def delete_redirected_output(file_name) ; File.unlink(File.join(cache_dir, file_name)) if File.exists?(File.join(cache_dir, file_name)) ; end
def get_redirected_output(file_name) ; File.read(File.join(cache_dir, file_name)) ; end
def with_redirected_output(file_name)
  redirect_output(File.open(File.join(cache_dir, file_name), 'w+')) { yield if block_given? }
end

def redirect_output(stream)
  orig_std_out = STDOUT.clone
  begin
    STDOUT.reopen(stream)
    yield if block_given?
  rescue => e
    begin
      puts "---| ERROR |---"
      puts "--- #{e.message}"
      e.backtrace.each { |l| puts "- #{l}" }
    rescue
    end
  ensure
    STDOUT.reopen(orig_std_out)
  end
end

def with_captured_output(process)
  return_value = nil
  reader, writer = IO.pipe
  internal_reader, internal_writer = IO.pipe

  fork do
    reader.close
    internal_reader.close

    redirect_output(writer) do
      return_value = process.call
      internal_writer.write return_value
      internal_writer.close
    end
  end

  writer.close
  internal_writer.close

  while message = reader.gets(100)
    begin
      yield message if block_given?
    rescue Interrupt
      clear_status
      raise
    end
  end

  internal_reader.read
end

def write_status(status)
  write_to_file 'status.yml', status.to_yaml
end

def read_status
  YAML.load(read_from_file('status.yml')) rescue { :in_progress => false }
end

def clear_status
  delete_file 'status.yml'
end

def cleanup
  Dir[File.join(cache_dir, '*ffmpeg*')].each { |f| File.delete(f) }
  clear_status
end

def cache_dir ; @cache_dir ||= Alfred::Core.new.volatile_storage_path ; end

def write_to_file(file, text, append = false) ; File.open(File.join(cache_dir, file), append ? 'a+' : 'w') { |f| f.puts text.to_s } ; end
def read_from_file(file) ; File.read(File.join(cache_dir, file)) ; end
def delete_file(file) ; File.delete(File.join(cache_dir, file)) if File.exists?(File.join(cache_dir, file)) ; end