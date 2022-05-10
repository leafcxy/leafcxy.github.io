#!/bin/bash

# 验证标题
if [ $# == 0 ]
then
echo 'Add failed'
exit
fi

# 考虑时区的问题
_date=`date '+%Y-%m-%d' -d "-1days"`
_time=`date '+%Y-%m-%d %H:%M:%S' -d "-1days"`
_file="./_posts/${_date}-$1.md"
echo $_time

printf "%s%s%s\r\n" '-' '-' '-' > $_file

printf "title: $1\r\n" >> $_file
printf "date: ${_time}\r\n" >> $_file
printf "categories:\r\n" >> $_file
printf "tags:\r\n" >> $_file

printf "%s%s%s\r\n" '-' '-' '-' >> $_file

echo $_file
echo 'Added successfully'
