#!/usr/bin/env python

""" Arguments
	sys.argv[0] = filename
	sys.argv[1] = number
	sys.argv[2] = source
	sys.argv[3] = destination
"""

import sys
import alp
import string
ALPHA = string.digits + string.uppercase + string.lowercase

def base62_encode(num, base, alphabet=ALPHA):
    """Encode a number in Base X

    `num`: The number to encode
    `base`: Base of number
    `alphabet`: The alphabet to use for encoding
    """
    if (num == 0):
        return alphabet[0]
    arr = []
    while num:
        rem = num % base
        num = num // base
        arr.append(alphabet[rem])
    arr.reverse()
    return ''.join(arr)

def base62_decode(string, base, alphabet=ALPHA):
	"""Decode a Base X encoded string into the number

	Arguments:
	- `string`: The encoded string
	- `base`: base of number
	- `alphabet`: The alphabet to use for encoding
	"""
	strlen = len(string)
	num = 0

	idx = 0
	for char in string:
	    power = (strlen - (idx + 1))
	    num += alphabet.index(char) * (base ** power)
	    idx += 1

	return num


if (len(sys.argv) == 4 and sys.argv[3] != "1"):
	# calculate integer first
	if (int(sys.argv[2]) <= 36):
		decimal = int(sys.argv[1], int(sys.argv[2]))
	elif (int(sys.argv[2]) > 36 and int(sys.argv[2]) <= 62):
		decimal = base62_decode(sys.argv[1], int(sys.argv[2]))
	else:
		# create dictionary to create xml from it
		errorDic = dict(title="Ohoh, your number couldn't be converted", subtitle="make sure your base is between 2 and 62", uid="error", valid=False)
		e = alp.Item(**errorDic)
		alp.feedback(e)
		sys.exit()

	# create dictionary to create xml from it
	decimalDic = dict(title=str(decimal), subtitle="Decimal", uid="decimal", valid=True, arg=str(decimal), icon="icons/decimal.png")
	d = alp.Item(**decimalDic)

	# calculate new number
	if (int(sys.argv[3]) >= 2 and int(sys.argv[3]) <= 62):
		conv = base62_encode(decimal, int(sys.argv[3]))
	else:
		# create dictionary to create xml from it
		errorDic = dict(title="Ohoh, your number couldn't be converted", subtitle="make sure your base is between 2 and 62", uid="error", valid=False)
		e = alp.Item(**errorDic)
		itemsList = [d, e]
		alp.feedback(itemsList)
		sys.exit()

	# create dictionary to create xml from it
	convertDic = dict(title=conv, subtitle="Number to base " + str(sys.argv[3]), uid="conv", valid=True, arg=conv)
	c = alp.Item(**convertDic)

	if (int(sys.argv[2]) >= 36 or int(sys.argv[3]) >= 36):
		# create dictionary to create xml from it
		infoDic = dict(title="Case-Sensitive", subtitle="Be aware, if base is >= 36 letters are case-sensitive", uid="conv", valid=True, arg=conv)
		i = alp.Item(**infoDic)
		itemsList = [d, c, i]
	else:
		itemsList = [d, c]

	alp.feedback(itemsList)

else:
	if (int(sys.argv[3]) == 1):
		errorDic = dict(title="Base 1 makes no sense", subtitle="", uid="error", valid=False, arg="error")
		error = alp.Item(**errorDic)
		alp.feedback(error)
	else:
		errorDic = dict(title="Make sure to pass 3 numbers", subtitle="for help type \"nsc help\"", uid="error", valid=False, arg="error")
		error = alp.Item(**errorDic)
		alp.feedback(error)
