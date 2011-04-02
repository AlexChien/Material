Ext.ux.grid.GroupSummary.Calculations = {
    'sum' : function(v, record, field){
        return (v*100 + ((record.data[field])||0)*100)/100;
    }
}