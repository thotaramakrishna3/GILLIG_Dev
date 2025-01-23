({
    //method to display opportunity lines 
    doInit : function(component, event, helper) {
        var action=component.get("c.getOpportunityLines");
        action.setParams({
            recordId:component.get("v.recordId"),
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows=response.getReturnValue();
                component.set('v.count',rows.length);
                if(rows.length>0)
                {
                    component.set('v.accountId',rows[0].Account__c);
                    component.set('v.recordTypeId',rows[0].RecordtypeId);
                }
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    row.linkName = '/lightning/r/Opportunity_Line__c/'+ row['Id']+'/view';
                }
                component.set('v.columns',[ 
                    {label: 'Opportunity Line Name', fieldName: 'linkName', type: 'url',
                     typeAttributes: {label: { fieldName: 'Name' },value:{fieldName: 'linkName'}, target: '_blank'}},
                    {label: 'Mode', fieldName: 'Mode__c', type: 'text'},
                    {label:'Length', fieldName:'Length__c', type:'text'},
                    {label: 'Style', fieldName:'Style__c', type: 'text'},
                    {label:'Quantity' , fieldName:'Quantity__c' ,type:'number',cellAttributes: { alignment: 'left'}},
                    {type: "button", typeAttributes: {
                        iconName: 'utility:edit',   
                        name: 'Edit',
                        title: 'Edit',
                        disabled: {fieldName: 'disabledValue'},
                        value: 'edit',
                        iconPosition: 'left'
                    }},
                ]);
                    component.set('v.data',rows);
                    helper.setActionValue(component); 
                    }
                    else if (state === "INCOMPLETE") {
                    // do something
                    }
                    else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                    if (errors[0] && errors[0].message) {
                    console.log("Error message: " + 
                                errors[0].message);
                }
            } else {
                console.log("Unknown error");
            }
        }
                           });
        $A.enqueueAction(action);
    },
    //method to display success message and to close model
    handleSuccess: function(component, event, helper) {
        var insertedResponse=event.getParams().response;
        var  insertedOpportunityLine=insertedResponse.id;
        component.find('notifLib').showToast({
            "variant": "success",
            "title": "Contact Created",
            "message": "Record ID: " + insertedOpportunityLine
        });
        component.set("v.isModalOpen", false);
    },
    //method to edit opportunity lines
    EditDetails: function(component, event, helper) {
        component.set('v.editButtonClick',true);
        var recId = event.getParam('row').Id;   
        component.set('v.editOpportunityLineId',recId);
    },
    //method to close model
    closeCreateModel:function(component,event,helper){
        component.set("v.editButtonClick", false);
    },
    //method to refresh opportunity line related list
    refreshChild:function(component,event,helper){
        var refreshRelatedList=component.get('c.doInit');
        $A.enqueueAction(refreshRelatedList); 
    },
})