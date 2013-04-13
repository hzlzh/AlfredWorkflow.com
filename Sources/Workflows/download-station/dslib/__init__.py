# -*- coding: utf-8 -*-

import os, urllib, urllib2, json, time, base64

from pdb import set_trace
from pprint import pprint

##
# Synology DSM Download Station python moudle
# API Version 20130313
# created by JinnLynn 2013-04-08
# http://jeeker.net http://github.com/JinnLynn
# license under the MIT License
## 

DSCommonCodeDesc = {  
    100: 'Unknown error',
    101: 'Invalid parameter',
    102: 'The requested API does not exist',
    103: 'The requested method does not exist',
    104: 'The requested version does not support the functionality',
    105: 'The logged in session does not have permission',
    106: 'Session timeout',
    107: 'Session interrupted by duplicate login'
}

DSAuthCodeDesc = {    
    400: 'No such account or incorrect password',
    401: 'Account disabled',
    402: 'Permission denied',
    403: '2-step verification code required',
    404: 'Failed to authenticate 2-step verification code'
}

DSTaskCodeDesc = {  
    400: 'File upload failed',
    401: 'Max number of tasks reached',
    402: 'Destination denied',
    403: 'Destination does not exist',
    404: 'Invalid task id',
    405: 'Invalid task action',
    406: 'No default destination'
}

DS_TASK_STATUS = ['waiting', 'downloading', 'paused', 'finishing', 'finished', 'hash_checking', 'seeding', 'filehosting_waiting', 'extracting', 'error']

DS_AVAILABLE_CONFIG_KEYS  = [
    'bt_max_download',      # INT KB/s
    'bt_max_upload',        # INT KB/s
    'emule_enabled',        # BOOL true / false 
    'emule_max_download',   # INT KB/s 
    'emule_max_upload',     # INT KB/s 
    'ftp_max_download',     # INT KB/s 
    'http_max_download',    # INT KB/s 
    'nzb_max_download',     # INT KB/s
    'unzip_service_enabled' # BOOL true / false 
    ]

DS_SESSION_MAX_ALIVE = 60 * 60 * 24

def dslibHumanReadable(self, byte):
    if isinstance(byte, (str, unicode)):
        byte = int(byte) if byte.isnumeric() else 0
    size = byte / 1024.0
    unit = 'KB'
    if size > 1024:
        size = size / 1024.0
        unit = 'MB'
    if size > 1024:
        size = size / 1024.0
        unit = 'GB'
    return '{:.2f}{}'.format(size, unit)

class DownloadStation(object):
    def __init__(self, host, usr, pwd, session = None):
        self.host = host
        self.usr = usr
        self.pwd = pwd

        self.session = session
        self.last_error = ''

        if not self.session:
            self.login()

    def __del__(self):
        pass

    def die(self, msg):
        pass

    def humanReadable(self, byte):
        if isinstance(byte, (str, unicode)):
            byte = int(byte) if byte.isnumeric() else 0
        size = byte / 1024.0
        unit = 'KB'
        if size > 1024:
            size = size / 1024.0
            unit = 'MB'
        if size > 1024:
            size = size / 1024.0
            unit = 'GB'
        return '{:.2f}{}'.format(size, unit)

    def getSession(self):
        return self.session

    def post(self, cgipath, paras):
        try:
            if not paras.has_key('version'):
                paras['version'] = 1
            if not paras.has_key('_sid'):
                paras['_sid'] = self.session
            paras = urllib.urlencode(paras)
            url = os.path.join(self.host, 'webapi', cgipath)
            requst = urllib2.urlopen(url, paras)
            res = json.load(requst)
        except Exception, e:
            return {'error': {'code': -1, 'desc': e.message},'success': False}
        return res

    def getErrorDesc(self, code = 100, extend_error_desc = {}):
        err_desc = DSCommonCodeDesc
        err_desc.update(extend_error_desc)
        return err_desc[code] if err_desc.has_key(code) else err_desc[100]

    def parseResult(self, res, extend_error_desc):
        if not isinstance(res, dict) or not res.has_key('success'):
            return False, self.getErrorDesc(extend_error_desc = extend_error_desc)
        if res['success']:
            return True, res['data'] if res.has_key('data') else None
        try:
            error = res['error']
            err_desc = error['desc'] if error.has_key('desc') and error['desc'] else self.getErrorDesc(error['code'], extend_error_desc = extend_error_desc)
        except Exception, e:
            err_desc = self.getErrorDesc(extend_error_desc = extend_error_desc)
        return False, err_desc

    def fetch(self, cgi, paras):
        res = self.post(cgi, paras)
        error_desc = {
            'auth.cgi'                  : DSAuthCodeDesc,
            'DownloadStation/task.cgi'  : DSTaskCodeDesc
        }
        extend_error_desc = {}
        if cgi in error_desc.keys():
            extend_error_desc = error_desc[cgi]
        return self.parseResult(res, extend_error_desc)

    def login(self):
        paras = { 
            'session'   : 'DownloadStation',
            'api'       : 'SYNO.API.Auth',
            'method'    : 'login',
            'version'   : 2,
            'account'   : self.usr,
            'passwd'    : self.pwd,
            '_sid'      : ''
        }
        success, data = self.fetch('auth.cgi', paras)
        if success:
            self.session = data['sid']
        else:
            self.last_error = data
            self.session = ''
        return success

    def logout(self):
        paras = { 
            'session'   : 'DownloadStation',
            'api'       : 'SYNO.API.Auth',
            'method'    : 'logout'
        }
        success, data = self.fetch('auth.cgi', paras)
        self.session = ''

    # 获取DS信息
    def fetchInfo(self):
        paras = {
            'session'   : 'DownloadStation',
            'api'       : 'SYNO.DownloadStation.Info',
            'method'    : 'getinfo',
        }
        return self.fetch('DownloadStation/info.cgi', paras)

    # 获取DS配置
    def fetchConfig(self):
        paras = {
            'session'   : 'DownloadStation',
            'api'       : 'SYNO.DownloadStation.Info',
            'method'    : 'getconfig',
        }
        return self.fetch('DownloadStation/info.cgi', paras)

    # 发送配置
    def sendConfig(self, data):
        paras = {
            'session'   : 'DownloadStation',
            'api'       : 'SYNO.DownloadStation.Info',
            'method'    : 'setserverconfig',
        }
        paras.update(data)
        return self.fetch('DownloadStation/info.cgi', paras)

    # 获取计划
    def fetchSchedule(self):
        paras = {
            'session'   : 'DownloadStation',
            'api'       : 'SYNO.DownloadStation.Schedule',
            'method'    : 'getconfig',
        }
        return self.fetch('DownloadStation/schedule.cgi', paras)

    def setSchedule(self, data):
        paras = {
            'session'   : 'DownloadStation',
            'api'       : 'SYNO.DownloadStation.Schedule',
            'method'    : 'setconfig',
        }
        paras.update(data)
        return self.fetch('DownloadStation/schedule.cgi', paras)

    # 统计 上传 下载速率
    def fetchStatistic(self):
        paras = {
            'session'   : 'DownloadStation',
            'api'       : 'SYNO.DownloadStation.Statistic',
            'method'    : 'getinfo',
        }
        return self.fetch('DownloadStation/statistic.cgi', paras)

    # 当前任务列表
    def fetchTaskList(self, additional = 'transfer,detail'):
        paras = { 
            'api'           : 'SYNO.DownloadStation.Task',
            'method'        : 'list',
            'additional'    : additional
        }
        return self.fetch('DownloadStation/task.cgi', paras)

    def putTask(self, method, put_list, put_name):
        if isinstance(put_list, list):
            put_list = ','.join(put_list)
        if not isinstance(put_list, (str, unicode)):
            return False, 'arguments error.'
        paras = {
            'api'       : 'SYNO.DownloadStation.Task',
            'method'    : method,
            put_name    : put_list
            }
        return self.fetch('DownloadStation/task.cgi', paras)

    def createTask(self, link):
        if isinstance(link, (str, unicode)) and os.path.exists(link):
            return self.createTaskByUploadFile(link)
        return self.putTask('create', link, 'uri')

    def createTaskByUploadFile(self, filepath):
        if not os.path.exists(filepath):
            return False, 'upload file is non-existent.'
        paras = {
            'version'   : '1',
            '_sid'      : self.session,
            'api'       : 'SYNO.DownloadStation.Task',
            'method'    : 'create1',
            'file'      : open(filepath, 'rb') 
            }
        url = os.path.join(self.host, 'webapi/DownloadStation/task.cgi')

        try:
            import MultipartPostHandler, cookielib
            cookies = cookielib.CookieJar()
            opener = urllib2.build_opener(
                urllib2.HTTPCookieProcessor(cookies),
                MultipartPostHandler.MultipartPostHandler
                )
            requst = opener.open(url, paras)
            res = json.load(requst)
        except Exception, e:
            return False, '{}'.format(e)
        return self.parseResult(res, DSTaskCodeDesc) 

    # 暂停任务
    def pauseTask(self, task_id):
        return self.putTask('pause', task_id, 'id')

    # 恢复任务
    def resumeTask(self, task_id):
        return self.putTask('resume', task_id, 'id')

    # 删除任务
    def deleteTask(self, task_id):
        return self.putTask('delete', task_id, 'id')

def createDownloadStation(host, usr, pwd, session = '', last_activity = 0):
    ds = DownloadStation(host, usr, pwd)
    session_lived = time.time() - last_activity
    if session_lived > 0 and session_lived < DS_SESSION_MAX_ALIVE:
        ds.setSession(session)
    return ds