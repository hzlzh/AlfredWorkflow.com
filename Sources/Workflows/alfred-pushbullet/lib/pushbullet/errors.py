class PushbulletError(Exception):
    pass

class InvalidKeyError(PushbulletError):
    pass

class PushError(PushbulletError):
    pass
