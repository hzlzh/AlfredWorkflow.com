#!/usr/bin/env python
# -*- coding: utf-8 -*-
#! 强制默认编码为utf-8
import sys
reload(sys)
sys.setdefaultencoding('utf8')

import os, time
import json, urllib, urllib2
import subprocess
import base64

from pprint import pprint
from pdb import set_trace

import alfred
from dslib import *
import util

__version__ = (1, 0, 0)

def createDownloadStationImp():
    cache = alfred.Cache()
    config = alfred.Config()
    session = cache.get('session')
    ds = DownloadStation(
        config.get('host', ''),
        config.get('usr', ''),
        config.get('pwd', ''),
        session
        )
    if not session:
        session = ds.getSession()
        if session:
            cache.set('session', session, DS_SESSION_MAX_ALIVE)
    return ds

def forkCacheProcess(delay=0):
    global __cache_process__
    __cache_process__ = subprocess.Popen(
        ['python', 'cache.py', 'all', '{}'.format(delay)], 
        stdin   = subprocess.PIPE, 
        stdout  = subprocess.PIPE, 
        stderr  = subprocess.PIPE
        )

def waitCacheProcess():
    global __cache_process__
    try:
        __cache_process__.wait()
    except:
        pass

class DSBase(object):
    def __init__(self):
        self.cache = alfred.Cache()
        self.config = alfred.Config()
        self.ds = createDownloadStationImp()

    def run(self):
        pass

    def checkAuthorization(self):
        if self.isAuthorized():
            return
        alfred.exitWithFeedback(
            title           = 'User Account or DS Host Information Missing. ',
            subtitle        = 'To set with `ds setting auth`'
            )

    def isAuthorized(self):
        usr = self.config.get('usr')
        pwd = self.config.get('pwd')
        host = self.config.get('host')
        session = self.cache.get('session')
        return usr and pwd and host and session

    def getCache(self, name):
        cache = self.cache.get(name)
        if cache:
            return cache
        # 如果没有获取到，等待缓存进程的结束
        waitCacheProcess()
        return self.cache.get(name)

    # 获取所有任务
    def getTasks(self):
        #! self._tasks 与 缓存中的task是不同
        if not hasattr(self, '_tasks'):
            self._tasks = []
        if self._tasks:
            return self._tasks

        tasks = self.getCache('tasks')
        if not tasks:
            return []

        # 忽略掉做种的任务
        exclude_status = ['seeding']
        tasks = filter(lambda t: t['status'] not in exclude_status, tasks)
        tasks = filter(lambda t: t['type'] in ['http', 'emule'], tasks)

        hr = lambda s: self.ds.humanReadable(s)
        parsed_tasks = []
        for task in tasks:
            transfer = task['additional']['transfer']
            detail = task['additional']['detail']
            try:
                progress = float(transfer['size_downloaded']) / float(task['size'])
            except:
                progress = 0.0
            status_desc = task['status'].title()
            if task['status'] == 'error':
                status_desc = '{}: {}'.format(status_desc, task['status_extra']['error_detail'])
            new_task = {
                'title'                 : task['title'],
                'id'                    : task['id'],
                'type'                  : task['type'],
                'type_desc'             : 'eMule' if task['type']=='emule' else task['type'].upper(),
                'status'                : task['status'],
                'status_desc'           : status_desc,
                'username'              : task['username'],
                'uri'                   : detail['uri'],
                'size'                  : util.toInt(task['size']),
                'size_downloaded'       : util.toInt(transfer['size_downloaded']),
                'size_uploaded'         : util.toInt(transfer['size_uploaded']),
                'speed_download'        : util.toInt(transfer['speed_download']),
                'speed_upload'          : util.toInt(transfer['speed_upload']),
                'hr_size'               : hr(task['size']),
                'hr_size_downloaded'    : hr(transfer['size_downloaded']),
                'hr_size_uploaded'      : hr(transfer['size_uploaded']),
                'hr_speed_download'     : hr(transfer['speed_download']),
                'hr_speed_upload'       : hr(transfer['speed_upload']),
                'progress'              : progress,
                'progress_percent'      : '{:.2%}'.format(progress)
            }
            new_task.update({
                'desc'  : '{hr_size:10}{hr_size_downloaded:10}{progress_percent:8} DL: {hr_speed_download:8} UL: {hr_speed_upload:8}{type_desc:8}{status_desc:15}'.format(**new_task)
                })
            parsed_tasks.append(new_task)
        self._tasks = sorted(parsed_tasks, key=lambda t:t['title'].lower())
        return self._tasks

    def getTaskFilters(self):
        return {
            'sort-by-filesize'              : lambda ts,r: sorted(ts, key=lambda t: t['size'], reverse=r),
            'sort-by-progress'              : lambda ts,r: sorted(ts, key=lambda t: t['progress'], reverse=r),
            'sort-by-status'                : lambda ts,r: sorted(ts, key=lambda t: t['status'].lower(), reverse=r),
            'sort-by-download-speed'        : lambda ts,r: sorted(ts, key=lambda t: t['speed_download'], reverse=r),
            'sort-by-upload-speed'          : lambda ts,r: sorted(ts, key=lambda t: t['speed_upload'], reverse=r),
            'filter-by-status-waiting'      : lambda ts,r: filter(lambda t: t['status']=='waiting', ts),
            'filter-by-status-downloading'  : lambda ts,r: filter(lambda t: t['status']=='downloading', ts),
            'filter-by-status-paused'       : lambda ts,r: filter(lambda t: t['status']=='paused', ts),
            'filter-by-status-finshed'      : lambda ts,r: filter(lambda t: t['status']=='finished', ts),
            'filter-by-status-error'        : lambda ts,r: filter(lambda t: t['status']=='error', ts),
            'filter-by-type-emule'          : lambda ts,r: filter(lambda t: t['type']=='emule', ts),
            'filter-by-type-bt'             : lambda ts,r: filter(lambda t: t['type']=='bt', ts),
            'filter-by-type-http'           : lambda ts,r: filter(lambda t: t['type']=='http', ts)
        }

    def filterTasks(self, tasks, filter_key='', order='desc'):
        if not tasks or not filter_key:
            return tasks
        reverse = False if order == 'asc' else True
        filters = self.getTaskFilters()
        filter_keys = [s.lower().strip() for s in filter_key.split(',') if s]
        for key in filter_keys:
            if key in filters.keys():
                tasks = filters[key](tasks, reverse)
        return tasks

    def getTasksStat(self):
        tasks = self.getTasks()
        total = len(tasks)
        total_without_seeding = 0
        seeding_tasks = []
        error_tasks = []
        for task in tasks:
            if task['status'] in ['seeding']:
                seeding_tasks.append(task['id'])
            elif task['status'] not in ['error']: 
                error_tasks.append(task['id'])
        total_without_seeding = total - len(seeding_tasks)
        return total, total_without_seeding, seeding_tasks, error_tasks

    def getSingleTask(self, task_id):
        if not task_id:
            return
        for task in self.getTasks():
            if task['id'] == task_id:
                return task

    def getSpecifiedStatusTask(self, status):
        if isinstance(status, (str, unicode)):
            status = status.split(',')
        if not isinstance(status, list):
            return []
        tasks = self.getTasks()
        if not tasks:
            return []
        return filter(lambda t: t['status'] in status, tasks)

    def getCompletedTasks(self):
        return self.getSpecifiedStatusTask('finished')

    def getErroneousTasks(self):
        return self.getSpecifiedStatusTask('error')

class DSSetting(DSBase):
    def __init__(self):
        super(DSSetting, self).__init__()

    def run(self):
        if alfred.argv(2) != 'auth':
            self.showAllSetting()
        self.authorize()

    def showAllSetting(self):
        feedback = alfred.Feedback()
        current_auth_info = '{}:{}@{}'.format(
            self.config.get('usr', ''),
            ''.join(['*' for s in self.config.get('pwd', '')]),
            self.config.get('host', '')
            )
        feedback.addItem(
            title           = 'Authorization',
            subtitle        = 'login information. current: {}'.format(current_auth_info),
            autocomplete    = ' auth ',
            valid           = False
            )

        # 未设置账户信息等登陆信息
        if not self.isAuthorized():
            feedback.output()
            alfred.exit() # 未授权不显示其它的设置信息，退出

        # 清理缓存
        feedback.addItem(
            title       = 'Clean',
            subtitle    = 'cache, login session ...',
            arg         = 'clean'
            )
        
        config = self.getCache('dsconfig')
        # pprint(data)
        if not config:
            feedback.addItem(
                title       = 'Fetch download station config failed.',
                subtitle    = '{}'.format(data)
                )
        else:
            # eMule的禁用与启用
            emule_enabled = config['emule_enabled']
            feedback.addItem(
                title       = 'Disable eMule' if emule_enabled else 'Enable eMule',
                arg         = 'server-config emule_enabled {}'.format('false' if emule_enabled else 'true')
                )
            # 计划的启用与禁用
            schedule_enabled = config['schedule_enabled']
            feedback.addItem(
                title       = 'Disable Download Schedule' if schedule_enabled else 'Enable Download Schedule',
                arg         = 'schedule-config enabled {}'.format('false' if schedule_enabled else 'true')
                )
            schedule_emule_enabled = config['schedule_emule_enabled']
            feedback.addItem(
                title       = 'Disable eMule Download Schedule' if schedule_emule_enabled else 'Enable eMule Download Schedule',
                arg         = 'schedule-config emule_enabled {}'.format('false' if schedule_emule_enabled else 'true')
                )

            # 其它配置信息
            emule_speed = 'eMule: {emule_max_download}/{emule_max_upload}'.format(**config)
            bt_speed = 'BT: {bt_max_download}/{bt_max_upload}'.format(**config)
            http_speed = 'FTP/HTTP: {http_max_download}'.format(**config)
            nzb_speend = 'NZB: {nzb_max_download}'.format(**config)
            feedback.addItem(
                title       = '{}   {}   {}   {}'.format(emule_speed, bt_speed, http_speed, nzb_speend),
                subtitle    = 'Max download/upload speed in KB/s(0 means unlimited)',
                arg         = 'open-browser'    # 打开网页端
                )
        feedback.output()

    def authorize(self):
        usr = alfred.argv(3)
        pwd = alfred.argv(4)
        host = alfred.argv(5)

        feedback = alfred.Feedback()
        title = 'Login Information'
        if usr and pwd and host:
            feedback.addItem(
                title       = title,
                subtitle    = 'usr: {} pwd: {} dsm_url: {}'.format(usr, pwd, host),
                arg         = 'authorize {} {} {}'.format(usr, pwd, host)
                )
        else:
            feedback.addItem(
                title           = title,
                subtitle        = 'e.g. my_username my_password https://my_ds_ip_address_or_ddns_hostname:5001' ,
                autocomplete    = '',
                valid           = False
                )
        feedback.output()


class DSStatus(DSBase):
    def __init__(self):
        super(DSStatus, self).__init__()
        self.checkAuthorization()

    def run(self):
        success, data = self.ds.fetchStatistic()
        if not success:
            alfred.exitWithFeedback(title = 'ERROR', subtitle = data)

        feedback = alfred.Feedback()

        # DS 信息
        ds_info = self.cache.get('dsinfo')
        if ds_info:
            total = len(self.getTasks())
            error = len(self.getErroneousTasks())
            completed = len(self.getCompletedTasks())
            paused = len(self.getSpecifiedStatusTask('paused'))
            waiting = len(self.getSpecifiedStatusTask('waiting'))
            downloading = len(self.getSpecifiedStatusTask('downloading'))
            feedback.addItem(
                title = 'Download Station v{}'.format(ds_info['version_string']),
                subtitle    = '{} task(s), {} downloading, {} waiting, {} paused, {} error, {} completed,'.format(
                    total, downloading, waiting, paused, error, completed
                    )
                )

        download = self.ds.humanReadable(data['speed_download'])
        upload = self.ds.humanReadable(data['speed_upload'])
        feedback.addItem(
            subtitle = 'Total speed except for eMule',
            title = 'DL: {:8} UL: {}'.format(download, upload)
            )
        if data.has_key('emule_speed_download'):
            download = self.ds.humanReadable(data['emule_speed_download'])
            upload = self.ds.humanReadable(data['emule_speed_upload'])
            feedback.addItem(
                subtitle = 'Total eMule speed',
                title = 'DL: {:8} UL: {}'.format(download, upload)
                )
        else:
            feedback.addItem(
                title = 'eMule was disabled.'
                )
        feedback.output()

class DSTask(DSBase):
    def __init__(self):
        super(DSTask, self).__init__()
        self.checkAuthorization()
        
    def run(self):
        cmd_map = {
            'more-actions'              : lambda: self.showMoreActions(),
            'detail'                    : lambda: self.showTaskDetail(),
            'create'                    : lambda: self.createTask(),
            'delete'                    : lambda: self.confimDeleteTask(),
            'remove-erroneous-tasks'    : lambda: self.confirmRemoveErroneousTasks(),
            'delete-all'                : lambda: self.confirmDeleteAllTasks()
        }
        subcmd = alfred.argv(2)
        if subcmd and subcmd.lower() in cmd_map.keys():
            return cmd_map[subcmd.lower()]()
        self.showAllTasks()

    def showAllTasks(self):
        tasks = self.getTasks()
        if not tasks:
            alfred.exitWithFeedback(title='No Task Found', subtitle='if this message is wrong, please try again or clean cache(ds setting - Clean)')
        tasks = self.filterTasks(tasks, alfred.argv(2), alfred.argv(3))
        feedback = alfred.Feedback()  
        if not tasks:
            feedback.addItem(
                title   = 'No Task Found.'
                )
        count = 0
        for task in tasks:
            count += 1
            feedback.addItem(
                title           = '{}. {}'.format(count, task['title']),
                subtitle        = task['desc'],
                autocomplete    = ' detail {}'.format(task['id']),
                valid           = False
                )  

        # 暂停所有任务
        feedback.addItem(
            title   = 'Pause All',
            arg     = 'pause-all-tasks'
            ),
        # 恢复所有任务
        feedback.addItem(
            title   = 'Resume All',
            arg     = 'resume-all-tasks'
            ),
        # 删除所有任务 需确认
        feedback.addItem(
            title           = 'Delete All',
            autocomplete    = ' delete-all',
            valid           = False
            )
        # 删除所有错误的任务 需确认
        feedback.addItem(
            title           = 'Remove Erroneous Tasks',
            autocomplete    = ' remove-erroneous-tasks',
            valid           = False
            ),
        # 清理所有已完成的任务
        feedback.addItem(
            title   = 'Clear Completed Tasks',
            arg     = 'clear-completed-tasks'
            ),
        # 更多操作
        feedback.addItem(
            title           = 'More Actions ...',
            autocomplete    = ' more-actions',
            valid           = False
            )

        feedback.output()

    def showMoreActions(self):
        feedback = alfred.Feedback()
        filter_keys = self.getTaskFilters().keys()
        filter_keys = sorted(filter_keys)
        specified_key_to_title = {
            'filter-by-type-http'   : 'Filter By Type HTTP',
            'filter-by-type-bt'     : 'Filter By Type BT',
            'filter-by-type-emule'  : 'Filter By Type eMule'
        }
        for k in filter_keys:
            title = ' '.join(k.split('-')).title()
            if k in specified_key_to_title.keys():
                title = specified_key_to_title[k]
            feedback.addItem(
                title           = title,
                autocomplete    = ' {}'.format(k),
                valid           = False
                )
        feedback.output()

    def showTaskDetail(self):
        task = self.getSingleTask(alfred.argv(3))
        if not task:
            alfred.exitWithFeedback(title='ERROR', subtitle='No Task Found.')

        feedback = alfred.Feedback()
        # 任务标题
        feedback.addItem(
            title           = task['title'],
            subtitle        = task['desc'],
            autocomplete    = ' detail {id}'.format(**task), # 参数与现有相同 即无任何反应
            valid           = False
            )
        status = task['status']
        # 状态为 '等待'、'下载中' 显示暂停操作
        if status in ['waiting', 'downloading']:
            feedback.addItem(
                title   = 'Pause',
                arg     = 'pause-task {id}'.format(**task)
                )
        # 状态为 '暂停' 显示 恢复操作
        if status in ['paused']:
            feedback.addItem(
                title   = 'Resume',
                arg     = 'resume-task {id}'.format(**task)
                )
        # 状态为 '完成' 显示 清理操作
        if status in ['finished']:
            feedback.addItem(
                title   = 'Clear',
                arg     = 'delete-task {id}'.format(**task) # 实际上就是删除已完成的任务
                )
        # 只有状态不是 '完成'、'完成中'才显示 删除操作
        if status not in ['finished', 'finishing']:
            feedback.addItem(
                title           = 'Delete',
                autocomplete    = ' delete {id}'.format(**task),
                valid           = False
                )
        feedback.addItem(
            title           = 'Show all',
            autocomplete    = '',
            valid           = False
            )
        feedback.output()

    # 创建任务
    #! 下载地址在传递参数时可能出现错误，因此使用base64加密后传输
    def createTask(self):
        if not alfred.argv(3):
            alfred.exitWithFeedback(title='ERROR', subtitle='No TasK Found.')
        feedback = alfred.Feedback()
        tasks = util.parseURIInfo(alfred.argv(3))
        if len(tasks) > 1:
            urls = []
            for task in tasks:
                urls.append(task['original'])
            feedback.addItem(
                title       = 'Create All',
                subtitle    = 'find {} links'.format(len(tasks)),
                arg         = 'create-task {}'.format(base64.b64encode(','.join(urls)))
                )
        for task in tasks:
            feedback.addItem(
                title   = task['original'],
                subtitle    = 'Title: {filename:5}  Size: {filesize}'.format(**task),
                arg     = 'create-task {}'.format(base64.b64encode(task['original']))
                )
        feedback.output()

    # 确认删除当个任务
    def confimDeleteTask(self):
        task = self.getSingleTask(alfred.argv(3))
        if not task:
            alfred.exitWithFeedback(title='ERROR', subtitle='task no found.')
        feedback = alfred.Feedback()
        feedback.addItem(
            title           = 'Are you sure you want to delete task?',
            subtitle        = task['title'],
            autocomplete    = ' delete {id}'.format(**task), #! 同样的命令，不进行任何操作
            valid           = False
            )
        feedback.addItem(
            title           = 'Yes',
            arg             = 'delete-task {id}'.format(**task)
            )
        feedback.addItem(
            title           = 'No',
            autocomplete    = '', #! 返回任务列表
            valid           = False
            )
        feedback.output()

    # 确认删除错误的任务
    def confirmRemoveErroneousTasks(self):
        feedback = alfred.Feedback()
        feedback.addItem(
            title           = 'Are you sure you want to remove all erroneous tasks?',
            subtitle        = '',
            autocomplete    = ' remove-erroneous-tasks', #! 同样的命令，不进行任何操作
            valid           = False
            )
        feedback.addItem(
            title           = 'Yes',
            arg             = 'remove-erroneous-tasks'
            )
        feedback.addItem(
            title           = 'No',
            autocomplete    = '', #! 返回任务列表
            valid           = False
            )
        feedback.output()

    # 确认删除所有任务
    def confirmDeleteAllTasks(self):
        feedback = alfred.Feedback()
        feedback.addItem(
            title           = 'Are you sure you want to delete all tasks?',
            subtitle        = '',
            autocomplete    = ' delete-all', #! 同样的命令，不进行任何操作
            valid           = False
            )
        feedback.addItem(
            title           = 'Yes',
            arg             = 'delete-all-tasks'
            )
        feedback.addItem(
            title           = 'No',
            autocomplete    = '', #! 返回任务列表
            valid           = False
            )
        feedback.output()

def main():
    cmds = {
        'setting'   : lambda: DSSetting().run(),
        'status'    : lambda: DSStatus().run(),
        'task'      : lambda: DSTask().run()
    }
    # fork一个进程进行缓存
    forkCacheProcess()
    subcmd = alfred.argv(1)
    if subcmd and subcmd.lower() in cmds.keys():
        cmds[subcmd.lower()]()

if __name__ == '__main__':
    main()