#!/bin/bash/env python
# -*- coding:utf-8 -*-

import json
import codecs
import uuid
import sys


def main():
    input_grid = sys.argv[1]
    output_json = sys.argv[2]

    in_f = codecs.open(input_grid, "r", "utf-8")
    grid_lines = in_f.readlines()
    in_f.close()    

    records_list = []
    for line in grid_lines:
        #print line.encode('utf-8')
        line_arr = line.strip().split('\t')
        if len(line_arr) != 4: 
            continue
        record = {}
        uuid_val = "".join(str(uuid.uuid4()).split('-'))
        record["uuid"] = uuid_val
        record["num"] = int(line_arr[0])
        time_loc = {}
        time_loc["begin"] = round(float(line_arr[1]), 3)
        time_loc["end"] = round(float(line_arr[2]), 3)
        record["time"] = time_loc
        record["content"] = line_arr[3]
        record["role"] = ""
        record["time1"] = time_loc

        audio_duration = line_arr[2]

        records_list.append(record)

    ret = {}
    ret["audioDuration"] = float(audio_duration)
    ret["audioFileName"] = ""
    ret["records"] = records_list

    with codecs.open(output_json, "w", "utf-8") as out_f:
        out_f.write(input_grid + "\t" + json.dumps(ret).decode('unicode-escape') + "\n")


if __name__ == "__main__":
    main()
