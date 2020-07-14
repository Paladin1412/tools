#!/bin/bash

part_size=19000
seed_size=1000
part_count=5

start_batch_id=1
end_batch_id=20

source_file=./20190312_00.txt
task_name=multi_channel_20190312_00
recog_ret_count=3

cur_dir=$(cd `dirname $0`; pwd)
workspace=${cur_dir}/../workspace/${task_name}
wer=${cur_dir}/../wer_#


function audio_rename(){
    cp ${ori_audio_lst} ./audio_ori.lst
    cat ./audio_ori.lst | xargs -I {} -P 100 sh ${cur_dir}/rename_one_file.sh {} $target_audio_dir
    awk -F"[/\t._ ]" '{print $(NF-1)"\t"$1}' audio_md5.lst > speechid_md5_match
    #awk -F"\t" 'ARGIND==1{val[$1]=$2}ARGIND==2{if($1 in val){print val[$1]"\t"$2"\t"$3"\t"$4}}' speechid_md5_match source_file_ori > source_file   
    #awk -F"[ ]+" -v target_dir=$target_audio_dir '{print "cp "$2" "target_dir"/"$1".wav"}' audio_md5.lst > copy_audio_cmd
}


function generate_wer_rlt(){
    split -l 300000 -d $source_file ${source_file}_
    for file in `ls ${source_file}_* | grep 'source_file_[0-9]\{2\}$'`; do
        awk -F"\t" -v recog_len=$recog_ret_count -v pref=$file '{
            len=split($2, recog_arr, ";") 
            if(len==recog_len){
                for(i=1; i<=len; i++){
                    print $1"\t"recog_arr[i]>pref"."i
                }
            }
        }' $file

        for i in `seq 1 $recog_ret_count`; do
            iconv -f utf-8 -t gbk ${file}.${i} > ${file}.${i}.gbk
            sed -i 's/://g' ${file}.${i}.gbk
            if [ $i -eq 1 ]; then
                continue
            fi
            {
            $wer ${file}.1.gbk ${file}.${i}.gbk ${file}.${i}.rlt 
            cat ${file}.${i}.rlt >> ${source_file}.${i}.rlt
            }&
        done
        wait
    done
}

function align_multi_recog_ret(){

    # 以第一个结果为标准答案，其他结果依次跟标准答案对齐
    for i in `seq 2 $recog_ret_count`; do
        iconv -f gbk -t utf-8 ${source_file}.${i}.rlt > ${source_file}.${i}.rlt.utf8
        awk -F":" '{
            if($1=="file"){
                speech_id=$2;getline;getline;getline;getline;
                ans_txt=$2;getline; 
                dec_txt=$2;
                print speech_id"\t"ans_txt"\t"dec_txt;
            }
        }' ${source_file}.${i}.rlt.utf8 > ${source_file}.${i}.rlt.utf8.format
        sed -i 's/#/ # /g' ${source_file}.${i}.rlt.utf8.format
        sed -i 's/ \+/ /g' ${source_file}.${i}.rlt.utf8.format

        # 将每次对齐后的标准答案合并到一起
        if [ $i -eq 2 ]; then
            awk -F"\t" '{print $1"\t"$2}' ${source_file}.${i}.rlt.utf8.format > ${source_file}.ans.rlt.utf8.format
        else
            awk -F"\t" 'ARGIND==1{val[$1]=$0}ARGIND==2{print val[$1]"\t"$2}' ${source_file}.ans.rlt.utf8.format ${source_file}.${i}.rlt.utf8.format > ${source_file}.ans.rlt.utf8.format.tmp
            mv ${source_file}.ans.rlt.utf8.format.tmp ${source_file}.ans.rlt.utf8.format
        fi
    done

    sed -i 's/#/ # /g' ${source_file}.ans.rlt.utf8.format
    sed -i 's/ \+/ /g' ${source_file}.ans.rlt.utf8.format

    # 将所有对齐结果中的标准答案进行合并,格式化
    awk -F"\t" '{
        merge_str=$2
        for(i=3;i<=NF;i++){
            len1=split(merge_str, ans_arr1, " ")
            len2=split($i, ans_arr2, " ")
            idx_1=1
            idx_2=1
            merge_str=""
            while(1==1){
                if(idx_1>len1&&idx_2>len2){
                    break
                }else if(idx_1>len1&&idx_2<=len2){
                    merge_str=merge_str" "ans_arr2[idx_2]
                    idx_2++
                    continue
                }else if(idx_1<=len1&&idx_2>len2){
                    merge_str=merge_str" "ans_arr1[idx_1]
                    idx_1++
                    continue
                }
                if(ans_arr1[idx_1]=="#"&&ans_arr2[idx_2]!="#"){
                    merge_str=merge_str" "ans_arr1[idx_1]
                    idx_1++
                }else if(ans_arr1[idx_1]!="#"&&ans_arr2[idx_2]=="#"){
                    merge_str=merge_str" "ans_arr2[idx_2]
                    idx_2++
                }else{
                    merge_str=merge_str" "ans_arr1[idx_1]
                    idx_1++
                    idx_2++
                }
            }
        }
        print $0"\t"merge_str
    }'  ${source_file}.ans.rlt.utf8.format > ${source_file}.ans.rlt.utf8.format.align

    # 将其他结果对齐到格式化后的标注答案
    for i in `seq 2 ${recog_ret_count}`; do
        awk -F"\t" '
        ARGIND==1{ans_format[$1]=$NF}
        ARGIND==2{
            ans_format_len=split(ans_format[$1], ans_format_arr, " ")
            ans_len=split($2, ans_arr, " ")
            dec_len=split($3, dec_arr, " ")
            idx_1=1
            idx_2=1
            dec_format_str=""
            for(i=1;i<=ans_format_len;i++){
                if(ans_format_arr[idx_1]==ans_arr[idx_2]){
                    dec_format_str=dec_format_str" "dec_arr[idx_2]
                    idx_1++
                    idx_2++
                    continue
                }else if(ans_format_arr[idx_1]=="#"){
                    dec_format_str=dec_format_str" #"
                    idx_1++
                }
            }
            print $0"\t"dec_format_str
        }' ${source_file}.ans.rlt.utf8.format.align ${source_file}.${i}.rlt.utf8.format > ${source_file}.${i}.rlt.utf8.format_final
    done

    # 将对齐结果合并到一个文件
    awk -F"\t" '
    ARGIND==1{ans[$1]=$NF}
    ARGIND==2{print $1"\t"ans[$1]";"$NF
    }' ${source_file}.ans.rlt.utf8.format.align ${source_file}.2.rlt.utf8.format_final > split_ret_align_final

    for i in `seq 3 ${recog_ret_count}`; do
        awk -F"\t" '
        ARGIND==1{ans[$1]=$0}
        ARGIND==2{
            print ans[$1]";"$NF
        }' split_ret_align_final ${source_file}.${i}.rlt.utf8.format_final > split_ret_align_final_tmp
        mv split_ret_align_final_tmp split_ret_align_final
    done
}

#将多个结果不同部分添加标签
function add_html_tag(){
    awk -F"[\t]" '{
        ret_count=split($2, ret_arr, ";")
        for(i=1;i<=ret_count;i++){
            text_len=split(ret_arr[i], tmp_arr, " ")
            for(j=1;j<=text_len;j++){
                ret_text_arr[i][j]=tmp_arr[j]
            }
        }
        had_start_tag=0
        ret_with_tag_arr_idx=1
        for(m=1;m<=text_len;m++){
            tmp_str=""
            is_same=1
            first_word=ret_text_arr[1][m]
            for(n=2;n<=ret_count;n++){
                if(first_word!=ret_text_arr[n][m]){
                    is_same=0
                    break
                }
            }
            if(is_same==1){
                if(had_start_tag==0){
                    for(k=1;k<=ret_count;k++){
                        ret_with_tag_arr[k][ret_with_tag_arr_idx]=ret_text_arr[k][m]
                    }
                    ret_with_tag_arr_idx++
                }else if(had_start_tag==1){
                    for(k=1;k<=ret_count;k++){
                        ret_with_tag_arr[k][ret_with_tag_arr_idx]="</span>"
                        ret_with_tag_arr[k][ret_with_tag_arr_idx+1]=ret_text_arr[k][m]
                    }  
                    ret_with_tag_arr_idx++
                    ret_with_tag_arr_idx++
                    had_start_tag=0
                }
            }else{
                if(had_start_tag==0){
                    for(k=1;k<=ret_count;k++){
                        ret_with_tag_arr[k][ret_with_tag_arr_idx]="<span style=\"color:#ff0000\">"
                        ret_with_tag_arr[k][ret_with_tag_arr_idx+1]=ret_text_arr[k][m]
                    }
                    ret_with_tag_arr_idx++
                    ret_with_tag_arr_idx++
                    had_start_tag=1
                }else if(had_start_tag==1){
                    for(k=1;k<=ret_count;k++){
                        ret_with_tag_arr[k][ret_with_tag_arr_idx]=ret_text_arr[k][m]
                    }
                    ret_with_tag_arr_idx++
                }
            }
        }
        if(had_start_tag==1){
            for(k=1;k<=ret_count;k++){
                ret_with_tag_arr[k][ret_with_tag_arr_idx]="</span>"
            }
            ret_with_tag_arr_idx++
        }
        out_str=""
        for(y=1;y<=ret_count;y++){
            for(z=1;z<ret_with_tag_arr_idx;z++){
                out_str=out_str""ret_with_tag_arr[y][z]
            }
            out_str=out_str"<br>;"
        }
        print $1"\t"out_str
    }' split_ret_align_final > split_ret_align_final.add_tag
    sed -i 's/^ \+//' split_ret_align_final.add_tag
}

function shuf_result_text(){
    awk -F"\t" 'BEGIN{srand()}
    ARGIND==1{
        ori_len=split($2, ret_arr, ";")
        delete ret_arr[ori_len]
        ori_len=length(ret_arr)

        len=ori_len
        tmp_str=""
        while(len > 0){
            idx=int(rand() * 100 % ori_len) + 1
            if(idx in ret_arr){
                tmp_str = tmp_str""ret_arr[idx]
                delete ret_arr[idx]
                len = length(ret_arr)
            }
        }
        val[$1]=tmp_str
    }
    ARGIND==2{
        if($1 in val){
            tmp = val[$1]
            gsub(/<br>/, ";", tmp)
            gsub(/<[^>]*>/, "", tmp)
            print $1"\t"tmp"\t"val[$1]"\t"$3"\t"$4}
    }' split_ret_align_final.add_tag ${source_file} > split_ret_align_final.add_tag.context
    shuf -o split_ret_align_final.shuf split_ret_align_final.add_tag.context 
    cp split_ret_align_final.shuf split_ret_align_final.shuf.bak
}


function split_to_batch(){
    #total_row=`wc -l split_ret_align_final.shuf | cut -d\  -f1`
    split_source_file="split_ret_align_final.shuf"
    total_row=`wc -l $split_source_file | cut -d\  -f1`
    batch_id=$start_batch_id
    part_id=1
    while [ $total_row -ge $part_size ] && [ $batch_id -le $end_batch_id ]; do
        if [ $part_id -gt $part_count ]; then
            #part_id=1
            echo xxx
        fi
        if [ $part_id -eq 1 ]; then
            mkdir batch_${batch_id}
            head -n $seed_size $split_source_file > ./batch_${batch_id}/part_seed
            sed -i "1,${seed_size}d" $split_source_file
        fi
        head -n $part_size $split_source_file > ./batch_${batch_id}/part_${part_id}
        cat ./batch_${batch_id}/part_seed ./batch_${batch_id}/part_${part_id} | shuf > ./batch_${batch_id}/part_${part_id}_done
        sed -i "1,${part_size}d" $split_source_file
        if [ $part_id -eq $part_count ]; then
            cat ./batch_${batch_id}/part_*_done | shuf > ./batch_${batch_id}/merge_output
            part_id=1
            ((batch_id=$batch_id+1))
        else
            ((part_id=$part_id+1))
        fi
        total_row=`wc -l $split_source_file | cut -d\  -f1`
    done
}

function main(){
#    [ -e $workspace ] && rm -rf $workspace
    mkdir -p $workspace
    cp $source_file $workspace/source_file
    cd $workspace
    source_file=source_file

####    audio_rename
    generate_wer_rlt
    align_multi_recog_ret

    add_html_tag
    shuf_result_text
    split_to_batch
}

main $*

