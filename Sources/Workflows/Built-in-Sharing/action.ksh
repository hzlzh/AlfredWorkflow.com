QUERY="$1"
OTHER_SERVICE="$2"

service=$(echo "${QUERY}" | cut -f1 -d"|")
text=$(echo "${QUERY}" | cut -f2 -d"|")
image=$(echo "${QUERY}" | cut -f3 -d"|")
video=$(echo "${QUERY}" | cut -f4 -d"|")
url=$(echo "${QUERY}" | cut -f5 -d"|")

if [ ${service} = "delete_selected_file" ]
then
	if [ -f file_list ]
	then
		file=$(cat file_list)
		rm file_list
	fi
	echo "Cancelled sharing of $file"
	exit 0
fi

text=$(echo ${text} | sed 's/AMPERSANDCHARACTER/\&/g')
text=$(echo ${text} | sed 's/LOWERTHANCHARACTER/</g')
text=$(echo ${text} | sed 's/GREATERTHANCHARACTER/>/g')
text=$(echo ${text} | sed 's/PIPECHARACTER/|/g')


if [ -f ./terminal-share.app/Contents/MacOS/terminal-share ]
then
	if [ "${OTHER_SERVICE}" = "droplr" ]
	then
		if [ ${service} = "facebook" ] || [ ${service} = "message" ] || [ ${service} = "email" ] || [ ${service} = "twitter" ]
		then
			if [ "-${image}-" != "--" ]
			then
				file=${image}
				image=""
			elif [ "-${otherfile}-" != "--" ]
			then
				file=${otherfile}
				otherfile=""
			elif [ "-${video}-" != "--" ]
			then
				file=${video}
				video=""
			else
				echo "Error: Droplr upload only works when a file is selected"
				exit 0					
			fi
				
			echo "" | pbcopy
			
			# check if droplr is started
			number=$(ps aux | grep Droplr | grep -v grep | wc -l)			
			if [ $number -lt 1 ]
			then
				open -a Droplr
				sleep 4
			fi
			open -a Droplr "${file}"
			if [ $? != 0 ]
			then
				echo "Error: Droplr could not be opened"
				exit 0
			fi
			
			typeset -i iter=1
			while [ iter -lt 300 ] 
			do 
				output=$(pbpaste)
				if [ "-${output}-" != "--" ]
				then
					break		
				fi
				let iter=${iter}+1
				sleep 1
			done
					
			text="${text} ${output}"
		else
			echo "Error: Droplr upload only works with facebook, twitter, imessage and email"
			exit 0	
		fi
	fi
	
	if [ ${service} = "email" ]
	then
		./terminal-share.app/Contents/MacOS/terminal-share -service "${service}" -image "${image}" -text "${text}" -video "${video}"
	elif [ ${service} = "readinglist" ]
	then
		./terminal-share.app/Contents/MacOS/terminal-share -service "${service}" -url "${url}"
	else
		if [ "-${image}-" != "--" ]
		then
			./terminal-share.app/Contents/MacOS/terminal-share -service "${service}" -text "${text}" -image "${image}"
		elif [ "-${video}-" != "--" ]
		then
			./terminal-share.app/Contents/MacOS/terminal-share -service "${service}" -text "${text}" -video "${video}"
		else
			./terminal-share.app/Contents/MacOS/terminal-share -service "${service}" -text "${text}"
		fi		
	fi	
	
	if [ $? != 0 ]
	then
		echo "Sharing has been cancelled"
	else
		if [ ${service} = "readinglist" ]
		then
			echo "URL $url was added to Safari Reading List"
		else
			echo "Sharing has been successful"
		fi
	fi
else
	echo "ERROR: terminal-share is not installed"
fi

if [ -f file_list ]
then
	rm file_list
fi