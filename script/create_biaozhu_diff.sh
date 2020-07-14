#!/bin/bash

# 提包列表，3列
tibao_lst=$1

# 工作路径，默认当前路径
workspace=$2
[ -z $workspace ] && workspace="./"
cd ${workspace}

# 全量种子文件
total_seed=./dumi-ertong-total-seed
cur_dir=$(cd `dirname $0`; pwd)

# 批次结果保存目录
[ -e batch_result ] || mkdir batch_result

# 获取本次tibao对应的batch
awk -F"[ :]+" '{print $3}' $tibao_lst | sort -u > batch_id.lst 
sed -i "/^ *$/d" batch_id.lst
# 删除该batch之前tibao保存的种子，主要是怕种子重复保存，所以需保证列表中每个batch的tibao尽可能全
cat batch_id.lst | xargs -I{} rm batch_result/{}.total_seed

# 逐个处理提包，解码拉取的标注结果，查找种子并保存。已解码过的不会重新解码，如果需要请手动删除之前解码结果
cat $tibao_lst | while read line; do
    tibao_ret=`echo $line | awk -F"[ :]+" '{print $1}'`
    batch_id=`echo $line | awk -F"[ :]+" '{print $3}'`
    if [ ! -e ${tibao_ret}.decode ]; then
        python ${cur_dir}/decode_zhongce_ret.py -i $tibao_ret -o ${tibao_ret}.decode -t decode 
    else
        echo "${tibao_ret}.decode exist. skip"
    fi
    awk -F"[\t]" 'ARGIND==1{seed[$1]=1}ARGIND==2{if($1 in seed){print $0}}' $total_seed ${tibao_ret}.decode > ${tibao_ret}.decode.seed
    sed -i "s/ //g" ${tibao_ret}.decode.seed
    cat ${tibao_ret}.decode.seed >> batch_result/${batch_id}.total_seed
done

# 计算每个tibao种子的same和diff部分
cat batch_id.lst | while read line; do
    awk -F"\t" '
        {out[$1]=out[$1]"\t"$5}
        END{for(i in out){print i"\t"out[i]}}
    ' batch_result/${line}.total_seed > batch_result/${line}.merge_seed
    
    awk -F"[\t]+" -v batch_id=$line '{
        if(NF<4){next}
        
        is_same = 1
        for(i=2;i<=NF; i++){
            if($2!=$i){
                is_same = 0
                break
            }
        }
        if(is_same==1){
            print $0 > "batch_result/"batch_id".seed.same"
        }else{
            print $0 > "batch_result/"batch_id".seed.diff"
        }
    }' batch_result/${line}.merge_seed
done

