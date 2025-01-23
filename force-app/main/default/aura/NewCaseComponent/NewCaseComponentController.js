({ 
    //Method to display account and case record type
    doInit:function (component, event, helper) {
        var action = component.get("c.getTripAccountVisited");
        action.setParams({
            'recordId': component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue(); 
            component.set("v.AccountVisited",result.accountId);
            component.set("v.caseRecordTypeId",result.recordTypeId); 
        });
        $A.enqueueAction(action);
    },
    handleLoad :function(component,event,helper){
    },
    //Method for getting case id after case creation
    handleSuccess : function(component, event, helper) {
        var insertedCaseId=event.getParams("id").response.id;
        component.set("v.CaseRecordId",insertedCaseId);       
    },
    //Method for uploading supporting documents and comments
    saveAndCloseModel: function(component, event, helper) {
        var contentDocumentId=component.get("v.contentDocumentId");
        if(contentDocumentId!=null){
            var comments =  component.find("commentupload").get("v.value");
            var action = component.get("c.uploadComment"); 
            action.setParams({
                'comment':comments,
                'contentDocumentId':contentDocumentId,                
            });
            action.setCallback(this, function(response1) {  
                var state = response1.getState();  
            });
            $A.enqueueAction(action); 
        }
        var event = $A.get("e.c:CaseRelatedListRefreshEvent");
        event.fire();
        var showValue= component.get("v.showModal");
        if (showValue==true) {
            component.set("v.showModal",false);     // closing the modal from related list of cases
        } else { 
            $A.get("e.force:closeQuickAction").fire(); // closing the quick action
        }
    },
    //Method for setting current step is one
    selectFromHeaderStep1:function(component,event,helper){
        component.set("v.currentStep","1");
    },
    //Method for setting current step is two
    selectFromHeaderStep2:function(component,event,helper){
        component.set("v.currentStep","2");
    }, 
    //Method for checking and setting current step
    handleSubmit:function(component,event,helper){
        component.find("recordEditForm").submit();
        var getCurrentStep=component.get("v.currentStep");
        if(getCurrentStep=="1"){
            component.set("v.currentStep","2");
        }
    },
    //Method for setting content document id
    handleUploadFinished: function (component, event) {
        var uploadedFiles = event.getParam("files");
        var documentId = uploadedFiles[0].documentId;
        component.set("v.contentDocumentId",documentId);   
    } 
})