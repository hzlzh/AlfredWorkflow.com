#!/usr/bin/env python
# -*- coding: utf-8 -*-
#! 强制默认编码为utf-8
import sys
reload(sys)
sys.setdefaultencoding('utf8')

import os, time, subprocess
import base64

from pprint import pprint

import alfred
from dslib import *
from ds import DSBase, forkCacheProcess, waitCacheProcess
import util

class DSAction(DSBase):
    def __init__(self):
        super(DSAction, self).__init__()
        self.cmds = {
            'authorize'                 : lambda: self.authorize(),
            'logout'                    : lambda: self.logout(),
            'clean'                     : lambda: self.clean(),
            'open-browser'              : lambda: self.openBrowser(),
            'server-config'             : lambda: self.setServerConfig(),
            'schedule-config'           : lambda: self.setScheduleConfig(),
            'pause-all-tasks'           : lambda: self.pauseAllTasks(),
            'resume-all-tasks'          : lambda: self.resumeAllTasks(),
            'delete-all-tasks'          : lambda: self.deleteAllTasks(),
            'clear-completed-tasks'     : lambda: self.clearCompletedTasks(),
            'remove-erroneous-tasks'    : lambda: self.removeErroneousTasks(),
            'create-task'               : lambda: self.createTask(),
            'pause-task'                : lambda: self.pauseTask(),
            'resume-task'               : lambda: self.resumeTask(),
            'delete-task'               : lambda: self.deleteTask(),
        }

    def run(self):
        cmd = alfred.argv(1)
        if not cmd:
            self.exit()
        cmd = cmd.lower()
        if cmd not in self.cmds.keys():
            self.exit('action is missing. {}'.format(cmd))
        # 进行操作前等待缓存进程
        waitCacheProcess()
        self.cmds[cmd]()

    def exit(self, msg, clear_cache=True):
        if clear_cache:
            # 删除缓存
            self.cache.delete('tasks')
            #! 延迟时间换取缓存 避免对DS的部分操作为完成造成任务状态错误
            forkCacheProcess(10)
        alfred.exit(msg)

    def authorize(self):
        self.config.clean()
        self.cache.clean()
        try:
            usr = sys.argv[2]
            pwd = sys.argv[3]
            host = sys.argv[4]
            ds = DownloadStation(host, usr, pwd)
            res = ds.login()
        except Exception, e:
            self.exit('Setting fail: {}'.format(e))

        if res:
            self.config.set(
                usr         = usr, 
                pwd         = pwd, 
                host        = host,
                session     = ds.getSession(),
                activity    = time.time()
                )
            self.exit('Setting success.')
        self.exit('Setting fail. {}'.format(ds.last_error), False)

    def logout(self):
        self.cache.delete('session')
        self.ds.logout()
        self.exit('logout')

    def clean(self):
        subprocess.Popen(
            ['python', 'action.py', 'logout'], 
            stdin   = subprocess.PIPE, 
            stdout  = subprocess.PIPE, 
            stderr  = subprocess.PIPE
        )
        self.cache.clean()
        self.exit('Everything is clean.')

    def openBrowser(self):
        host = self.config.get('host', '')
        if not host:
            self.exit('DS host url is empty.', False)
        url = os.path.join(host, 'webman/index.cgi?launchApp=SYNO.SDS.DownloadStation.Application')
        subprocess.check_output(['open', url])
        self.exit('DS host opened', False)

    def setServerConfig(self):
        key = alfred.argv(2)
        value = alfred.argv(3)
        if not key or not value:
            self.exit('arguments error', False)
        data = {key:value}
        success, data = self.ds.sendConfig(data)
        self.cache.delete('dsconfig')
        success_msg = {
            'emule_enabled' : 'eMule enabled.' if value == 'true' else 'eMule disabled.'
        }
        if success:
            if key in success_msg.keys():
                self.exit(success_msg[key])
            self.exit('set server config {}={} success.'.format(key, value))
        self.exit('set server config {}={} failed.'.format(key, value))

    def setScheduleConfig(self):
        key = alfred.argv(2)
        value = alfred.argv(3)
        if not key or not value:
            self.exit('arguments error', False)
        data = {key:value}
        success, data = self.ds.setSchedule(data)
        self.cache.delete('dsconfig')
        success_msg = {
            'enabled'       : 'Schedule enabled.' if value == 'true' else 'Schedule disabled.',
            'emule_enabled' : 'eMule schedule enabled.' if value == 'true' else 'eMule schedule disabled.',
        }
        if success:
            if key in success_msg.keys():
                self.exit(success_msg[key])
            self.exit('set schedule config {}={} success.'.format(key, value))
        self.exit('set seschedulerver config {}={} failed.'.format(key, value))

    def pauseAllTasks(self):
        tasks = self.getTasks()
        if not tasks:
            self.exit('No task found')
        ids = [task['id'] for task in tasks]
        success, data = self.ds.pauseTask(ids)
        msg = '{} task(s) paused.'.format(len(ids) if success else 'No')
        self.exit(msg)

    def resumeAllTasks(self):
        tasks = self.getTasks()
        if not tasks:
            self.exit('No task found')
        ids = [task['id'] for task in tasks]
        success, data = self.ds.resumeTask(ids)
        msg = '{} task(s) resumed.'.format(len(ids) if success else 'No')
        self.exit(msg)

    def deleteAllTasks(self):
        tasks = self.getTasks()
        if not tasks:
            self.exit('No task found')
        ids = [task['id'] for task in tasks]
        success, data = self.ds.deleteTask(ids)
        msg = '{} task(s) deleted.'.format(len(ids) if success else 'No')
        self.exit(msg)

    def clearCompletedTasks(self):
        tasks = self.getCompletedTasks()
        if not tasks:
            self.exit('No completed task found.')
        ids = [task['id'] for task in tasks]
        success, data = self.ds.deleteTask(ids)
        msg = '{} completed task(s) cleared.'.format(len(ids) if success else 'No')
        self.exit(msg)

    def removeErroneousTasks(self):
        tasks = self.getErroneousTasks()
        if not tasks:
            self.exit('No erroneous task found.')
        ids = [task['id'] for task in tasks]
        success, data = self.ds.deleteTask(ids)
        msg = '{} erroneous task(s) removed.'.format(len(ids) if success else 'No')
        self.exit(msg)

    # 创建任务
    # 传递过来的参数经过base64编码
    def createTask(self):
        link = alfred.argv(2)
        if not link:
            self.exit('arguments error')
        link = base64.b64decode(link)
        success, res = self.ds.createTask(link)
        if success:
            self.exit('Create task success')
        self.exit('Create task failed: {}'.format(res))

    def pauseTask(self):
        success, data = self.ds.pauseTask(alfred.argv(2))
        self.judgeSingleTaskResult(success, data, 'Pause task')

    def resumeTask(self):
        success, data = self.ds.resumeTask(alfred.argv(2))
        self.judgeSingleTaskResult(success, data, 'Resume task')

    def deleteTask(self):
        success, data = self.ds.deleteTask(alfred.argv(2))
        self.judgeSingleTaskResult(success, data, 'Delete task')
            
    def judgeSingleTaskResult(self, success, data, action_str='Do action'):
        if not success:
            self.exit('{} failed: {}'.format(action_str, data))
        error_code = data[0]['error']
        if error_code == 0:
            self.exit('{} success.'.format(action_str))
        else:
            desc = self.getDSTaskErrorCodeDesc(error_code)
            self.exit('{} failed: {}'.format(action_str, desc))

    def getDSTaskErrorCodeDesc(self, code):
        global DSTaskCodeDesc
        return self.ds.getErrorDesc(code, extend_error_desc=DSTaskCodeDesc)

if __name__ == '__main__':
    #! 必须重新获取缓存 防止在这时缓存过期
    forkCacheProcess()
    DSAction().run()
        