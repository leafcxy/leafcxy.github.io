#!/bin/bash

if [ $# == 0 ]
then
echo 'Add failed'
exit
fi

_date=`date '+%Y-%m-%d'`
_time=`date '+%Y-%m-%d %H:%M:%S'`
_file="./_posts/${_date}-$1.md"
# echo $_date
echo $_time

echo '---' > $_file

echo "title: $1" >> $_file
echo "date: ${_time}" >> $_file
echo "categories:" >> $_file
# echo "photos:" >> $_file
# echo "tags:" >> $_file
# echo "description:" >> $_file

echo '---' >> $_file

echo $_file
echo 'Added successfully'
