##
# By @simonbs
# http://simonbs.dk/
##

import youtube
import string
from Feedback import Feedback

# Returns feedback according to query
def youtube_helper(query):
  args = string.split(query, " ")
  if (args[0] == "s" or args[0] == "search") and len(args) > 1 and args[1] is not "":
    return youtube.search_videos(" ".join(args[1:]))
  elif (args[0] == "c" or args[0] == "channels") and len(args) > 1 and args[1] is not "":
    return youtube.search_channels(" ".join(args[1:]))
  elif (args[0] == "cv" or args[0] == "channelvideos") and len(args) > 1 and args[1] is not "":
    return youtube.channel_videos(" ".join(args[1:]))
  elif args[0] == "toprated":
    return youtube.top_rated_videos()
  elif args[0] == "topfavorited":
    return youtube.top_favorited_videos()
  elif args[0] == "mostviewed":
    return youtube.most_viewed_videos()
  elif args[0] == "mostpopular":
    return youtube.most_popular_videos()
  elif args[0] == "mostrecent":
    return youtube.most_recent_videos()
  elif args[0] == "mostdiscussed":
    return youtube.most_discussed_videos()
  elif args[0] == "mostresponded":
    return youtube.most_responded_videos()
  elif args[0] == "recentlyfeatured":
    return youtube.recently_featured_videos()
  elif len(args) == 0 or args[0] == "":
    feedback = Feedback()
    feedback.add_item("Search videos", "", "", "no", "s")
    feedback.add_item("Search channels", "", "", "no", "c")
    feedback.add_item("View videos on channel", "", "", "no", "cv")
    feedback.add_item("Top rated videos", "", "", "no", "toprated")
    feedback.add_item("Top favorited videos", "", "", "no", "topfavorited")
    feedback.add_item("Most viewed videos", "", "", "no", "mostviewed")
    feedback.add_item("Most popular videos", "", " videos", "no", "mostpopular")
    feedback.add_item("Most recent videos", "", "", "no", "mostrecent")
    feedback.add_item("Most discussed videos", "", "", "no", "mostdiscussed")
    feedback.add_item("Most responded videos", "", "", "no", "mostresponded")
    feedback.add_item("Recently featured videos", "", "", "no", "recentlyfeatured")
    return feedback
  else:
    return youtube.search_videos(" ".join(args))
  return None