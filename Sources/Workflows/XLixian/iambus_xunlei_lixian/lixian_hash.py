#!/usr/bin/env python

import hashlib
import lixian_hash_ed2k
import lixian_hash_bt
import os

def lib_hash_file(h, path):
	with open(path, 'rb') as stream:
		while True:
			bytes = stream.read(1024*1024)
			if not bytes:
				break
			h.update(bytes)
	return h.hexdigest()

def sha1_hash_file(path):
	return lib_hash_file(hashlib.sha1(), path)

def verify_sha1(path, sha1):
	return sha1_hash_file(path).lower() == sha1.lower()

def md5_hash_file(path):
	return lib_hash_file(hashlib.md5(), path)

def verify_md5(path, md5):
	return md5_hash_file(path).lower() == md5.lower()

def md4_hash_file(path):
	return lib_hash_file(hashlib.new('md4'), path)

def verify_md4(path, md4):
	return md4_hash_file(path).lower() == md4.lower()

def dcid_hash_file(path):
	h = hashlib.sha1()
	size = os.path.getsize(path)
	with open(path, 'rb') as stream:
		if size < 0xF000:
			h.update(stream.read())
		else:
			h.update(stream.read(0x5000))
			stream.seek(size/3)
			h.update(stream.read(0x5000))
			stream.seek(size-0x5000)
			h.update(stream.read(0x5000))
	return h.hexdigest()

def verify_dcid(path, dcid):
	return dcid_hash_file(path).lower() == dcid.lower()

def main(args):
	option = args.pop(0)
	def verify_bt(f, t):
		from lixian_progress import SimpleProgressBar
		bar = SimpleProgressBar()
		result = lixian_hash_bt.verify_bt_file(t, f, progress_callback=bar.update)
		bar.done()
		return result
	if option.startswith('--verify'):
		hash_fun = {'--verify-sha1':verify_sha1,
					'--verify-md5':verify_md5,
					'--verify-md4':verify_md4,
					'--verify-dcid':verify_dcid,
					'--verify-ed2k':lixian_hash_ed2k.verify_ed2k_link,
					'--verify-bt': verify_bt,
				   }[option]
		assert len(args) == 2
		hash, path = args
		if hash_fun(path, hash):
			print 'looks good...'
		else:
			print 'failed...'
	else:
		hash_fun = {'--sha1':sha1_hash_file,
					'--md5':md5_hash_file,
					'--md4':md4_hash_file,
					'--dcid':dcid_hash_file,
					'--ed2k':lixian_hash_ed2k.generate_ed2k_link,
					'--info-hash':lixian_hash_bt.info_hash,
				   }[option]
		for f in args:
			h = hash_fun(f)
			print '%s *%s' % (h, f)

if __name__ == '__main__':
	import sys
	args = sys.argv[1:]
	main(args)

