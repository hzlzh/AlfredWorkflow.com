# -*- coding: utf-8 -*-

import urllib2
import urllib
import cookielib
import json
import HTMLParser
import re
import alfred

################################################################################
def strip_html( html ):
    p = re.compile( r"<.*?>" )
    return p.sub( "", html )
    
def unescape_html( html ):
	html_parser = HTMLParser.HTMLParser()
	return html_parser.unescape( html )
	
def parse_href( html ):
	link_begin = html.find( "<a href=\"http" )
	if link_begin == -1:
		return ""
	link_end = html.find( "\"" , link_begin+12 )
	if link_end == -1:
		return ""
	return html[link_begin+9:link_end]	

def set_proxy():
	proxy = "http://127.0.0.1:8087" # goagent proxy
	if proxy != "":
		cookies = cookielib.CookieJar()
		proxy_handler = urllib2.ProxyHandler( {"http":proxy, "https":proxy} )
		opener = urllib2.build_opener( proxy_handler, urllib2.HTTPCookieProcessor(cookies) )
		
		#httpHandler = urllib2.HTTPHandler( debuglevel=1 )
		#httpsHandler = urllib2.HTTPSHandler( debuglevel=1 )
		#opener = urllib2.build_opener( httpHandler, httpsHandler,
		#	proxy_handler, urllib2.HTTPCookieProcessor(cookies) )
        
		urllib2.install_opener( opener )
	return

################################################################################
def search_sina( query ):
	args = { "app_key":"1335320450", "c":"news", "sort":"rel", "range":"all", "ie":"utf-8", "video":"1", "q":query }
	response = json.loads( urllib2.urlopen("http://platform.sina.com.cn/search/search?"+urllib.urlencode(args)).read() )
	news = response["result"]["list"]
	
	result = []
	default_title = u"更多详细结果……"
	if len(news) == 0:
		default_title = u"找不到结果，请使用网页查询……"
	default_link = "http://search.sina.com.cn/?c=news&q=" + urllib.urlencode( args )
	result.append( alfred.Item( {"uid":alfred.uid("0"), "arg":default_link}, default_title, default_link, ("sina.png") ) )
		
	for n in news:
		result.append( alfred.Item( {"uid":alfred.uid(n["url"]), "arg":n["url"]}, 
			unescape_html(n["title"]), n["datetime"]+" "+n["url"], ("sina.png")) )

	return result
	
################################################################################
def search_wiki( query ):
	set_proxy()
	args = { "action":"query", "list":"search", "srprop":"timestamp", "format":"json", "srsearch":query }
	response = json.loads( urllib2.urlopen("https://zh.wikipedia.org/w/api.php?"+urllib.urlencode(args)).read() )
	wiki = response["query"]["search"]
	
	result = []
	default_title = u"更多详细结果……"
	if len(wiki) == 0:
		default_title = u"找不到结果，请使用网页查询……"
	default_link = "https://zh.wikipedia.org/w/index.php?" + urllib.urlencode({"search":query})
	result.append( alfred.Item( {"uid":alfred.uid("0"), "arg":default_link}, default_title, default_link, ("wiki.png") ) )

	for w in wiki:
		link = u"https://zh.wikipedia.org/wiki/" + urllib.quote( w["title"].encode("utf8") )
		result.append( alfred.Item( {"uid":alfred.uid(w["title"]), "arg":link}, 
			unescape_html(w["title"]), link, ("wiki.png")) ) 
	return result
	
################################################################################
def search_imfdb( query ):
	args = { "action":"query", "list":"search", "srprop":"timestamp", "format":"json", "srsearch":query }
	response = json.loads( urllib2.urlopen("http://www.imfdb.org/api.php?"+urllib.urlencode(args)).read() )
	wiki = response["query"]["search"]
	
	result = []
	default_title = u"更多详细结果……"
	if len(wiki) == 0:
		default_title = u"找不到结果，请使用网页查询……"
	default_link = "http://www.imfdb.org/index.php?" + urllib.urlencode({"search":query})
	result.append( alfred.Item( {"uid":alfred.uid("0"), "arg":default_link}, default_title, default_link, ("imfdb.png") ) )

	for w in wiki:
		link = u"http://www.imfdb.org/wiki/" + urllib.quote( w["title"].encode("utf8") )
		result.append( alfred.Item( {"uid":alfred.uid(w["title"]), "arg":link}, 
			unescape_html(w["title"]), link, ("imfdb.png")) ) 
	return result

################################################################################
def search_google( query ):
	set_proxy()
	args = { "hl":"zh-CN", "q":query }
	request=urllib2.Request( "https://www.google.com.hk/search?"+urllib.urlencode(args), None, 
		{'User-Agent':"Mozilla/5.0 (iPhone; CPU iPhone OS 5_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B179 Safari/7534.48.3",} )
	response = urllib2.urlopen( request ).read().replace("rwt(","\nrwt(").split("\n")
	
	result = []
	default_link = "https://www.google.com/search?" + urllib.urlencode( args )
	result.append( alfred.Item( {"uid":alfred.uid("0"), "arg":default_link}, u"更多详细结果……", default_link, ("google.png") ) )

	buffer_line = ""
	prev_line = ""
	for line in response:

		prev_line = buffer_line
		buffer_line = line
		if "rwt(" not in line or "<em>" not in line:
			continue

		title_begin = line.find("\"_blank\">")
		title_end = line.find("</a>")
		if title_begin==-1 or title_end==-1:
			continue
		title = strip_html( line[title_begin+9:title_end] )

		#link = parse_href( prev_line )
		link_begin = prev_line.rfind("<a href=\"http")
		link_end = prev_line.find("\" ",link_begin)
		if link_begin==-1 or link_end==-1:
			continue
		link = strip_html( prev_line[link_begin+9:link_end] )
		
		result.append( alfred.Item( {"uid":alfred.uid(link), "arg":link}, 
			unescape_html(unicode(title,"utf-8")), unicode(link,"utf-8"), ("google.png")) )
	
	if len(result) == 1:
		result = []
		result.append( alfred.Item( {"uid":alfred.uid("0"), "arg":default_link}, u"找不到结果，请使用网页查询……", default_link, ("google.png") ) )
	
	return result
	
################################################################################
def search_suggest( query, api ):
	if api == "bing":
		args = { "query":query }
		response = urllib2.urlopen("http://api.bing.com/osjson.aspx?"+urllib.urlencode(args)).read()
		suggests = json.loads(response)[1]
	else:
		set_proxy()
		args = { "output":"firefox", "hl":"zh-CN", "q":query }
		response = urllib2.urlopen("https://www.google.com.hk/complete/search?"+urllib.urlencode(args)).read()
		suggests = json.loads(unicode(response,"gbk"))[1]
	
	result = []
	default_title = u"更多详细结果……"
	if len(suggests) == 0:
		default_title = u"找不到提示建议，请使用网页查询……"
	args = { "hl":"zh-CN", "q":query }
	default_link = "https://www.google.com/search?" + urllib.urlencode( args )
	result.append( alfred.Item( {"uid":alfred.uid("0"), "arg":default_link}, default_title, default_link, ("google.png") ) )
    
	for q in suggests:
		args = { "hl":"zh-CN", "q":q.encode("gb18030") }
		link = "https://www.google.com/search?" + urllib.urlencode( args ) 
		result.append( alfred.Item( {"uid":alfred.uid(q), "arg":link}, q, link, ("google.png")) ) 
	return result

################################################################################
def search_zhihu( query ):
	
	params = { "type":"question", "q":query }
	default_link = "http://www.zhihu.com/search?" + urllib.urlencode(params)
	result = []
	result.append( alfred.Item( {"uid":alfred.uid("0"), "arg":default_link}, u"更多详细结果……", default_link, ("zhihu.png") ) )
	
	def _search_zhihu( search_type, query ):
		params = { "type":search_type, "q":query }
		response = urllib2.urlopen( "http://m.zhihu.com/search?"+urllib.urlencode(params) ).read().split( "\n" )
		
		result = []
		title = ""
		link = ""
		answers = "" 
		for line in response:
			# <a class="question_link" target="_blank" href="/question/{id}">{title}</a>
			# <a href="/question/{id}" class="answer zg-link-gray" target="_blank"><i></i>{answers}</a><a
	
			if "question_link" in line:
				title_begin = line.find( "\">" )
				title_end = line.rfind( "</a>" )
				if title_begin==-1 or title_end==-1:
					continue
				title = strip_html( line[title_begin+2:title_end] )
				
			elif "class=\"answer" in line and title!="":
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
						unescape_html(unicode(title,"utf-8")), unicode(answers,"utf-8"), ("zhihu.png")) )				
				# next
				title = ""
				link = ""
				answers = ""
				
			else:
				continue
				
		return result
		
	result.extend( _search_zhihu("question", query) )
	result.extend( _search_zhihu("answer", query) )
		
	if len(result) == 1:
		result = []
		result.append( alfred.Item( {"uid":alfred.uid("0"), "arg":default_link}, u"找不到结果，请使用网页查询……", default_link, ("zhihu.png") ) )
	
	return result

################################################################################
def search_weibo( query ):
	weibo_gsid = ""
	
	result = []
	if weibo_gsid == "":
		result.append( alfred.Item( {"uid":"0", "arg":"http://weibo.cn/search/"}, 
			u"请登录手机版微博查询gsid参数值", u"请修改search.py文件中search_weibo()函数的weibo_gsid变量", ("weibo.png")) )
		return result

	params = { "filter":"all", "sort":"time", "vt":"4", "keyword":query, "gsid":weibo_gsid }	
	request=urllib2.Request( "http://weibo.cn/search/mblog/?"+urllib.urlencode(params), None, 
		{'User-Agent':"Mozilla/5.0 (iPhone; CPU iPhone OS 5_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B179 Safari/7534.48.3",} )
	response = urllib2.urlopen( request ).read().replace("<div","\n<div").split("\n")
	
	default_link = u"http://s.weibo.com/weibo/" + urllib.quote_plus(query) + "&" + urllib.urlencode(params)
	result.append( alfred.Item( {"uid":alfred.uid("0"), "arg":default_link}, u"更多详细结果……", default_link, ("weibo.png") ) )
	
	name = ""
	weibo = ""
	link = ""
	repost = ""
	comment = ""
	for line in response:
		if "<div class=\"c\"> id=\"" in line:
			name = weibo = link = repost = comment = ""
			continue
			
		if "<a class=\"nk\"" in line:
			# <a class="nk" href="...">name</a>
			fields = line.replace("><",">\n<").split("\n")
			for field in fields:
				if "<a class=\"nk\"" in field:
					name = strip_html( field )
					break

		if "<span class=\"ctt\"" in line:
			# <span class="ctt">:weibo</span>
			fields = line.replace("><",">\n<").split("\n")
			for field in fields:
				if "<span class=\"ctt\"" in field:
					weibo = strip_html( field )
					if weibo[0:1] == ":":
						weibo = weibo[1:]
					break

		if "class=\"cc\">评论[" in line:
			# <a href="http://weibo.cn/repost/...">转发[n]></a>
			# <a href="http://weibo.cn/comment/..." class="cc">评论[n]></a>
			fields = line.replace("<",">\n<").split("\n")
			for field in fields:
				if ">转发[" in field:
					repost = strip_html( field ).replace( ">", "" )
				if ">评论[" in field:
					comment = strip_html( field ).replace( ">", "" )
					link = parse_href( field )
					href_pos = link.find( "#" )
					if href_pos != -1:
						link = link[0:href_pos]
					link += "&amp;gsid=" + weibo_gsid
					link = link.replace( "&amp;", "&" )
			
		if "<div class=\"s\"></div>" in line:
			# append
			if name!="" and weibo!="" and link!="":
				name 	= unicode( name, "utf-8" )
				weibo 	= unicode( weibo, "utf-8" )
				link 	= unicode( link, "utf-8" )
				repost 	= unicode( repost, "utf-8" )
				comment = unicode( comment, "utf-8" )
				result.append( alfred.Item( {"uid":link, "arg":link}, "@"+name+": "+weibo, repost+", "+comment, ("weibo.png")) )
			# next
			name = weibo = link = repost = comment = ""

	return result
	
	"""
	set_proxy()
	params = { "xsort":"time" }
	response = urllib2.urlopen( "http://s.weibo.com/weibo/"+urllib.quote_plus(query)
		+"&"+urllib.urlencode(params) ).read().decode("unicode-escape").split( "\n" )
	
	result = []
	default_link = u"http://s.weibo.com/weibo/" + urllib.quote_plus(query) + "&" + urllib.urlencode(params)
	result.append( alfred.Item( {"uid":alfred.uid("0"), "arg":default_link}, u"更多详细结果……", default_link, ("weibo.png") ) )
	
	name = ""
	weibo = ""
	link = ""	
	for line in response:
		if "pincode" in line:
			result.append( alfred.Item( {"uid":alfred.uid(link), "arg":default_link}, u"搜素行为异常，请退出微博登录并打开以下网页输入验证码", default_link, ("weibo.png")) )				
		
		if u"您可能感兴趣的结果" in line:
			break				

		elif "nick-name" in line:
			content = strip_html( line )
			weibo_pos = content.find( u"：" )
			if weibo_pos == -1:
				continue
			name = content[1:weibo_pos]
			if name[0:1] == u"@":
				name = name[1:]
			weibo = content[weibo_pos+1:]
		
		elif "action-data=\"allowForward" in line and name!="" and weibo!="":
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
				result.append( alfred.Item( {"uid":link, "arg":link}, "@"+name+": "+unescape_html(weibo), link, ("weibo.png")) )
			# next
			name = ""
			weibo = ""
			link = ""
			
		else:
			continue
	
	if len(result) == 1:
		result = []
		result.append( alfred.Item( {"uid":alfred.uid("0"), "arg":default_link}, u"找不到结果，请使用网页查询……", default_link, ("weibo.png") ) )
	
	return result
	"""

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
	elif param == "imfdb":
		result = search_imfdb( query )
	elif param == "google":
		result = search_google( query )
	elif param == "suggest":
		result = search_suggest( query, "google" )
	elif param == "bing":
		result = search_suggest( query, "bing" )

	alfred.write( alfred.xml(result) )

if __name__ == "__main__":
	main()

