#!/usr/bin/env python

import sys
import alp

# calculate decimal number
decimal = int(sys.argv[1], 2)
# create associative array and create xml from it
decimalDic = dict(title=str(decimal), subtitle="Decimal", uid="decimal", valid=True, arg=str(decimal), icon="icons/decimal.png")
d = alp.Item(**decimalDic)


# calculate octal number
octal = oct(decimal)[1:]
# create associative array and create xml from it
octalDic = dict(title=str(octal), subtitle="Octal", uid="octal", valid=True, arg=str(octal), icon="icons/octal.png")
o = alp.Item(**octalDic)


# calculate hex number
hexadec = hex(decimal)[2:].upper()
# create associative array and create xml from it
hexDic = dict(title=str(hexadec), subtitle="Hexadecimal", uid="hex", valid=True, arg=str(hexadec), icon="icons/hex.png")
h = alp.Item(**hexDic)

itemsList = [d, o, h]
alp.feedback(itemsList)