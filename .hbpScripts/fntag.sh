#!/bin/bash

help_flag=0
###############################
clean()
{
	rm -vf ./filenametags
	rm -vf ./.vim_mru_files
	rm -vf ./tempfile1
}
###############################
fntag_func()
{
	# generate tag file for lookupfile plugin
	echo "Searching source code"
	#find ./ -type f -regex '.*\.\(c\|h\)' \( \( -regex './arch/arm.+' -printf "%f\t%p\t1\n" \) -o -path "./arch*" -prune -o -printf "%f\t%p\t1\n" \) | sort -f >> filenametags
	if [ -n "$except_dir" ];then
		find -regex '\./\('$except_dir'\)' -prune -o -type f -regex '.+\.\(c\|cc\|cpp\|h\|S\)' -printf "%f\t%p\t1\n" >> tempfile1
	else
		find -type f -regex '.+\.\(c\|cc\|cpp\|h\|S\)' -printf "%f\t%p\t1\n" >> tempfile1
	fi

	#find -path "./arch*" -prune -o -type f -regex '.+\.\(c\|h\)' -printf "%f\t%p\t1\n" >> tempfile1

	echo "Generate filenametags"
	echo -e "!_TAG_FILE_SORTED\t2\t/2=foldcase/" > filenametags
	sort -f tempfile1 >> filenametags
	rm -vf tempfile1
}

add_fntag_func()
{
	# generate tag file for lookupfile plugin
	echo "Searching source code"

	find ${add_dir} -type f -regex '.+\.\(c\|cc\|cpp\|h\|S\)' -printf "%f\t%p\t1\n" >> tempfile1

	echo "Generate filenametags"
	sort -f tempfile1 >> filenametags
	rm -vf tempfile1
}


kfntag_func()
{
	echo "Searching source code"
	echo "process arch/arm directory"
	find arch/arm/ -regex ".+\(mach\|plat\)-vc.+" -type f -regex '.+\.\(c\|cc\|cpp\|h\|S\)' -printf "%f\t%p\t1\n" >> tempfile1
	find arch/arm/ -regex '.+\(mach\|plat\)-.+' -prune -o -type f -regex '.+\.\(c\|cc\|cpp\|h\|S\)' -printf "%f\t%p\t1\n" >> tempfile1

	echo "process other directories"
	find -regex '\./\(arch\|usr\|Documentation\|scripts\)' -prune -o -type f -regex '.+\.\(c\|cc\|cpp\|h\|S\)' -printf "%f\t%p\t1\n" >> tempfile1

	echo "Generate filenametags"
	echo -e "!_TAG_FILE_SORTED\t2\t/2=foldcase/" > filenametags
	sort -f tempfile1 >> filenametags
	rm -vf tempfile1
}

ufntag_func()
{
	echo "Searching source code"
	echo "process arch/arm/cpu directory"
	find arch/arm/cpu/arm926ejs -regex ".+vc0.+"  -type f -regex '.+\.\(c\|h\|S\)' -printf "%f\t%p\t1\n" >> tempfile1
	echo "process arch/arm/include/asm directory"
	find arch/arm/include/asm  -regex ".+arch-vc.+" -type f -regex '.+\.\(c\|h\|S\)' -printf "%f\t%p\t1\n" >> tempfile1
	find arch/arm/include/asm  -regex ".+arch-.+"  -prune -o -type f -regex '.+\.\(c\|h\|S\)' -printf "%f\t%p\t1\n" >> tempfile1
	echo "process arch/arm/lib directory"
	find arch/arm/lib  -type f -regex '.+\.\(c\|h\|S\)' -printf "%f\t%p\t1\n" >> tempfile1
	echo "process include/configs directory"
	find include/configs  -regex ".*vc.+" -type f -regex '.+\.h' -printf "%f\t%p\t1\n" >> tempfile1

	echo "process other directory"
	find -regex '\./\(arch\|Documentation\|scripts\|include/configs\)' -prune -o -type f -regex '.+\.\(c\|h\|S\)' -printf "%f\t%p\t1\n" >> tempfile1

	echo "Generate filenametags"
	echo -e "!_TAG_FILE_SORTED\t2\t/2=foldcase/" > filenametags
	sort -f tempfile1 >> filenametags
	rm -vf tempfile1
}

AddNormal()
{
	echo "$0:"
	echo "lookupfile prcocess ..."
	time add_fntag_func
	echo "lookupfile process OK!"
}

Normal()
{
	clean
	echo "$0:"
	echo "lookupfile prcocess ..."
	time fntag_func
	echo "lookupfile process OK!"
}
Kernel()
{
	clean
	echo "$0: Kernel special process"
	echo "lookupfile prcocess ..."
	time kfntag_func
	echo "lookupfile process OK!"
}
Uboot()
{
	clean
	echo "$0: Uboot special process"
	echo "lookupfile prcocess ..."
	time ufntag_func
	echo "lookupfile process OK!"
}
function fntag_main()
{
if [ $# -eq 0 ]; then
	time Normal
else
	case $1 in
	clean)
		time clean
		;;
	kernel|kernel/)
		time Kernel
		;;
	uboot|u-boot)
		time Uboot 
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
	fntag_main $param
else
	fntag_main $@ 
fi
if [  $help_flag -eq 1 ]; then
	cmd=`echo "$0" | sed -n 's#\.*/.*/##p'`
	echo "$cmd to do normal process"
	echo "\"$cmd -e xxx yyy\" to do normal process with except \"xxx\" and \"yyy\" directory"
	echo "\"$cmd kernel|kernel/\" to do kernel special process"
	echo "\"$cmd uboot|u-boot\" to do uboot special process"
fi
exit 0


