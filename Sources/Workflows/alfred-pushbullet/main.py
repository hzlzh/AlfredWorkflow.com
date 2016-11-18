# -*- coding: utf-8 -*-

try:
    import alfred
    import sys
    sys.path.append('lib')
    from lib.pushbullet import Pushbullet
    from lib.pushbullet.errors import InvalidKeyError
    from lib.requests.exceptions import ConnectionError
except ImportError as e:
    print e
    sys.exit()

args = alfred.args()
if len(args) != 3:
    print 'Wrong number of parameters.'
    sys.exit()

apiKey     = args[0]
deviceName = args[1]
text       = args[2]

try:
    api = Pushbullet(apiKey)
except InvalidKeyError:
    print 'API key is invalid.'
    sys.exit()
except ConnectionError:
    print 'Failed connecting to pushbullet.'
    sys.exit()

try:
    device = api.get_device(deviceName)
except InvalidKeyError:
    print 'Device %s not found.' % deviceName
    sys.exit()

try:
    device.push_note('', text)
    print 'Text pushed to %s.' % deviceName
except Exception as e:
    print e
    sys.exit()
