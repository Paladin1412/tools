#!/bin/bash

source_file_lst=$1
output_dir=$2
task_name=$3
thread_num=$4
#process_py=/mnt/NFS2/zhangyanchao/tools/script/split_multi_channel.py

workspace=/home/speech/workspace_multi_channel
[ -d $workspace ] || mkdir -p $workspace
cd $workspace

cp /mnt/NFS2/zhangyanchao/tools/script/all2pcm ./
cp /mnt/NFS2/zhangyanchao/tools/script/pcm2bv ./
cp /mnt/NFS2/zhangyanchao/tools/script/split_multi_channel.py ./
cp /mnt/NFS2/zhangyanchao/tools/script/cut_pcm_by_len.py ./
rsync -a /mnt/NFS2/zhangyanchao/tools/script/MicArrayProcessTool ./

[ -e /tmp/tmp_fd ] || mkfifo /tmp/tmp_fd
exec 3<>/tmp/tmp_fd
rm /tmp/tmp_fd
for((i=0;i<${thread_num};i++));do
    echo >&3
done

[ -d $output_dir ] || mkdir -p $output_dir
touch $output_dir/tag

audio_out_dir=$workspace/$task_name
[ -d $audio_out_dir ] && rm -rf $audio_out_dir
mkdir -p $audio_out_dir

time1=`date +%s`
echo "start timestamp: $time1"
while read line; do
    read -u3
    {
        key=`basename $line`
    	size=$(ls -l $line | awk '{print $5}')
        [ $size -eq 648 ] && { echo >&3; continue; }
        mkdir -p $audio_out_dir/$key
        python split_multi_channel.py $line $audio_out_dir/$key >> ${task_name}.log 2>&1
        {
            echo "$audio_out_dir/$key/" > $audio_out_dir/${key}.lst
            ./MicArrayProcessTool/ArrayProcessing 3 1 ./MicArrayProcessTool/config_xiaodu_linux_3_1.lst $audio_out_dir/${key}.lst > /dev/null 2>&1 
            python ./cut_pcm_by_len.py $audio_out_dir/${key}/opt_outsig_asr_bv.pcm 160 $audio_out_dir/${key}/opt_outsig_asr_bv_cut.pcm > /dev/null 2>&1
            ./pcm2bv  $audio_out_dir/${key}/opt_outsig_asr_bv_cut.pcm  $audio_out_dir/${key}/opt_outsig_asr_bv.bv
            mv $audio_out_dir/$key/opt_outsig_asr_bv.pcm $output_dir/${key}.pcm
            mv $audio_out_dir/$key/opt_outsig_asr_bv.bv $output_dir/${key}.bv
            rm -rf $audio_out_dir/${key}*
            #./pcm2bv $output_dir/$key/opt_outsig_asr_bv.pcm $output_dir/$key/opt_outsig_asr_bv.bv 
            echo "$output_dir/$key" >> $output_dir/../total_${task_name}.lst
        }
        echo >&3
    }&
done < $source_file_lst

time2=`date +%s`
echo "end timestamp: $time2"
echo $(($time2-$time1))

sleep 10s

exec 3>&-
exec 3<&-
