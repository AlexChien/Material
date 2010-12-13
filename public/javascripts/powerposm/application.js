// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(function(){
	resetInfo();
	nav_toggle();
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