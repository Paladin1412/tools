#!/usr/bin/env python
################################################################################
#
# Copyright (c) 2018 Baidu.com, Inc. All Rights Reserved
#
################################################################################
#-*- coding:utf8 -*-



import sys
import xlsxwriter



input_base="base.fm"
input_com=sys.argv[1]
fd=open(input_base,'r')
fd_com=open(input_com,'r')

workbook = xlsxwriter.Workbook(input_com+".xlsx")
# 自定义样式，加粗
bold = workbook.add_format({'bold': 1})

# 创建sheet
#worksheet_1 = workbook.add_worksheet('Sheet1')
#worksheet_2 = workbook.add_worksheet('Sheet2')
#worksheet_3 = workbook.add_worksheet('Sheet3')
#worksheet_4 = workbook.add_worksheet('Sheet4')
#worksheet_5 = workbook.add_worksheet('Sheet5')

# worksheet = workbook.add_worksheet("bug_analysis")

#表头
headings = ['Comp', 'base(%)','tmp_model(%)']

data=[[],[],[]]
def draw():
	for sheet in range(1,6):	
		sheet = str(sheet)	
		tmp_sheet="worksheet_" + str(sheet)
		tt_sheet="Sheet" + sheet
		#print (tt_sheet)
		tmp_sheet= workbook.add_worksheet(tt_sheet)
		# 创建一个excel
		
		tmp_sheet.set_column('A:A',50) 
		tmp_sheet.set_column('B:C',10) 
		#Sheet(1,5)	
		sheet = int(sheet)
		for da  in fd:
			print ("sheet:",sheet)
			L1=da.strip("\n").split("\t")[0]
			data[sheet*3-3].append(L1)
			L2=float(da.strip("\n").split("\t")[sheet].split(" ")[2].strip("]").strip('%'))
			#num1= sheet*3-2
			data[sheet*3-2].append(L2)
		for da_com  in fd_com:
			L1_com=da_com.strip("\n").split("\t")[0]
			data[0].append(L1)
			L2_com=float(da_com.strip("\n").split("\t")[sheet].split(" ")[2].strip("]").strip('%'))
			num2= sheet*3-1
			data[sheet*3-1].append(L2_com)
	
		
		# 写入表头
		tmp_sheet.write_row('A1', headings, bold)
		
		# 写入数据
		tmp_sheet.write_column('A2', data[0])
		tmp_sheet.write_column('B2', data[1])
		tmp_sheet.write_column('C2', data[2])
		
		# --------2、生成图表并插入到excel---------------
		# 创建一个柱状图(line chart)
		chart_col = workbook.add_chart({'type': 'line'})
		
		# 配置第一个系列数据
		chart_col.add_series({
		    # 这里的sheet1是默认的值，因为我们在新建sheet时没有指定sheet名
		    # 如果我们新建sheet时设置了sheet名，这里就要设置成相应的值
		    'name': '=tt_sheet!$B$1',
		    'categories': '=tt_sheet!$A$2:$A$25',
		    'values':   '=tt_sheet!$B$2:$B$25',
		    'line': {'color': 'red'},
		})
		
		# 配置第二个系列数据
		chart_col.add_series({
		    'name': '=tt_sheet!$C$1',
		    'categories':  '=tt_sheet!$A$2:$A$25',
		    'values':   '=tt_sheet!$C$2:$C$25',
		    'line': {'color': 'yellow'},
		})
		
		# 配置第二个系列数据(用了另一种语法)
		# chart_col.add_series({
		#     'name': ['Sheet1', 0, 2],
		#     'categories': ['Sheet1', 1, 0, 6, 0],
		#     'values': ['Sheet1', 1, 2, 6, 2],
		#     'line': {'color': 'yellow'},
		# })
		
		# 设置图表的title 和 x，y轴信息
		if sheet == "1":
			title="input_spontaneous_10000"
			chart_col.set_title({'name': "input_spontaneous_10000 draw lines"})
		elif sheet == "2":
			chart_col.set_title({'name': "input_3100_2400_9000 draw lines"})
		elif sheet == "3":
			chart_col.set_title({'name': "input_7508 draw lines"})
		elif sheet == "4":
			chart_col.set_title({'name': "ime_2019_07_5167 draw lines"})
		elif sheet == "5":
			chart_col.set_title({'name': "noises draw lines"})
		
		chart_col.set_x_axis({'name': 'model num(%)'})
		chart_col.set_y_axis({'name':  'wer num'})
		
		# 设置图表的风格
		chart_col.set_style(1)
		
		# 把图表插入到worksheet并设置偏移
		tmp_sheet.insert_chart('A26', chart_col, {
			'x_offset': 50, 
			'y_offset': 20,
			'x_scale': 1,
			'y_scale': 1
			})
		
	workbook.close()



print (data)
if __name__ == '__main__':
	#init_env()
	draw()
