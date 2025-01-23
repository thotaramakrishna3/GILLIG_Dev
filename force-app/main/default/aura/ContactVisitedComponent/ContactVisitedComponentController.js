({
    //Method to display list of contact with their associated trip contact records
    doInit:function (component, event, helper) {
        var relatedrecord = component.get("v.recordId");
        var action = component.get("c.getTripContacts");
        action.setParams({
            'recordId': component.get("v.recordId"),           
        });
        action.setCallback(this, function(response) {  
            var rows = response.getReturnValue();           
            var selected=[];
            for (var i = 0; i < rows.length; i++) {
                var row = rows[i];
                var Account;
                Account = row.accountId;
                component.set("v.AccountVisited",Account);             
                row.linkName = '/lightning/r/Contact/' + row['contactId'] + '/view';
                if(row.isVisited==true){
                    selected.push(row.contactId); 
                }
            }
            component.set('v.columns', [
                {label: 'Contact Name', fieldName: 'linkName', type: 'url',
                 typeAttributes: {label: { fieldName: 'contactName' },value:{fieldName: 'linkName'}, target: '_blank'}
                },
                {label: 'Phone', fieldName: 'phone', type: 'Phone'},
                {label: 'Mobile', fieldName: 'mobilePhone', type: 'Phone'},                
            ]);           
             component.set('v.data', rows);
             component.set('v.selectedRows',selected);
             component.set('v.count',rows.length);
              });
             $A.enqueueAction(action);
             helper.getRecordType(component);
           },
                
       //Method to update visited value for selected trip contact         
       updateSelectedText:function( component, event, helper){
           var SaveButton = component.find('SaveButton');
           SaveButton.set('v.disabled',false);
           var selectedRows = event.getParam('selectedRows');
           var allContactData=[];
           allContactData =component.get('v.data');
            for(var i=0;i<allContactData.length;i++){
                if(selectedRows.includes(allContactData[i])){
                    allContactData[i].isVisited=true;
                }
                else{
                    allContactData[i].isVisited=false;
                }
            }
            component.set('v.selectedContactRows',allContactData);
        },
                           
        //Method to create a new tripcontact or to update existing trip contact                  
       SaveRecord: function (component, event, helper) {      
         var tripContact= component.get("v.selectedContactRows");
         var SaveButton = component.find('SaveButton');
         SaveButton.set('v.disabled',true);
         var action = component.get("c.createTripContact");
         action.setParams({
                'tripContactListJson':JSON.stringify(tripContact),
                'recordId': component.get("v.recordId"),                
            });
         action.setCallback(this, function(response1) {    
           var state = response1.getState();        
           if (component.isValid() && state === "SUCCESS"){
                component.set('v.data', tripContact);
                } 
            else{
                }
          });
         $A.enqueueAction(action);     
        }, 
            
       //Method to open Model/Popup
       createRecord : function (component, event, helper) {
            component.set("v.isModalOpen", true);
        },
            
       //Method to close Model/Popup
        closeModel: function(component, event, helper) {
            // Set isModalOpen attribute to false  
             component.set("v.isModalOpen", false);
        },
            
        //Method to create new contact   
        submitDetails: function(component, event, helper) {
             component.find("recordEditForm").submit();
        },
            
        //pre-popoulte account name in modal
        handleLoad :function(component,event,helper){
          var VisitedAccount = component.get('v.AccountVisited');
          var nameFieldValue = component.find("PopulateAccount").set("v.value", VisitedAccount);
        },
            
        //Method to close Model/Popup  and refreh contact list  
        handleSuccess : function(component, event, helper) {
         var refreshRelatedList=component.get('c.doInit');
         $A.enqueueAction(refreshRelatedList);    
         component.set("v.isModalOpen", false);
       },
    })