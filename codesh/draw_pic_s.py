#!/usr/bin/env python
################################################################################
#
# Copyright (c) 2018 Baidu.com, Inc. All Rights Reserved
#
################################################################################
#-*- coding:utf8 -*-



import sys
import os
import datetime
import xlsxwriter


data=[
	[],[],[],
	[],[],[],
	[],[],[],
	[],[],[],
	[],[],[]
]
input_base="base.fm"
input_com=sys.argv[1]
tmp_model=input_com


#Sheet1=sys.argv[2]

fd=open(input_base,'r')
fd_com=open(input_com,'r')


file_Tstamp=datetime.datetime.now().strftime('%Y%m%d%H%M%S')
workbook = xlsxwriter.Workbook(input_com + "_" + file_Tstamp + ".xlsx")
# 自定义样式，加粗
bold = workbook.add_format({'bold': 1})
	

print ("---------------------------------------")
Sheet1="input_spontaneous_10000"
worksheet_1 = workbook.add_worksheet(Sheet1)
headings = ['tmp_model_epoch_0_', 'base(%)',tmp_model]
worksheet_1.write_row('A1', headings, bold)
worksheet_1.set_column('A:A',70) 
worksheet_1.set_column('B:C',15) 
for da  in fd:
	L1=da.strip("\n").split("\t")[0]
	data[0].append(L1)
	L2=float(da.strip("\n").split("\t")[1].split(" ")[2].strip("]").strip('%'))
	data[1].append(L2)
for da_com  in fd_com:
	L1_com=da_com.strip("\n").split("\t")[0]
	#data[0].append(L1)
	L2_com=float(da_com.strip("\n").split("\t")[1].split(" ")[2].strip("]").strip('%'))
	data[2].append(L2_com)
worksheet_1.write_column('A2', data[0])
worksheet_1.write_column('B2', data[1])
worksheet_1.write_column('C2', data[2])
chart_col = workbook.add_chart({'type': 'line'})
Sheet1=str(Sheet1)
chart_col.add_series({
    'name': '=' + Sheet1 + '!$B$1',
    'categories': '=' + Sheet1 + '!$A$2:$A$25',
    'values':  '='+ Sheet1 + '!$B$2:$B$25',
    'line': {'color': 'red'},
})
chart_col.add_series({
    'name':  '=' + Sheet1 + '!$C$1',
    'categories':  '=' + Sheet1 + '!$A$2:$A$25',
    'values':   '='+Sheet1+ '!$C$2:$C$25',
    'line': {'color': 'yellow'},
})
chart_col.set_title({'name': Sheet1})
chart_col.set_x_axis({'name': 'model num(%)'})
chart_col.set_y_axis({'name':  'wer num'})
chart_col.set_y_axis({'min': 7, 'max': 9})
chart_col.set_style(1)
worksheet_1.insert_chart('A26', chart_col, {'x_offset': 50, 'y_offset': 20,'x_scale': 1,'y_scale': 1})
fd.close()
fd_com.close()
print ("---------------------------------------")
Sheet1="input_3100_2400_9000"
worksheet_2 = workbook.add_worksheet(Sheet1)

fd=open(input_base,'r')
fd_com=open(input_com,'r')
headings = ['tmp_model_epoch_0_', 'base(%)',tmp_model]
worksheet_2.write_row('A1', headings, bold)
worksheet_2.set_column('A:A',70) 
worksheet_2.set_column('B:C',15) 
for da  in fd:
	L1=da.strip("\n").split("\t")[0]
	data[3].append(L1)
	L2=float(da.strip("\n").split("\t")[2].split(" ")[2].strip("]").strip('%'))
	data[4].append(L2)
for da_com  in fd_com:
	L1_com=da_com.strip("\n").split("\t")[0]
	#data[0].append(L1)
	L2_com=float(da_com.strip("\n").split("\t")[2].split(" ")[2].strip("]").strip('%'))
	data[5].append(L2_com)
worksheet_2.write_column('A2', data[3])
worksheet_2.write_column('B2', data[4])
worksheet_2.write_column('C2', data[5])
chart_col = workbook.add_chart({'type': 'line'})
Sheet1=str(Sheet1)
chart_col.add_series({
    'name': '=' + Sheet1 + '!$B$1',
    'categories': '=' + Sheet1 + '!$A$2:$A$25',
    'values':  '='+ Sheet1 + '!$B$2:$B$25',
    'line': {'color': 'red'},
})
chart_col.add_series({
    'name':  '=' + Sheet1 + '!$C$1',
    'categories':  '=' + Sheet1 + '!$A$2:$A$25',
    'values':   '='+Sheet1+ '!$C$2:$C$25',
    'line': {'color': 'yellow'},
})
chart_col.set_title({'name': Sheet1})
chart_col.set_x_axis({'name': 'model num(%)'})
chart_col.set_y_axis({'name':  'wer num'})
chart_col.set_y_axis({'min': 3.4, 'max': 4.5})
chart_col.set_style(1)
worksheet_2.insert_chart('A26', chart_col, {'x_offset': 50, 'y_offset': 20,'x_scale': 1,'y_scale': 1})

fd.close()
fd_com.close()





print ("---------------------------------------")
Sheet1="input_7508"
fd=open(input_base,'r')
fd_com=open(input_com,'r')
worksheet_3 = workbook.add_worksheet(Sheet1)




headings = ['tmp_model_epoch_0_', 'base(%)',tmp_model]
worksheet_3.write_row('A1', headings, bold)
worksheet_3.set_column('A:A',70) 
worksheet_3.set_column('B:C',15) 
for da  in fd:
	L1=da.strip("\n").split("\t")[0]
	data[6].append(L1)
	L2=float(da.strip("\n").split("\t")[3].split(" ")[2].strip("]").strip('%'))
	data[7].append(L2)
for da_com  in fd_com:
	L1_com=da_com.strip("\n").split("\t")[0]
	#data[0].append(L1)
	L2_com=float(da_com.strip("\n").split("\t")[3].split(" ")[2].strip("]").strip('%'))
	data[8].append(L2_com)
worksheet_3.write_column('A2', data[6])
worksheet_3.write_column('B2', data[7])
worksheet_3.write_column('C2', data[8])
chart_col = workbook.add_chart({'type': 'line'})
Sheet1=str(Sheet1)
chart_col.add_series({
    'name': '=' + Sheet1 + '!$B$1',
    'categories': '=' + Sheet1 + '!$A$2:$A$25',
    'values':  '='+ Sheet1 + '!$B$2:$B$25',
    'line': {'color': 'red'},
})
chart_col.add_series({
    'name':  '=' + Sheet1 + '!$C$1',
    'categories':  '=' + Sheet1 + '!$A$2:$A$25',
    'values':   '='+Sheet1+ '!$C$2:$C$25',
    'line': {'color': 'yellow'},
})
chart_col.set_title({'name': Sheet1})
chart_col.set_x_axis({'name': 'model num(%)'})
chart_col.set_y_axis({'name':  'wer num'})
chart_col.set_y_axis({'min': 5.6, 'max': 6.4})
chart_col.set_style(1)
worksheet_3.insert_chart('A26', chart_col, {'x_offset': 50, 'y_offset': 20,'x_scale': 1,'y_scale': 1})

fd.close()
fd_com.close()



print ("---------------------------------------")
Sheet1="ime_2019_07_5167"
fd=open(input_base,'r')
fd_com=open(input_com,'r')
worksheet_4 = workbook.add_worksheet(Sheet1)
headings = ['tmp_model_epoch_0_', 'base(%)',tmp_model]
worksheet_4.write_row('A1', headings, bold)
worksheet_4.set_column('A:A',70) 
worksheet_4.set_column('B:C',15) 
for da  in fd:
	L1=da.strip("\n").split("\t")[0]
	data[9].append(L1)
	L2=float(da.strip("\n").split("\t")[4].split(" ")[2].strip("]").strip('%'))
	data[10].append(L2)
for da_com  in fd_com:
	L1_com=da_com.strip("\n").split("\t")[0]
	#data[0].append(L1)
	L2_com=float(da_com.strip("\n").split("\t")[4].split(" ")[2].strip("]").strip('%'))
	data[11].append(L2_com)
worksheet_4.write_column('A2', data[9])
worksheet_4.write_column('B2', data[10])
worksheet_4.write_column('C2', data[11])
chart_col = workbook.add_chart({'type': 'line'})
Sheet1=str(Sheet1)
chart_col.add_series({
    'name': '=' + Sheet1 + '!$B$1',
    'categories': '=' + Sheet1 + '!$A$2:$A$25',
    'values':  '='+ Sheet1 + '!$B$2:$B$25',
    'line': {'color': 'red'},
})
chart_col.add_series({
    'name':  '=' + Sheet1 + '!$C$1',
    'categories':  '=' + Sheet1 + '!$A$2:$A$25',
    'values':   '='+Sheet1+ '!$C$2:$C$25',
    'line': {'color': 'yellow'},
})
chart_col.set_title({'name': Sheet1})
chart_col.set_x_axis({'name': 'model num(%)'})
chart_col.set_y_axis({'name':  'wer num'})
chart_col.set_y_axis({'min': 6, 'max': 7.5})
chart_col.set_style(1)
worksheet_4.insert_chart('A26', chart_col, {'x_offset': 50, 'y_offset': 20,'x_scale': 1,'y_scale': 1})

fd.close()
fd_com.close()



print ("---------------------------------------")
Sheet1="noises"
fd=open(input_base,'r')
fd_com=open(input_com,'r')
worksheet_5 = workbook.add_worksheet(Sheet1)

headings = ['tmp_model_epoch_0_', 'base(%)',tmp_model]
worksheet_5.write_row('A1', headings, bold)
worksheet_5.set_column('A:A',70) 
worksheet_5.set_column('B:C',15) 
for da  in fd:
	L1=da.strip("\n").split("\t")[0]
	data[12].append(L1)
	L2=float(da.strip("\n").split("\t")[5].split(" ")[2].strip("]").strip('%'))
	data[13].append(L2)
for da_com  in fd_com:
	L1_com=da_com.strip("\n").split("\t")[0]
	#data[0].append(L1)
	L2_com=float(da_com.strip("\n").split("\t")[5].split(" ")[2].strip("]").strip('%'))
	data[14].append(L2_com)
worksheet_5.write_column('A2', data[12])
worksheet_5.write_column('B2', data[13])
worksheet_5.write_column('C2', data[14])
chart_col = workbook.add_chart({'type': 'line'})
Sheet1=str(Sheet1)
chart_col.add_series({
    'name': '=' + Sheet1 + '!$B$1',
    'categories': '=' + Sheet1 + '!$A$2:$A$25',
    'values':  '='+ Sheet1 + '!$B$2:$B$25',
    'line': {'color': 'red'},
})
chart_col.add_series({
    'name':  '=' + Sheet1 + '!$C$1',
    'categories':  '=' + Sheet1 + '!$A$2:$A$25',
    'values':   '='+Sheet1+ '!$C$2:$C$25',
    'line': {'color': 'yellow'},
})
chart_col.set_title({'name': Sheet1})
chart_col.set_x_axis({'name': 'model num(%)'})
chart_col.set_y_axis({'min': 75.0, 'max': 100.0})
chart_col.set_y_axis({'name':  'UTTERANCE_ACU'})
chart_col.set_style(1)
worksheet_5.insert_chart('A26', chart_col, {'x_offset': 50, 'y_offset': 20,'x_scale': 1,'y_scale': 1})


fd.close()
fd_com.close()














def hold():
	workbook = xlsxwriter.Workbook(input_com+"xxx.xlsx")
	# 自定义样式，加粗
	bold = workbook.add_format({'bold': 1})
	
	# 创建sheet
	
	# worksheet = workbook.add_worksheet("bug_analysis")
	
	#表头
	
	headings = ['tmp_model_epoch_0_', 'base(%)',tmp_model]
	worksheet_1.write_row('A1', headings, bold)
	
	worksheet_1.set_column('A:A',50) 
	worksheet_1.set_column('B:C',10) 
	for da  in fd:
		L1=da.strip("\n").split("\t")[0]
		data[0].append(L1)
		L2=float(da.strip("\n").split("\t")[1].split(" ")[2].strip("]").strip('%'))
		data[1].append(L2)
	for da_com  in fd_com:
		L1_com=da_com.strip("\n").split("\t")[0]
		#data[0].append(L1)
		L2_com=float(da_com.strip("\n").split("\t")[1].split(" ")[2].strip("]").strip('%'))
		data[2].append(L2_com)
	worksheet_1.write_column('A2', data[0])
	worksheet_1.write_column('B2', data[1])
	worksheet_1.write_column('C2', data[2])
	chart_col = workbook.add_chart({'type': 'line'})
	Sheet1=str(Sheet1)
	chart_col.add_series({
	    'name': '=' + Sheet1 + '!$B$1',
	    'categories': '=' + Sheet1 + '!$A$2:$A$25',
	    'values':  '='+ Sheet1 + '!$B$2:$B$25',
	    'line': {'color': 'red'},
	})
	chart_col.add_series({
	    'name':  '=' + Sheet1 + '!$C$1',
	    'categories':  '=' + Sheet1 + '!$A$2:$A$25',
	    'values':   '='+Sheet1+ '!$C$2:$C$25',
	    'line': {'color': 'yellow'},
	})
	chart_col.set_title({'name': Sheet1})
	chart_col.set_x_axis({'name': 'model num(%)'})
	chart_col.set_y_axis({'name':  'UTTERANCE_ACU'})
	chart_col.set_style(1)
	chart.set_size({'width': 720, 'height': 576})
	worksheet_1.insert_chart('A26', chart_col, {'x_offset': 50, 'y_offset': 20,'x_scale': 1,'y_scale': 1})















workbook.close()



#if __name__ == '__main__':
	#init_env()
	#pass



