import alp
from alp.request import requests
import json
import sys

from datetime import datetime, timedelta
import time

settings = alp.Settings()
tkn = settings.get('token')

ACTION_STRINGS = [
    'start',
    'stop',
    'token',
    'timers',
    'execute'
]

ACTIONS = [
    alp.Item(title='Start Timer', subtitle='Start a new Toggl Timer', valid=False, autocomplete='start'),
    alp.Item(title='Stop Timer', subtitle='Stop the current Toggl Timer', valid=False, autocomplete='stop', arg='stop'),
    alp.Item(title='Set Token', subtitle='Set the current Toggl Token', valid=False, autocomplete='token'),
    alp.Item(title='Previous Timers', subtitle='Restart an old timer', valid=False, autocomplete='timers'),
]

def toDateTime(timestamp):
    return datetime.strptime(timestamp, '%Y-%m-%dT%H:%M:%S+00:00')

def toString(timestamp):
    return datetime.strftime(timestamp, '%Y-%m-%dT%H:%M:%S+00:00')

def timestamp(date):
    return time.mktime(date.timetuple())

def computeDuration(timer):
    start = toDateTime(timer['start'])
    stop  = toDateTime(timer['stop'])

    return (stop - start).total_seconds()

def fetchTimers():
    if tkn is None:
        return 'Please set Token via \'tgl token <TOKEN>\''
    else:
        timers = requests.get('https://www.toggl.com/api/v8/time_entries', auth=(tkn, 'api_token'))
        if timers.status_code == 200:
            items = []
            for timer in timers.json:
                subtitle = 'No longer running'
                if timer['duration'] < 0:
                    subtitle = 'Currently running'
                items.append(alp.Item(title=timer['description'], subtitle=subtitle, valid=timer['duration'] >= 0, arg='start %s' % timer['description']))

            return alp.feedback(items)


def stopTimer():
    if tkn is None:
        return 'Please set Token via \'tgl token <TOKEN>\''
    else:
        timer = requests.get('https://www.toggl.com/api/v8/time_entries', auth=(tkn, 'api_token'))
        if timer.status_code == 200:
            current = timer.json[len(timer.json)-1]
            alp.log(current)
            if 'stop' in current:
                return 'No currently running timer'
            else:
                current['stop'] = toString(datetime.utcnow())
                current['duration'] = computeDuration(current)
                res = requests.put('https://www.toggl.com/api/v8/time_entries/%s' % current['id'], auth=(tkn, 'api_token'), data=json.dumps({'time_entry':current}))

                return "Stopped current timer %s" %  current['description']


def startTimer(value):
    if tkn is None:
        return 'Please set Token via \'tgl token <TOKEN>\''
    else:
        wrk = requests.get('https://www.toggl.com/api/v8/workspaces', auth=(tkn, 'api_token'))
        if wrk.status_code == 200:
            default_wrk = wrk.json[0]['id']

            timer = {"time_entry":{"description":value,"duration":-1 * timestamp(datetime.now()),"start":toString(datetime.utcnow()), "wid":default_wrk, "created_with": "Alfred Toggl"}}

            res = requests.post('https://www.toggl.com/api/v8/time_entries', auth=(tkn, 'api_token'), data=json.dumps(timer))

            return 'New Timer Started at %s' % datetime.utcnow().isoformat()

def executeFunction(args):
    cmd = args[2]
    if cmd == 'start':
        return startTimer(' '.join(args[3:]))
    elif cmd == 'token':
        settings.set(token=args[3])
        return 'Token has been set to %s' % args[3]
    elif cmd == 'stop':
        return stopTimer()
    else:
        return startTimer(' '.join(args[2:]))

alp.log(sys.argv)
if sys.argv[1] not in ACTION_STRINGS:
    print alp.feedback(ACTIONS)
else:
    if sys.argv[1] == 'start':
        item = alp.Item(title='Start Timer \'%s\'' % ' '.join(sys.argv[2:]), subtitle='Start a new Toggl Timer', valid=(len(sys.argv) > 2), arg='start %s' % ' '.join(sys.argv[2:]))
        print alp.feedback([item])
    elif sys.argv[1] == 'stop':
        item = alp.Item(title='Stop Timer', subtitle='Stop the current Toggl Timer', valid=True, autocomplete='stop', arg='stop')
        print alp.feedback([item])
    elif sys.argv[1] == 'token':
        item = alp.Item(title='Set Token to \'%s\'' % ' '.join(sys.argv[2:]), subtitle='Set your Toggl Token', valid=(len(sys.argv) == 3), arg='token %s' % ' '.join(sys.argv[2:]))
        print alp.feedback([item])
    elif sys.argv[1] == 'timers':
        print fetchTimers()
    elif sys.argv[1] == 'execute':
        print executeFunction(sys.argv)
