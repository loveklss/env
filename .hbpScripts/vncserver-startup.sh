#!/bin/bash

function process_id(){
pid=`ps -ef | grep -v grep | grep $1 | sed -n '1p' | awk '{print $2}'`
}

process_id Xvnc4
if [ -z $pid ];then
	vncserver -depth 24 -geometry 1440x840
fi

