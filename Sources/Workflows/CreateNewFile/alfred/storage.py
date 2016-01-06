# -*- coding: utf-8 -*-
from __future__ import absolute_import, division, unicode_literals
import os, subprocess

from . import core, util, request

def getLocalPath(source_link):
    storage_dir = os.path.join(core._storage_base_dir, core.bundleID())
    if not os.path.exists(storage_dir):
        os.makedirs(storage_dir)
    _, ext = os.path.splitext(source_link)
    filename = '{}{}'.format(util.hashDigest(source_link), ext)
    return os.path.join(storage_dir, filename)

def getLocalIfExists(source_link, download=False):
    filepath = getLocalPath(source_link)
    if os.path.exists(filepath):
        return filepath
    if download:
        singleDownload(source_link)
        return getLocalIfExists(source_link, False)

def isLocalExists(source_link):
    filepath = getLocalPath(source_link)
    return os.path.exists(filepath)

def batchDownload(links, wait=True):
    if isinstance(links, basestring):
        links = links.split(',')
    if not links or not isinstance(links, list):
        return
    process = []
    for link in links:
        if isLocalExists(link):
            continue
        sub = subprocess.Popen(
            'python "{}" "{}"'.format(os.path.abspath(__file__), link),
            shell   = True,
            stdin   = subprocess.PIPE, 
            stdout  = subprocess.PIPE, 
            stderr  = subprocess.PIPE
        )
        if sub:
            process.append(sub)
    if wait:
        # 等待所有的下载进程结束
        for sub in process:
            sub.wait()

def singleDownload(link):
    if not link or isLocalExists(link):
        return
    try:
        filepath = getLocalPath(link)
        request.download(link, filepath)
    except:
        pass

if __name__ == '__main__':
    singleDownload(core.argv(1))