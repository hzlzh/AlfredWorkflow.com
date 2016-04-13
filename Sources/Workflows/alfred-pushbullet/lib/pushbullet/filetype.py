def _magic_get_file_type(f, _):
    file_type = magic.from_buffer(f.read(1024), mime=True)
    f.seek(0)
    return file_type.decode('utf-8')


def _guess_file_type(_, filename):
    return mimetypes.guess_type(filename)[0]


try:
    import magic
except ImportError:
    import mimetypes
    get_file_type = _guess_file_type
else:
    get_file_type = _magic_get_file_type
