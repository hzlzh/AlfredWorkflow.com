#! /usr/bin/python
# -*- coding: utf-8 -*-
import subprocess
import re
import xml.dom.minidom as Dom 
import sys

# 修正编码
def fixCoding():
	sysEncoding = sys.getdefaultencoding()
	if sysEncoding != 'UTF-8':
		reload(sys)
		sys.setdefaultencoding('UTF-8')
fixCoding()

# 创建文本结点
def createTextElement(doc,tag,text):
	node =doc.createElement(tag)
	nodeValue = doc.createTextNode(text)
	node.appendChild(nodeValue)
	return node

# 创建一个item,一个item就是一个结果
def buildItem(doc,title,uid):
	# print title,_uid
	item = doc.createElement("item")
	item.setAttribute('uid',uid)
	item.setAttribute('arg',uid+','+title)
	item.appendChild(createTextElement(doc,'title',title))
	item.appendChild(createTextElement(doc,'subtitle','切换至'+title))
	item.appendChild(createTextElement(doc,'icon','icon.png'))
	return item

# 提取构造xml文件
def buildXml( query):
	p = subprocess.Popen('scselect', shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
	p.wait()
	#retval = p.wait()
	#print retval
	#print p.stdout.readline()
	#构造文档
	doc = Dom.Document()  
	items = doc.createElement("items")
	doc.appendChild(items)  

	for line in p.stdout.readlines():

		pattern = re.compile(r'^\s*(\*?)\s*([\w-]+)\s*\((.*)\)')
		match = pattern.match(line)
		#print match
		if match:
			# print match.groups()
			uid = match.group(2)
			title = match.group(3)
			current = match.group(1)=='*'
			if current:
				continue
			if (not query in title) and query:
			 	continue
			items.appendChild(buildItem(doc, title, uid))
	return doc.toxml()

if __name__ == '__main__':
	query = ''.strip()
	print buildXml(query)