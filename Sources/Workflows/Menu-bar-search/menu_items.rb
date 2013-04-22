# encoding: UTF-8
require 'yaml'
require 'pp'
load 'alfred_feedback.rb'

module MenuItems

  def self.gather_leaves(menu_items)
    leaves = []
    menu_items.each do |menu_item|
      locator = menu_item['locator']
      children = menu_item['children']
      if children
        leaves += gather_leaves(menu_item['children'])
      else
        if locator && locator.length > 0
          leaves << menu_item
        end
      end
    end
    leaves
  end

  def generate_items()
    menu_yaml = `./menudump --yaml`
    if $? == 0
      menu_items = YAML.load(menu_yaml)

      menu_leaves = gather_leaves(menu_items['menus'])

      items = []
      menu_leaves.each do |menu_item|
        items << {:name => menu_item['name'],
          :shortcut => menu_item['shortcut'],
          :line => menu_item['locator'],
          :path => menu_item['menuPath']
        }
      end
      app_info = menu_items['application']
      {:menus => items, :application => app_info['name'], :application_location => app_info['bundlePath']}
    else
      parts = menu_yaml.split(/\. /)
      {:menus => [{:name => "Error: #{parts[0]}", :shortcut => "", :line => "", :path => parts[1]}], :application => 'Error', :application_location => 'Error'}
    end
  end

  def generate_xml(search_term, items)
    application = items[:application]
    application_location = items[:application_location]
    found_items = items[:menus]
    if search_term.length > 0
      found_items = found_items.find_all { |item| "#{item[:path]} > #{item[:name]}" =~ /#{search_term}/i }
    end

    feedback = Feedback.new
    found_items.each do |item|
      icon = {:type => "fileicon", :name => application_location}
      name = item[:name]
      feedback.add_item({:title => name, :arg => item[:line], :uid => "#{application}: #{item[:path]} > #{item[:name]}", :subtitle => "#{application}: #{item[:path]}", :icon => icon})
    end

    feedback.to_xml
  end

  module_function :generate_xml
  module_function :generate_items
end

