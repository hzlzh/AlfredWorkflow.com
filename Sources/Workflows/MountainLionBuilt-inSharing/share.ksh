#!/bin/ksh

text="$1"
image=""
url=""
video=""
extension=""
file=""
otherfile=""

typeset -i uid_counter
uid_counter=0
typeset timestamp

print "<?xml version=\"1.0\"?>"
print "<items>"

DATE=`date +"%s"`
let uid_counter=$uid_counter+1
timestamp=$DATE$uid_counter


if [ -f file_list ]
then
	file=$(cat file_list)
	# in case file has spaces
	file_without_spaces=$(echo "$file" | perl -pe 's/ /?/g')

	if [ "-${file}-" != "--" ] && [ -d ${file_without_spaces} ]
	then		
		print "<item uid=\"$timestamp\" arg=\"\" valid=\"no\">"
		print "<title>The selected element is a directory.</title>"
		print "<subtitle>Sharing directories is not supported. Zip it.</subtitle>"
		print "<icon type=\"fileicon\">${file}</icon>"
		print "</item>"
		exit 0
	fi	
		
	if [ "-${file}-" != "--" ] && [ -f ${file_without_spaces} ]
	then
		filename=$(basename "$file")
		extension="${filename##*.}"
		filename="${filename%.*}"
		filesize=$(ls -lah ${file_without_spaces} | awk '{ print $5}')
		
		let uid_counter=$uid_counter+1
		timestamp=$DATE$uid_counter
			
		
		print "<item uid=\"$timestamp\" arg=\"delete_selected_file||||\" valid=\"yes\">"
		print "<title>Selected file: ${filename}.${extension} (size: ${filesize}). Select to cancel sharing.</title>"
		print "<subtitle>${file}</subtitle>"
		print "<icon type=\"fileicon\">${file}</icon>"
		print "</item>"
		
		extension=$(echo ${extension} | awk '{print tolower($0)}')
		
		if [ ${extension} = "jpg" ] || [ ${extension} = "jpeg" ] || [ ${extension} = "png" ] || [ ${extension} = "gif" ] || [ ${extension} = "bmp" ] || [ ${extension} = "tif" ]
		then
			image=${file}
		elif [ ${extension} = "mov" ] || [ ${extension} = "avi" ] || [ ${extension} = "wmv" ] || [ ${extension} = "mp4" ] || [ ${extension} = "mpg" ]
		then
			video=${file}
		else
			otherfile=${file}
		fi
	fi
fi

# check for url in typed text
regex='(http(s?)\:\/\/|~/|/)+([a-zA-Z]{1}([\w\-]+\.)+([\w]{2,5}))(:[\d]{1,5})?/?(\w+\.[\w]{3,4})?((\?\w+=\w+)?(&\w+=\w+)*)?'

if [[ $text =~ $regex ]]
then
	url="${text}"
	url=$(echo "${url}" | sed 's/.*http\:/http:/')
	# remove anything after space
	url=$(echo "${url}" | sed 's/ .*//')
	url=$(echo "${url}" | sed 's/ //')
	url=$(echo "${url}" | sed 's/\\//g')
fi
	
# service|text|image|video|url

# remove backslash for displaying text
displayed_text=$(echo ${text} | sed 's/\\//g')

# replace some weird characters
# as $text is passed as csv argument
text=$(echo ${text} | sed "s/'/\\'/g")
text=$(echo ${text} | sed 's/"//g')
text=$(echo ${text} | sed 's/&/AMPERSANDCHARACTER/g')
text=$(echo ${text} | sed 's/</LOWERTHANCHARACTER/g')
text=$(echo ${text} | sed 's/>/GREATERTHANCHARACTER/g')
text=$(echo ${text} | sed 's/|/PIPECHARACTER/g')


##
# facebook
##
let uid_counter=$uid_counter+1
timestamp=$DATE$uid_counter
if [ "-${image}-" != "--" ]
then
	print "<item uid=\"$timestamp\" arg=\"facebook|$text|$image||\" valid=\"yes\">"
	print "<title>Post image ${filename}.${extension} on Facebook</title>"
	if [ "-${displayed_text}-" != "--" ]
	then
		print "<subtitle><![CDATA[message: ${displayed_text}]]></subtitle>"
	else
		print "<subtitle>Type to add text to your post (use cmd to upload file with Droplr)</subtitle>"
	fi
	print "<icon>./images/facebook.png</icon>"
	print "</item>"
elif [ "-${otherfile}-" = "--"  -a  "-${video}-" = "--" ]
then
	print "<item uid=\"$timestamp\" arg=\"facebook|$text|$image||\" valid=\"yes\">"
	print "<title>Post on Facebook</title>"
	if [ "-${displayed_text}-" != "--" ]
	then
		print "<subtitle><![CDATA[message: ${displayed_text}]]></subtitle>"
	else
		print "<subtitle>Type to add text to your post</subtitle>"
	fi
	print "<icon>./images/facebook.png</icon>"
	print "</item>"
fi

##
# twitter
##
let uid_counter=$uid_counter+1
timestamp=$DATE$uid_counter
if [ "-${image}-" != "--" ]
then	
	print "<item uid=\"$timestamp\" arg=\"twitter|$text|$image||\" valid=\"yes\">"
	print "<title>Post image ${filename}.${extension} on Twitter</title>"
	if [ "-${displayed_text}-" != "--" ]
	then
		print "<subtitle><![CDATA[message: ${displayed_text}]]></subtitle>"
	else
		print "<subtitle>Type to add text to your post (use cmd to upload file with Droplr)</subtitle>"
	fi
	print "<icon>./images/twitter.png</icon>"
	print "</item>"	
elif [ "-${otherfile}-" = "--"  -a  "-${video}-" = "--" ]
then
	print "<item uid=\"$timestamp\" arg=\"twitter|$text|||\" valid=\"yes\">"
	print "<title>Post on Twitter</title>"
	if [ "-${displayed_text}-" != "--" ]
	then
		print "<subtitle><![CDATA[message: ${displayed_text}]]></subtitle>"
	else
		print "<subtitle>Type to add text to your post</subtitle>"
	fi
	print "<icon>./images/twitter.png</icon>"
	print "</item>"	
fi

##
# message
##
let uid_counter=$uid_counter+1
timestamp=$DATE$uid_counter
if [ "-${image}-" != "--" ]
then
	print "<item uid=\"$timestamp\" arg=\"message|$text|$image||\" valid=\"yes\">"
	print "<title>Attach image ${filename}.${extension} into Message</title>"
	if [ "-${displayed_text}-" != "--" ]
	then
		print "<subtitle><![CDATA[message: ${displayed_text}]]></subtitle>"
	else
		print "<subtitle>Type to add text to your message (use cmd to upload file with Droplr)</subtitle>"
	fi
	print "<icon>./images/imessage.png</icon>"
	print "</item>"
elif [ "-${otherfile}-" != "--" ]
then	
	# use video to send files
	print "<item uid=\"$timestamp\" arg=\"message|$text||$otherfile|\" valid=\"yes\">"
	print "<title>Attach file ${filename}.${extension} into Message</title>"
	if [ "-${displayed_text}-" != "--" ]
	then
		print "<subtitle><![CDATA[message: ${displayed_text}]]></subtitle>"
	else
		print "<subtitle>Type to add text to your message (use cmd to upload file with Droplr)</subtitle>"
	fi
	print "<icon>./images/imessage.png</icon>"
	print "</item>"
elif [ "-${video}-" != "--" ]
then
	print "<item uid=\"$timestamp\" arg=\"message|$text||$video|\" valid=\"yes\">"
	print "<title>Attach video ${filename}.${extension} into Message</title>"
	if [ "-${displayed_text}-" != "--" ]
	then
		print "<subtitle><![CDATA[message: ${displayed_text}]]></subtitle>"
	else
		print "<subtitle>Type to add text to your message (use cmd to upload file with Droplr)</subtitle>"
	fi
	print "<icon>./images/imessage.png</icon>"
	print "</item>"	
else
	print "<item uid=\"$timestamp\" arg=\"message|$text|||\" valid=\"yes\">"
	print "<title>Compose Message</title>"
	if [ "-${displayed_text}-" != "--" ]
	then
		print "<subtitle><![CDATA[message: ${displayed_text}]]></subtitle>"
	else
		print "<subtitle>Type to add text to your message</subtitle>"
	fi
	print "<icon>./images/imessage.png</icon>"
	print "</item>"	
fi


##
# email
##
let uid_counter=$uid_counter+1
timestamp=$DATE$uid_counter
if [ "-${image}-" != "--" ]
then
	print "<item uid=\"$timestamp\" arg=\"email|$text|$image||\" valid=\"yes\">"
	print "<title>Attach image ${filename}.${extension} into Email</title>"
	if [ "-${displayed_text}-" != "--" ]
	then
		print "<subtitle><![CDATA[message: ${displayed_text}]]></subtitle>"
	else
		print "<subtitle>Type to add text to your message (use cmd to upload file with Droplr)</subtitle>"
	fi
	print "<icon>./images/mail.png</icon>"
	print "</item>"	
elif [ "-${otherfile}-" != "--" ]
then
	print "<item uid=\"$timestamp\" arg=\"email|$text||$otherfile|\" valid=\"yes\">"
	print "<title>Attach file ${filename}.${extension} into Email</title>"
	if [ "-${displayed_text}-" != "--" ]
	then
		print "<subtitle><![CDATA[message: ${displayed_text}]]></subtitle>"
	else
		print "<subtitle>Type to add text to your message (use cmd to upload file with Droplr)</subtitle>"
	fi
	print "<icon>./images/mail.png</icon>"
	print "</item>"	
elif [ "-${video}-" != "--" ]
then
	print "<item uid=\"$timestamp\" arg=\"email|$text||$video|\" valid=\"yes\">"
	print "<title>Attach video ${filename}.${extension} into Email</title>"
	if [ "-${displayed_text}-" != "--" ]
	then
		print "<subtitle><![CDATA[message: ${displayed_text}]]></subtitle>"
	else
		print "<subtitle>Type to add text to your message (use cmd to upload file with Droplr)</subtitle>"
	fi
	print "<icon>./images/mail.png</icon>"
	print "</item>"	
else
	print "<item uid=\"$timestamp\" arg=\"email|$text|||\" valid=\"yes\">"
	print "<title>Compose Email</title>"
	if [ "-${displayed_text}-" != "--" ]
	then
		print "<subtitle><![CDATA[message: ${displayed_text}]]></subtitle>"
	else
		print "<subtitle>Type to add text to your message</subtitle>"
	fi
	print "<icon>./images/mail.png</icon>"
	print "</item>"	
fi

##
# airdrop
##
let uid_counter=$uid_counter+1
timestamp=$DATE$uid_counter
if [ "-${image}-" != "--" ]
then
	# use video to send files
	print "<item uid=\"$timestamp\" arg=\"airdrop|||$image|\" valid=\"yes\">"
	print "<title>Send image ${filename}.${extension} via AirDrop</title>"
	print "<subtitle>${image}</subtitle>"
	print "<icon>./images/airdrop.png</icon>"
	print "</item>"
elif [ "-${otherfile}-" != "--" ]
then
	print "<item uid=\"$timestamp\" arg=\"airdrop|||$otherfile|\" valid=\"yes\">"
	print "<title>Send file ${filename}.${extension} via AirDrop</title>"
	print "<subtitle>${otherfile}</subtitle>"
	print "<icon>./images/airdrop.png</icon>"
	print "</item>"	
elif [ "-${video}-" != "--" ]
then
	print "<item uid=\"$timestamp\" arg=\"airdrop|||$video|\" valid=\"yes\">"
	print "<title>Send video ${filename}.${extension} via AirDrop</title>"
	print "<subtitle>${video}</subtitle>"
	print "<icon>./images/airdrop.png</icon>"
	print "</item>"	
fi

#
# image only
#
if [ "-${image}-" != "--" ]
then
	##
	# flicker
	##	
	let uid_counter=$uid_counter+1
	timestamp=$DATE$uid_counter
	print "<item uid=\"$timestamp\" arg=\"flickr||$image||\" valid=\"yes\">"
	print "<title>Post image ${filename}.${extension} on Flickr</title>"
	print "<subtitle>${image}</subtitle>"
	print "<icon>./images/flickr.png</icon>"
	print "</item>"

	##
	# iphoto
	##
	let uid_counter=$uid_counter+1
	timestamp=$DATE$uid_counter
	print "<item uid=\"$timestamp\" arg=\"iphoto||$image||\" valid=\"yes\">"
	print "<title>Add image ${filename}.${extension} to iPhoto</title>"
	print "<subtitle>${image}</subtitle>"
	print "<icon>./images/iphoto.png</icon>"
	print "</item>"	

	##
	# aperture
	##	
	let uid_counter=$uid_counter+1
	timestamp=$DATE$uid_counter
	print "<item uid=\"$timestamp\" arg=\"aperture||$image||\" valid=\"yes\">"
	print "<title>Add image ${filename}.${extension} to Aperture</title>"
	print "<subtitle>${image}</subtitle>"
	print "<icon>./images/aperture.png</icon>"
	print "</item>"
fi

#
# video only
#
if [ "-${video}-" != "--" ]
then
	##
	# vimeo
	##	
	let uid_counter=$uid_counter+1
	timestamp=$DATE$uid_counter
	print "<item uid=\"$timestamp\" arg=\"vimeo|||$video|\" valid=\"yes\">"
	print "<title>Post video on Vimeo</title>"
	print "<subtitle>${video}</subtitle>"
	print "<icon>./images/vimeo.png</icon>"
	print "</item>"
fi

#
# url only
#
if [ "-${url}-" != "--" ]
then
	##
	# readinglist
	##	
	let uid_counter=$uid_counter+1
	timestamp=$DATE$uid_counter
	print "<item uid=\"$timestamp\" arg=\"readinglist||||$url\" valid=\"yes\">"
	print "<title>Add to Safari Reading List</title>"
	print "<subtitle>URL is ${url}</subtitle>"
	print "<icon>./images/readinglist.png</icon>"
	print "</item>"	
fi

print "</items>"