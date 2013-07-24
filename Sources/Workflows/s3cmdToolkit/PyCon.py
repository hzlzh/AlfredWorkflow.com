#
# Program:          PyCon.py
#
# Description:    This program take want is piped to it and displays it in a window. This makes it easy
#                         to run cli programs and give the output to the user.
#
import sys, string
import Tkinter
import string, sys, errno, fcntl, os
import time
from threading import Thread

tk = Tkinter

fnta = ("Arial", 12)

class clsMainFrame(tk.Frame):
    def __init__(self, master):
        self.parent = master
        tk.Frame.__init__(master)
        self.text = tk.Text(master, height=20, width=100, font= fnta, bg="black", fg="green")
        exitBtn = tk.Button(master, text = 'Exit', command = master.quit)
        exitBtn.pack(side = 'right')

    def add(self, message):
        self.text.insert(tk.END, message)
        self.text.pack()

def readInput(event=None):
    global app
    mystr = ""
    try: mystr = sys.stdin.read()
    except IOError, (errnum, str):
        if errnum != errno.EAGAIN: raise
    app.add(mystr)

#
# Set up the graphics.
#
root =tk.Tk()
root.title ("Python Command Line Console")
Frm = tk.Frame(root)
app = clsMainFrame(Frm)
Frm.pack()

#
# Opening Statement
#
app.add("Python Console Output\n\n")
root.bind('<<heartbeat>>', readInput)

fd = sys.stdin.fileno()
fl = fcntl.fcntl(fd, fcntl.F_GETFL)
fcntl.fcntl(fd, fcntl.F_SETFL, fl | os.O_NONBLOCK)

def heartbeat():
    while 1:
        time.sleep(1)
        root.event_generate('<<heartbeat>>', when='tail')

th = Thread(None, heartbeat)
th.setDaemon(True)
th.start()

#
# Main Loop
#
root.mainloop()