({
    //Method to display edit button to forecasted opportunity lines
    setActionValue : function (component) {
        var data = component.get('v.data');
        data = data.map(function(rowData) {
           if (rowData.RecordType.Name == 'Forecasted') {
               rowData.disabledValue = false;
            } else {
                rowData.disabledValue = true;
           }
           return rowData;
        });
        component.set('v.data',data);
    }
})