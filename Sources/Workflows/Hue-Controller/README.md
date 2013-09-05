# Alfred 2 Workflow for Philips Hue

Trigger:

	hue [<command> | <light>:<function>:<query>]

## Examples

	hue off
	hue on
	hue party
	hue lights
	hue 2:off
	hue 1:effect:colorloop
	hue 1:effect:none
	hue 3:color:red

## Download

Download the extension here: http://goo.gl/Yt6qg

I've yet to officially release this workflow, but if you happened to stumble upon this Github repo, feel free to give it a try.  I will officially publish the workflow when I've finished the TODO items below and thoroughly tested everything.

## Setup

Press the link button on the top of the bridge and use the `setup-hue` Alfred keyword within 30 seconds to automatically configure the workflow to work with the Hue bridge on the local network.

A group id can optionally be specified, e.g. `setup-hue 1` (defaults to `0`, which is all of the Hue bulbs).  Although much of the [Groups API](http://developers.meethue.com/2_groupsapi.html) remains undocumented, some developers have figured out [how to add and configure groups](http://www.everyhue.com/vanilla/discussion/57/api-groups/p1).

## Screenshots

Home (blank query):

![Home](/screenshots/home.png)

Lights:

![Lights](/screenshots/lights.png)

Light controls:

![Control](/screenshots/control.png)

Setting the color:

![Color](/screenshots/color.png)

## Roadmap

* Add the ability to save current state as a preset.
