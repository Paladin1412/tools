#!/bin/bash

awk -F"\t" '
    ARGIND==1{val[$1]=$1}
    ARGIND==2{
        for(i=1; i<=10; i++)
        {
            cuid[i] = cuid[i+1]
            speech_id[i] = speech_id[i+1]
            text[i] = text[i+1]
        }
        cuid[11] = $1
        speech_id[11] = $3
        text[11] = $4

        if(speech_id[6]!="" && speech_id[6] in val){
            pre_text=""
            for(i=1; i<=5; i++){
                if(cuid[i]==cuid[6]){
                    pre_text=pre_text";"text[i]
                }
            }
            
            suf_text=""
            for(i=7; i<=11; i++){
                if(cuid[i]==cuid[6]){
                    suf_text=suf_text";"text[i]
                }
            }
            print speech_id[6]"\t"substr(pre_text, 2)"\t"substr(suf_text, 2)
        }
    }
' $1 $2
