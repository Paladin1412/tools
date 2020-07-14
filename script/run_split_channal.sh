
if [ $# -ne 1 ]; then
    echo "Usage: $0 2channals_wav_lst"
    exit
fi

wav_lst=$1

#cat ${wav_lst} | while read wav;
#do
#    base_name=`echo $wav | awk -F ".wav" '{print $1}'`
#    echo $base_name
#    # get channal 1 wav
#    sox ${wav} -t raw -e signed-integer -b 16 ${base_name}_c1.pcm remix 1
#    # get channal 2 wav
#    sox ${wav} -t raw -e signed-integer -b 16 ${base_name}_c2.pcm remix 2
#
#done

tmp=`head -n1 ${wav_lst}`
dir_name=`dirname ${tmp}`
echo $dir_name
#exit
find ${dir_name} -type f -name "*_c1.pcm" > ${dir_name}_c1.lst
./run2.sh ${dir_name}_c1.lst ${dir_name}_c1

find ${dir_name} -type f -name "*_c2.pcm" > ${dir_name}_c2.lst
./run2.sh ${dir_name}_c2.lst ${dir_name}_c2
