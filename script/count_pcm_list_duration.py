#!/usr/bin/usr python
#coding:utf8

import sys
import os

total_size = 0
with open(sys.argv[1]) as f:
    for line in f:
        if line.strip() == "":
            continue
        line_info = line.strip().split()
#        assert len(line_info) == 2, "format error %s"%line
        total_size += os.path.getsize(line_info[0])-44
	#total_size=total_size - 44
#        print str(os.path.getsize(line_info[0]) / 16000.0 / 2. / 60.)+'\t'+line.strip()
	#print total_size,str(os.path.getsize(line_info[0]) / 16000.0 / 2. / 60.)+'\t'+line.strip()
	print line.strip() + '\t' + str((os.path.getsize(line_info[0]) -44) / 8000.0 / 2. )
#print "total duration for %s is:"%sys.argv[0]
#print round(total_size / 16000.0 / 2. / 3600.,5)
#print total_size
#print  total_size / 8000.0 / 2. / 60.
