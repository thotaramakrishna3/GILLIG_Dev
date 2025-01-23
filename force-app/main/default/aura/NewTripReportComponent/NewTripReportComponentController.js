({
    // To prepopulate the selected value pill if value attribute is filled
    doInit : function( component, event, helper ) {
        $A.util.toggleClass(component.find('resultsDiv'),'slds-is-open');
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
        var context = JSON.parse(window.atob(value));
        if(context.attributes.objectApiName=='Account')
        {
           component.set('v.value',context.attributes.recordId);
        }
        helper.searchRecordsHelper( component, event, helper, component.get('v.value') );
        var action =component.get('c.getRecordtypeId');
        action.setCallback(this,function(response1){
            var response = response1.getReturnValue();
            var state = response1.getState(); 
            if (component.isValid() && state === "SUCCESS"){
                component.set('v.recordTypeId',response);
            }
        });
        $A.enqueueAction(action);
    },
    //Toggles input and output modes for inline editing
    onClickToggleDiv : function(component, event, helper) {
        // first get the div element. by using aura:id
        var divName = event.target.id;
        var buttonName=divName+'Button';
        let res = component.find(buttonName);
        res.forEach(function(v,i) {
            $A.util.toggleClass(v, "slds-hide");
        });
        var outputElementID="output"+divName;
        var outputElement = component.find(outputElementID);
        // by using $A.util.toggleClass add-remove slds-hide class
        $A.util.toggleClass(outputElement, "slds-hide");
        var InputElement = component.find("input"+divName);
        // by using $A.util.toggleClass add-remove slds-hide class
        $A.util.toggleClass(InputElement,"slds-hide");
    },
    onClickToggleButton : function(component, event, helper) {
        // first get the div element. by using aura:id
        var button = event.getSource();
        var localId = button.getLocalId();
        event.stopPropagation();
        var sectionName=localId.replace("Button","");
        let res = component.find(localId);
        res.forEach(function(v,i) {
            $A.util.toggleClass(v, "slds-hide");
        });
        var outputElementID="output"+sectionName;
        var outputElement = component.find(outputElementID);
        // by using $A.util.toggleClass add-remove slds-hide class
        $A.util.toggleClass(outputElement, "slds-hide");
        var InputElement = component.find("input"+sectionName);
        // by using $A.util.toggleClass add-remove slds-hide class
        $A.util.toggleClass(InputElement,"slds-hide");
    },
    // When a keyword is entered in search box
    searchRecords : function( component, event, helper ) {
        if( !$A.util.isEmpty(component.get('v.searchString')) ) {
            helper.searchRecordsHelper( component, event, helper, '' );
        } else {
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
    },
    // When an item is selected
    selectItem : function( component, event, helper ) {
        if(!$A.util.isEmpty(event.currentTarget.id)) {
             var recordsList = component.get('v.recordsList');
            var index = recordsList.findIndex(x => x.value === event.currentTarget.id)
            if(index != -1) {
                var selectedRecord = recordsList[index];
            }
            component.set('v.selectedRecord',selectedRecord);
            component.set('v.tripReport.Account_Visited__c',selectedRecord.value);
            component.set('v.value',selectedRecord.value);
            helper.searchDetailsHelper( component, event, helper );
            component.set('v.editDetails',true);
        }
    },
    //Show the  details based on keyword entered
    showRecords : function( component, event, helper ) {
        if(!$A.util.isEmpty(component.get('v.recordsList')) && !$A.util.isEmpty(component.get('v.searchString'))) {
            $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        }
    },
    // To remove the selected item.
    removeItem : function( component, event, helper ){
        component.set('v.selectedRecord','');
        component.set('v.value','');
        component.set('v.searchString','');
        setTimeout( function() {
            component.find( 'inputLookup' ).focus();
        }, 250);
    },
    // To close the dropdown if clicked outside the dropdown.
    blurEvent : function( component, event, helper ){
        $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
    },
    getValue :function( component, event, helper ){
    },
    // Fired when saving a trip report 
    saveRecord :function( component, event, helper ){
        var tripReport=component.get('v.tripReport');
        var VisitedDate= tripReport.Date_of_Visit__c;
        if(VisitedDate=="")
        {
            // Displays a message
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Required Field Missing',
                message:'Visited Date is missing',
                messageTemplate: 'Please enter a visited date to continue',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        else
        {
            //selecting  contacts from a list of contacts shown
            var tripContact= component.get("v.selectedContactRows");
            var action = component.get("c.createTripReport"); 
            action.setParams({
                'tripReport' :tripReport,
                'selectedcontact':tripContact
            });
            action.setCallback(this, function(response1) {    
                var response = response1.getReturnValue();
                var state = response1.getState();  
                console.log('response'+response1);
                if (component.isValid() && state === "SUCCESS"){
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": response.Id,
                        "slideDevName": "related"
                    });
                    navEvt.fire();
                } 
                else{
                }
            });
            $A.enqueueAction(action);
        }
    },
    cancel :function( component, event, helper ){
        //set "editDetails" attribute to false to close the accordion
        component.set('v.editDetails',false);
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    redirect: function (){
        var url = window.location.href; 
        var value = url.substr(0,url.lastIndexOf('/') + 1);
        window.history.back();
        return false;
    },
    // To get the selected contacts 
    updateSelectedText:function( component, event, helper ){
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedContactRows',selectedRows);
    },
    createRecord : function (component, event, helper) {
        //set "isModalOpen" attribute to true to open the modal
        component.set("v.isModalOpen", true);
    },
    closeModel: function(component, event, helper) {
        //set "isModalOpen" attribute to false to close the modal
        component.set("v.isModalOpen", false);
    },
    submitDetails: function(component, event, helper) {
        //Submit the form 
        component.find("recordEditForm").submit();
    },
    // To toast success message with record id after contact creation
    handleSuccess : function(component, event, helper) {
        var payload = event.getParams().response;
        component.find('notifLib').showToast({
            "variant": "success",
            "title": "Contact Created",
            "message": "Record ID: " + payload.id
        });
        var action = component.get("c.getcreatedcontact"); 
        action.setParams({
            'contactId' :payload.id,
        });
        action.setCallback(this, function(response1) { 
            var state = response1.getState();        
            if (component.isValid() && state === "SUCCESS"){
                var resultData = response1.getReturnValue(); 
                var datalist=component.get('v.data');
                var adddetail={Id: resultData.Id,TripContact__c:resultData.Id,Name:resultData.Name, ContactName: resultData.Name,Phone:resultData.Phone,MobilePhone:resultData.MobilePhone, Visited__c: false};
                datalist.push(adddetail);
                component.set("v.data", datalist);
            } 
            else{
            }
        });
        $A.enqueueAction(action);
        component.set("v.isModalOpen", false);
    }
})