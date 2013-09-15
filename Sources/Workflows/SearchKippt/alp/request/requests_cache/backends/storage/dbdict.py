#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
    requests_cache.backends.dbdict
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Dictionary-like objects for saving large data sets to `sqlite` database
"""
from collections import MutableMapping
import sqlite3 as sqlite
from contextlib import contextmanager
try:
   import threading
except ImportError:
    import dummy_threading as threading
try:
    import cPickle as pickle
except ImportError:
    import pickle

from alp.request.requests_cache.compat import bytes



class DbDict(MutableMapping):
    """ DbDict - a dictionary-like object for saving large datasets to `sqlite` database

    It's possible to create multiply DbDict instances, which will be stored as separate
    tables in one database::

        d1 = DbDict('test', 'table1')
        d2 = DbDict('test', 'table2')
        d3 = DbDict('test', 'table3')

    all data will be stored in ``test.sqlite`` database into
    correspondent tables: ``table1``, ``table2`` and ``table3``
    """

    def __init__(self, filename, table_name='data', fast_save=False, **options):
        """
        :param filename: filename for database (without extension)
        :param table_name: table name
        :param fast_save: If it's True, then sqlite will be configured with
                          `"PRAGMA synchronous = 0;" <http://www.sqlite.org/pragma.html#pragma_synchronous>`_
                          to speedup cache saving, but be careful, it's dangerous.
                          Tests showed that insertion order of records can be wrong with this option.
        """
        self.filename = filename
        self.table_name = table_name
        self.fast_save = fast_save
        
        #: Transactions can be commited if this property is set to `True`
        self.can_commit = True

        
        self._bulk_commit = False
        self._pending_connection = None
        self._lock = threading.RLock()
        with self.connection() as con:
            con.execute("create table if not exists `%s` (key PRIMARY KEY, value)" % self.table_name)


    @contextmanager
    def connection(self, commit_on_success=False):
        with self._lock:
            if self._bulk_commit:
                if self._pending_connection is None:
                    self._pending_connection = sqlite.connect(self.filename)
                con = self._pending_connection
            else:
                con = sqlite.connect(self.filename)
            try:
                if self.fast_save:
                    con.execute("PRAGMA synchronous = 0;")
                yield con
                if commit_on_success and self.can_commit:
                    con.commit()
            finally:
                if not self._bulk_commit:
                    con.close()

    def commit(self, force=False):
        """
        Commits pending transaction if :attr:`can_commit` or `force` is `True`

        :param force: force commit, ignore :attr:`can_commit`
        """
        if force or self.can_commit:
            if self._pending_connection is not None:
                self._pending_connection.commit()

    @contextmanager
    def bulk_commit(self):
        """
        Context manager used to speedup insertion of big number of records
        ::

            >>> d1 = DbDict('test')
            >>> with d1.bulk_commit():
            ...     for i in range(1000):
            ...         d1[i] = i * 2

        """
        self._bulk_commit = True
        self.can_commit = False
        try:
            yield
            self.commit(True)
        finally:
            self._bulk_commit = False
            self.can_commit = True
            self._pending_connection.close()
            self._pending_connection = None

    def __getitem__(self, key):
        with self.connection() as con:
            row = con.execute("select value from `%s` where key=?" %
                              self.table_name, (key,)).fetchone()
            if not row:
                raise KeyError
            return row[0]

    def __setitem__(self, key, item):
        with self.connection(True) as con:
            if con.execute("select key from `%s` where key=?" %
                           self.table_name, (key,)).fetchone():
                con.execute("update `%s` set value=? where key=?" %
                            self.table_name, (item, key))
            else:
                con.execute("insert into `%s` (key,value) values (?,?)" %
                            self.table_name, (key, item))

    def __delitem__(self, key):
        with self.connection(True) as con:
            if con.execute("select key from `%s` where key=?" %
                           self.table_name, (key,)).fetchone():
                con.execute("delete from `%s` where key=?" %
                            self.table_name, (key,))
            else:
                raise KeyError

    def __iter__(self):
        with self.connection() as con:
            for row in con.execute("select key from `%s`" %
                                   self.table_name):
                yield row[0]

    def __len__(self):
        with self.connection() as con:
            return con.execute("select count(key) from `%s`" %
                                self.table_name).fetchone()[0]

    def clear(self):
        with self.connection(True) as con:
            con.execute("drop table `%s`" % self.table_name)
            con.execute("create table `%s` (key PRIMARY KEY, value)" %
                        self.table_name)

    def __str__(self):
        return str(dict(self.items()))


class DbPickleDict(DbDict):
    """ Same as :class:`DbDict`, but pickles values before saving
    """
    def __setitem__(self, key, item):
        super(DbPickleDict, self).__setitem__(key,
                                              sqlite.Binary(pickle.dumps(item)))

    def __getitem__(self, key):
        return pickle.loads(bytes(super(DbPickleDict, self).__getitem__(key)))
