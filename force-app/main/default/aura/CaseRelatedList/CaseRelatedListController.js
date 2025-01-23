({
    //Method to display case related informations in a table
    doInit:function (component, event, helper) {
        var action = component.get("c.getCaseDetails");
        action.setParams({
            'recordId': component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            var rows = response.getReturnValue();
            for (var i = 0; i < rows.length; i++) {
                var row = rows[i];
                var Account;
                Account = row.AccountId;
                component.set("v.AccountVisited",Account);
            }
            component.set('v.columns', [
                {label: 'Case Number', fieldName: 'CaseNumber', type: 'Number'},
                {label: 'Subject', fieldName: 'Subject', type: 'text'},
                {label: 'Status', fieldName: 'Status', type: 'text'},
                {type: 'button', typeAttributes: {
                    label: 'Files',
                    name: 'Files',
                    title: 'Files',
                    disabled: false,
                    value: 'Files',
                    iconPosition: 'right'
                }}
            ]);
            component.set('v.data', rows);
            component.set('v.count',rows.length);
        });
        $A.enqueueAction(action);
    },
    //Metod to display File details
    viewFileDetails: function(component, event, helper) {
        component.set('v.fileButtonClick',true);
        var recId = event.getParam('row').Id;   
        component.set('v.CaseRecordId',recId);
        var action = component.get("c.getfileAndComment");      
        action.setParams({ 'caseRecordId':recId ,
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();        
            if (state === "SUCCESS") {
                var FilesList = response.getReturnValue();
                component.set('v.FileAndCommentList', FilesList);               
            }
        });
        $A.enqueueAction(action);
    },
    //Method for assign true to boolean variable to open modal
    createNew:function(component,event,helper){
        component.set("v.createNewCaseButton" , true);
    },
    //Method for refreshing the page
    refreshChild:function(component,event,helper){
        var refreshRelatedList=component.get('c.doInit');
        $A.enqueueAction(refreshRelatedList); 
    },
    //Method for close the modal
    handleSubmit:function(component,event,helper){
        component.set("v.createNewCaseButton" , false);
    },
    
    //Method to close modal and refresh related list
    closeCreateModel:function(component,event,helper){
        component.set("v.createNewCaseButton" , false);
        var refreshRelatedList=component.get('c.doInit');
        $A.enqueueAction(refreshRelatedList); 
    },
    //Method for submit the file
    handleNew:function(component,event,helper){
        component.set("v.newButtonClick" , true);
        var changeElement = component.find("uploadNewFileButton");
        $A.util.toggleClass(changeElement, "slds-hide");
    },
    //Method for close the submit modal
    closeFileModel:function(component,event,helper){
        component.set("v.newButtonClick", false);
        component.set("v.fileButtonClick", false);
    },
    //Method to upload comments and close modal
    saveAndCloseModel: function(component, event, helper) {
        var contentDocumentId=component.get("v.contentDocumentId");
        var comments =  component.find("commentUpload").get("v.value");
        var caseRecordId=component.get('v.CaseRecordId');
        var action = component.get("c.uploadComment"); 
        action.setParams({
            'comment':comments,
            'contentDocumentId':contentDocumentId,  
            'caseRecordId': caseRecordId,
        });
        action.setCallback(this, function(response) {  
            component.set('v.FileAndCommentList', response.getReturnValue());      
            var state = response.getState();  
        });
        $A.enqueueAction(action);  
        component.find("fileCard").set("v.fileId", "");
        component.find("commentUpload").set("v.value", "");
        component.find("Submitbutton").set('v.disabled',true);
        var changeElement = component.find("uploadNewFileButton");
        $A.util.removeClass(changeElement, "slds-hide");
        component.set('v.newButtonClick', false);
    },
    //Method for a button to be disabled 
    handleUploadFinished: function (component, event, helper) {
        var uploadedFiles = event.getParam("files");
        var documentId = uploadedFiles[0].documentId;
        component.set("v.contentDocumentId",documentId);
        component.find("Submitbutton").set('v.disabled',false);      
    },
    //Method to get selected records
    getSelected:function(component, event, helper)
    {
        var rec_id =  event.currentTarget.getAttribute("data-Id");
        $A.get('e.lightning:openFiles').fire({ 
            recordIds: [rec_id]
        });  
    },
})