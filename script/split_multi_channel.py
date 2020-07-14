#!/bin/bash/env python
# -*- coding:utf-8 -*-

import sys
import struct
import os
import commands
import time

file = sys.argv[1]
out_dir = sys.argv[2]

with open(file, 'r') as in_f:
    ss = in_f.read()
    flen = len(ss)

audio_type = ss[:4]
loc = ss[4:20]
with open(out_dir + os.path.sep + "location", 'w') as loc_f:
    loc_f.write(loc)

audio_type = ss[20:24]
alen = flen - 24;

pkg_num = alen / ((8 + 644) * 4)
total_num = (pkg_num * 4)

# 去掉最后一包（即砍掉尾部160ms）
#total_num -= 1

index = 24
channel = {}
for i in range(total_num):
    header = ss[index:index+8]
    cid, len = struct.unpack('<ii', header)
    index += 8
    bv_name = out_dir + os.path.sep + str(i+1) + '.bv'
    pcm_name = out_dir + os.path.sep + str(i+1) + '.pcm'
    with open(bv_name, 'w') as bv_f:
        bv_f.write(ss[index:index+644])
    err, out = commands.getstatusoutput('./all2pcm ' + bv_name + ' ' + pcm_name)
    if cid in channel:
        channel[cid] = channel[cid] + " " + pcm_name
    else:
        channel[cid] = pcm_name
    index += 644

for k, v in channel.items():
    cmds= 'cat ' + v + ' > ' + out_dir + os.path.sep + 'channel_' + str(k) + '.pcm'
    err, out = commands.getstatusoutput(cmds)

cmds=os.system('cd %s  ; rm -f [0-9]*.pcm [0-9]*.bv '%(format(out_dir)))

