#! /bin/bash
if [ $# != 2 ]
then
	echo parameter is error!!!
	exit 1
else
	echo parameter is OK!
fi
varInShell=		#测试Shell内部变量
replace=		#测试替换运算符
pattern_del=	#测试模式匹配运算符
special_var=	#测试Shell特殊变量$*、$@
#############################################################
if [ -n "$varInShell" ]
then
	echo "$0 PID=$$"
	echo $ENV
	echo "home=$HOME"
	echo "LANG=$LANG"
	echo "LC_ALL=$LC_ALL"
	echo "LINENO=$LINENO"
fi
#############################################################
echo "***** test for test命令 *****"
ls -l test
#if test $? = 0
#if [ $? = "0" ]
if test $? = 0
then
	rm test
	echo \$?=$?, ls command ok!
else
	echo \$?=$?, ls command failed!
fi
######################################################
if test -n "$replace";then
	echo "***** test for 替换运算符 *****"
	variable1=
	echo "variable1 content: ${variable1}"

	#替换运算符
	#	${varname:-word}	(变量未定义，返回默认值)即：如果varname存在且非null，则返回其值；否则返回word. 
	#	${varname:=word}	(变量未定义，设置变量为默认值)即：如果varname存在且非null，则返回其值；否则设置varname的值为word,并返回其值。
	#	${varname:?message}	(捕捉变量未定义所导致的错误)即：如果varname存在且非null，则返回其值；否则显示varname:mesage并退出当前命令或脚本。
							#如果省略message会默认信息parameter null or not set.
	#	${varname:+word}	(测试变量的存在)即：如果varname存在且非null,则返回word;否则返回null.
	#上面的运算符内冒号(:)省略则变为“如果变量存在”，即运算符仅用于测试变量是否存在。
	#实例:
	echo ${variable1:-"variable1 not set or null"}	#如果varibale1未定义或为null，则返回“variable1 not set or null”
	echo ${variable1:="default value"}		#如果variable1未定义或为null,设置其值为“default value”并返回该值；否则返回variable1的值。
	echo ${variable1:?"No define"}			#如果variable1未定义或为null,则显示"No define"并退出该脚本。
	echo ${variable1:+1}					#如果variable1存在且非null，则返回1(真值)，否则返回null。
fi
if test -n "$pattern_del"; then
	#模式匹配运算符
	#	${variable#pattern}		#如果模式匹配于变量值的开头处，则删除匹配的最短部分，并返回剩下的部分。
	#	${variable##pattern}	#如果模式匹配于变量值的开头处，则删除匹配的最长部分，并返回剩下的部分。
	#	${variable%pattern}		#如果模式匹配于变量值的结尾处，则删除匹配的最短部分，并返回剩下的部分。
	#	${variable%%pattern}	#如果模式匹配于变量值的结尾处，则删除匹配的最长部分，并返回剩下的部分。
	#实例
	echo "***** test for 模式匹配运算符 *****"
	path1=/home/tolstoy/mem/long.file.name
	echo path1 original value=$path1
	echo ${path1#/*/}			#结果为:tolstoy/mem/long.file.name
	echo ${path1##/*/}			#结果为:long.file.name
	echo ${path1%.*}			#结果为:/home/tolstoy/mem/long.file
	echo ${path1%%.*}			#结果为:/home/tolstoy/mem/long
fi
#########################################################
if [ -n "$special_var" ]
then
	set -- param1 "param2-0 param2-1" param3
	echo "There are $# total arguments."		#变量$#提供传递给shell脚本或函数的参数总数。
	#printf "Arguments total number=%s\n" $#
	echo "***** test1 for \$* *****"
	for i in $*
	do
		echo i is $i
	done
	echo "***** test2 for \$@ *****"
	for i in $@
	do
		echo i is $i
	done				#没有双引号的情况下，$*与$@是一样的。
	echo "***** test3 for \"\$*\" *****"
	for i in "$*"
	do
		echo i is $i
	done				#加双引号,“$*”表示一个字符串。
	echo "***** test4 for \"\$@\" *****"
	for i in "$@"
	do
		echo i is $i
	done				#加双引号，“$@”保留真正的参数值。将每个参数视为单独的个体。
	echo "***** test5 for shift 2 *****"
	shift 2				#截去2个参数
	echo "$*"
	echo "$@"
fi
########################################




exit $?
