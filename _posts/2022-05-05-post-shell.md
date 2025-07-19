---
title: post-shell
date: 2022-05-04 10:43:27
---

<!-- more -->

```shell
#!/bin/bash

if [ $# == 0 ]
then
echo 'Add failed'
exit
fi

_date=`date '+%Y-%m-%d'`
_time=`date '+%Y-%m-%d %H:%M:%S'`
_file="./_posts/${_date}-$1.md"
echo $_time

printf "%s%s%s\r\n" '-' '-' '-' > $_file

printf "title: $1\r\n" >> $_file
printf "date: ${_time}\r\n" >> $_file
printf "categories:\r\n" >> $_file

printf "%s%s%s\r\n" '-' '-' '-' >> $_file

echo $_file
echo 'Added successfully'
```
