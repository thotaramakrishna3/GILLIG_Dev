({
    //method to set record type Id to an attribute(recordTypeId)
	getRecordType : function(component) {
		 var getRecordTypeIdAction = component.get("c.getRecordtypeId");
                getRecordTypeIdAction.setCallback(this, function(response11) {    
                var state = response11.getState();        
                if (component.isValid() && state === "SUCCESS"){
                var recordTypeId=response11.getReturnValue();
                component.set("v.recordTypeId",recordTypeId);  
                }
                });
             
                $A.enqueueAction(getRecordTypeIdAction);     
	}
})