#!/bin/bash
# rc.app startup script template
# Made to make creating one-off init scripts for your apps stupid easy
# 
# MIT Licensed. Copyright Lyon Bros. Enterprises, LLC

# ------------------------------------------------------------------------------
# config section
# ------------------------------------------------------------------------------
NAME=my-app
PID=/var/run/${NAME}.pid
USER=app
EXE=/path/to/node
APP=/path/to/app.js
ARGS=""
LOG=/var/log/apps/my-app.log
CWD=
CHGRP_LOG=0
# ------------------------------------------------------------------------------

function start () {
	spawn "${EXE} ${APP} ${ARGS}"
}

function stop () {
	app_pid=$(cat ${PID})
	if [ "${app_pid}" == "" ]; then
		return 0;
	fi
	
	children="$(allchildren ${app_pid})"
	echo "Stopping ${NAME} (pids:" ${children} ")"
	for x in $( echo "${children}" ); do
		do_kill $x
	done
}

function allchildren () {
	start=$1
	pids="${start}"
	next="$( pgrep -P ${start} )"
	while [ "${next}" != "" ]; do
		pids="${pids} ${next}"
		next="$( pgrep -P ${next} )"
	done
	echo "${pids}" | tr ' ' '\n'
}

function do_kill () {
	pid=$1
	while kill -0 ${pid} 2> /dev/null; do
		kill -TERM ${pid}
		sleep 1
	done
}

function restart () {
	stop
	sleep 1
	start
}

function is_running () {
	if [ -f ${PID} ]; then
		app_pid="$(cat ${PID})"
		kill -0 ${app_pid} > /dev/null 2>&1
		if [ "$?" == "0" ]; then
			echo "yes"
			return
		fi
	fi
	echo "no"
	return
}

function spawn () {
	apprun=$1
	mkdir -p `dirname ${LOG}`
	if [ "${CHGRP_LOG}" == "1" ]; then
		# allow user to directly write to the log
		touch ${LOG}
		chgrp ${USER} ${LOG}
		chmod 664 ${LOG}
	fi
	if [ "${CWD}" != "" ]; then
		cd ${CWD}
	fi
	echo "Starting ${NAME}: ${apprun}"
	sudo -u ${USER} sh -c "${apprun}" 1>> ${LOG} 2>&1 &
	app_pid=$!
	echo "${app_pid}" > ${PID}
}

case "$1" in
	start)
		if [ "$(is_running)" == "yes" ]; then
			echo "${NAME} already running (pid $( cat ${PID} ))"
			exit 1
		fi
		$1
		;;
	stop)
		if [ "$(is_running)" == "no" ]; then
			echo "${NAME} not running"
			exit 1
		fi
		$1
		;;
	status)
		if [ "$(is_running)" == "yes" ]; then
			echo "${NAME} is running (pid $( cat ${PID} ))"
		else
			echo "${NAME} is not running"
		fi
		;;
	restart)
		$1
		;;
	*)
		echo "Usage: $0 {start|stop|restart|status}"
		exit 2
esac

