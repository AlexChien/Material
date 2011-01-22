var win_yyc;
function addwindow(href,title,width,height) {
    var temwin = new Ext.Panel({
    animScroll : true,
    autoDestroy: false,
    defaults:{autoScroll: true},
    html: '<iframe src="'+href+'" height=100% width=100% frameborder="no" border=0 marginwidth="0" marginheight="0" scrolling="no" allowtransparency="yes"></iframe>',
    closeAction:'hide',
    closable:true
    });
    win_yyc = new Ext.Window({
        title: title,
        closable:true,
        maximizable:true,
        constrain:true,
        modal:true,
        width:width,
        height:height,
        //border:false,
        plain:true,
        layout: 'fit',
        buttonAlign:'center',
        items: [temwin]
    });
    win_yyc.show(this);
}