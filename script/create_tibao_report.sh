#!/bin/bash

# 提包列表，3列
tibao_lst=$1

# 工作路径，默认当前路径
workspace=$2
cur_dir=$(cd `dirname $0`; pwd)

[ -z $workspace ] && workspace="./"
cd ${workspace}

# 全量种子文件
total_seed_check_ret=./dumi_ertong_5w.check_ret

>${tibao_lst}.report
# 逐个处理提包，解码拉取的标注结果，查找种子并保存。已解码过的不会重新解码，如果需要请手动删除之前解码结果
cat $tibao_lst | while read line; do
    tibao_file=`echo $line | awk -F"[ :]+" '{print $1}'`
    
    sed -i "s/ //g" ${tibao_file}.decode.seed
    sed -i "s/ //g" ${total_seed_check_ret}
    >${tibao_file}.decode.seed.right
    >${tibao_file}.decode.seed.right_check
    >${tibao_file}.decode.seed.error
    >${tibao_file}.decode.seed.error_check
    awk -F"\t" -v pre=${tibao_file}.decode.seed '
        ARGIND==1{gsub(" ", "", $2); check[$1]=$2}
        ARGIND==2{
            if($1 in check && $3=="包含有效语音"){
                gsub(" ", "", $5)
                if($5==check[$1]){
                    print $0 > pre".right"
                    print $1"\t"$2"\t"$3"\t"$4"\t"check[$1]"\t"$6"\t"$7 > pre".right_check"
                }else{
                    print $0 > pre".error"
                    print $1"\t"$2"\t"$3"\t"$4"\t"check[$1]"\t"$6"\t"$7 > pre".error_check"
                }
            }
        }' ${total_seed_check_ret} ${tibao_file}.decode.seed

    python ${cur_dir}/decode_zhongce_ret.py -i ${tibao_file}.decode.seed.right -o ${tibao_file}.decode.seed.right.encode -t encode 
    python ${cur_dir}/decode_zhongce_ret.py -i ${tibao_file}.decode.seed.right_check -o ${tibao_file}.decode.seed.right_check.encode -t encode 
    python ${cur_dir}/decode_zhongce_ret.py -i ${tibao_file}.decode.seed.error -o ${tibao_file}.decode.seed.error.encode -t encode 
    python ${cur_dir}/decode_zhongce_ret.py -i ${tibao_file}.decode.seed.error_check -o ${tibao_file}.decode.seed.error_check.encode -t encode 

    speech_id_idx=`head -n1 ${tibao_file} | awk -F"\t" '{for(i=1; i<=NF; i++){if($i=="url"){print i; break;}}}'`
    ye_id_idx=`head -n1 ${tibao_file} | awk -F"\t" '{for(i=1; i<=NF; i++){if($i=="页id"){print i; break;}}}'`

    awk -v idx=$speech_id_idx -v ye_idx=$ye_id_idx '
        BEGIN{FS="\t"; OFS="\t"}
        ARGIND==1{biaozhu[$1"_"$2]=$3}
        ARGIND==2{check[$1"_"$2]=$3}
        ARGIND==3{
            id = $idx
            gsub("^.*/", "", id)
            gsub("^16000_", "", id)
            gsub(".wav$", "", id)
            id=id"_"$ye_idx
            if(id in biaozhu){
                print $1,$2,$3,$4,$5,$6,$7,$8,biaozhu[id],check[id]
            }
    }' ${tibao_file}.decode.seed.right.encode ${tibao_file}.decode.seed.right_check.encode ${tibao_file} > ${tibao_file}.seed.right

    awk -v idx=$speech_id_idx -v ye_idx=$ye_id_idx '
        BEGIN{FS="\t"; OFS="\t"}
        ARGIND==1{biaozhu[$1"_"$2]=$3}
        ARGIND==2{check[$1"_"$2]=$3}
        ARGIND==3{
            id = $idx
            gsub("^.*/", "", id)
            gsub("^16000_", "", id)
            gsub(".wav$", "", id)
            id=id"_"$ye_idx
            if(id in biaozhu){
                print $1,$2,$3,$4,$5,$6,$7,$8,biaozhu[id],check[id]
            }
    }' ${tibao_file}.decode.seed.error.encode ${tibao_file}.decode.seed.error_check.encode ${tibao_file} > ${tibao_file}.seed.error

    right_count=`wc -l ${tibao_file}.seed.right | cut -d\  -f1`
    right_count_half=$(($right_count/2))
    error_count=`wc -l ${tibao_file}.seed.error | cut -d\  -f1`
    error_count_half=$(($error_count/2))

    if [ $right_count -lt 5 ] && [ $error_count -lt 5 ]; then
        continue
    fi

    head -n $right_count_half ${tibao_file}.seed.right > ${tibao_file}.seed.right.head
    tail -n $right_count_half ${tibao_file}.seed.right > ${tibao_file}.seed.right.tail

    head -n $error_count_half ${tibao_file}.seed.error > ${tibao_file}.seed.error.head 
    tail -n $error_count_half ${tibao_file}.seed.error > ${tibao_file}.seed.error.tail
    new_title=`head -n 1 ${tibao_file} | awk 'BEGIN{FS="\t"; OFS="\t"}{print $1,$2,$3,$4,$5,$6,$7,$8,"最终答案","验收答案"}'`

    sed -i -e "1i${new_title}" ${tibao_file}.seed.right ${tibao_file}.seed.error ${tibao_file}.seed.right.head ${tibao_file}.seed.right.tail  ${tibao_file}.seed.error.head ${tibao_file}.seed.error.tail
    #echo -e "${tibao_file}\t${right_count}\t${error_count}\t$((${right_count}*1000/(${right_count}+${error_count})))" >> ${tibao_lst}.report
    total_num=$((right_count+ error_count))
    echo  -e "${tibao_file}\t${right_count}\t${error_count}\t"`awk 'BEGIN{printf "%.2f%%\n",('$right_count'/'$total_num')*100}'` >> ${tibao_lst}.tmp
done
    sort -n -k 4 ${tibao_lst}.tmp >${tibao_lst}.report
    rm -f ${tibao_lst}.tmp

