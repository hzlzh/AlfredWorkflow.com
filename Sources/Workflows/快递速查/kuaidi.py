#
# icyleaf
# 2013-4-5
# -*- coding: utf-8 -*-
#
import sys
import argparse
import re
import json
import requests
from feedback import Feedback

class Kuaidi:

	is_terminal = True
	companies = ''

	def __init__(self):
		with open('company.json') as data_file:
			self.companies = json.load(data_file)
			
	def tracking_search(self, number, company=''):
		if number <= 0:			
			sys.exit('\033[33m[Error]\033[0m Tracking number must more than zero')

		dataset = None
		company = self._company_match(company)
		if company:
			url = 'http://m.kuaidi100.com/query?type=%s&postid=%s&id=1' % (company, number)
			r = requests.get(url)
			dataset = r.json()

			if not self.is_terminal:
				fb = Feedback()

			if dataset['status'] == '200':
				for step in dataset['data']:
					time = step['time']
					content = step['context'].replace(' ', '')
					if self.is_terminal:
						print '%s\t%s' % (time, content)
					else:
						arg = '%s %s' % (time, content)
						fb.add_item(content, time, arg=arg, valid='no')

				if not self.is_terminal:
					print fb
			else:
				if self.is_terminal:
					print '\033[33m[Error]\033[0m %s' % dataset['message']
				else:
					fb.add_item(dataset['message'], valid='no')

	def company_search(self, company_name):
		fb = Feedback()
		company_codes = []
		for company in self.companies:
			if re.search(company_name, company['url']):
				company = self._format_company_filter(company)
				fb.add_item(company['title'], company['subtitle'], arg=company['arg'], valid='no', autocomplete=company['autocomplete'])
		print fb

	def companies_list(self):
		if not self.is_terminal: 
			fb = Feedback()

		for company in self.companies:
			if self.is_terminal:
				title = '%s [%s]' % (company['companyname'], company['tel'])
				subtitle = company['comurl']
				print '%s -> %s (%s)' % (company['companyname'], company['code'], company['url'])
			else: 
				company = self._format_company_filter(company)
				fb.add_item(company['title'], company['subtitle'], arg=company['arg'], valid='no', autocomplete=company['autocomplete'])

		if not self.is_terminal: 
			print fb

	def _company_match(self, search_company):
		for company in self.companies:
			if search_company in (company['companyname'], company['shortname'], company['url'], company['code']):
				return company['code']
		return None 

	def _format_company_filter(self, company):
		title = '%s / %s' % (company['companyname'], company['url'])
		subtitle = '[%s] %s' % (company['tel'], company['comurl'])
		args = '%s-[icyleaf]-%s' % (company['tel'], company['comurl'])
		autocomplete = '%s ' % company['url']

		return {
			'title': title,
			'subtitle': subtitle,
			'arg': args,
			'autocomplete': autocomplete
		}


def main(argv):
	parser = argparse.ArgumentParser(description='Express Delivery Status')

	parser.add_argument('number', type=int, help='Tracking Number')
	parser.add_argument('-c', '--company', action='store', dest='company', help='Express Company')
	args = parser.parse_args(argv)

	kd = Kuaidi()
	dataset = kd.search(args.number, company=args.company)
	if dataset:
		kd.render_in_terminal(dataset)
	else:
		kd.render_companies_in_terminal()

if __name__ == '__main__':
	main(sys.argv[1:])