#!/bin/bash
echo "generate systags file"
rm -f ~/.vim/arm_systags
sudo ctags -R -f ~/.vim/arm_systags  \
	--c++-kinds=+p --c-kinds=+p --fields=+iaS --extra=+q \
	/usr/local/arm/4.4.3/arm-none-linux-gnueabi/sys-root/usr/include

#在对C++文件进行补全时，OmniCppComplete插件需要在标签文件中包含C++的额外信息，因此上面的
#ctags命令不同于以前我们所使用的，它专门为C++语言生成一些额外的信息，上述选项的含义如下：
#--c++-kinds=+p : 为C++文件增加函数原型的标签
#--fields=+iaS   : 在标签文件中加入继承信息(i)、类成员的访问控制信息(a)、以及函数的指纹(S)
#--extra=+q      : 为标签增加类修饰符。注意，如果没有此选项，将不能对类成员补全
