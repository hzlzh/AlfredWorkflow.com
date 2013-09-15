import alp
import sys
import os
import search

SETTINGS_FILE = "settings.plist"
SETTINGS_PATH = os.path.join(alp.local(), SETTINGS_FILE)


def setKeyChainPassword(password):
    keychain = alp.Keychain(alp.bundle())
    settings = alp.readPlist(SETTINGS_PATH)
    username = settings["username"]

    if settings["passwordSet"] == "true":
        keychain.modifyPassword(username, password)
    else:
        keychain.storePassword(username, password)
        settings["passwordSet"] = "true"

    settings["credentialsChanged"] = "true"
    alp.writePlist(settings, SETTINGS_PATH)


def getKeyChainPassword():
    keychain = alp.Keychain(alp.bundle())
    settings = alp.readPlist(SETTINGS_PATH)
    return keychain.retrievePassword(settings["username"])


def setUserName(username):
    settings = alp.readPlist(SETTINGS_PATH)
    settings["username"] = username
    settings["credentialsChanged"] = "true"
    alp.writePlist(settings, SETTINGS_PATH)


def setUpdateDatabase():
    settings = alp.readPlist(SETTINGS_PATH)
    settings["updateClips"] = "true"
    alp.writePlist(settings, SETTINGS_PATH)


def main():
    args = sys.argv[1:]

    if len(args) < 1:
        print "Error"

    # Check if settings file exists
    search.createSettingsFile()

    if args[0] == "username":
        setUserName(args[1])
        print "Set Username to: " + args[1]
    elif args[0] == "password":
        setKeyChainPassword(args[1])
        print "Set Password to: " + args[1]
    elif args[0] == "update":
        setUpdateDatabase()
        print "Clips will be updated on next search"
    else:
        print "Error"


if __name__ == '__main__':
    main()
