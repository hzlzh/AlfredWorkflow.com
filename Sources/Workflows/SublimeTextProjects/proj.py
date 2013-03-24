import os
import alp
import re
from alp.item import Item as I
import codecs
import json

def find_projects():
    q = alp.args()[0] if len(alp.args()) else ""

    if os.path.exists("/Applications/Sublime Text.app"):
        session_path = "~/Library/Application Support/Sublime Text 3/Local/Session.sublime_session"
        session_path = os.path.expanduser(session_path)
    elif os.path.exists("/Applications/Sublime Text 2.app"):
        session_path = "~/Library/Application Support/Sublime Text 2/Settings/Session.sublime_session"
        session_path = os.path.expanduser(session_path)
    else:
        alp.feedback(I(title="No Sublime Installation",
                        subtitle="Sublime Text 2 or 3 is required.",
                        valid=False))
        return

    with codecs.open(session_path, "r", "utf-8") as f:
        projects = json.load(f)["workspaces"]["recent_workspaces"]

    projectNames = []
    for project in projects:
        projPath = project
        (projPath, projFile) = os.path.split(projPath)
        (projTitle, _) = projFile.rsplit(".", 1)
        projPath = os.path.join(projPath, projTitle + ".sublime-project")
        projectNames.append((projPath, projTitle))

    items = []
    for path, title in projectNames:
        if re.match("(?i).*%s.*" % q, path) or re.match("(?i).*%s.*" % q, title) or len(q) == 0:
            items.append(I(title=title,
                            subtitle=path,
                            arg=path,
                            valid=True,
                            uid=path))

    if len(items):
        alp.feedback(items)
    else:
        alp.feedback(I(title="No Matches",
                        subtitle="No recent projects matched your query.",
                        valid=False))


if __name__ == "__main__":
    find_projects()
