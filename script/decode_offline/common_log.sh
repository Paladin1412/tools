#!/bin/bash

function log(){
    [ $# -eq 0 ] && return

    log_level=`echo $1 | tr 'a-z' 'A-Z'`
    cur_time=`date "+%Y-%m-%d %H:%M:%S"`
    case "$log_level" in
        "INFO")
            shift 1
            echo "${cur_time} [INFO] $*" >> ${LOG_FILE}
            ;;
        "WARNING")
            shift 1
            echo "${cur_time} [WARNING] $*" >> ${LOG_FILE}
            ;; 
        "ERROR")
            shift 1
            echo "${cur_time} [ERROR] $*" >> ${LOG_FILE}
            ;;
        *)
            echo "${cur_time} [INFO] $*" >> ${LOG_FILE}
            ;;
    esac
}

function log_info(){
    cur_time=`date "+%Y-%m-%d %H:%M:%S"`
    echo "${cur_time} [INFO] $*" >> ${LOG_FILE}
}

function log_warning(){
    cur_time=`date "+%Y-%m-%d %H:%M:%S"`
    echo "${cur_time} [WARNING] $*" >> ${LOG_FILE}
}

function log_error(){
    cur_time=`date "+%Y-%m-%d %H:%M:%S"`
    echo "${cur_time} [ERROR] $*" >> ${LOG_FILE}
}

function log_init(){
    if [ $# -eq 0 ]; then
        echo "log will be write in stand output"
    else
        echo "log will be write in file: $1"
        log_dir=`dirname $1`
        [ -d ${log_dir} ] || mkdir -p ${log_dir} 
    
        LOG_FILE="$1"
        >${LOG_FILE}
        exec &>>${LOG_FILE}
    fi
}


