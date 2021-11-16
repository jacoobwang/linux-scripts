#!/bin/bash
# 定义清理路径
core_path=(/export/Data)

# 清理阀值
size_limit=40


# 记录清理操作时间
time1=$(date "+%Y%m%d%H%M%S")


# 清理core文件函数
function clear_corefiles()
{
         if [ -d $core_path ];then

            cd $core_path
            # 清理掉大小为0的core文件
            find  -name "core*" -size 0 |xargs /bin/rm -v |tee /tmp/core_delete_$time1.log
            # 保留一个大小不为0且日期为最新的core文件，其余都删除
            number=$(ls core*|wc -l)
            if [ $number -gt 1 ];then
                newcore=$(ls -rt core*|tail -n 1)
                mkdir -p  backup
                mv $newcore backup
                ls core*|xargs /bin/rm -v |tee /tmp/core_delete_$time1.log
            fi
            # 清理2天前的core文件
            find . -name "core*" -ctime +2 |xargs /bin/rm -v |tee /tmp/core_delete_$time1.log
            find /tmp -name "core_delete*" -ctime +5 |xargs /bin/rm
         fi
}


size_current=$(df -h /export|grep "/export"|awk '{print int($(NF-1))}')

if [ $size_current -ge $size_limit ];then
   clear_corefiles
fi