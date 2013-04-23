# encoding: UTF-8
require "cgi"
require "digest/md5"
load "alfred_feedback.rb"
load "vmware.rb"

@vmware = VMWare.new

def generate
  items = Feedback.new
  vmlist = @vmware.list
  vmlist.each do |vm|
    yield items, vm
  end
  if items.items.length == 0
    items.add_item({:uid => "novm", :arg => "list", :title => "No VM found", :subtitle => "No matching VM available"})
  end
  items.to_xml
end

def list
  generate { |items, vm|
    items.add_item({:uid => vm.path, :arg => "#{vm.name}|||#{vm.path}", :title => "#{vm.name} (#{vm.status})", :subtitle => "Action to copy path or press ⌘ to select window. #{vm.path}", :icon => {:name => vm.icon}})
  }
end

def switch
  generate { |items, vm|
    if vm.running?
      items.add_item({:uid => vm.path, :arg => "#{vm.name}|||#{vm.path}", :title => "#{vm.name} (#{vm.status})", :subtitle => vm.path, :icon => {:name => vm.icon}})
    end
  }
end

def ip
  generate { |items, vm|
    if vm.running?
      items.add_item({:uid => vm.path, :arg => vm.ip_address, :title => "#{vm.ip_address} - #{vm.name}", :subtitle => vm.path, :icon => {:name => vm.icon}})
    end
  }
end

def start(arg)
  arg = arg.nil? ? "gui" : arg
  generate { |items, vm|
    unless vm.running?
      items.add_item({:uid => vm.path, :arg => "start \"#{vm.path}\" #{arg}", :title => "Start #{vm.name}", :subtitle => vm.path, :icon => {:name => vm.icon}})
    end
  }
end

def stop(arg)
  arg = arg.nil? ? "soft" : arg
  generate { |items, vm|
    if vm.running?
      items.add_item({:uid => vm.path, :arg => "stop \"#{vm.path}\" #{arg}", :title => "Stop #{vm.name}", :subtitle => vm.path, :icon => {:name => vm.icon}})
    end
  }
end

def reset(arg)
  arg = arg.nil? ? "soft" : arg
  generate { |items, vm|
    if vm.running?
      items.add_item({:uid => vm.path, :arg => "reset \"#{vm.path}\" #{arg}", :title => "Reset #{vm.name}", :subtitle => vm.path, :icon => {:name => vm.icon}})
    end
  }
end

def suspend(arg)
  arg = arg.nil? ? "soft" : arg
  generate { |items, vm|
    if vm.running?
      items.add_item({:uid => vm.path, :arg => "suspend \"#{vm.path}\" #{arg}", :title => "Suspend #{vm.name}", :subtitle => vm.path, :icon => {:name => vm.icon}})
    end
  }
end

def pause
  generate { |items, vm|
    if vm.running?
      items.add_item({:uid => vm.path, :arg => "pause \"#{vm.path}\"", :title => "Pause #{vm.name}", :subtitle => vm.path, :icon => {:name => vm.icon}})
    end
  }
end

def unpause
  generate { |items, vm|
    if vm.running?
      items.add_item({:uid => vm.path, :arg => "unpause \"#{vm.path}\"", :title => "Unpause #{vm.name}", :subtitle => vm.path, :icon => {:name => vm.icon}})
    end
  }
end

def snapshot(name)
  generate { |items, vm|
    if vm.running?
      items.add_item({:uid => vm.path, :arg => "snapshot \"#{vm.path}\" #{name}", :title => "Snapshot #{vm.name} as '#{name}'", :subtitle => vm.path, :icon => {:name => vm.icon}})
    end
  }
end

def revert(name)
  generate { |items, vm|
    if vm.running?
      items.add_item({:uid => vm.path, :arg => "revertToSnapshot \"#{vm.path}\" #{name}", :title => "Revert to snapshot for #{vm.name} from '#{name}'", :subtitle => vm.path, :icon => {:name => vm.icon}})
    end
  }
end

if ARGV.length > 0
  command = ARGV[0]
  param = nil
  if ARGV.length > 1
    param = ARGV[1]
  end
  case command
    when 'list' then
      puts list()
    when 'switch' then
      puts switch()
    when 'ip' then
      puts ip()
    when 'start' then
      puts start(param)
    when 'stop' then
      puts stop(param)
    when 'reset' then
      puts reset(param)
    when 'suspend' then
      puts suspend(param)
    when 'pause' then
      puts pause()
    when 'unpause' then
      puts unpause()
    when 'snapshot' then
      puts snapshot(param)
    when 'revert' then
      puts revert(param)
    when 'run' then
      puts @vmware.run(param)
    else
      puts list()
  end

end