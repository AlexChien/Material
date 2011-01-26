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

function init_listener(){
    var App = new Ext.App({});
    Ext.data.DataProxy.addListener('beforewrite', function(proxy, action) {
        App.setAlert(App.STATUS_NOTICE, "操作中...");
    });

    Ext.data.DataProxy.addListener('write', function(proxy, action, result, res, rs) {
        var display_text = res.message.display_text;
        var grand_total = res.message.grand_total;
        if(grand_total=="defined"){
            $("#grand_total").html(display_text);
        }else{
            $("#grand_total").html(display_text+grand_total);
            if(grand_total <= 0){
                $("#order_list").html('<font color="red">您在此活动中无任何预订记录</font>');
            }
        }
        App.setAlert(true, res.message.notice);
    });

    Ext.data.DataProxy.addListener('exception', function(proxy, type, action, options, res) {
        // App.setAlert(false, "Something bad happend while executing " + action);
        Ext.Msg.show({
            title: '发生错误',
            msg: res.message,
            icon: Ext.MessageBox.ERROR
        });
    });
}