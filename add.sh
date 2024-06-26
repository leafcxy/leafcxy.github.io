#!/bin/bash

# 验证标题
if [ $# == 0 ]
then
echo 'Add failed'
exit
fi

# 获取当前时间戳并减去8小时（28800秒）
adjusted_timestamp=$(($(date +%s) - 28800))

# 考虑时区的问题
_date=$(date -d @$adjusted_timestamp +"%Y-%m-%d")
_time=$(date -d @$adjusted_timestamp +"%Y-%m-%d %H:%M:%S")
_file="./_posts/${_date}-$1.md"
echo $_time

printf "%s%s%s\r\n" '-' '-' '-' > $_file

printf "title: $1\r\n" >> $_file
printf "date: ${_time}\r\n" >> $_file
printf "tags: [Blogs, Jekyll, default_tags]\r\n" >> $_file

printf "%s%s%s\r\n" '-' '-' '-' >> $_file

echo $_file
echo 'Added successfully'
