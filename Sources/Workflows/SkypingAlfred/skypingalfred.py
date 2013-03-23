#!/usr/bin/python
# -*- coding: utf8 -*-
"""
Name: 		    PyFred
Description: 	Alfred 2 Workflow for Skype interaction. Allows to write messages, and call users
Author: 		Rafael Hostettler (@rhostettler)
License:        CC BY-SA 3.0
Revised: 		24/3/2013
Version:		0.1.2
Todo:           - Use SkypePy for event based replies
                - Implement: Global user search and adding, Last messages, Unread messages
                - Fix Encoding Problems
Changelog:      2013/3/23 - 0.1 - Initial Release
                2013/3/23 - 0.1.1 - Error Checking for Skype not running, Encoding fixed, New Message handling
"""
from subprocess import Popen, PIPE
import re
import pickle
import os
import sqlite3
import contextlib
import datetime

from pyfred import PyFred


def skype(msg):
    """
    Sends message to skype, use skype API syntax. Only works for Skype calls that do not return events.
    :param msg: Message
    :return: Reply from Skype
    """
    cmd = "tell app \"Skype\" to send command \"" + msg + "\" script name \"Alfred\""
    p = Popen(['osascript', '-'], stdin=PIPE, stdout=PIPE, stderr=PIPE)
    stdout, stderr = p.communicate(cmd)
    return stdout

def getUserName():
    """
    Get the skypename of the currently logged in user.
    :return:
    """
    us = skype("GET CURRENTUSERHANDLE").partition("CURRENTUSERHANDLE")[2].strip()
    if(us == ""): raise Exception("Could not access skype!")
    return us


def handleFriends(qry):
    """
    Handles the search for friends with autocompletion. Fallback if the list of friends has not been updated.
    :param qry: Current search query
    :return: List of matching friends
    """
    try: getUserName()
    except: return _skypeError()
    try:
        return _findFriends(qry,"",False)
    except EnvironmentError:
        return PyFred("ch.xtin.skypingalfred.error",False).addItem("skypeupdate",
                "skype update","No Skype Friends Found","Use skype update to cache friends!",True,"update").toXML()
    except:
        return PyFred.GenericError()

def handleMessage(qry):
    """
    Handles the message sending for skype. If no : and valid skypename is present,
    keep searching, otherwise start with message entering
    :param qry: current query for search
    :return: XML for Alfred with found friends. Fallback if the list of friends has not been updated.
    """
    try: getUserName()
    except: return _skypeError()
    qry = qry.decode("utf8")

    try:
        if ":" in qry and (qry.partition(":")[0] in map(lambda s:s[0],_readFriends())):
            return _sendMessageWait(qry)
        else:
            return _findFriends(qry)
    except EnvironmentError:
        return PyFred("ch.xtin.skypingalfred.error",False).addItem("skypeupdate",
                "skype update","No Skype Friends Found","Use skype update to cache friends!",True,"update").toXML()
    except:
        return PyFred.GenericError()

def handleNewest(qry):
    """
    Gets the newest 5 Messages,
    keep searching, otherwise start with message entering
    :param qry: current query for search
    :return: XML for Alfred with found friends. Fallback if the list of friends has not been updated.
    """
    try: getUserName()
    except: return _skypeError()
    qry = qry.decode("utf8")

    try:
        if ":" in qry and (qry.partition(":")[0] in map(lambda s:s[0],_readFriends())):
            return _sendMessageWait(qry)
        else:
            return _findNewest()
    except EnvironmentError:
        return PyFred("ch.xtin.skypingalfred.error",False).addItem("skypeupdate",
               "skype update","No Skype Friends Found","Use skype update to cache friends!",True,"update").toXML()
    except:
        return PyFred.GenericError()

def sendMessage(qry):
    """
    Message sending handling, either update if the query suggests it otherwise send the message.
    :param qry: current query
    :return: Status of Message sending.
    """
    try: getUserName()
    except: return _skypeError()

    if(qry == "skype update"):
        _writeFriends()
        _getAvatars()
        return len(_readFriends()).__str__()+" friends found and cached!"
    else:
        m = qry.partition(": ")
        ret = skype("MESSAGE " + m[0]+" "+m[2])
        if("SENDING" in ret):
            return "Message sent to "+m[0]
        else:
            return "ERROR sending message to: "+m[0]


def callUser(acc):
    """
    Call some user
    :param acc: skypename
    :return: messsage from Skype
    """
    try: getUserName()
    except: _skypeError()
    return skype("CALL "+acc)

def _skypeError():
    return PyFred("ch.xtin.skypingalfred.error",False).addItem("skypeerror","skype error","No Skype Access!",
           "Either Skype is not running or you didn't give Alfred access to it, when it asked for it!",False).toXML()

def _getFriends():
    """
    Get friends from Skype database
    :return: List of tuples of friends, tuple: (skypename,fullname,displayname)
    """
    path = os.path.expanduser("~/Library/Application Support/Skype/"+getUserName()+"/main.db")
    with contextlib.closing(sqlite3.connect(path).cursor()) as db:
        db.execute("SELECT skypename,fullname,displayname FROM Contacts WHERE type=1 AND is_permanent=1")
        return db.fetchall()
        #Using Skype API:
        #friends = map(lambda s:s[:-1],re.findall(r"[\w.,-]+", skype("SEARCH FRIENDS"))[1:])
        #return map(lambda usr:
        #    [usr, getFullName(usr)], friends)


def _getAvatars():
    """
    Extracts the avatars from the database and stores them in the alfred extension directory.
    """
    path = os.path.expanduser("~/Library/Application Support/Skype/"+getUserName()+"/main.db")
    with contextlib.closing(sqlite3.connect(path).cursor()) as db:
        for av in db.execute("SELECT skypename,avatar_image FROM Contacts WHERE type=1 AND is_permanent=1"):
            if av[1] is not None:
                with open("avatars/"+av[0]+".jpeg","wr") as f:
                    f.write(str(av[1])[1:]) #For some reason, the first byte is 0, then the jpg starts.

def _getAvatar(acc):
    """
    Get the path for the avatar image of a user
    :param acc: skypename of the user
    :return: path to image or fallback image if not available
    """
    pimg = "avatars/"+acc+".jpeg"
    return (pimg,None) if os.path.exists(pimg) else ("/Applications/Skype.app","fileicon")

def _getLastMessage(acc):
    """
    Get the last message that a user sent to the currently logged in user
    :param acc: skypename of the other user
    :return: tuple with timestamp and the message as an XML
    """
    path = os.path.expanduser("~/Library/Application Support/Skype/"+getUserName()+"/main.db")
    with contextlib.closing(sqlite3.connect(path).cursor()) as db:
        db.execute("SELECT timestamp,body_xml FROM Messages WHERE author=? ORDER BY timestamp DESC LIMIT 1",(acc,))
        return db.fetchone()

def _getLastMessageFormated(acc):
    """
    Returns the last message as a formated string, that should not break alfred.
    :param acc: skypename of the user
    :return: string
    """
    m = _getLastMessage(acc)
    if m is None: return "None"
    t = datetime.datetime.fromtimestamp(m[0]).strftime('%Y-%m-%d %H:%M')
    return u"{}: {}".format(t,m[1])

def _writeFriends():
    try:
        with open("AlfredSkype.pcl", "w") as file:
            pickle.dump(_getFriends(), file)
    except (EOFError,IOError):
        os.remove("AlfredSkype.pcl")

def _readFriends():
    try:
        with open("AlfredSkype.pcl", "r") as file:
            friends = pickle.load(file)
            return friends
    except (EOFError,IOError):
        os.remove("AlfredSkype.pcl")


def _matchFriends(tg, friends):
    """
    Finds matching friends to a query. Special chars are removed and then matched
    against the skypename, fullname and displayname of the user.
    Ordered by highest number of matches.
    :param tg: match to look for
    :param friends: list of friends
    :return: sorted list of friends that at least partially match
    """
    mfilter = lambda s:len("".join(
        re.findall(
            re.sub("[\.\,\-\_]","","|".join(tg.split()).lower()),
            re.sub("[\.\,\-\_]",""," ".join(filter(None,s)).lower()))
        ))
    return sorted(filter(lambda s:mfilter(s) > 0,friends),key=mfilter,reverse=True)


def _sendMessageWait(msg):
    """
    A valid skypename has been matched, now simply wait for the user to finish his message.
    :param msg:
    :param msg: current query, format: skypename: message
    :return: XML for that entry.
    """
    m = msg.partition(": ")
    img,imgtype = _getAvatar(m[0])
    return PyFred("ch.xtin.skypingalfred.wait",False).addItem("skypename_"+m[0],msg,
                  "Message to: "+m[0],_getLastMessageFormated(m[0]),True,None,img,imgtype).toXML()



def _listFriends(fs,sep=": ",lock=True,getLastMessage=False):
    """
    Uses a list of friends and creates the output for Alfred
    :param fs: List of friends, format [(skypname,fullname,displayname)...]
    :param sep: The seperator to use to seperate account name from message,
                don't use characters that can be part of a skype name
    :param lock: prevent sending until a valid name has been found.
    :param getLastMessage: if the last written Message should be retrieved
    :return: XML for Alfred with listed friends.
    """
    p = PyFred("ch.xtin.skypingalfred.find", False)
    for f in fs:
        img,imgtype = _getAvatar(f[0])
        p.addItem(
            "skypename_"+f[0],
            f[0]+sep,
            f[0]+(" ("+f[1]+")" if f[1] else (" ("+f[2]+")") if f[2] else ""),
            _getLastMessageFormated(f[0]) if getLastMessage else "",
            not lock,
            f[0]+sep,
            img,
            imgtype)
    if(len(p._items)==0): p.addItem("skypename_notfound","skype update","No Skype friend found: "+tg,
                                    "Maybe try updating your friends? Hit enter to do so!",True)
    return p.toXML()

def _findFriends(tg,sep=": ",lock=True,getLastMessage=False):
    """
    Searches for friends and returns them.
    :param tg: current query
    :param sep: how to seperate the friend from the second part (e.g. the message)
    :param lock: prevent sending until a valid name has been found.
    :param getLastMessage: if the last written Message should be retrieved
    :return: XML for Alfred with found friends
    """
    return _listFriends(_matchFriends(tg,_readFriends())[0:5],sep,lock,getLastMessage)

def _findNewest():
    """
    Get newest messages from Skype database
    :return: List of tuples of friends, tuple: (skypename,fullname,displayname)
    """
    path = os.path.expanduser("~/Library/Application Support/Skype/"+getUserName()+"/main.db")
    with contextlib.closing(sqlite3.connect(path).cursor()) as db:
        db.execute("SELECT skypename,fullname,displayname FROM Contacts WHERE skypename IN " \
                   "(SELECT identity FROM Conversations ORDER BY last_activity_timestamp DESC LIMIT 5)")
        return _listFriends(db.fetchall(),": ",True,True)
        #Using Skype API:
        #friends = map(lambda s:s[:-1],re.findall(r"[\w.,-]+", skype("SEARCH FRIENDS"))[1:])
        #return map(lambda usr:
        #    [usr, getFullName(usr)], friends)



''' Global User Search TODO requires header.''
def handleUserSearch(qry):
    return skype("SEARCH USERS "+qry)

def addUserToContacts(acc):
    s = acc.partition(":")
    skype("SET USER "+s[0]+" BUDDYSTATUS 2 "+s[1])
'''

