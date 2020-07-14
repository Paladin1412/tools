#!/bin/bash

filename=20190704_706_bz.tar.gz
pid=$1
basepath=/home/disk4/mark_data/Multi_intrctn
url=http://10.199.99.25:8080/Multi_intrctn
download_url=http://njjs-speech-arch00.njjs:8187
server=audio@njjs-speech-arch00.njjs
date=`date  +%Y%m%d`
yes_day=`date  "+%Y%m%d" -d " -2 days"`
#mkdir -p $basepath/$pid/$date









mkdir -p $basepath/$pid/$yes_day
cd ${basepath}/$pid/$yes_day
#res=`ls $download_url/${yes_day}_${pid}_bz.tar.gz`
#wget -c $download_url/${yes_day}_${pid}_bz.tar.gz >/dev/null 2>&1
rsync -arP $server:/home/audio/users/masai02/share/${yes_day}_${pid}_bz.tar.gz .
if [ $? -eq 0 ];then 
tar -xf ${yes_day}_${pid}_bz.tar.gz
find   ./${yes_day}_contact_dir_${pid} -name "*.wav"|sed "s#./${yes_day}_contact_dir_${pid}/##" |sed 's#_8k.wav##g'>basename.txt
#rm -f ${yes_day}_${pid}_bz.tar.gz
cd  ${yes_day}_contact_dir_${pid}
cat ../basename.txt |while read line;do bash /home/tools/decode_textgrid.sh ${line}.grid;done
export LD_LIBRARY_PATH=/mnt/QA_disk2/tools/mysql-5.6/lib:/mnt/QA_disk2/python2.7/lib:$LD_LIBRARY_PATH

cat ../basename.txt|while read line;do /home/tools/python2.7 /home/tools/trans_from_grid_to_json.py  ${line}.grid.decode  ${line}.grid.js.txt ;done >/dev/null 2>&1 
cat *grid.js.txt|sed 's#.grid.decode\t#_8k.wav\t#g'  > ../${yes_day}_${pid}.txt
cd ..
cut -f1 ${yes_day}_${pid}.txt >${yes_day}_${pid}.key
#sed -i "s#^#http://10.199.99.25:8080/Multi_intrctn/${pid}/$yes_day/${yes_day}_contact_dir_${pid}/#g" ${yes_day}_${pid}.txt
sed -i "s#^#http://10.199.99.25:8080/disk4/mark_data/Multi_intrctn/${pid}/$yes_day/${yes_day}_contact_dir_${pid}/#g" ${yes_day}_${pid}.txt
#paste  ${yes_day}_${pid}.key ${yes_day}_${pid}.txt |sed '1iaudio_file_name\taudio_url\tsourceData' >Multi_intrctn_${yes_day}_${pid}.L
#paste  ${yes_day}_${pid}.key ${yes_day}_${pid}.txt |awk '{gsub("}","",$NF);if ($NF<=300) {print $1"\t"$2"\t"$3} }'|sed '1iaudio_file_name\taudio_url\tsourceData' >Multi_intrctn_${yes_day}_${pid}.L

paste  ${yes_day}_${pid}.key ${yes_day}_${pid}.txt |awk 'BEGIN{FS="\t";OFS="\t"}{tmp=$3;len=split(tmp,arr," ");gsub("}","",arr[len]);if (arr[len]<=300) {print $0} }'|sed '1iaudio_file_name\taudio_url\tsourceData' |head -n 7500 >Multi_intrctn_${yes_day}_${pid}.L

#head -n 3001 Multi_intrctn_${yes_day}_${pid}.L > Multi_intrctn_${yes_day}_${pid}_3000.L
scp ${basepath}/$pid/${yes_day}/Multi_intrctn_${yes_day}_${pid}.L  speech@yq01-vs-m42-q1-audio92.yq01.baidu.com:/home//disk2/speech/samba/zhangyanchao/label_L/

else 
    echo "${yes_day}_${pid}_bz.tar.gz not found!!!"
fi
