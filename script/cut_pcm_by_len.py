#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 19 11:35:47 2019

@author: wudan14
"""
from __future__ import print_function
import os
import sys
import re
import random


dt = 1.0 / 16000

if __name__ == '__main__':
    if len(sys.argv) < 4 or len(sys.argv) > 5:
        print("Usage : {0} input_pcm, cut_len(ms), output_pcm, [head/tail]".format(sys.argv[0]))
        exit(1)
    
    pcm_file = sys.argv[1]
    cut_len = float(sys.argv[2])
    
    head_or_tail = "tail"
    
    if len(sys.argv) == 5:
        head_or_tail = sys.argv[4]
        
    new_pcm_data = ""
    with open(pcm_file, 'rb') as f:
        data = f.read()
    
    len_ori = len(data)
    
    cut_point_number = int(cut_len / float(1000) * 2. * 16000)
    
    if head_or_tail == 'tail':
        data_new = data[0: len_ori - cut_point_number]
    elif head_or_tail == 'head':
        data_new = data[cut_point_number + 1: ]
    else:
        print("wrong head/tail arg!")
        exit(2)
        
    with open(sys.argv[3], 'wb') as f:
        f.write(data_new)        
        
    
    
