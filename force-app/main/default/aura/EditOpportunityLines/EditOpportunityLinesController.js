({
    
    doInit:function (component, event, helper) {
    },
    
    //Method to display success message and fire an event 
    handleSuccess : function(component, event, helper) {     
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully.",
            "type":"success"
        });
        toastEvent.fire();
        var event = $A.get("e.c:CaseRelatedListRefreshEvent");
        event.fire();
        var showValue= component.get("v.showModal");
        if (showValue==true) {
            component.set("v.showModal",false);    
        }
    },
    
    //Method to update opportunuty line
    handleSubmit:function(component,event,helper){
        component.find("recordEditForm").submit();
    }, 
})