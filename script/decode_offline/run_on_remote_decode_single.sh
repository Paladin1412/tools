#!/bin/bash

function parse_options(){
    ARGS=`getopt -o h --long "decode_bin:,wer_bin:,conf_dir:,data_dir:,lm_dir:,fsn_dir:,
            testdata_lst:,testdata_dir:,model_file:,remove_mood_blank:,decode_output_dir:,
            help" -n "sh $0 -h" -- "$@"`
    eval set -- "${ARGS}"

    while true
    do
        case "$1" in
            -h|--help)
                usage $0
                exit 0 ;;
            --decode_bin)
                decode_bin=$2; shift 2 ;;
            --wer_bin)
                wer_bin=$2; shift 2 ;;
            --conf_dir)
                conf_dir=$2; shift 2 ;;
            --data_dir)
                data_dir=$2; shift 2 ;;
            --lm_dir)
                lm_dir=$2; shift 2 ;;
            --fsn_dir)
                fsn_dir=$2; shift 2 ;;
            --testdata_lst)
                testdata_lst=$2; shift 2 ;;
            --testdata_dir)
                testdata_dir=$2; shift 2 ;;
            --remove_mood_blank)
                remove_mood_blank=$2; shift 2 ;;
            --model_file)
                model_file=$2; shift 2 ;;
            --decode_output_dir)
                decode_output_dir=$2; shift 2 ;;
            --)
                break ;;
            *)
                echo "Not Support Option: $1"
                shift 
        esac
    done
}


function usage(){
    echo "Usage msg"
}


function decode_model(){
    model=$1
    model_name=`basename $model`
    model_name_tag=$model_name

    # 修改decode_api.conf中声学模型
    sed -i 's/\(^\s*NN_MODEL_NAME\s*:\).*$/\1 '"$model_name_tag"'/' conf/decoder_api.conf

    # 将声学模型连接到data目录下
    [ -f data/$model_name_tag ] && rm data/$model_name_tag
    ln -s $model data/$model_name_tag

    # 临时解码结果文件
    tmp_testdata_out=tmp_merge_testdata.out
    [ -f $tmp_testdata_out ] && rm $tmp_testdata_out -f

    # 解码
    $decode_bin conf/asr_cmd.conf $tmp_testdata_lst $tmp_testdata_out

    if [ ! -f $tmp_testdata_out ]; then
        echo "Decode output file not exit."
        return
    fi
    mv $tmp_testdata_out ${decode_output_dir}/`basename ${testdata_lst}`.out

    # 备份日志文件
    host_name=`hostname`
    log_bak_path=${decode_output_dir}/decode_log
    [ -d $log_bak_path ] || mkdir -p $log_bak_path
    mv ./log ${log_bak_path}/${model_name_tag}.${host_name} 

    # 清除临时文件
    rm data/$model_name_tag
    rm $tmp_testdata_out
}


# 判断本地是否有对应的解码data
function check_local_decode_data(){
    # data文件名，以"."分割为产品线和版本量部分
    data_dir_name=`basename $data_dir`
    # 获取产品线名称
    data_product_name=${data_dir_name%%.*}
    # 版本号
    data_version_name=${data_dir_name#*.}
    # 本地data地址
    data_local_dir=""
    
    data_size=`du -s $data_dir | cut -f1`
    ((free_disk_size=$data_size+10000000))
    echo "Source data size: $data_size"

    # 遍历本地三个存储目录来查找是否有本地缓存目录
    for dir in ${DECODE_DATA_ROOT[@]}; do
        if [ -d ${dir}/${data_product_name}/${data_version_name}/data ]; then
            data_dir=${dir}/${data_product_name}/${data_version_name}/data
            return
        fi
    done

    # 如果本地无对应产品目录，则查找一个新的路径
    #if [ -z $data_local_dir ]; then
:<<\###
    if [[ -d /home/ssd0/speech && -z $data_local_dir ]]; then
        free_disk=`df -l | grep /home/ssd0 | awk -F"[ ]+" '{print $4}'`
        free_disk=${free_disk:=0}
        # 空闲空间需大于10G
        if [ $free_disk -ge $free_disk_size ]; then
            data_local_dir=/home/ssd0/speech/decode_data/${data_product_name}/${data_version_name}
        fi
    fi
    if [[ -d /home/ssd1/speech && -z $data_local_dir ]]; then
        free_disk=`df -l | grep /home/ssd1 | awk -F"[ ]+" '{print $4}'`
        free_disk=${free_disk:=0}
        if [ $free_disk -ge $free_disk_size ]; then
            data_local_dir=/home/ssd1/speech/decode_data/${data_product_name}/${data_version_name}
        fi
    fi
    if [[ -d /home/ssd2/speech && -z $data_local_dir ]]; then
        free_disk=`df -l | grep /home/ssd2 | awk -F"[ ]+" '{print $4}'`
        free_disk=${free_disk:=0}
        if [ $free_disk -ge $free_disk_size ]; then
            data_local_dir=/home/ssd2/speech/decode_data/${data_product_name}/${data_version_name}
        fi
    fi
###
    if [[ -d /home/speech && -z $data_local_dir ]]; then
        free_disk=`df -l | grep /home$ | awk -F"[ ]+" '{print $4}'`
        free_disk=${free_disk:=0}
        if [ $free_disk -ge $free_disk_size ]; then
            data_local_dir=/home/speech/decode_data/${data_product_name}/${data_version_name}
        fi
    fi
    #fi

    # 如果未查找到可用路径，说明空间不够，报错
    if [ -z $data_local_dir ]; then
        echo "`hostname` disk size not enough. please check!"
        exit 1
    fi

    # 判断对应的版本是否存在，如果不存在，则删除历史版本，拷贝新版本
    [ ! -d $data_local_dir ] && mkdir -p $data_local_dir/
    rm -rf $data_local_dir/*
    # 从解码集群查找是否有对应资源
    source_data=`search_from_group "data" $data_dir_name`
    echo "source_data: $source_data"
    # 集群没有则从原始磁盘拷贝，否则从集群其他机器拷贝
    if [ -z $source_data ]; then
        cp -r $data_dir $data_local_dir/tmp
    else
        rsync -a $source_data/ $data_local_dir/tmp
    fi
    tmp_data_size=`du -s $data_local_dir/tmp | cut -f1`
    echo "Copied data tmp size: $tmp_data_size"
    ((tmp_data_size=$tmp_data_size+10000))
    if [ $tmp_data_size -lt $data_size ]; then
        echo "Copy data failed, please check!"
        exit 1
    fi
    mv $data_local_dir/tmp $data_local_dir/data
    cur_hostname=`hostname`
    grep "data $data_dir_name ${cur_hostname}:$data_local_dir/data" $DECODE_SOURCE_LST
    if [ $? -eq 1 ]; then
        echo "data $data_dir_name ${cur_hostname}:$data_local_dir/data" >> $DECODE_SOURCE_LST
    fi
    data_dir=$data_local_dir/data 
    
}

# 判断本地是否有对应的解码data
function check_local_decode_lm(){
    # data文件名，以"."分割为产品线和版本量部分
    lm_dir_name=`basename $lm_dir`
    # 获取产品线名称
    lm_product_name=${lm_dir_name%%.*}
    # 版本号
    lm_version_name=${lm_dir_name#*.}
    # 本地data地址
    lm_local_dir=""

    lm_size=`du -s $lm_dir | cut -f1`
    ((lm_need_disk_size=$lm_size+10000000))
    echo "Source LM size: $lm_size"

    # 遍历本地三个存储目录来查找是否有本地缓存目录
    for dir in ${DECODE_DATA_ROOT[@]}; do
        if [ -d ${dir}/${lm_product_name}/${lm_version_name}/lm ]; then
            lm_dir=${dir}/${lm_product_name}/${lm_version_name}/lm
            return
        fi
    done
    
    # 如果本地无对应产品目录，则查找一个新的路径
    #if [ -z $lm_local_dir ]; then
:<<\###
    if [[ -d /home/ssd0/speech && -z $lm_local_dir ]]; then
        free_disk=`df -l | grep /home/ssd0 | awk -F"[ ]+" '{print $4}'`
        free_disk=${free_disk:=0}
        # 空闲空间需大于100G
        if [ $free_disk -ge $lm_need_disk_size ]; then
            lm_local_dir=/home/ssd0/speech/decode_data/${lm_product_name}/${lm_version_name}
        fi
    fi
    if [[ -d /home/ssd1/speech && -z $lm_local_dir ]]; then
        free_disk=`df -l | grep /home/ssd1 | awk -F"[ ]+" '{print $4}'`
        free_disk=${free_disk:=0}
        if [ $free_disk -ge $lm_need_disk_size ]; then
            lm_local_dir=/home/ssd1/speech/decode_data/${lm_product_name}/${lm_version_name}
        fi
    fi
    if [[ -d /home/ssd2/speech && -z $lm_local_dir ]]; then
        free_disk=`df -l | grep /home/ssd2 | awk -F"[ ]+" '{print $4}'`
        free_disk=${free_disk:=0}
        if [ $free_disk -ge $lm_need_disk_size ]; then
            lm_local_dir=/home/ssd2/speech/decode_data/${lm_product_name}/${lm_version_name}
        fi
    fi
###
    if [[ -d /home/speech && -z $lm_local_dir ]]; then
        free_disk=`df -l | grep /home$ | awk -F"[ ]+" '{print $4}'`
        free_disk=${free_disk:=0}
        if [ $free_disk -ge $lm_need_disk_size ]; then
            lm_local_dir=/home/speech/decode_data/${lm_product_name}/${lm_version_name}
        fi
    fi
    #fi

    # 如果未查找到可用路径，说明空间不够，报错
    if [ -z $lm_local_dir ]; then
        echo "`hostname` disk size not enough. please check!"
        exit 1
    fi

    # 判断对应的版本是否存在，如果不存在，则删除历史版本，拷贝新版本
    [ ! -d $lm_local_dir ] && mkdir -p $lm_local_dir
    rm -rf $lm_local_dir/*
    # 从解码集群查找是否有对应资源
    source_data=`search_from_group "lm" $lm_dir_name`
    echo "source_data: $source_data"
    # 集群没有则从原始磁盘拷贝，否则从集群其他机器拷贝
    if [ -z $source_data ]; then
        cp -r $lm_dir $lm_local_dir/tmp
    else
        rsync -a $source_data/ $lm_local_dir/tmp
    fi
    tmp_size=`du -s $lm_local_dir/tmp | cut -f1`
    echo "Copied tmp LM size: $tmp_size"
    ((tmp_size=$tmp_size+10000))
    if [ $tmp_size -lt $lm_size ]; then
        echo "Copy lm failed, please check !"
        exit 1
    fi
    mv $lm_local_dir/tmp $lm_local_dir/lm

    cur_hostname=`hostname`
    grep "lm $lm_dir_name ${cur_hostname}:$lm_local_dir/lm" $DECODE_SOURCE_LST
    if [ $? -eq 1 ]; then
        echo "lm $lm_dir_name ${cur_hostname}:$lm_local_dir/lm" >> $DECODE_SOURCE_LST
    fi
    lm_dir=$lm_local_dir/lm
    
}


function search_from_group(){
    source_lst=`grep "^$1 $2 " $DECODE_SOURCE_LST | shuf | awk '{print $3}'`
    source_data=""
    for val in $source_lst
    do
        host_name=${val%%:*}
        path=${val#*:}
        a=`ssh $host_name "if [ -d $path ]; then echo 1; else echo 0; fi"`
        if [ -z $a ] || [ $a -eq 0 ]; then
            sed -i "\#^$1 $2 $val#d" $DECODE_SOURCE_LST
        else
            source_data=$val
            break
        fi
    done
    echo $source_data
}


function main(){
    echo `hostname`
    check_local_decode_data

    decode_workspace=/home/speech/decode_workspace
    [ -d $decode_workspace ] || mkdir -p $decode_workspace
    cd $decode_workspace

    # 解码conf
    [ -L conf ] && rm conf
    ln -s $conf_dir conf

    # 解码data
    [ -L data ] && rm data
    ln -s $data_dir data

    # 如果单独配置lm，则单独处理，否则任务data中包含lm
    if [ -n "$lm_dir" ]; then
        check_local_decode_lm
        # 解码lm
        [ -L data/lm ] && rm data/lm
        ln -s $lm_dir data/lm
    fi
    
    # 地域信息
    [ -L fsn ] && rm fsn
    if [ -n "$fsn_dir" ]; then
        ln -s $fsn_dir fsn
    fi

    # 测试数据目录
    if [ ! -z $testdata_dir ]; then
        testdata_dir_name=`basename $testdata_dir`
        #[ -L $testdata_dir_name ] && rm -f $testdata_dir_name
        if [ -L $testdata_dir_name ]; then
            rm -f $testdata_dir_name
        fi
        ln -s $testdata_dir $testdata_dir_name
    fi

    tmp_testdata_lst=tmp_merge_testdata.lst
    [ -f $tmp_testdata_lst ] && rm $tmp_testdata_lst
    if [ ! -e $testdata_lst ]; then 
        echo "testdata can not be accessed, job will be sleeping."
        sleep 1000000000000000000
    fi
    sort -u $testdata_lst > ${tmp_testdata_lst}

    # 逐个解码模型
    echo "Start decode model: $model_file"
    #sleep 10s
    decode_model $model_file
    echo "End decode model: $model_file"
    echo $one_model >> ${decode_output_dir}/finished.lst

    # 清理临时文件
    [ -L $testdata_dir_name ] && rm $testdata_dir_name
    [ -f $tmp_testdata_lst ] && rm $tmp_testdata_lst

}

# 去掉语气词需要
#source /tools/tts_libs/set_python3.4.rc

readonly DECODE_SOURCE_LST=/mnt/QA_disk1/mrmt/decode_group_data/decode_source_data_lst
DECODE_DATA_ROOT=(/home/speech/decode_data /home/ssd0/speech/decode_data /home/ssd1/speech/decode_data /home/ssd2/speech/decode_data)
parse_options $@

main 

