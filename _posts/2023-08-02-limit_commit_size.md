---
title: 限制提交文件大小
date: 2023-08-02 11:22:14
tags:
---

<!-- more -->

```shell
#!/bin/sh
hard_limit=$(git config hooks.filesizehardlimit)
soft_limit=$(git config hooks.filesizesoftlimit)
: ${hard_limit:=100000000} # 100M
: ${soft_limit:=50000000} # 50M

list_new_or_modified_files()
{
    git diff --staged --name-status|sed -e '/^D/ d; /^D/! s/.\s\+//'
}

unmunge()
{
 local result="${1#\"}"
    result="${result%\"}"
    env echo -e "$result"
}

check_file_size()
{
    n=0 
 while read -r munged_filename
 do
        f="$(unmunge "$munged_filename")"
        h=$(git ls-files -s "$f"|cut -d' ' -f 2)
        s=$(git cat-file -s "$h")
 if [ "$s" -gt $hard_limit ]
 then
            env echo -E 1>&2 "ERROR: hard size limit ($hard_limit) exceeded: $munged_filename ($s)"
            n=$((n+1))
 elif [ "$s" -gt $soft_limit ]
 then
            env echo -E 1>&2 "WARNING: soft size limit ($soft_limit) exceeded: $munged_filename ($s)"
 fi
 done

    [ $n -eq 0 ] 
}

list_new_or_modified_files | check_file_size
```

