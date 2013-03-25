#!/bin/bash
# sh XLixian.sh {query}
# sh XLixian.sh user username password
# lx user username password

# setup env
export LANG=zh_CN.UTF-8
LOGtoFile=${LOGtoFile-true}
LOG_DIR=${LOG_DIR-~/Desktop}
LIXIAN_CLI_PATH=${LIXIAN_CLI_PATH-./iambus-xunlei-lixian/lixian_cli.py}
shopt -s expand_aliases
# Must set this option, else script will not expand aliases.
alias lx="python $LIXIAN_CLI_PATH"

# setup log: log "filename.txt"
log(){
(
	echo "-----------------------------------------------"
	echo "   Date: $(date)"
	echo "-----------------------------------------------" 
	) >>"$LOG_DIR/$1"
}

# get user input
CMD_ARR=($@)
CMD_NUM=${#CMD_ARR[@]}
echo "输入命令：lx" ${CMD_ARR[@]}

# execute
case "${CMD_ARR[0]}" in
	( "user" )
		echo "配置文件"
		if [[ $CMD_NUM = 3 ]]; then
			lx config username ${CMD_ARR[1]}
			lx config password ${CMD_ARR[2]}
		else
			echo "使用方法：lx user your_username your_password"
			lx config
		fi
		;;
	( "push" )
		echo "添加任务..."
		ADD_SRC=`pbpaste`
		MULTI_FILES=false
		#echo $ADD_SRC
		if [[ $CMD_NUM = 1 ]] ; then
			echo "---从剪切板---"
			#lx add "$ADD_SRC"
		elif [[ $CMD_NUM = 2 ]] && [[ ${CMD_ARR[1]} = "-t" ]] ; then
			echo "---BT 从剪切板---"
			EXE_ARG="--torrent"
			#lx add --torrent "$ADD_SRC"
		elif [[ $CMD_NUM = 2 ]] && [[ ${CMD_ARR[1]} = "-lf" ]] ; then
			echo "---从选择的链接文件---"
			ADD_SRC=`osascript -e 'tell application "Finder" to set theFile to POSIX path of (selection as alias)'`
			echo "$ADD_SRC"
			if [[ "$ADD_SRC" != "" ]]; then
				echo "---批量任务---"
				EXE_ARG="--input"
				#lx add --input "$ADD_SRC"
			else
				echo "请选中要添加的链接文件！"
				exit 1
			fi
		elif [[ $CMD_NUM = 2 ]] && [[ ${CMD_ARR[1]} = "-tf" ]] ; then
			echo "---从选择的BT文件---"
			OIFS=$IFS
			IFS=':'
			EXE_ARG="--torrent"
			ADD_SRC=(`osascript filepath.scpt`)
			IFS=$OIFS
			MULTI_FILES=true
			echo "${ADD_SRC[@]}"
		else
			echo "其他方式"
			exit 1 
		fi
		if [[ "$EXE_ARG" = "" ]]; then
			if [[ $LOGtoFile ]]; then
				lx add  "${ADD_SRC?}" >>$LOG_DIR/push_result.txt
			else
				lx add  "${ADD_SRC?}"
			fi
		elif $MULTI_FILES ; then
			OIFS=$IFS
			IFS=':'
			if $LOGtoFile ; then
				lx add "$EXE_ARG" "${ADD_SRC[@]}" >>$LOG_DIR/push_result.txt
			else
				lx add "$EXE_ARG" "${ADD_SRC[@]}"
			fi	
			IFS=$OIFS
		else
			echo "单文件模式"
			if $LOGtoFile ; then
				lx add "$EXE_ARG" "${ADD_SRC?}" >>$LOG_DIR/push_result.txt
			else
				lx add "$EXE_ARG" "${ADD_SRC?}"
			fi	
		fi
		if $LOGtoFile ; then
			log "push_result.txt"
		fi
		;;
	( "pull" )
		TASK_NAME_ID=${CMD_ARR[1]-`pbpaste`}
		echo "获取下载链接（ID）" "$TASK_NAME_ID" "下载链接保存到桌面文本文件中"
		lx list "$TASK_NAME_ID" --download-url >>$LOG_DIR/download-url.txt
		log "download-url.txt"
		;;
	( * )
		echo "your are superuser !!" "do what u want"
		echo "使用帮助：" "lx help"
		echo "查看配置：" "lx config"
		if $LOGtoFile ; then
			lx ${CMD_ARR[@]} >>$LOG_DIR/info.txt
		fi
		exit 2
		;;
esac
exit 0