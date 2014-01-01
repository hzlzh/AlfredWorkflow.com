import sys
sys.path.append('lib')

import alp
import boto

import logging
logging.basicConfig(filename='debug.log')

def list_instances(name):
	"""Returns a list of instances with a given name"""
	items = []
	try:
		if len(name) <2:
			items.append(alp.Item(
				title='Searching',
				subtitle='Please type more then one character to start searching',
				valid=False
			))
		else:
			ec2 = boto.connect_ec2()
			for r in ec2.get_all_instances():
				groups = ';'.join([g.name or g.id for g in r.groups])
				for instance in r.instances:
					instance_name = instance.tags.get('Name', instance.tags.get('name', ''))
					if not name.lower() in instance_name.lower():
						continue
					if instance.public_dns_name:
						arg = 'ssh -i ~/.ssh/%s.pem %s\n' % (instance.key_name, instance.public_dns_name)
					else:
						arg = 'ssh vpc\nssh %s\n' % instance.private_ip_address
						
						
					items.append(alp.Item(
						title=instance_name,
						subtitle='[%s]: %s' % (instance.id, groups),
						valid=True,
						arg=arg
					))
				
		if len(items) == 0:
			items.append(alp.Item(
				title='No Results Found',
				subtitle='Please refine your search and try again'
			))
	except Exception, e:
		alp.log(str(e))
		items = [alp.Item(
			title='Problem Searching',
			subtitle='%s' % str(e).replace("'", ''),
			valid=False
		)]
		alp.log(items[0].get())
	alp.feedback(items)
