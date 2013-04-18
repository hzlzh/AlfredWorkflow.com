import alfred
import subprocess
import search
import sys

workflows = search.get_cache()
workflows = [w for w in workflows if w['download'] == sys.argv[1]]
if len(workflows) > 0:
    command = "open " + workflows[0]['release']
    subprocess.call(command, shell=True)
