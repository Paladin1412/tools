ip=$(ip a|tail -n 1|sed 's#^.*inet #http://#'|sed 's#/24.*$#:8080/#');find `pwd`/ -name "*.wav"|sed "s#/home/disk7/mark_data/#$ip#" 
