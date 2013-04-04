
from lixian_plugins.api import command

@command(name='hash', usage='compute hashes')
def print_hash(args):
	'''
	lx hash --sha1 file...
	lx hash --md5 file...
	lx hash --md4 file...
	lx hash --dcid file...
	lx hash --ed2k file...
	lx hash --info-hash xxx.torrent...
	lx hash --verify-sha1 file hash
	lx hash --verify-md5 file hash
	lx hash --verify-md4 file hash
	lx hash --verify-dcid file hash
	lx hash --verify-ed2k file ed2k://...
	lx hash --verify-bt file xxx.torrent
	'''
	#assert len(args) == 1
	import lixian_hash
	#import lixian_hash_ed2k
	#print 'ed2k:', lixian_hash_ed2k.hash_file(args[0])
	#print 'dcid:', lixian_hash.dcid_hash_file(args[0])
	import lixian_cli_parser
	lixian_hash.main(lixian_cli_parser.expand_command_line(args))

