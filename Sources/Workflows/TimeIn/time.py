from xml.etree import ElementTree as ET
import wolframalpha
import urllib

# Consts
app_id = ''

# Variables
client = wolframalpha.Client(app_id)

def get_current_time(place):
    timeRes = client.query('time in ' + place)
    timePod = timeRes.pods[1]
    currentTime = timePod.text
    return currentTime

def get_location_icon_url(place):
    flagRes = client.query('Flag of ' + place)
    flagPod = flagRes.pods[1]
    flagUrl = flagPod.main.node._children[1].get('src')
    return flagUrl

def make_temp_location_file(flagUrl, temp_flag_file_name):
    urllib.urlretrieve(flagUrl, temp_flag_file_name)

def get_location_item(place):
    temp_flag_file_name = 'temp_flag.gif'

    currentTime = get_current_time(place)
    try:
        locationIconUrl = get_location_icon_url(place)
        make_temp_location_file(locationIconUrl, temp_flag_file_name)
    except IndexError:
        temp_flag_file_name = 'icon.png'

    xml_items = ET.Element('items')
    xml_item = ET.SubElement(xml_items, 'item')

    xml_item.set('uid', 'convert')
    xml_item.set('arg', place)
    xml_item_title = ET.SubElement(xml_item, 'title')
    xml_item_title.text = place + ' - ' + currentTime
    xml_item_icon = ET.SubElement(xml_item, 'icon')
    xml_item_icon.text = temp_flag_file_name
    return ET.tostring(xml_items)