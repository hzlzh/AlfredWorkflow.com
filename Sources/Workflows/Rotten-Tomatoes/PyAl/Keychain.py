from ctypes import *
from ctypes import util
from core import *

security = cdll.LoadLibrary(util.find_library("Security"))


class Keychain:
    def __init__(self, service=None):
        if service:
            self.service = c_char_p(service)
            self.serviceLen = c_ulong(len(service))
        else:
            self.service = c_char_p(bundle())
            self.serviceLen = c_ulong(len(bundle()))

    def storePassword(self, account, password):
        acctLen = c_ulong(len(account))
        pwLen = c_ulong(len(password))
        acctData = c_char_p(account)
        pwData = c_char_p(password)
        security.SecKeychainAddGenericPassword(
                    None,
                    self.serviceLen,
                    self.service,
                    acctLen,
                    acctData,
                    pwLen,
                    pwData,
                    None
            )

    def retrievePassword(self, account):
        acctLen = c_ulong(len(account))
        acctData = c_char_p(account)
        pwLen = c_ulong()
        pwData = pointer(c_char_p())

        security.SecKeychainFindGenericPassword(
                    None,
                    self.serviceLen,
                    self.service,
                    acctLen,
                    acctData,
                    byref(pwLen),
                    pwData,
                    None
            )

        return pwData[0]

    def modifyPassword(self, account, newPassword):
        acctLen = c_ulong(len(account))
        newPwLen = c_ulong(len(newPassword) + 1)
        itemRef = pointer(c_void_p())
        newPwData = create_string_buffer(newPassword)

        security.SecKeychainFindGenericPassword(
                    None,
                    self.serviceLen,
                    self.service,
                    acctLen,
                    account,
                    None,
                    None,
                    itemRef
            )
        security.SecKeychainItemModifyAttributesAndData(
                itemRef.contents,
                None,
                newPwLen,
                newPwData
        )

    def deletePassword(self, account):
        acctLen = c_ulong(len(account))
        itemRef = c_void_p()
        security.SecKeychainFindGenericPassword(
                    None,
                    self.serviceLen,
                    self.service,
                    acctLen,
                    account,
                    None,
                    None,
                    byref(itemRef)
            )
        security.SecKeychainItemDelete(itemRef)
