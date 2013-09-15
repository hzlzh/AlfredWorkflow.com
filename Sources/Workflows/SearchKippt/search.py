from kippt.kippt import Kippt
import alp
import os
import sqlite3 as lite
import utils

##
# Constants
##

SETTINGS_FILE = "settings.plist"
SETTINGS_PATH = os.path.join(alp.local(), SETTINGS_FILE)
DEFAULT_SETTINGS = dict(
    username="",
    sqliteDB="kippt.sqlite",
    lastUpdate="",
    updateClips="false",
    firstRun="true",
    credentialsChanged="false",
    passwordSet="false"
    )

# Global settings object
settings = None


def createSettingsFile():
    """
    Creates the default settings file, if it doesn't exists.
    """
    # Check if the settings file exists
    try:
        with open(SETTINGS_PATH):
            pass
    except IOError:
        # No, settings file. Create the file and load the default settings.
        file = open(SETTINGS_PATH, 'w+')
        file.close()
        alp.writePlist(DEFAULT_SETTINGS, SETTINGS_PATH)


def createDatabase():
    """
    Creates an empty database.
    """
    global settings
    conn = lite.connect(settings["sqliteDB"])

    with conn:
        cur = conn.cursor()
        cur.execute("CREATE TABLE Clips(Id INTEGER PRIMARY KEY, Title TEXT, Subtitle TEXT, Url TEXT, AppUrl TEXT, Notes TEXT)")


def udpateDatabaseFromKippt():
    """
    Update the SQlite database with all clips from Kippt.
    """
    global settings

    # Check if database exists; if not, create it.
    if not os.path.exists(os.path.join(alp.local(), settings["sqliteDB"])):
        createDatabase()

    clips = readAllClips()

    if clips == None:
        return

    conn = lite.connect(settings["sqliteDB"])

    with conn:
        cur = conn.cursor()

        # Remove old clips
        cur.execute("DELETE FROM Clips")

        # Add all clips
        for clip in clips:
            title = clip["title"]
            subtitle = clip["title"]
            url = clip["url"]
            app_url = clip["app_url"]
            notes = clip["notes"]

            sql = "INSERT INTO Clips VALUES(NULL,"
            sql += "\"%s\"," % title
            sql += "\"%s\"," % subtitle
            sql += "\"%s\"," % url
            sql += "\"%s\"," % app_url
            sql += "\"%s\"" % notes
            sql += ")"

            cur.execute(sql)


def readAllClips():
    """
    Reads all clips from Kippt.
    """
    global settings

    k = Kippt(settings["username"], password=utils.getKeyChainPassword())
    clips = k.clips().all()

    # First, read the total count of clips
    count = clips["meta"]["total_count"]

    # Now, get all clips
    clips = k.clips().all(limit=count)

    return clips["objects"]


def search(keywords):
    """
    Performs a search with the given keywords in the database. Returns the found clips
    as Alfred Items (XML).
    """
    global settings

    if len(keywords) < 1:
        return None

    conn = lite.connect(settings["sqliteDB"])

    titles = []
    urls = []
    notes = []
    for word in keywords:
        titles.append("Title LIKE \"%%%s%%\"" % word)
        urls.append("Url LIKE \"%%%s%%\"" % word)
        notes.append("Notes LIKE \"%%%s%%\"" % word)

    titles = " AND ".join(titles)
    urls = " AND ".join(urls)
    notes = " AND ".join(notes)

    sql = "SELECT Title, Subtitle, Url, AppUrl"
    sql += " FROM Clips"
    sql += " WHERE (%s) OR" % titles
    sql += "  (%s) OR " % urls
    sql += "  (%s)" % notes

    alfredItems = []
    with conn:
        cur = conn.cursor()
        cur.execute(sql)

        rows = cur.fetchall()
        for row in rows:
            itemDict = dict(title=row[0],
                subtitle=row[1],
                arg=row[2],
                valid=True)
            item = alp.Item(**itemDict)
            alfredItems.append(item)

    return alfredItems
            


def main():
    """
    Everything dispatches from this function.
    """
    global settings

    # Create default settings if necessary
    createSettingsFile()

    # Read settings
    settings = alp.readPlist(SETTINGS_PATH)

    # Process the settings
    if settings["firstRun"] == "true":
        udpateDatabaseFromKippt()
        settings["firstRun"] = "false"
        settings["credentialsChanged"] = "false"
        alp.writePlist(settings, SETTINGS_PATH)
    elif settings["credentialsChanged"] == "true":
        udpateDatabaseFromKippt()
        settings["credentialsChanged"] = "false"
        alp.writePlist(settings, SETTINGS_PATH)
    elif settings["updateClips"] == "true":
        udpateDatabaseFromKippt()
        settings["updateClips"] = "false"
        alp.writePlist(settings, SETTINGS_PATH)

    # Get the keywords
    args = alp.args()
    if len(args) < 1:
        return

    # Execute the search
    items = search(args)
    if items is not None:
        alp.feedback(items)
    else:
        print "No items found"


if __name__ == '__main__':
    # Let's start!
    main()
