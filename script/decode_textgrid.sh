#!/bin/bash


awk -F"=" '{
    key=$1
    gsub("\\[.*\\]:", "", key)
    gsub(" ", "", key)

    if(key=="name"){
        file_name=$2
        gsub(".*/", "", file_name)
        gsub("\"", "", file_name)
    }else if(key=="intervals"){
        idx=$1; gsub("[^0-9]", "", idx)
        getline; xmin=$2; gsub(" ", "", xmin)
        getline; xmax=$2; gsub(" ", "", xmax)
        getline; text=$2; gsub("[ \"]", "", text)
        print idx"\t"xmin"\t"xmax"\t"text
    }
}' ${1} > ${1}.decode
