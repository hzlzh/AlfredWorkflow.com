# encoding: utf-8

require "open-uri"
require "google-search"
require "json"
load 'alfred_feedback.rb'

type = Alfred.query

feedback = Feedback.new

uri = ""
case type
#最新话题
when "t", "T" 
  uri = "http://ruby-china.org/api/topics.json"
  
  html_response = nil
  
  open(uri) do |http|
    html_response = http.read
  end
  
  html_response = JSON.parse(html_response)
  
  i = 0
  
  html_response.each do |result|
      feedback.add_item({ 
        :uid => result['id'], 
        :title => result['title'], 
        :subtitle => "#{result['node_name']} | by #{result['user']['login']} | #{result['replies_count']}条评论", 
        :arg => "http://ruby-china.org/topics/#{result['id']}", :icon => {:name => "topics.png"}
      })
  
      i = 1 + i
      break if i >= 10
  end

when "h", "H"
  #优质帖子
  uri = "http://ruby-china.org/topics/popular" 
  
  open(uri) do |f|
    s = ""
    f.each do |line|
      s << line 
    end

    #topics-related
    m = /href="(\/topics\/[0-9]\d*)"\stitle="(.+)"/
    topics = s.scan(m)
    
    #nodes-related
    n = /\/topics\/node[0-9]\d*">.+/
    nodes = s.scan(n)
    nodes.collect! do |node|
      node = node.match(/>.+</).to_s 
      l = node.size
      node.slice!(1, l-2) 
    end

    #authors-related
    a = /^.+data-name=.+/
    authors = s.scan(a) 
    authors.delete_if { |author| author.match(/最后由/)}
    authors.collect! do |author|
      author.split('/')[1].split('"')[0]
    end
    
    #comments-related
    c = /reply[0-9]\d*">[0-9]\d*/
    comments = s.scan(c)
    comments.collect! do |comment|
      comment.split('>')[1]
    end
  
    i = 0
    topics.each do |topic|
      feedback.add_item({ 
        :title => topic[1], 
        :subtitle =>"#{nodes[i]} | by #{authors[i]} | #{comments[i]}人喜欢", 
        :arg => "http://ruby-china.org/#{topic[0]}", 
        :icon => { :name => "hot.png" }
      })

      i += 1
    end
  end

when "n", "N"
  #无人问津
  uri = "http://ruby-china.org/topics/no_reply"
  
  open(uri) do |f|
    s = ""

    f.each do |line|
      s << line
    end
  
    #topics-related
    m = /href="(\/topics\/[0-9]\d*)"\stitle="(.+)"/
    topics = s.scan(m)
    
    #nodes-related
    n = /\/topics\/node[0-9]\d*">.+/
    nodes = s.scan(n)
    nodes.collect! do |node|
      node = node.match(/>.+</).to_s 
      l = node.size
      node.slice!(1, l-2) 
    end

    #authors-related
    a = /^.+data-name=.+/
    authors = s.scan(a) 
    authors.delete_if { |author| author.match(/最后由/)}
    authors.collect! do |author|
      author.split('/')[1].split('"')[0]
    end

    i = 0
    topics.each do |topic|
      feedback.add_item({ 
        :title => topic[1], 
        :subtitle =>"#{nodes[i]} | by #{authors[i]}", 
        :arg => "http://ruby-china.org/#{topic[0]}", 
        :icon => { :name => "no_reply.png" }
      })

      i += 1
    end
  end
else
  search = Google::Search::Web.new(:query => "site:ruby-china.org #{type}")

  i = 0

  search.each do |result|
    feedback.add_item({
      :uid => "suggest #{type}", 
      :title => result.title, 
      :subtitle => result.uri, 
      :arg => result.uri
    })
    i = 1 + i
    break if i > 10 
  end
end

puts feedback.to_xml
