#!/bin/bash

help_flag=0
######################################
clean()
{
	rm -vf tags
	rm -vf cscope.files
	rm -vf cscope.out cscope.in.out cscope.po.out 0 1
}
#####################
cscope_func()
{
	echo "Generate cscope.files"
	#find ./ -type f -regex '.*\.\(c\|h\)' \( \( -regex './arch/arm.+' -print \) -o -path "./arch*" -prune -o -print \) | sort -f > cscope.files
	if [ -n "$except_dir" ];then
		find -regex '\./\('$except_dir'\)' -prune -o -type f -regex '.+\.\(c\|cc\|cpp\|h\|S\|hpp\|tops\)' -print > cscope.files
	else
		find -type f -regex '.+\.\(c\|cc\|cpp\|h\|S\|hpp\|tops\)' -print > cscope.files
	fi
	#find -path "./arch" -prune -o -type f -regex '.+\.\(c\|h\)' -print >> cscope.files

	echo "Generate cscope.out"
	cscope -bkq -P $PWD -i cscope.files
}

ctags_func()
{
	echo "Generate tags"
	touch tags
	ctagcmd="ctags -R --c-kinds=+p --c++-kinds=+p --fields=+iaS --extra=+q -a tags"
	########
	if [ -n "$except_dir" ];then
		find -regex '\./\('$except_dir'\)' -prune -o -type f -regex '.+\.\(c\|cc\|cpp\|h\|hpp\|tops\)' -exec $ctagcmd {} +
	else
		find -type f -regex '.+\.\(c\|cc\|cpp\|h\|hpp\|tops\)' -exec $ctagcmd {} +
	fi
	#find arch/arm/ -regex ".+\(mach\|plat\)-vc.+" -type f -regex '.+\.\(c\|h\)' -exec ctags -R --c-kinds=+p --fields=+iaS --extra=+q {} +
	#find arch/arm/ -regex '.+\(mach\|plat\)-.+' -prune -o -type f -regex '.+\.\(c\|h\)' -exec ctags -R --c-kinds=+p --fields=+iaS --extra=+q -a tags {} +

	#find -regex '\./\(arch\|Documentation\|scripts\)' -prune -o -type f -regex '.+\.\(c\|h\)' -exec ctags -R --c-kinds=+p --fields=+iaS --extra=+q -a tags {} +
	#find -path "./arch*" -prune -o -path "./Documentation*" -prune -o -type f -regex '.+\.\(c\|h\)' -exec ctags -R --c-kinds=+p --fields=+iaS --extra=+q -a tags {} +

	##############################################################################################
	#ctags -R --langmap=c:+.h --c++-kinds=+p --c-kinds=+p --fields=+iaS --extra=+q
	#在对C++文件进行补全时，OmniCppComplete插件需要在标签文件中包含C++的额外信息，因此上面的
	#ctags命令不同于以前我们所使用的，它专门为C++语言生成一些额外的信息，上述选项的含义如下：
	#--c++-kinds=+p : 为C++文件增加函数原型的标签
	#--fields=+iaS   : 在标签文件中加入继承信息(i)、类成员的访问控制信息(a)、以及函数的指纹(S)
	#--extra=+q      : 为标签增加类修饰符。注意，如果没有此选项，将不能对类成员补全
}

add_cscope_func()
{
	echo "Add extra info into cscope.files"
#	find -regex '.+\('${add_dir}'\).*' -type f -regex '.+\.\(c\|cc\|cpp\|h\|S\)' -print >> cscope.files

	newlines=`find ${add_dir} -type f -regex '.+\.\(c\|cc\|cpp\|h\|S\|hpp\|tops\)' -print`

	touch cscope.files
	for line in $newlines
	do
		line='./'$line
		if [ `grep -c $line cscope.files` -eq '0' ]; then
			echo "no found!" $line
			echo $line >> cscope.files
		else
			echo "found!" $line
		fi
	done

	echo "Generate cscope.out"
	cscope -bkq -P $PWD -i cscope.files
}

add_ctags_func()
{
	touch tags
	ctagcmd="ctags -R --c-kinds=+p --c++-kinds=+p --fields=+iaS --extra=+q -a tags"
	########
	find -regex '.+\('${add_dir}'\).*' -type f -regex '.+\.\(c\|cc\|cpp\|h\|S\|hpp\|tops\)'  -exec $ctagcmd {} +
	#find arch/arm/ -regex ".+\(mach\|plat\)-vc.+" -type f -regex '.+\.\(c\|h\)' -exec ctags -R --c-kinds=+p --fields=+iaS --extra=+q {} +
	#find arch/arm/ -regex '.+\(mach\|plat\)-.+' -prune -o -type f -regex '.+\.\(c\|h\)' -exec ctags -R --c-kinds=+p --fields=+iaS --extra=+q -a tags {} +

	#find -regex '\./\(arch\|Documentation\|scripts\)' -prune -o -type f -regex '.+\.\(c\|h\)' -exec ctags -R --c-kinds=+p --fields=+iaS --extra=+q -a tags {} +
	#find -path "./arch*" -prune -o -path "./Documentation*" -prune -o -type f -regex '.+\.\(c\|h\)' -exec ctags -R --c-kinds=+p --fields=+iaS --extra=+q -a tags {} +

	##############################################################################################
	#ctags -R --langmap=c:+.h --c++-kinds=+p --c-kinds=+p --fields=+iaS --extra=+q
	#在对C++文件进行补全时，OmniCppComplete插件需要在标签文件中包含C++的额外信息，因此上面的
	#ctags命令不同于以前我们所使用的，它专门为C++语言生成一些额外的信息，上述选项的含义如下：
	#--c++-kinds=+p : 为C++文件增加函数原型的标签
	#--fields=+iaS   : 在标签文件中加入继承信息(i)、类成员的访问控制信息(a)、以及函数的指纹(S)
	#--extra=+q      : 为标签增加类修饰符。注意，如果没有此选项，将不能对类成员补全
}

##### linux-kernel special process #####
kcscope_func()
{
	echo "Generate cscope.files"
	find arch/arm/ -regex ".+\(mach\|plat\)-vc.+" -type f -regex '.+\.\(c\|cc\|cpp\|h\|S\)' -print > cscope.files
	find arch/arm/ -regex '.+\(mach\|plat\)-.+' -prune -o -type f -regex '.+\.\(c\|cc\|cpp\|h\|S\)' -print >> cscope.files
	find -regex '\./\(arch\|usr\|Documentation\|scripts\)' -prune -o -type f -regex '.+\.\(c\|cc\|cpp\|h\|S\)' -print >> cscope.files

	echo "Generate cscope.out"
	cscope -bkq -P $PWD -i cscope.files
}

kctags_func()
{
	echo "Generate tags"
	touch tags
	ctagcmd="ctags -R --c-kinds=+p --fields=+iaS --extra=+q -a tags"
	########
	echo "process arch/arm directory"
	find arch/arm/ -regex ".+\(mach\|plat\)-vc.+" -type f -regex '.+\.\(c\|cc\|cpp\|h\)' -exec $ctagcmd {} +
	find arch/arm/ -regex '.+\(mach\|plat\)-.+' -prune -o -type f -regex '.+\.\(c\|cc\|cpp\|h\)' -exec $ctagcmd {} +

	echo "process other directories"
	find -regex '\./\(arch\|usr\|Documentation\|scripts\)' -prune -o -type f -regex '.+\.\(c\|h\)' -exec $ctagcmd {} +
}

##### uboot special process #####
ucscope_func()
{
	echo "Generate cscope.files"
	echo "process arch/arm/cpu directory"
	find arch/arm/cpu/arm926ejs -regex ".+vc0.+" -type f -regex '.+\.\(c\|h\|S\)' -print >> cscope.files
	echo "process arch/arm/include/asm directory"
	find arch/arm/include/asm  -regex ".+arch-vc.+" -type f -regex '.+\.\(c\|h\|S\)' -print >> cscope.files
	find arch/arm/include/asm  -regex ".+arch-.+" -prune -o -type f -regex '.+\.\(c\|h\|S\)' -print >> cscope.files
	echo "process arch/arm/lib directory"
	find arch/arm/lib -type f -regex '.+\.\(c\|h\|S\)' -print >> cscope.files
	echo "process include/configs directory"
	find include/configs  -regex ".*vc.+" -type f -regex '.+\.h' -print >> cscope.files
	echo "process other directory"
	find -regex '\./\(arch\|Documentation\|scripts\|include/configs\)' -prune -o -type f -regex '.+\.\(c\|h\|S\)' -print >> cscope.files

	echo "Generate cscope.out"
	cscope -bkq -P $PWD -i cscope.files
}
uctags_func()
{
	echo "Generate tags"
	touch tags
	ctagcmd="ctags -R --c-kinds=+p --fields=+iaS --extra=+q -a tags"
	########
	echo "process arch/arm/cpu directory"
	find arch/arm/cpu/arm926ejs -regex ".+vc0.+" -type f -regex '.+\.\(c\|h\|S\)' -exec $ctagcmd {} +
	echo "process arch/arm/include/asm directory"
	find arch/arm/include/asm  -regex ".+arch-vc.+" -type f -regex '.+\.\(c\|h\|S\)' -exec $ctagcmd {} +
	find arch/arm/include/asm  -regex ".+arch-.+" -prune -o -type f -regex '.+\.\(c\|h\|S\)' -exec $ctagcmd {} +
	echo "process arch/arm/lib directory"
	find arch/arm/lib -type f -regex '.+\.\(c\|h\|S\)' -exec $ctagcmd {} +
	echo "process include/configs directory"
	find include/configs  -regex ".*vc.+" -type f -regex '.+\.h' -exec $ctagcmd {} +

	echo "process other directories"
	find -regex '\./\(arch\|Documentation\|scripts\|include/configs\)' -prune -o -type f -regex '.+\.\(c\|h\)' -exec $ctagcmd {} +

}

AddNormal()
{
	echo "$0:"
	echo "cscope prcocess ..."
	add_cscope_func
	echo "cscope process OK!"
	echo "ctags prcocess ..."
	add_ctags_func
	echo "ctags process OK!"
}

Normal()
{
	clean
	echo "$0:"
	echo "cscope prcocess ..."
	cscope_func
	echo "cscope process OK!"
	echo "ctags prcocess ..."
	ctags_func
	echo "ctags process OK!"
}
Kernel()
{
	clean
	echo "$0: Kernel special process"
	echo "cscope prcocess ..."
	kcscope_func
	echo "cscope process OK!"
	echo "ctags prcocess ..."
	kctags_func
	echo "ctags process OK!"
}
Uboot()
{
	clean
	echo "$0: Uboot special process"
	echo "cscope prcocess ..."
	ucscope_func
	echo "cscope process OK!"
	echo "ctags prcocess ..."
	uctags_func
	echo "ctags process OK!"
}
######################
function csync_main()
{
if [ $# -eq 0 ]; then
	time Normal
else
	case $1 in
	clean)
		time clean
		rm -vf .lconfig
		;;
	kernel|kernel/)
		time Kernel
		;;
	uboot|u-boot)
		time Uboot 
		;;
	config)
		shift 1
		if [ $# -ne 0 ];then
			echo "$*" > .lconfig
		else
			help_flag=1
		fi
		;;
	-e)
		shift 1
		while [ -n "$1" ]; do
			if [ -n "$except_dir" ];then
				except_dir=$except_dir"\|"
			fi
			except_dir=$except_dir"$1"
			echo except_dir: [$except_dir]
			shift 1
		done
		time Normal
		;;
	-a)
		shift 1
		add_dir="$1"
		time AddNormal
		;;
	*)
		help_flag=1
		;;
	esac
fi
}
####################################################################
if [ $# -eq 0 ];then
	if [ -e .lconfig ];then
		param=`cat .lconfig`
	fi
	csync_main $param
else
	csync_main $@ 
fi
if [  $help_flag -eq 1 ]; then
	cmd=`echo "$0" | sed -n 's#\.*/.*/##p'`
	echo "$cmd to do normal process"
	echo "\"$cmd config xxx\" to save default param to \".lconfig\" file used as on \"$cmd\" form"
	echo "\"$cmd -e xxx yyy\" to do normal process with except \"xxx\" and \"yyy\" directory"
	echo "\"$cmd kernel|kernel/\" to do kernel special process"
	echo "\"$cmd uboot|u-boot\" to do uboot special process"
fi
exit 0

