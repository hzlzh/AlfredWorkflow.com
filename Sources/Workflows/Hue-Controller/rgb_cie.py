import math
import random
from collections import namedtuple


# Represents a CIE 1931 XY coordinate pair.
XYPoint = namedtuple('XYPoint', ['x', 'y'])


class ColorHelper:

	Red = XYPoint(0.675, 0.322)
	Lime = XYPoint(0.4091, 0.518)
	Blue = XYPoint(0.167, 0.04)

	def hexToRed(self, hex):
		"""Parses a valid hex color string and returns the Red RGB integer value."""
		return int(hex[0:2], 16)

	def hexToGreen(self, hex):
		"""Parses a valid hex color string and returns the Green RGB integer value."""
		return int(hex[2:4], 16)

	def hexToBlue(self, hex):
		"""Parses a valid hex color string and returns the Blue RGB integer value."""
		return int(hex[4:6], 16)

	def hexToRGB(self, h):
		"""Converts a valid hex color string to an RGB array."""
		rgb = [self.hexToRed(h), self.hexToGreen(h), self.hexToBlue(h)]
		return rgb

	def randomRGBValue(self):
		"""Return a random Integer in the range of 0 to 255, representing an RGB color value."""
		return random.randrange(0, 256)

	def crossProduct(self, p1, p2):
		"""Returns the cross product of two XYPoints."""
		return (p1.x * p2.y - p1.y * p2.x)

	def checkPointInLampsReach(self, p):
		"""Check if the provided XYPoint can be recreated by a Hue lamp."""
		v1 = XYPoint(self.Lime.x - self.Red.x, self.Lime.y - self.Red.y)
		v2 = XYPoint(self.Blue.x - self.Red.x, self.Blue.y - self.Red.y)

		q = XYPoint(p.x - self.Red.x, p.y - self.Red.y)
		s = self.crossProduct(q, v2) / self.crossProduct(v1, v2)
		t = self.crossProduct(v1, q) / self.crossProduct(v1, v2)

		return (s >= 0.0) and (t >= 0.0) and (s + t <= 1.0)

	def getClosestPointToPoint(self, A, B, P):
		"""Find the closest point on a line. This point will be reproducible by a Hue lamp."""
		AP = XYPoint(P.x - A.x, P.y - A.y)
		AB = XYPoint(B.x - A.x, B.y - A.y)
		ab2 = AB.x * AB.x + AB.y * AB.y
		ap_ab = AP.x * AB.x + AP.y * AB.y
		t = ap_ab / ab2

		if t < 0.0:
			t = 0.0
		elif t > 1.0:
			t = 1.0

		return XYPoint(A.x + AB.x * t, A.y + AB.y * t)

	def getDistanceBetweenTwoPoints(self, one, two):
		"""Returns the distance between two XYPoints."""
		dx = one.x - two.x
		dy = one.y - two.y
		return math.sqrt(dx * dx + dy * dy)

	def getXYPointFromRGB(self, red, green, blue):
		"""Returns an XYPoint object containing the closest available CIE 1931 coordinates
		based on the RGB input values."""

		r = ((red + 0.055) / (1.0 + 0.055))**2.4 if (red > 0.04045) else (red / 12.92)
		g = ((green + 0.055) / (1.0 + 0.055))**2.4 if (green > 0.04045) else (green / 12.92)
		b = ((blue + 0.055) / (1.0 + 0.055))**2.4 if (blue > 0.04045) else (blue / 12.92)

		X = r * 0.4360747 + g * 0.3850649 + b * 0.0930804
		Y = r * 0.2225045 + g * 0.7168786 + b * 0.0406169
		Z = r * 0.0139322 + g * 0.0971045 + b * 0.7141733

		cx = X / (X + Y + Z)
		cy = Y / (X + Y + Z)

		# cx = isNaN(cx) ? 0.0 : cx;
		# cy = isNaN(cy) ? 0.0 : cy;

		# Check if the given XY value is within the colourreach of our lamps.
		xyPoint = XYPoint(cx, cy)
		inReachOfLamps = self.checkPointInLampsReach(xyPoint)

		if not inReachOfLamps:
			# Color is unreproducible, find the closest point on each line in the CIE 1931 'triangle'.
			pAB = self.getClosestPointToPoint(self.Red, self.Lime, xyPoint)
			pAC = self.getClosestPointToPoint(self.Blue, self.Red, xyPoint)
			pBC = self.getClosestPointToPoint(self.Lime, self.Blue, xyPoint)

			# Get the distances per point and see which point is closer to our Point.
			dAB = self.getDistanceBetweenTwoPoints(xyPoint, pAB)
			dAC = self.getDistanceBetweenTwoPoints(xyPoint, pAC)
			dBC = self.getDistanceBetweenTwoPoints(xyPoint, pBC)

			lowest = dAB
			closestPoint = pAB

			if (dAC < lowest):
				lowest = dAC
				closestPoint = pAC

			if (dBC < lowest):
				lowest = dBC
				closestPoint = pBC

			# Change the xy value to a value which is within the reach of the lamp.
			cx = closestPoint.x
			cy = closestPoint.y

		return XYPoint(cx, cy)


class Converter:

	color = ColorHelper()

	def hexToCIE1931(self, h):
		"""Converts hexadecimal colors represented as a String to approximate CIE
		1931 coordinates. May not produce accurate values."""
		rgb = self.color.hexToRGB(h)
		return self.rgbToCIE1931(rgb[0], rgb[1], rgb[2])

	def rgbToCIE1931(self, red, green, blue):
		"""Converts red, green and blue integer values to approximate CIE 1931
		x and y coordinates. Algorithm from:
		http://www.easyrgb.com/index.php?X=MATH&H=02#text2. May not produce
		accurate values.
		"""
		point = self.color.getXYPointFromRGB(red, green, blue)
		return [point.x, point.y]

	def getCIEColor(self, hexColor=None):
		"""Returns the approximate CIE 1931 x,y coordinates represented by the
		supplied hexColor parameter, or of a random color if the parameter
		is not passed."""
		xy = []

		if hexColor:
			xy = self.hexToCIE1931(hexColor)

		else:
			r = self.color.randomRGBValue()
			g = self.color.randomRGBValue()
			b = self.color.randomRGBValue()
			xy = self.rgbToCIE1931(r, g, b)

		return xy
