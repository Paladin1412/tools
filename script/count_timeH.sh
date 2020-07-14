#!/bin/bash
sed "s#^.*audioDuration#audioDuration#"  $1|sed 's#}##' |awk '{print $2}'|sed '1d'|awk '{x+=$0}END{printf "%.2f\n",x/3600}'
