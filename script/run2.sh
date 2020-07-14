if [ $# -ne 2 ]; then
  echo "usage: bash $0 wav.lst save_dir"
  echo "wav.lst: sample-rate:16000, channals:1, format:wav"
  exit 1;
fi

wav_lst=$1
save_dir=$2
mkdir -p $save_dir

for wav in `cat $wav_lst`;
do
    wav_name=`basename ${wav}`
    cp $wav $save_dir
    new_path=$save_dir/$wav_name

    # Do vad-split
    ./VADClient_callcenter vad.cfg 1 $new_path > ${new_path}.log 2>&1
    #./VADClient_callcenter vad.cfg 1 $new_path > ${new_path}.log 2>&1

    #./VADClient_V3 vad.cfg2 1 $new_path > ${new_path}.log 2>&1
    #./VADClient_fbank80 ./vad.cfg 1 $new_path > ${new_path}.log 2>&1
    rm $new_path

    # Rename each segment into .pcm
    #mkdir -p $wav_name
    ls -rt ${new_path}*dnnvad* | while read item
    do 
        idx=`echo $item | awk -F "dnnvad" '{print $NF}'`
        mv $item ${new_path}_${idx}.pcm
    done

    #break
done
