【可执行程序】ArrayProcessing
【更新时间】20190409
【使用说明】
（1）linux下直接运行ArrayProcessing可执行文件，即可以处理小度音箱上传的原始麦克风信号；
（2）支持多线程处理；
（3）增加容错机制，定位结果文件名可以为location或location.txt，同时文件夹内文件错误时，不做处理，跳到下一条；
（3）命令参数如下：
./Arrayprocess 3 1 config_xiaodu_linux_3_1.lst filepath.lst
argv[1] 麦克风数量，设置为3
argv[2] 参考信号数量，设置为1
argv[3] 麦克风坐标配置文件，设置为config_xiaodu_linux_3_1.lst
argv[4] 需要处理的文件列表，示例如下：
例如：文件列表为filepath.lst，内容为：
/home/work/Project/longhai/data/ori_bv/test3_20190222/bv_audio/6660703721700468514_pcm/
/home/work/Project/longhai/data/ori_bv/test3_20190222/bv_audio/6660703743206943513_pcm/
/home/work/Project/longhai/data/ori_bv/test3_20190222/bv_audio/6660703859175459544_pcm/
/home/work/Project/longhai/data/ori_bv/test3_20190222/bv_audio/6660703889190362798_pcm/
/home/work/Project/longhai/data/ori_bv/test3_20190222/bv_audio/6660703923542334824_pcm/
/home/work/Project/longhai/data/ori_bv/test3_20190222/bv_audio/6660703945069007657_pcm/
/home/work/Project/longhai/data/ori_bv/test3_20190222/bv_audio/6660703970799107326_pcm/
/home/work/Project/longhai/data/ori_bv/test3_20190222/bv_audio/6660704065296384243_pcm/
/home/work/Project/longhai/data/ori_bv/test3_20190222/bv_audio/6660704142563816316_pcm/
/home/work/Project/longhai/data/ori_bv/test3_20190222/bv_audio/6660704172721604640_pcm/
/home/work/Project/longhai/data/ori_bv/test3_20190222/bv_audio/6660704194119048808_pcm/