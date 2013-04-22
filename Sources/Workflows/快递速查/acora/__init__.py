"""\
Acora - a multi-keyword search engine based on Aho-Corasick trees
and NFA2DFA powerset construction.

Usage::

    >>> from acora import AcoraBuilder

Collect some keywords::

    >>> builder = AcoraBuilder('ab', 'bc', 'de')
    >>> builder.add('a', 'b')

Generate the Acora search engine::

    >>> ac = builder.build()

Search a string for all occurrences::

    >>> ac.findall('abc')
    [('a', 0), ('ab', 0), ('b', 1), ('bc', 1)]
    >>> ac.findall('abde')
    [('a', 0), ('ab', 0), ('b', 1), ('de', 2)]
"""

try:
    unicode
except NameError:
    unicode = str

FILE_BUFFER_SIZE = 32 * 1024

class PyAcora(object):
    """A simple (and very slow) Python implementation of the Acora
    search engine.
    """
    def __init__(self, start_state, transitions):
        self.start_state = start_state.id
        self.transitions = dict([
                ((state.id, char), (target_state.id, target_state.matches))
                for ((state, char), target_state) in transitions.items() ])

    def finditer(self, s):
        """Iterate over all occurrences of any keyword in the string.

        Returns (keyword, offset) pairs.
        """
        state = self.start_state
        start_state = (state, [])
        next_state = self.transitions.get
        pos = 0
        for char in s:
            pos += 1
            state, matches = next_state((state,char), start_state)
            if matches:
                for match in matches:
                    yield (match, pos-len(match))

    def findall(self, s):
        """Find all occurrences of any keyword in the string.

        Returns a list of (keyword, offset) pairs.
        """
        return list(self.finditer(s))

    def filefind(self, f):
        """Iterate over all occurrences of any keyword in a file.

        Returns (keyword, offset) pairs.
        """
        opened = False
        if not hasattr(f, 'read'):
            f = open(f, 'rb')
            opened = True

        try:
            state = self.start_state
            start_state = (state, ())
            next_state = self.transitions.get
            pos = 0
            while 1:
                data = f.read(FILE_BUFFER_SIZE)
                if not data:
                    break
                for char in data:
                    pos += 1
                    state, matches = next_state((state,char), start_state)
                    if matches:
                        for match in matches:
                            yield (match, pos-len(match))
        finally:
            if opened:
                f.close()

    def filefindall(self, f):
        """Find all occurrences of any keyword in a file.

        Returns a list of (keyword, offset) pairs.
        """
        return list(self.filefind(f))

try:
    from acora._nfa2dfa import nfa2dfa, insert_keyword, NfaState
except ImportError:
    # C module not there ...
    from acora.nfa2dfa import nfa2dfa, insert_keyword, NfaState
try:
    from acora._acora import UnicodeAcora, BytesAcora
except ImportError:
    # C module not there ...
    UnicodeAcora = BytesAcora = PyAcora

class AcoraBuilder(object):
    """The main builder class for an Acora search engine.

    Add keywords by calling ``.add(*keywords)`` or by passing them
    into the constructor. Then build the search engine by calling
    ``.build()``.
    """
    def __init__(self, *keywords):
        if len(keywords) == 1 and isinstance(keywords[0], (list, tuple)):
            keywords = keywords[0]
        self.for_unicode = None
        self.keywords = list(keywords)
        self.state_counter = 1
        self.tree = NfaState(0)
        self._insert_all(self.keywords)

    def add(self, *keywords):
        """Add more keywords to the search engine builder.

        Adding keywords does not impact previously built search
        engines.
        """
        self.keywords.extend(keywords)
        self._insert_all(keywords)

    def build(self, ignore_case=False, acora=None):
        """Build a search engine from the aggregated keywords.

        Builds a case insensitive search engine when passing
        ``ignore_case=True``, and a case sensitive engine otherwise.
        """
        if acora is None:
            if self.for_unicode:
                acora = UnicodeAcora
            else:
                acora = BytesAcora
        if self.for_unicode == False and ignore_case:
            import sys
            if sys.version_info[0] >= 3:
                raise ValueError("Case insensitive search is not supported for byte strings in Python 3")
        return acora(*nfa2dfa(self.tree, ignore_case))

    def _insert_all(self, keywords):
        for keyword in keywords:
            if self.for_unicode is None:
                self.for_unicode = isinstance(keyword, unicode)
            elif self.for_unicode != isinstance(keyword, unicode):
                raise TypeError(
                    "keywords must be either bytes or unicode, not mixed (got %s)" %
                    type(keyword))
            self.state_counter = insert_keyword(
                self.tree, keyword, self.state_counter)

### convenience functions

def search(s, *keywords):
    """Convenience function to search a string for keywords.
    """
    acora  = AcoraBuilder(keywords).build()
    return acora.findall(s)

def search_ignore_case(s, *keywords):
    """Convenience function to search a string for keywords.  Case
    insensitive version.
    """
    acora  = AcoraBuilder(keywords).build(ignore_case=True)
    return acora.findall(s)
