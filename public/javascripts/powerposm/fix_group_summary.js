Ext.ux.grid.GroupSummary.Calculations = {
    'sum' : function(v, record, field){
        return (v*1000 + ((record.data[field])||0)*1000)/1000;
    }
}