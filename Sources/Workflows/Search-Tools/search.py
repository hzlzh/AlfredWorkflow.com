# -*- coding: utf-8 -*-

import urllib2
import urllib
import json
import re
import alfred

################################################################################
def strip_html( html ):
    p = re.compile( r"<.*?>" )
    return p.sub( "", html )

def set_proxy():
	proxy = "http://127.0.0.1:8087" # goagent proxy
	if proxy != "":
		proxy_handler = urllib2.ProxyHandler( {"http":proxy} ) 
		opener = urllib2.build_opener( proxy_handler )
		urllib2.install_opener( opener )
	return

################################################################################
def search_sina( query ):
	params = { "c":"news", "sort":"rel", "range":"all", "ie":"utf-8", "video":"1", "q":query }
	response = json.loads( urllib2.urlopen("http://api.search.sina.com.cn/?"+urllib.urlencode(params)).read() )
	news = response["result"]["list"]
	result = []
	
	default_link = "http://search.sina.com.cn/?c=news&q=" + urllib.urlencode( params )
	result.append( alfred.Item( {"uid":"0", "arg":default_link}, u"更多详细结果……", default_link, ("sina.png") ) )
	
	for n in news:
		result.append( alfred.Item( {"uid":alfred.uid(n["url"]), "arg":n["url"]}, 
			n["title"], n["datetime"]+" "+n["url"], ("sina.png")) ) 
	return result
	
################################################################################
def search_wiki( query ):
	set_proxy()
	args = { "action":"query", "list":"search", "srprop":"timestamp", "format":"json", "srsearch":query }
	response = json.loads( urllib2.urlopen("https://zh.wikipedia.org/w/api.php?"+urllib.urlencode(args)).read() )
	wiki = response["query"]["search"]
	result = []
	
	default_link = "https://zh.wikipedia.org/w/index.php?" + urllib.urlencode({"search":query})
	result.append( alfred.Item( {"uid":"0", "arg":default_link}, u"更多详细结果……", default_link, ("wiki.png") ) )

	for w in wiki:
		link = u"https://zh.wikipedia.org/wiki/" + urllib.quote( w["title"].encode("utf8") )
		result.append( alfred.Item( {"uid":alfred.uid(w["title"]), "arg":link, "autocomplete":w["title"]}, 
			w["title"], link, ("wiki.png")) ) 
	return result
	
################################################################################
def search_google( query ):
	set_proxy()
	args = { "hl":"zh", "q":query }
	request=urllib2.Request( "https://www.google.com/search?"+urllib.urlencode(args), None, 
		{'User-Agent':"Mozilla/5.0 (iPhone; CPU iPhone OS 5_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B179 Safari/7534.48.3",} )
	response = urllib2.urlopen( request ).read().replace("rwt(","\nrwt(").split("\n")
	
	result = []
	default_link = "https://www.google.com/search?" + urllib.urlencode( args )
	result.append( alfred.Item( {"uid":"0", "arg":default_link}, u"更多详细结果……", default_link, ("google.png") ) )

	buffer_line = ""
	prev_line = ""
	for line in response:
		
		prev_line = buffer_line
		buffer_line = line
		if line.find("rwt(")==-1 or line.find("<em>")==-1:
			continue
			
		title_begin = line.find("event)\">")
		title_end = line.find("</a>")
		if title_begin==-1 or title_end==-1:
			continue
		title = strip_html( line[title_begin+8:title_end] )
		
		link_begin = prev_line.find("<a href=\"http")
		link_end = prev_line.find("\" ",link_begin)
		if link_begin==-1 or link_end==-1:
			continue
		link = strip_html( prev_line[link_begin+13:link_end] )
		
		result.append( alfred.Item( {"uid":alfred.uid(link), "arg":link}, unicode(title,"utf-8"), unicode(link,"utf-8"), ("google.png")) ) 
	return result

################################################################################
def search_zhihu( query ):
	params = { "type":"question", "q":query }
	response = urllib2.urlopen( "http://m.zhihu.com/search?"+urllib.urlencode(params) ).read().split( "\n" )
	
	result = []
	default_link = "http://www.zhihu.com/search?" + urllib.urlencode(params)
	result.append( alfred.Item( {"uid":"0", "arg":default_link}, u"更多详细结果……", default_link, ("zhihu.png") ) )
	
	title = ""
	link = ""
	answers = "" 
	for line in response:
		# <a class="question_link" target="_blank" href="/question/{id}">{title}</a>
		# <a href="/question/{id}" class="answer zg-link-gray" target="_blank"><i></i>{answers}</a><a

		if line.find("question_link") != -1:
			title_begin = line.find( "\">" )
			title_end = line.rfind( "</a>" )
			if title_begin==-1 or title_end==-1:
				continue
			title = strip_html( line[title_begin+2:title_end] )
			
		elif line.find("answer")!=-1 and title!="":
			link_begin = line.find( "<a href=\"/question/" )
			link_end = line.find( "\" class=\"answer" )
			answers_begin = line.find( "<i></i>" )
			answers_end = line.rfind( "</a>" )			
			if link_begin==-1 or link_end==-1 or answers_begin==-1 or answers_end==-1:
				title = ""			
				continue
			link = line[link_begin+19:link_end]
			answers = line[answers_begin+7:answers_end]
	
			# append
			if title!="" and link!="" and answers!="":
				result.append( alfred.Item( {"uid":alfred.uid(link), "arg":"http://www.zhihu.com/question/"+link}, 
					unicode(title,"utf-8"), unicode(answers,"utf-8"), ("zhihu.png")) )				
			# next
			title = ""
			link = ""
			answers = ""
			
		else:
			continue
		
	return result

################################################################################
def search_weibo( query ):
	params = { "xsort":"time" }
	response = urllib2.urlopen( "http://s.weibo.com/weibo/"+query+"&"+urllib.urlencode(params) ).read().decode("unicode-escape").split( "\n" )
	
	result = []
	#escaped = unicode(query,"utf-8").encode("unicode-escape").replace("\u","%")
	default_link = u"http://s.weibo.com/weibo/" + query + "&" + urllib.urlencode(params)
	result.append( alfred.Item( {"uid":"0", "arg":default_link}, u"更多详细结果……", default_link, ("weibo.png") ) )
	
	name = ""
	weibo = ""
	link = ""	
	for line in response:
		if line.find("pincode") != -1:
			result.append( alfred.Item( {"uid":alfred.uid(link), "arg":link}, u"搜素行为异常，请退出微博登录并打开以下网页输入验证码", default_link, ("weibo.png")) )				
		
		elif line.find("nick-name") != -1:
			content = strip_html( line )
			weibo_pos = content.find( u"：" )
			if weibo_pos == -1:
				continue
			name = content[1:weibo_pos]
			if name[0:1] == u"@":
				name = name[1:]
			weibo = content[weibo_pos+1:]
		
		elif line.find("action-data=\"allowForward")!=-1 and name!="" and weibo!="":
			link_begin = line.find( "&url=http:\/\/weibo.com\/" )
			link_end = line.find( "&mid=" )
			if link_begin==-1 or link_end==-1:
				name = ""
				weibo = ""
				continue
			link =line[link_begin+5:link_end]
			link = link.replace( "\\", "" )

			# append
			if name!="" and weibo!="" and link!="":
				result.append( alfred.Item( {"uid":link, "arg":link}, "@"+name+": "+weibo, link, ("weibo.png")) )				
			# next
			name = ""
			weibo = ""
			link = ""
			
		else:
			continue
	
	return result

################################################################################
def main():
	( param, query ) = alfred.args2()

	if param == "sina":
		result = search_sina( query )
	elif param == "zhihu":
		result = search_zhihu( query )
	elif param == "weibo":
		result = search_weibo( query )
	elif param == "wiki":
		result = search_wiki( query )
	elif param == "google":
		result = search_google( query )

	alfred.write( alfred.xml(result) )

if __name__ == "__main__":
	main()

