#!/bin/bash
if [ $# -ne 1 ];then
	echo "usage:./$0 in_file!!!"
	exit -1
fi
input_wer=$1
#grep -v -E 'CHN_WER|ENG_WER|CHARACTOR_ACU|UTTERANCE_ACU' $1|sed 's# \[SUB:.*$##g'|sed '/^test set.*$/{:p1;$!N;/\n[\[WER].*/s/\n/\t/;tp1;P;D}'
#grep -v -E 'CHN_WER|ENG_WER|CHARACTOR_ACU|UTTERANCE_ACU'  $1 |sed 's# \[SUB:.*$##g'|sed '/^test set.*$/{:p1;$!N;/\n[\[WER].*/s/\n/\t/;tp1;P;D}'|sed  '/^test_model.*$/{:p1;$!N;/\ntest.*/s/\n/\t/;tp1;P;D}'|sed 's#test_model:.*/#test_model:#g'|sed 's#test set: ##g'|sed 's#\t\[WER# \[WER#g'|sed '/======/d' >${input_wer}.fm


#grep -v -E 'CHN_WER|ENG_WER|CHARACTOR_ACU'  $1 |sed 's# \[SUB:.*$##g'|sed '/^test set.*$/{:p1;$!N;/\n[\[WER].*/s/\n/\t/;tp1;P;D}' |sed 's#test set: ##g'|sed 's#\t\[WER# \[WER#g'|sed '/======/d'|sed '/^.*\%]$/{:p1;$!N;/\nUTTERANCE_ACU.*/s/\n/\t/;tp1;P;D}'|sed 's#[0-9]\%.*UTTERANCE_ACU.*%$#%]#g'|sed 's# inf.*UTTERANCE_ACU##g'|sed 's#%$#%]#'|sed '/model$/{:p1;$!N;/\ntest.*/s/\n/\t/;tp1;P;D}'|sed '/]$/{:p1;$!N;/\nime_2019_07.*/s/\n/\t/;tp1;P;D}'|sed '/]$/{:p1;$!N;/\ntest_noises.*/s/\n/\t/;tp1;P;D}' |sed 's#/home.*/##' |sed 's#\.yq01-.*\.model##' |sed 's#test_model:##' >${input_wer}.fm
grep -v -E 'CHN_WER|ENG_WER|CHARACTOR_ACU'  $1 |sed 's# \[SUB:.*$##g'|sed '/^test set.*$/{:p1;$!N;/\n[\[WER].*/s/\n/\t/;tp1;P;D}' |sed 's#test set: ##g'|sed 's#\t\[WER# \[WER#g'|sed '/======/d'|sed '/^.*\%]$/{:p1;$!N;/\nUTTERANCE_ACU.*/s/\n/\t/;tp1;P;D}'|sed 's#[0-9]\%.*UTTERANCE_ACU.*%$#%]#g'|sed 's# inf.*UTTERANCE_ACU##g'|sed 's#%$#%]#'|sed '/model$/{:p1;$!N;/\ntest.*/s/\n/\t/;tp1;P;D}'|sed '/]$/{:p1;$!N;/\nime_2019_07.*/s/\n/\t/;tp1;P;D}'|sed '/]$/{:p1;$!N;/\ntest_noises.*/s/\n/\t/;tp1;P;D}' |sed 's#/home.*/##' |awk -F'-2020' '{print $2"___"$0}' |sort  -n |awk -F'___' '{print $2}'  >${input_wer}.fm

#python draw_pic.py ${input_wer}.fm
