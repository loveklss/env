
pid=`ps -ef | grep -v grep | grep Xvnc4 | sed -n '1p' | awk '{print $2}'`
if [ -z $pid ];then
	vncserver -depth 24 -geometry 1440x840
fi

