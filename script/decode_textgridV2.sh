import sys
import os 
import string

scp=open(sys.argv[1],"r")
lines=scp.readlines()
for ff in range(len(lines)):
    if ff+1 >= len(lines): 
	break
    index=ff +1
    print  str(index) + "\t"  + lines[ff].strip()+ "\t" + lines[ff+1].strip() + "\tNULL"


