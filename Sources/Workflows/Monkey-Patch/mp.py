#!/usr/bin/env python
# -*- coding: utf-8 -*-

import alfred
import os
import plistlib
import json
import codecs
import urllib2
import logging
import inspect
from subprocess import call
import tempfile
import shutil
import logging.handlers
import threading
import Queue

class Workflow():

    def __init__(self, dirname):
        self.dirname = dirname
        self.alleyoop = False
        plist_file = 'info.plist' if os.path.exists(os.path.join(dirname, 'info.plist')) else 'Info.plist'
        plist_file = os.path.join(dirname, plist_file)
        if os.path.exists(plist_file):
            plist = plistlib.readPlist(plist_file)
            self.name = plist['name']
            self.disabled = plist.get('disabled', False)
            self.description = plist['description']
            self.icon = os.path.join(dirname, 'icon.png')
            if not self.disabled:
                # hunt for update.json
                for (b, d, f) in os.walk(self.dirname):
                    if 'update.json' in f:
                        try:
                            with codecs.open(os.path.join(b, 'update.json'), "r", "utf-8") as f:
                                info = json.load(f)
                                self.alleyoop = True
                                self.version = info['version']
                                self.remote = info['remote_json']
                                autolog('%s is Alleyoop compatible' % self.name)
                            break
                        except Exception, e:
                            autolog('%s invalid update.json - %s' % (self.name, str(e)))
        else:
            autolog('no info.plist found at ' + dirname)

    def check_for_update(self):
        if self.disabled:
            return
        self.has_update = False
        self.has_check_errors = False
        self.error = ''
        if self.alleyoop:
            try:
                autolog('%s checking for update' % self.name)
                autolog('%s remote url - %s' % (self.name, self.remote))
                update_data = json.loads(urllib2.urlopen(self.remote).read())
                if self.version < update_data['version']:
                    self.has_update = True
                    self.update = {}
                    self.update['version'] = update_data['version']
                    self.update['description'] = update_data['description']
                    if 'download_url' in update_data:
                        self.update['download'] = update_data['download_url']
                        autolog('%s download_url - %s' % (self.name, self.update['download']))
                    else:
                        self.update['download'] = update_data['download_uri']
                        autolog('%s download_uri - %s' % (self.name, self.update['download']))
                else:
                    autolog('%s already on latest version - %f' % (self.name, self.version))
            except Exception, e:
                self.has_check_errors = True
                self.error = 'Could not check for updates'
                autolog('%s error when checking for update - %s' % (self.name, str(e)))
        return self.has_update

    def to_dict(self):
        ignored = ['check_for_update', 'to_dict', 'log']
        attributes = [c for c in dir(self) if not c.startswith('_') and c not in ignored]
        d = {}
        for a in attributes:
            d[a] = getattr(self, a)
        return d


def show_options():
    """Displays initial options"""
    feedback = alfred.Feedback()
    feedback.addItem(title='List compatible workflows', autocomplete='list', valid='no')
    feedback.addItem(title='Check for updates', subtitle='This may take a while...' if get_updateable_timeout() <= 10.0 else '', autocomplete='update', valid='no')
    feedback.addItem(title='Reset cache', autocomplete='reset', valid='no')
    feedback.addItem(title='View log', autocomplete='log', valid='no')
    feedback.output()


def get_compatible():
    """Gets a list if compatible workflows"""
    basedir = os.path.dirname(os.path.abspath('.'))
    workflow_dirs = [f for f in os.listdir(basedir) if os.path.isdir(os.path.join(basedir, f))]
    workflows = []
    for d in workflow_dirs:
        workflows.append(Workflow(os.path.join(basedir, d)))
    workflows = [w for w in workflows if w.alleyoop]
    autolog('found %s compatible workflows' % len(workflows))
    return sorted(workflows, key=lambda x: x.name)


def list_compatible():
    """Displays all Alleyoop compatible workflows"""
    workflows = get_compatible()
    feedback = alfred.Feedback()
    for w in workflows:
        subtitle = 'v' + unicode(w.version) + ' ' + w.description
        feedback.addItem(title=w.name, subtitle=subtitle, icon=w.icon, valid='no')

    if feedback.isEmpty():
        feedback.addItem(title='No compatible workflows found', valid='no', autocomplete='')
    else:
        feedback.addItem(title='Go back', valid='no', icon='back.png', autocomplete='')
    feedback.output()


def check_update(work_q, done_q, total):
    while True:
        w = work_q.get()
        w.check_for_update()
        done_q.put(w)
        work_q.task_done()


def cache_updateable():
    work_q = Queue.Queue()
    done_q = Queue.Queue()
    workflows = get_compatible()

    # create a fixed numbner of threads
    for i in range(10):
        t = threading.Thread(target=check_update, args=(work_q, done_q, len(workflows)))
        t.daemon = True
        t.start()


    alfred.notify("Monkey Patch", "Checking updates for %i workflows" % (len(workflows)), text='Please wait...', sound=False)
    for i, w in enumerate(workflows):
        # w.check_for_update()
        work_q.put(w)

    work_q.join()
    alfred.notify("Monkey Patch", "Checking updates done", sound=False)

    workflows = [w.to_dict() for w in workflows if w.has_update or w.has_check_errors]
    alfred.cache.set('workflow.update', workflows, expire=86400)


def get_updateable(force=True):
    cache_timeout = get_updateable_timeout()
    autolog('cache_timeout is: ' + str(cache_timeout))
    if force and cache_timeout == -1:
        cache_updateable()
    if not force and cache_timeout == -1:
        return None
    return alfred.cache.get('workflow.update')


def get_updateable_timeout():
    return alfred.cache.timeout('workflow.update')


def list_updates():
    """Displays all available updates"""
    workflows = get_updateable()
    feedback = alfred.Feedback()
    # if we have at least one item with updates
    valid_updates = [w for w in workflows if w['has_update'] and not w['has_check_errors']]
    if len(valid_updates) > 0:
        feedback.addItem(title='Download', valid='yes', arg='download-all')
    for w in workflows:
        if w['has_update'] and not w['has_check_errors']:
            subtitle = 'v' + str(w['version']) + u' ➔ ' + str(w['update']['version']) + ' ' + w['update']['description']
            feedback.addItem(title=w['name'], subtitle=subtitle, icon=w['icon'], arg='download "%s"' % w['dirname'])
        elif w['has_check_errors']:
            feedback.addItem(title=w['name'], subtitle=w['error'], icon='bad.png', valid='no', arg=w['dirname'])
    if feedback.isEmpty():
        feedback.addItem(title='All your workflows are up to date', valid='no', icon='uptodate.png', autocomplete='')
    else:
        feedback.addItem(title='Go back', valid='no', icon='back.png', autocomplete='')
    feedback.output()


def reset():
    """Resets the cache"""
    show_state('Resetting...')
    alfred.cache.delete('workflow.update')
    alfred.show('mp ')


def logfile():
    return os.path.join(alfred.work(False), 'monkeypatch_log.txt')

def show_state(state):
    feedback = alfred.Feedback()
    feedback.addItem(title='state')
    feedback.output()


def openlog():
    show_state('Opening log folder...')
    call(['open', os.path.dirname(logfile())])


def autolog(message):
    """Automatically log the current function details."""
    # Get the previous frame in the stack, otherwise it would
    # be this function!!!
    func = inspect.currentframe().f_back.f_code
    # Dump the message + the name of this function to the log.
    logging.debug("%s: %s() in %s:%i" % (
        message,
        func.co_name,
        func.co_filename,
        func.co_firstlineno
    ))


def download_all():
    """Downloads all available updates"""
    workflows = get_updateable()
    workflows = [w for w in workflows if w['has_update'] and not w['has_check_errors']]
    for i, w in enumerate(workflows):
        download(w['dirname'], w_cached=w, current=i+1, total=len(workflows))
    print "Updates downloaded"


def download(w_dir, w_cached=None, direct=False, current=None, total=None):
    try:
        if w_cached is None:
            workflows = get_updateable()
            w_cached = [w for w in workflows if w['has_update'] and not w['has_check_errors'] and w['dirname'] == w_dir][0]

        w = w_cached

        download_file = os.path.join(os.path.expanduser("~/Downloads"), "{0} v{1}.alfredworkflow".format(w['name'], w['update']['version']))
        if os.path.exists(download_file):
            os.remove(download_file)

        tmp = tempfile.mkdtemp()
        f = tempfile.NamedTemporaryFile(suffix=".alfredworkflow", dir=tmp, delete=False)
        f.write(urllib2.urlopen(w['update']['download']).read())
        f.close()
        shutil.copy(f.name, download_file)

        info = "Downloaded"
        if current is not None and total is not None:
            info = "Downloaded %i of %i" % (current, total)
        alfred.notify("Monkey Patch", info, text=os.path.basename(download_file), sound=False)
        autolog(info + ' ' + os.path.basename(download_file))

        # we can remove this entry from our cache
        if direct:
            updateables = get_updateable(force=False)
            if updateables is not None:
                for i, u in enumerate(updateables):
                    if u['dirname'] == w['dirname']:
                        del updateables[i]
                        break
                alfred.cache.set('workflow.update', updateables, expire=86400)
            call(['open', download_file])
    except Exception, e:
        w_name = w_dir
        if w is not None:
            w_name = w['name']
        autolog('error while trying to download %s - %s' % (w_name, str(e)))
        alfred.notify("Monkey Patch", "Download error", text=w_name, sound=False)


def main():
    logging.basicConfig(filename=logfile(), level=logging.DEBUG)
    try:
        args = alfred.args()
        command, options = (args[0:]) if len(args) > 1 else (args[0], None)
        command_switch = {
            'list': lambda x: list_compatible(),
            'update': lambda x: list_updates(),
            'reset': lambda x: reset(),
            'log': lambda x: openlog(),
            'download-all': lambda x: download_all(),
            'download': lambda w: download(w, direct=True)
        }
        if command in command_switch:
            command_switch[command](options)
        else:
            show_options()

    except Exception, e:
        print str(e)
        autolog(str(e))

if __name__ == '__main__':
    main()
