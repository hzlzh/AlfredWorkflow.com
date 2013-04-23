VMWARE_INSTALL_PATH = "/Applications/VMware\ Fusion.app"
VMRUN_PATH = "#{VMWARE_INSTALL_PATH}/Contents/Library/vmrun"
USER_INVENTORY_PATH = "~/Library/Application\ Support/VMware\ Fusion/vmInventory"
SHARED_INVENTORY_PATH = "/Library/Application\ Support/VMware/VMware\ Fusion/Shared/vmInventory"

class VMConfig
  attr_accessor :path, :name, :status, :ip_address, :os, :icon

  def initialize
    @status = "Stopped"
    @icon = "icon.png"
  end

  def running?
    @status != "Stopped"
  end
end

class VMWare
	def run(cmd)
	  exec(%Q{"#{VMRUN_PATH}" #{cmd}})
	end

	def list
	  add_info(update_status(inventory_list))
	end

private
	def ip_address(vm_path)
	  `"#{VMRUN_PATH}" readVariable "#{vm_path}" guestVar ip`.strip
	end

	def inventory_list
	  inventory_path = File.expand_path(USER_INVENTORY_PATH)
	  unless File.exists?(inventory_path)
	    inventory_path = File.expand_path(SHARED_INVENTORY_PATH)
	  end
	  inventory = File.open(inventory_path)

	  vmlist = {}
	  inventory.each_line do |line|
	    parts = line.split("=")
	    if parts.length == 2
	      lhs = parts[0].strip
	      rhs = parts[1].strip
	      tokens = lhs.split(".")
	      if tokens.length == 2 && tokens[0].length > 0
	        id = tokens[0].strip
	        param = tokens[1].strip
	        vm = vmlist[id]
	        if vm.nil?
	          vm = VMConfig.new
	          vmlist[id] = vm
	        end
	        if param == "config"
	          vm.path = remove_quotations(rhs).strip
	        elsif param == "DisplayName"
	          vm.name = remove_quotations(rhs).strip
	        end
	      end
	    end
	  end
	  vmlist.values.find_all {|item| item.path.length > 0}
	end

	def update_status(inventory)
	  results = `"#{VMRUN_PATH}" list`

	  results.each_line do |line|
	    line = line.strip
	    unless line.start_with?("Total running VMs")
	      vmconfig = inventory.find do |item|
	        item.path == line
	      end
	      if vmconfig
	        vmconfig.status = "Running"
	      end
	    end
	  end
	  inventory
	end

	def icon_name(os)
		osname = os.downcase
		icon_name = "icon.png"
		if osname =~ /.*debian.*/
			icon_name = "debian.png"
		elsif osname =~ /.*fedora.*/
			icon_name = "fedora.png"
		elsif osname =~ /.*freebsd.*/
			icon_name = "freebsd.png"
		elsif osname =~ /.*netbsd.*/
			icon_name = "netbsd.png"
		elsif osname =~ /.*openbsd.*/
			icon_name = "openbsd.png"
		elsif osname =~ /.*osx.*/
			icon_name = "osx.png"
		elsif osname =~ /.*os\/x.*/
			icon_name = "osx.png"
		elsif osname =~ /.*mac.*/
			icon_name = "osx.png"
		elsif osname =~ /.*redhat.*/
			icon_name = "redhat.png"
		elsif osname =~ /.*suse.*/
			icon_name = "suse.png"
		elsif osname =~ /.*ubuntu.*/
			icon_name = "ubuntu.png"
		elsif osname =~ /.*win.*/
			icon_name = "windows.png"
		elsif osname =~ /.*bsd.*/
			icon_name = "freebsd.png"
		end
		icon_name
	end

	def add_info(inventory)
		inventory.each do |vmconfig|
			if vmconfig.running?
				vmconfig.ip_address = ip_address(vmconfig.path)
			end
			guestOS = runtimeConfig(vmconfig.path, 'guestOS')
			if !guestOS.nil?
				vmconfig.os = guestOS
				vmconfig.icon = icon_name(vmconfig.os)
			end
		end
		inventory
	end

	def runtimeConfig(path, var)
		if File.exists?(path) 
			contents = File.open(path, "rb").each_line do |line|
				parts = line.split("=")
				if parts.length == 2
				  lhs = parts[0].strip
				  rhs = parts[1].strip
				  if lhs == var
				  	return remove_quotations(rhs)
				  end
				end
			end
		end
		nil
	end

	def remove_quotations(str)
	  if str.start_with?('"')
	    str = str.slice(1..-1)
	  end
	  if str.end_with?('"')
	    str = str.slice(0..-2)
	  end
	  str
	end
end
