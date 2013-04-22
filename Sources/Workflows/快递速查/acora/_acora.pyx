#cython: embedsignature=True

"""A fast C implementation of the Acora search engine.

There are two main classes, UnicodeAcora and BytesAcora, that handle
byte data and unicode data respectively.
"""

__all__ = ['BytesAcora', 'UnicodeAcora']

from libc cimport stdio
cimport cpython.exc
cimport cpython.mem
from cpython.ref cimport PyObject
from cpython.version cimport PY_MAJOR_VERSION
from cpython.unicode cimport PyUnicode_AS_UNICODE, PyUnicode_GET_SIZE

cdef extern from * nogil:
    ctypedef Py_ssize_t ssize_t
    ssize_t read(int fd, void *buf, size_t count)

DEF FILE_BUFFER_SIZE = 32 * 1024

ctypedef struct _AcoraUnicodeNodeStruct:
    Py_UNICODE* characters
    _AcoraUnicodeNodeStruct** targets
    PyObject** matches
    int char_count

ctypedef struct _AcoraBytesNodeStruct:
    char* characters
    _AcoraBytesNodeStruct** targets
    PyObject** matches
    int char_count

cdef _init_unicode_node(_AcoraUnicodeNodeStruct* c_node, state,
                        list state_transitions,
                        _AcoraUnicodeNodeStruct* all_nodes,
                        dict node_offsets, dict pyrefs):
    cdef size_t targets_mem_size, mem_size
    cdef Py_ssize_t i

    state_transitions.sort() # sort by characters
    characters, targets = list(zip(*state_transitions))
    characters = _intern(pyrefs, u''.join(characters))

    c_node.characters = PyUnicode_AS_UNICODE(characters)
    c_node.char_count = PyUnicode_GET_SIZE(characters)

    # use a single malloc for targets and match-string pointers
    mem_size = targets_mem_size = sizeof(_AcoraUnicodeNodeStruct**) * len(targets)
    if state.matches is not None and len(state.matches) > 0:
        mem_size += sizeof(PyObject*) * (len(state.matches) + 1) # NULL terminated
    c_node.targets = <_AcoraUnicodeNodeStruct**> cpython.mem.PyMem_Malloc(mem_size)
    if c_node.targets is NULL:
        cpython.exc.PyErr_NoMemory()

    for i, target in enumerate(targets):
        c_node.targets[i] = all_nodes + <size_t>node_offsets[target]

    if mem_size == targets_mem_size:
        c_node.matches = NULL
    else:
        c_node.matches = <PyObject**> (c_node.targets + len(targets))
        matches = _intern(pyrefs, tuple(state.matches))
        i = 0
        for match in matches:
            c_node.matches[i] = <PyObject*>match
            i += 1
        c_node.matches[i] = NULL

cdef _init_bytes_node(_AcoraBytesNodeStruct* c_node, state,
                      list state_transitions,
                      _AcoraBytesNodeStruct* all_nodes,
                      dict node_offsets, dict pyrefs):
    cdef size_t targets_mem_size, mem_size
    cdef Py_ssize_t i

    state_transitions.sort() # sort by characters
    characters, targets = list(zip(*state_transitions))
    if PY_MAJOR_VERSION >= 3:
        characters = bytes(characters) # items are integers, not byte strings
    else:
        characters = b''.join(characters)
    characters = _intern(pyrefs, characters)

    c_node.characters = characters
    c_node.char_count = len(characters)

    # use a single malloc for targets and match-string pointers
    mem_size = targets_mem_size = sizeof(_AcoraBytesNodeStruct**) * len(targets)
    if state.matches is not None and len(state.matches) > 0:
        mem_size += sizeof(PyObject*) * (len(state.matches) + 1) # NULL terminated
    c_node.targets = <_AcoraBytesNodeStruct**> cpython.mem.PyMem_Malloc(mem_size)
    if c_node.targets is NULL:
        cpython.exc.PyErr_NoMemory()

    for i, target in enumerate(targets):
        c_node.targets[i] = all_nodes + <size_t>node_offsets[target]

    if mem_size == targets_mem_size:
        c_node.matches = NULL
    else:
        c_node.matches = <PyObject**> (c_node.targets + len(targets))
        matches = _intern(pyrefs, tuple(state.matches))
        i = 0
        for match in matches:
            c_node.matches[i] = <PyObject*>match
            i += 1
        c_node.matches[i] = NULL

cdef inline _intern(dict d, obj):
    if obj in d:
        return d[obj]
    d[obj] = obj
    return obj


cdef dict group_transitions_by_state(dict transitions):
    # sort transitions by state ID (0 is start state) and transition character
    cdef list transition_list = sorted(transitions.items())
    transitions_by_state = {}
    for (state, character), target in transition_list:
        if state in transitions_by_state:
            transitions_by_state[state].append((character, target))
        else:
            transitions_by_state[state] = [(character, target)]
    return transitions_by_state


# unicode data handling

cdef class UnicodeAcora:
    """Acora search engine for unicode data.
    """
    cdef _AcoraUnicodeNodeStruct* start_node
    cdef Py_ssize_t node_count
    cdef tuple _pyrefs

    def __cinit__(self, start_state, dict transitions):
        cdef _AcoraUnicodeNodeStruct* c_nodes
        cdef Py_ssize_t i
        self.start_node = NULL
        cdef dict transitions_by_state = group_transitions_by_state(transitions)

        self.node_count = len(transitions_by_state)
        c_nodes = self.start_node = <_AcoraUnicodeNodeStruct*> cpython.mem.PyMem_Malloc(
            sizeof(_AcoraUnicodeNodeStruct) * self.node_count)
        if c_nodes is NULL:
            cpython.exc.PyMem_NoMemory()

        for i in range(self.node_count):
            # required by __dealloc__ in case of subsequent errors
            c_nodes[i].targets = NULL

        node_offsets = dict([ (state, i) for i,state in enumerate(transitions_by_state) ])
        pyrefs = {} # used to keep Python references alive (and intern them)
        for i, (state, state_transitions) in enumerate(transitions_by_state.iteritems()):
            _init_unicode_node(&c_nodes[i], state, state_transitions,
                               c_nodes, node_offsets, pyrefs)

        self._pyrefs = tuple(pyrefs)

    def __dealloc__(self):
        cdef Py_ssize_t i
        if self.start_node is not NULL:
            for i in range(self.node_count):
                if self.start_node[i].targets is not NULL:
                    cpython.mem.PyMem_Free(self.start_node[i].targets)
            cpython.mem.PyMem_Free(self.start_node)

    cpdef finditer(self, unicode data):
        """Iterate over all occurrences of any keyword in the string.
        """
        return _UnicodeAcoraIter(self, data)

    def findall(self, unicode data):
        """Build a list of all occurrences of any keyword in the string.
        """
        return list(self.finditer(data))

cdef class _UnicodeAcoraIter:
    cdef _AcoraUnicodeNodeStruct* current_node
    cdef _AcoraUnicodeNodeStruct* start_node
    cdef Py_ssize_t match_index
    cdef unicode data
    cdef UnicodeAcora acora
    cdef Py_UNICODE* data_char
    cdef Py_UNICODE* data_end

    def __cinit__(self, UnicodeAcora acora, unicode data):
        assert acora.start_node is not NULL and acora.start_node.matches is NULL
        self.acora = acora
        self.start_node = self.current_node = acora.start_node
        self.match_index = 0
        self.data = data
        self.data_char = PyUnicode_AS_UNICODE(data)
        self.data_end = self.data_char + PyUnicode_GET_SIZE(data)

    def __iter__(self):
        return self

    def __next__(self):
        cdef Py_UNICODE* data_char = self.data_char
        cdef Py_UNICODE* data_end = self.data_end
        cdef Py_UNICODE* test_chars
        cdef Py_UNICODE current_char
        cdef int i, found = 0
        cdef _AcoraUnicodeNodeStruct* start_node = self.start_node
        cdef _AcoraUnicodeNodeStruct* current_node = self.current_node
        if current_node.matches is not NULL:
            if current_node.matches[self.match_index] is not NULL:
                return self._build_next_match()
            self.match_index = 0
        with nogil:
            while data_char < data_end:
                current_char = data_char[0]
                data_char += 1
                test_chars = current_node.characters
                if current_char < test_chars[0] \
                        or current_char > test_chars[current_node.char_count-1]:
                    current_node = start_node
                else:
                    for i in range(current_node.char_count):
                        if current_char <= test_chars[i]:
                            if current_char == test_chars[i]:
                                current_node = current_node.targets[i]
                            else:
                                current_node = start_node
                            break
                    else:
                        current_node = start_node
                    if current_node.matches is not NULL:
                        found = 1
                        break
        self.data_char = data_char
        self.current_node = current_node
        if found:
            return self._build_next_match()
        raise StopIteration

    cdef _build_next_match(self):
        match = <unicode> self.current_node.matches[self.match_index]
        self.match_index += 1
        return (match,
                <Py_ssize_t>(self.data_char - PyUnicode_AS_UNICODE(self.data)
                             ) - PyUnicode_GET_SIZE(match))


# bytes data handling

cdef class BytesAcora:
    """Acora search engine for byte data.
    """
    cdef _AcoraBytesNodeStruct* start_node
    cdef Py_ssize_t node_count
    cdef tuple _pyrefs

    def __cinit__(self, start_state, dict transitions):
        cdef _AcoraBytesNodeStruct* c_nodes
        cdef Py_ssize_t i
        self.start_node = NULL
        cdef dict transitions_by_state = group_transitions_by_state(transitions)

        self.node_count = len(transitions_by_state)
        c_nodes = self.start_node = <_AcoraBytesNodeStruct*> cpython.mem.PyMem_Malloc(
            sizeof(_AcoraBytesNodeStruct) * self.node_count)
        if c_nodes is NULL:
            cpython.exc.PyMem_NoMemory()

        for i in range(self.node_count):
            # required by __dealloc__ in case of subsequent errors
            c_nodes[i].targets = NULL

        node_offsets = dict([ (state, i) for i,state in enumerate(transitions_by_state) ])
        pyrefs = {} # used to keep Python references alive (and intern them)
        for i, (state, state_transitions) in enumerate(transitions_by_state.iteritems()):
            _init_bytes_node(&c_nodes[i], state, state_transitions,
                             c_nodes, node_offsets, pyrefs)

        self._pyrefs = tuple(pyrefs)

    def __dealloc__(self):
        cdef Py_ssize_t i
        if self.start_node is not NULL:
            for i in range(self.node_count):
                if self.start_node[i].targets is not NULL:
                    cpython.mem.PyMem_Free(self.start_node[i].targets)
            cpython.mem.PyMem_Free(self.start_node)

    cpdef finditer(self, bytes data):
        return _BytesAcoraIter(self, data)

    def findall(self, bytes data):
        return list(self.finditer(data))

    def filefind(self, f):
        close_file = False
        if not hasattr(f, 'read'):
            f = open(f, 'rb')
            close_file = True
        return _FileAcoraIter(self, f, close_file)

    def filefindall(self, f):
        return list(self.filefind(f))

cdef class _BytesAcoraIter:
    cdef _AcoraBytesNodeStruct* current_node
    cdef _AcoraBytesNodeStruct* start_node
    cdef Py_ssize_t match_index
    cdef bytes data
    cdef BytesAcora acora
    cdef char* data_char
    cdef char* data_end
    cdef char* data_start

    def __cinit__(self, BytesAcora acora, bytes data):
        assert acora.start_node is not NULL and acora.start_node.matches is NULL
        self.acora = acora
        self.start_node = self.current_node = acora.start_node
        self.match_index = 0
        self.data_char = self.data_start = self.data = data
        self.data_end = self.data_char + len(data)

    def __iter__(self):
        return self

    def __next__(self):
        cdef char* data_char = self.data_char
        cdef char* data_end = self.data_end
        cdef char* test_chars
        cdef char current_char
        cdef int i, found = 0
        if self.current_node.matches is not NULL:
            if self.current_node.matches[self.match_index] is not NULL:
                return self._build_next_match()
            self.match_index = 0
        with nogil:
            found = _search_in_bytes(self.start_node, data_end,
                                     &self.data_char, &self.current_node)
        if found:
            return self._build_next_match()
        raise StopIteration

    cdef _build_next_match(self):
        match = <bytes> self.current_node.matches[self.match_index]
        self.match_index += 1
        return (match, <Py_ssize_t>(self.data_char - self.data_start) - len(match))

cdef int _search_in_bytes(_AcoraBytesNodeStruct* start_node,
                          char* data_end,
                          char** _data_char,
                          _AcoraBytesNodeStruct** _current_node) nogil:
    cdef char* data_char = _data_char[0]
    cdef _AcoraBytesNodeStruct* current_node = _current_node[0]
    cdef char* test_chars
    cdef char current_char
    cdef int i, found = 0

    while data_char < data_end:
        current_char = data_char[0]
        data_char += 1
        test_chars = current_node.characters
        if current_char < test_chars[0] \
                or current_char > test_chars[current_node.char_count-1]:
            current_node = start_node
        else:
            for i in range(current_node.char_count):
                if current_char <= test_chars[i]:
                    if current_char == test_chars[i]:
                        current_node = current_node.targets[i]
                    else:
                        current_node = start_node
                    break
            else:
                current_node = start_node
            if current_node.matches is not NULL:
                found = 1
                break
    _data_char[0] = data_char
    _current_node[0] = current_node
    return found

# file data handling

cdef class _FileAcoraIter:
    cdef _AcoraBytesNodeStruct* current_node
    cdef _AcoraBytesNodeStruct* start_node
    cdef Py_ssize_t match_index, read_size, buffer_offset_count
    cdef bytes buffer
    cdef char* c_buffer_pos
    cdef char* c_buffer_end
    cdef object f
    cdef bint close_file
    cdef int c_file
    cdef BytesAcora acora

    def __cinit__(self, BytesAcora acora, f, bint close=False, Py_ssize_t buffer_size=FILE_BUFFER_SIZE):
        assert acora.start_node is not NULL and acora.start_node.matches is NULL
        self.acora = acora
        self.start_node = self.current_node = acora.start_node
        self.match_index = 0
        self.buffer_offset_count = 0
        self.f = f
        self.close_file = close
        try:
            self.c_file = f.fileno()
        except:
            # maybe not a C file?
            self.c_file = -1
        self.read_size = buffer_size
        if self.c_file == -1:
            self.buffer = b''
        else:
            # use a statically allocated, fixed-size C buffer
            self.buffer = b'\0' * buffer_size
        self.c_buffer_pos = self.c_buffer_end = <char*> self.buffer

    def __iter__(self):
        return self

    def __next__(self):
        cdef bytes buffer
        cdef char* c_buffer
        cdef char* data_end
        cdef int error = 0, found = 0
        cdef Py_ssize_t buffer_size, bytes_read = 0
        if self.c_buffer_pos is NULL:
            raise StopIteration
        if self.current_node.matches is not NULL:
            if self.current_node.matches[self.match_index] is not NULL:
                return self._build_next_match()
            self.match_index = 0

        buffer_size = len(self.buffer)
        c_buffer = <char*> self.buffer
        if self.c_file != -1:
            with nogil:
                found = _find_next_match_in_cfile(
                    self.c_file, c_buffer, buffer_size, self.start_node,
                    &self.c_buffer_pos, &self.c_buffer_end,
                    &self.buffer_offset_count, &self.current_node, &error)
            if error:
                cpython.exc.PyErr_SetFromErrno(IOError)
        else:
            data_end = c_buffer + buffer_size
            while not found:
                if self.c_buffer_pos >= data_end:
                    self.buffer_offset_count += buffer_size
                    self.buffer = self.f.read(self.read_size)
                    buffer_size = len(self.buffer)
                    if buffer_size == 0:
                        self.c_buffer_pos = NULL
                        break
                    c_buffer = self.c_buffer_pos = <char*> self.buffer
                    data_end = c_buffer + buffer_size
                with nogil:
                    found = _search_in_bytes(
                        self.start_node, data_end,
                        &self.c_buffer_pos, &self.current_node)
        if self.c_buffer_pos is NULL:
            if self.close_file:
                self.f.close()
        elif found:
            return self._build_next_match()
        raise StopIteration

    cdef _build_next_match(self):
        match = <bytes> self.current_node.matches[self.match_index]
        self.match_index += 1
        return (match, self.buffer_offset_count + (
                self.c_buffer_pos - (<char*> self.buffer)) - len(match))


cdef int _find_next_match_in_cfile(int c_file, char* c_buffer, size_t buffer_size,
                                   _AcoraBytesNodeStruct* start_node,
                                   char** _buffer_pos, char** _buffer_end,
                                   Py_ssize_t* _buffer_offset_count,
                                   _AcoraBytesNodeStruct** _current_node,
                                   int* error) nogil:
    cdef char* buffer_pos = _buffer_pos[0]
    cdef char* buffer_end = _buffer_end[0]
    cdef char* data_end = c_buffer + buffer_size
    cdef Py_ssize_t buffer_offset_count = _buffer_offset_count[0]
    cdef _AcoraBytesNodeStruct* current_node = _current_node[0]
    cdef int found = 0
    cdef Py_ssize_t bytes_read

    while not found:
        if buffer_pos >= buffer_end:
            buffer_offset_count += buffer_end - c_buffer
            bytes_read = read(c_file, c_buffer, buffer_size)
            if bytes_read <= 0:
                if bytes_read < 0:
                    error[0] = 1
                buffer_pos = NULL
                break
            buffer_pos = c_buffer
            buffer_end = c_buffer + bytes_read

        found = _search_in_bytes(
            start_node, buffer_end, &buffer_pos, &current_node)

    _current_node[0] = current_node
    _buffer_offset_count[0] = buffer_offset_count
    _buffer_pos[0] = buffer_pos
    _buffer_end[0] = buffer_end
    return found
