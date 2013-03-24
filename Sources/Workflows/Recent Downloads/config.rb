require 'yaml'

module RDW
  def RDW.directory?(path, base = "")
    File.directory?(File.expand_path path, base) &&
    !RDW.hidden?(path) &&
    ![".app", ".lpdf", ".mpkg", ".prefpane"].include?(File.extname(path).downcase)
  end

  def RDW.hidden?(path)
    File.basename(path).start_with?(".")
  end
  
  def RDW.entries(path, base = "")
    Dir.entries(File.expand_path path, base).delete_if {|f| RDW.hidden? f}
  end
  
  class Config
    BUNDLE_ID       = "recentdownloads.ddjfreedom"
    VOLATILE_DIR    = File.expand_path BUNDLE_ID, "~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/"
    NONVOLATILE_DIR = File.expand_path BUNDLE_ID, "~/Library/Application Support/Alfred 2/Workflow Data/"
    Dir.mkdir VOLATILE_DIR unless File.exist? VOLATILE_DIR
    Dir.mkdir NONVOLATILE_DIR unless File.exist? NONVOLATILE_DIR

    attr_reader :base_dir, :config_file_path

    def initialize
      @config_file_path = File.expand_path "config.yaml", NONVOLATILE_DIR
      @base_dir = File.expand_path "~/Downloads"
      if File.exist? @config_file_path
        @config = File.open(@config_file_path, "r") {|f| YAML.load f}
      else
        @config = {"install_action" => "open",
                   "auto_start"     => "never",
                   "subfolders"     => :none}
        self.commit
      end
      self.standardize
    end

    def [](key)
      @config[key]
    end

    def method_missing(sym, *arg)
      @config[sym.to_s]
    end

    def commit
      File.open(@config_file_path, "w") {|f| YAML.dump @config, f}
    end

    def standardize
      @config["subfolders"] ||= :none
      @config["subfolders"] = [@config["subfolders"]] unless @config["subfolders"].is_a? Array

      i = 0
      while i < @config["subfolders"].count
        entry = @config["subfolders"][i]
        hash = entry.is_a?(Hash) ? entry : {"folder" => entry}

        hash["exclude"] = false unless hash["exclude"] == true
        hash["depth"] ||= 1
        if hash["folder"] == :all
          dirs = RDW.entries(@base_dir).delete_if do |f|
            !RDW.directory? f, @base_dir
          end
          dirs.map! do |f|
            {"folder"  => f,
             "depth"   => hash["depth"],
             "exclude" => hash["exclude"]}
          end
          @config["subfolders"] = dirs
          break
        elsif hash["folder"] == :none
          @config["subfolders"] = []
          break
        end
        hash["folder"] = hash["folder"]

        @config["subfolders"][i] = hash
        i += 1
      end
    end
  end
end
