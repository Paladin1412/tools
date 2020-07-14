#!/bin/bash

LANG=zh_CN.UTF8


function init(){
    xdyx_decode_out=decode_xdyx.out
    xdzj_decode_out=decode_xdzj.out

    [ -e $xdyx_decode_out ] || { echo "xdyx_decode_out not found. exit"; exit 1; }
    iconv -f gbk -t utf-8 $xdyx_decode_out -c > ${xdyx_decode_out}.utf8
    iconv -f gbk -t utf-8 $xdzj_decode_out -c > ${xdzj_decode_out}.utf8

    cp /mnt/HDDFS4/speech_data/zhangfangping/${data_date}/${data_part_id}/sn_ori_${data_date}_${data_part_id} decode_online.out
    online_decode_out=decode_online.out
    [ -e $online_decode_out ] || { echo "online_decode_out not found. exit"; exit 1; }
}


function filter_by_endword(){
    # 根据小度音箱识别结果和线上识别结果进行过滤，生成过滤后的列表
    awk -F"\t" '
        ARGIND==1{
            gsub(".*/16000_", "", $1)
            gsub(".bv$", "", $1)
            xdzj[$1] = $2
        }
        ARGIND==2{
            if(length($2)>0){
                gsub(".*/16000_", "", $1)
                gsub(".bv$", "", $1)
                xdyx[$1]=$2
            }
        }
        ARGIND==3{
            if(length($4)==0){
            }else if($4==xdyx[$3]){
                print $2"\t"$3"\t"$4";"xdyx[$3]";"xdzj[$3]
            }else if(length($4)<2){
            }else {
                if(substr($4,length($4)-2)==substr(xdyx[$3],length(xdyx[$3])-2)){
                    print $2"\t"$3"\t"$4";"xdyx[$3]";"xdzj[$3]
                }
            }
        }
    ' ${xdzj_decode_out}.utf8 ${xdyx_decode_out}.utf8 $online_decode_out > decode_xdyx.out.filter
    
    # 筛选出过滤后的pcm音频列表
    awk -F"\t" 'ARGIND==1{val[$3]=1}ARGIND==2{gsub(".*/16000_", "", $1); if($1 in val){ print $0".pcm"}}' decode_xdyx.out.filter merge_total.lst > merge_total_pcm_filter.lst
}

function main(){
    workspace=/mnt/NFS1/zhangyanchao/src_mul_channel//multi_channel_${data_date}_${data_part_id}
    [ -d $workspace ] || { echo "workspace dir not exist, exit"; exit 1; }
    cd $workspace

    init

    filter_by_endword

}

# 数据日期
data_date=$1 
# 数据批次
data_part_id=$2

main

