import json
import requests

from .device import Device
from .channel import Channel
from .chat import Chat
from .errors import PushbulletError, InvalidKeyError, PushError
from .filetype import get_file_type


class Pushbullet(object):

    DEVICES_URL = "https://api.pushbullet.com/v2/devices"
    CHATS_URL = "https://api.pushbullet.com/v2/chats"
    CHANNELS_URL = "https://api.pushbullet.com/v2/channels"
    ME_URL = "https://api.pushbullet.com/v2/users/me"
    PUSH_URL = "https://api.pushbullet.com/v2/pushes"
    UPLOAD_REQUEST_URL = "https://api.pushbullet.com/v2/upload-request"
    EPHEMERALS_URL = "https://api.pushbullet.com/v2/ephemerals"

    def __init__(self, api_key):
        self.api_key = api_key
        self._json_header = {'Content-Type': 'application/json'}

        self._session = requests.Session()
        self._session.auth = (self.api_key, "")
        self._session.headers.update(self._json_header)

        self.refresh()

    def _get_data(self, url):
        resp = self._session.get(url)

        if resp.status_code != requests.codes.ok:
            raise InvalidKeyError()

        return resp.json()

    def _load_devices(self):
        self.devices = []

        resp_dict = self._get_data(self.DEVICES_URL)
        device_list = resp_dict.get("devices", [])

        for device_info in device_list:
            if device_info.get("active"):
                d = Device(self, device_info)
                self.devices.append(d)

    def _load_chats(self):
        self.chats = []

        resp_dict = self._get_data(self.CHATS_URL)
        chat_list = resp_dict.get("chats", [])

        for chat_info in chat_list:
            if chat_info.get("active"):
                c = Chat(self, chat_info)
                self.chats.append(c)

    def _load_user_info(self):
        self.user_info = self._get_data(self.ME_URL)

    def _load_channels(self):
        self.channels = []

        resp_dict = self._get_data(self.CHANNELS_URL)
        channel_list = resp_dict.get("channels", [])

        for channel_info in channel_list:
            if channel_info.get("active"):
                c = Channel(self, channel_info)
                self.channels.append(c)

    @staticmethod
    def _recipient(device=None, chat=None, email=None, channel=None):
        data = dict()

        if device:
            data["device_iden"] = device.device_iden
        elif chat:
            data["email"] = chat.email
        elif email:
            data["email"] = email
        elif channel:
            data["channel_tag"] = channel.channel_tag

        return data

    def new_device(self, nickname):
        data = {"nickname": nickname, "type": "stream"}
        r = self._session.post(self.DEVICES_URL, data=json.dumps(data))
        if r.status_code == requests.codes.ok:
            new_device = Device(self, r.json())
            self.devices.append(new_device)
            return new_device
        else:
            raise PushbulletError(r.text)

    def new_chat(self, name, email):
        data = {"name": name, "email": email}
        r = self._session.post(self.CHATS_URL, data=json.dumps(data))
        if r.status_code == requests.codes.ok:
            new_chat = Chat(self, r.json())
            self.chats.append(new_chat)
            return new_chat
        else:
            raise PushbulletError(r.text)

    def edit_device(self, device, nickname=None, model=None, manufacturer=None):
        data = {k: v for k, v in
                (("nickname", nickname or device.nickname), ("model", model),
                 ("manufacturer", manufacturer)) if v is not None}
        iden = device.device_iden
        r = self._session.post("{}/{}".format(self.DEVICES_URL, iden), data=json.dumps(data))
        if r.status_code == requests.codes.ok:
            new_device = Device(self, r.json())
            self.devices[self.devices.index(device)] = new_device
            return new_device
        else:
            raise PushbulletError(r.text)


    def edit_chat(self, chat, name):
        data = {"name": name}
        iden = chat.iden
        r = self._session.post("{}/{}".format(self.CHATS_URL, iden), data=json.dumps(data))
        if r.status_code == requests.codes.ok:
            new_chat = Chat(self, r.json())
            self.chats[self.chats.index(chat)] = new_chat
            return new_chat
        else:
            raise PushbulletError(r.text)


    def remove_device(self, device):
        iden = device.device_iden
        r = self._session.delete("{}/{}".format(self.DEVICES_URL, iden))
        if r.status_code == requests.codes.ok:
            self.devices.remove(device)
        else:
            raise PushbulletError(r.text)


    def remove_chat(self, chat):
        iden = chat.iden
        r = self._session.delete("{}/{}".format(self.CHATS_URL, iden))
        if r.status_code == requests.codes.ok:
            self.chats.remove(chat)
            return True
        else:
            raise PushbulletError(r.text)

    def get_device(self, nickname):
        req_device = next((device for device in self.devices if device.nickname == nickname), None)

        if req_device is None:
            raise InvalidKeyError()

        return req_device

    def get_pushes(self, modified_after=None, limit=None, filter_inactive=True):
        data = {"modified_after": modified_after, "limit": limit}
        if filter_inactive:
            data['active'] = "true"

        pushes_list = []
        get_more_pushes = True
        while get_more_pushes:
            r = self._session.get(self.PUSH_URL, params=data)
            if r.status_code != requests.codes.ok:
                raise PushbulletError(r.text)

            pushes_list += r.json().get("pushes")
            if 'cursor' in r.json() and (not limit or len(pushes_list) < limit):
                data['cursor'] = r.json()['cursor']
            else:
                get_more_pushes = False

        return pushes_list

    def dismiss_push(self, iden):
        data = {"dismissed": True}
        r = self._session.post("{}/{}".format(self.PUSH_URL, iden), data=json.dumps(data))

        if r.status_code != requests.codes.ok:
            raise PushbulletError(r.text)

    def delete_push(self, iden):
        r = self._session.delete("{}/{}".format(self.PUSH_URL, iden))

        if r.status_code != requests.codes.ok:
            raise PushbulletError(r.text)

    def delete_pushes(self):
        r = self._session.delete(self.PUSH_URL)

        if r.status_code != requests.codes.ok:
            raise PushbulletError(r.text)

    def upload_file(self, f, file_name, file_type=None):
        if not file_type:
            file_type = get_file_type(f, file_name)

        data = {"file_name": file_name, "file_type": file_type}

        # Request url for file upload
        r = self._session.post(self.UPLOAD_REQUEST_URL, data=json.dumps(data))

        if r.status_code != requests.codes.ok:
            raise PushbulletError(r.text)

        upload_data = r.json().get("data")
        file_url = r.json().get("file_url")
        upload_url = r.json().get("upload_url")

        upload = requests.post(upload_url, data=upload_data, files={"file": f})

        return {"file_type": file_type, "file_url": file_url, "file_name": file_name}

    def push_file(self, file_name, file_url, file_type, body=None, device=None, chat=None, email=None, channel=None, title=None):
        data = {"type": "file", "file_type": file_type, "file_url": file_url, "file_name": file_name}
        if body:
            data["body"] = body

        if title:
            data["title"] = title

        data.update(Pushbullet._recipient(device, chat, email, channel))

        return self._push(data)

    def push_note(self, title, body, device=None, chat=None, email=None):
        data = {"type": "note", "title": title, "body": body}

        data.update(Pushbullet._recipient(device, chat, email))

        return self._push(data)

    def push_address(self, name, address, device=None, chat=None, email=None):
        data = {"type": "address", "name": name, "address": address}

        data.update(Pushbullet._recipient(device, chat, email))

        return self._push(data)

    def push_list(self, title, items, device=None, chat=None, email=None):
        data = {"type": "list", "title": title, "items": items}

        data.update(Pushbullet._recipient(device, chat, email))

        return self._push(data)

    def push_link(self, title, url, body=None, device=None, chat=None, email=None):
        data = {"type": "link", "title": title, "url": url, "body": body}

        data.update(Pushbullet._recipient(device, chat, email))

        return self._push(data)

    def _push(self, data):
        r = self._session.post(self.PUSH_URL, data=json.dumps(data))

        if r.status_code == requests.codes.ok:
            return r.json()
        else:
            raise PushError(r.text)

    def push_sms(self, device, number, message):
        data = {
            "type": "push",
            "push": {
                "type": "messaging_extension_reply",
                "package_name": "com.pushbullet.android",
                "source_user_iden": self.user_info['iden'],
                "target_device_iden": device.device_iden,
                "conversation_iden": number,
                "message": message
            }
        }

        r = self._session.post(self.EPHEMERALS_URL, data=json.dumps(data))
        if r.status_code == requests.codes.ok:
            return r.json()
        raise PushError(r.text)

    def refresh(self):
        self._load_devices()
        self._load_chats()
        self._load_user_info()
        self._load_channels()
