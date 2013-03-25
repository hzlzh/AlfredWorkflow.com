
import sys

class SimpleProgressBar:
	def __init__(self):
		self.displayed = False
	def update(self, percent):
		self.displayed = True
		bar_size = 40
		percent = int(percent*100)
		if percent > 100:
			percent = 100
		dots = bar_size * percent / 100
		plus = percent - dots / bar_size * 100
		if plus > 0.8:
			plus = '='
		elif plus > 0.4:
			plu = '>'
		else:
			plus = ''
		bar = '=' * dots + plus
		bar = '{0:>3}%[{1:<40}]'.format(percent, bar)
		sys.stdout.write('\r'+bar)
		sys.stdout.flush()
	def done(self):
		if self.displayed:
			print
			self.displayed = False

