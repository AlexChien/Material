// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(function(){
	resetInfo();
	nav_toggle();
	datepicker_zhCN();
});

function resetInfo() {
	window.setTimeout(
		function() {
			$('#notice,#error,#warn').slideUp('slow');
	}, 5000);
}

function nav_toggle() {
	$('.leftnav_header').click(function(e){
  		var val = $(this).attr("value");
  		$("#leftnav_"+val).toggle("slow");
  	})
}

function DrawImage(ImgD,w,h){
	var image=new Image();
	var iwidth = w; //定义允许图片宽度
	var iheight = h; //定义允许图片高度
	image.src=ImgD.src;

	if(image.width>0 && image.height>0){
		if(image.width/image.height>= iwidth/iheight){
			if(image.width>iwidth){
			ImgD.width=iwidth;
			ImgD.height=(image.height*iwidth)/image.width;
			}else{
			ImgD.width=image.width;
			ImgD.height=image.height;
			}
			ImgD.alt=image.width + "x" + image.height;
		}
		else{
			if(image.height>iheight){
				ImgD.height=iheight;
				ImgD.width=(image.width*iheight)/image.height;
			}else{
			ImgD.width=image.width;
			ImgD.height=image.height;
			}
			ImgD.alt=image.width + "x" + image.height;
		}
	}
}

jQuery(function($){
	$.datepicker.regional['zh-CN'] = {
		closeText: '关闭',
		prevText: '&#x3c;上月',
		nextText: '下月&#x3e;',
		currentText: '今天',
		monthNames: ['一月','二月','三月','四月','五月','六月',
		'七月','八月','九月','十月','十一月','十二月'],
		monthNamesShort: ['一','二','三','四','五','六',
		'七','八','九','十','十一','十二'],
		dayNames: ['星期日','星期一','星期二','星期三','星期四','星期五','星期六'],
		dayNamesShort: ['周日','周一','周二','周三','周四','周五','周六'],
		dayNamesMin: ['日','一','二','三','四','五','六'],
		weekHeader: '周',
		dateFormat: 'yy-mm-dd',
		firstDay: 1,
		isRTL: false,
		showMonthAfterYear: true,
		yearSuffix: '年'};
	$.datepicker.setDefaults($.datepicker.regional['zh-CN']);
});


function datepicker_zhCN(){
	$.datepicker.regional['zh-CN'] = {
		closeText: '关闭',
		prevText: '&#x3c;上月',
		nextText: '下月&#x3e;',
		currentText: '今天',
		monthNames: ['一月','二月','三月','四月','五月','六月',
		'七月','八月','九月','十月','十一月','十二月'],
		monthNamesShort: ['一','二','三','四','五','六',
		'七','八','九','十','十一','十二'],
		dayNames: ['星期日','星期一','星期二','星期三','星期四','星期五','星期六'],
		dayNamesShort: ['周日','周一','周二','周三','周四','周五','周六'],
		dayNamesMin: ['日','一','二','三','四','五','六'],
		weekHeader: '周',
		dateFormat: 'yy-mm-dd',
		firstDay: 1,
		isRTL: false,
		showMonthAfterYear: true,
		yearSuffix: '年'};
	$.datepicker.setDefaults($.datepicker.regional['zh-CN']);
}