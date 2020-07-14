
ff=$1
end=`./VADClient_callcenter vad.cfg 2  $ff |grep -B 1 '<'|grep time|sed 's#^.*time:##g'|sed 's# ms##' |awk '{printf "%.2f\n",$num/1000}'`;./VADClient_callcenter vad.cfg 2 $ff |grep '<' |grep -v - | awk '{print $3"\t"$4}'|sed 's#<##'|sed 's#>##'|sed 's#\t#\n#'g|sed  '1i0\.00' >${ff}.grid;echo $end >>${ff}.grid
python  decode_textgridV2.sh ${ff}.grid  >${ff}.grid.decode
#if [ -s  ${ff}.grid  ];then
#python trans_from_grid_to_jsonV2.py ${ff}.grid.decode ${ff}.grid.decode.js.txt
#fi
