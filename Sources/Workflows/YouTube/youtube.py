##
# By @simonbs
# http://simonbs.dk/
##

# Whether or not to show the view count in subtitle
SUBTITLE_SHOWS_VIEW_COUNT = False

# Locale
LOCALE = "da_DK"

###
# Don't edit below :-)
##

import re
import sys
import urllib
import json
import locale
from Feedback import Feedback
from xml.dom import minidom

# Returns the top rated videos on YouTube.
def top_rated_videos(max_results = 0):
  return results("https://gdata.youtube.com/feeds/api/standardfeeds/top_rated?v=2&alt=jsonc", max_results)

# Returns the top favorited videos on YouTube.
def top_favorited_videos(max_results = 0):
  return results("https://gdata.youtube.com/feeds/api/standardfeeds/top_favorites?v=2&alt=jsonc", max_results)
  
# Returns the most viwed videos on YouTube.
def most_viewed_videos(max_results = 0):
  return results("https://gdata.youtube.com/feeds/api/standardfeeds/most_viewed?v=2&alt=jsonc", max_results)
  
# Returns the most popular videos on YouTube.
def most_popular_videos(max_results = 0):
  return results("https://gdata.youtube.com/feeds/api/standardfeeds/most_popular?v=2&alt=jsonc", max_results)

# Returns the most recent videos on YouTube.
def most_recent_videos(max_results = 0):
  return results("https://gdata.youtube.com/feeds/api/standardfeeds/most_recent?v=2&alt=jsonc", max_results)
  
# Returns the most discussed videos on YouTube.
def most_discussed_videos(max_results = 0):
  return results("https://gdata.youtube.com/feeds/api/standardfeeds/most_discussed?v=2&alt=jsonc", max_results)

# Returns the most responded videos on YouTube.
def most_responded_videos(max_results = 0):
  return results("https://gdata.youtube.com/feeds/api/standardfeeds/most_responded?v=2&alt=jsonc", max_results)

# Returns the recently featured videos on YouTube.
def recently_featured_videos(max_results = 0):
  return results("https://gdata.youtube.com/feeds/api/standardfeeds/recently_featured?v=2&alt=jsonc", max_results)

# Returns the videos for a given channel
def channel_videos(username, max_results = 0, orderby = "published"):
  url = "https://gdata.youtube.com/feeds/api/users/%s/uploads?v=2&alt=jsonc&orderby=%s" % (username, orderby)
  return results(url, max_results)
  
# Searches YouTube for results matching the terms and returns the results.
# Supported values for orderby are
# - relevance, viewCount, published, rating
def search_videos(terms, max_results = 0, orderby = "relevance"):
  url = "https://gdata.youtube.com/feeds/api/videos?v=2&alt=jsonc&q=%s&orderby=%s" % (terms, orderby)
  return results(url, max_results)
  
# Searches for channels.
def search_channels(query, max_results = 0):
  feedback = Feedback()
  url = "https://gdata.youtube.com/feeds/api/channels?q=%s&v=2" % (query)
  url = max_results_url(url, max_results)
  content = content_of_url(url)
  dom = minidom.parseString(content)
  entries = dom.getElementsByTagName("entry")
  for entry in entries:
    title = entry.getElementsByTagName("title")[0].firstChild.nodeValue
    summary = entry.getElementsByTagName("summary")[0].firstChild
    name = entry.getElementsByTagName("author")[0].firstChild.firstChild.nodeValue
    if summary is not None:
      summary = summary.data
    feedback.add_item(title, summary, ("http://www.youtube.com/user/%s" % name))
  return feedback

# Returns XML parsed results for the specified URL and maximum amount of results.
def results(url, max_results):
  url = max_results_url(url, max_results)
  items = items_at_url(url)
  if items == None or len(items) == 0:
    return no_results()
  return xml_results(items)
  
# Appends the maximum results to a URL.
# The maximum results is only added if the value is between 1 and 50
# which is the range Google allows.
# If the max results falls out of this range, Googles default max results is used.
def max_results_url(url, max_results):
  if max_results >= 1 and max_results <= 50:
    url = "%s&max-results=%s" % (url, max_results)
  return url
  
# Loads the items at the specified URL.
def items_at_url(url):
  content = content_of_url(url)
  json_response = json.loads(content)
  if "data" in json_response and "items" in json_response["data"]:
    return json_response["data"]["items"]
  return None
  
# Loads the content of a URL.
def content_of_url(url):
  conn = urllib.urlopen(url)
  response = conn.read()
  return response
  
# Parses a list results into XML for Alfred.
def xml_results(items):
  feedback = Feedback()
  for item in items:
    video_id = item["id"]
    if video_id is not None:
      title = item["title"]
      subtitle = "by %s (%s)" % (item["uploader"], seconds_to_string(item["duration"]))
      if SUBTITLE_SHOWS_VIEW_COUNT is True:
        view_count = item["viewCount"]
        view_word = "view"
        if view_count is not 1:
          view_word = "views"
        subtitle = "%s [%s %s]" % (subtitle, locale.format("%d", view_count, grouping = True), view_word)
      feedback.add_item(title, subtitle, ("http://www.youtube.com/watch?v=%s" % video_id))
  return feedback

# Converts seconds into a string cotnaing hours, minutes and seconds and returns the string.
def seconds_to_string(seconds):
  hours = seconds / 3600
  minutes = (seconds % 3600) / 60
  seconds = seconds % 3600 % 60
  result = ""
  if hours > 0:
    result = "%sh" % (hours)
  if minutes > 0:
    if hours > 0:
      result = "%s " % (result)
    result = "%s%sm" % (result, minutes)
  if seconds > 0:
    if hours > 0 and minutes == 0 or minutes > 0:
      result = "%s " % (result)
    result = "%s%ss" % (result, seconds)
  return result
  
# Message returned when no results were found
def no_results():
  feedback = Feedback()
  feedback.add_item("No results found", "I'm really sorry that you had to experience this.", arg = "", valid = "no")
  return feedback
  
# Configurations
def config():
  if SUBTITLE_SHOWS_VIEW_COUNT == True:
    locale.setlocale(locale.LC_ALL, LOCALE)

# Make configurations
config()