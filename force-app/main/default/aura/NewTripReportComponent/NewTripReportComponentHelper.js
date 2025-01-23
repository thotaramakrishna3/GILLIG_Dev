({
    //To get accountId if created from account detail page
    getParameterByName: function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    //Search a account Records based on keyword entered
    searchRecordsHelper : function(component, event, helper, value) {
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
        var searchString = component.get('v.searchString');
        component.set('v.message', '');
        component.set('v.recordsList', []);
        var  filterField = component.get('v.fieldName');
        // Calling Apex Method
        var action = component.get('c.fetchRecords');
        action.setParams({
            'objectName' : component.get('v.objectName'),
            'filterField' : filterField,
            'searchString' : searchString,
            'value' : value
        });
        action.setCallback(this,function(response){
            var result = response.getReturnValue();
            if(response.getState() === 'SUCCESS') {
                if(result.length > 0) {
                    // To check if value attribute is prepopulated or not
                    if( $A.util.isEmpty(value) ) {
                        component.set('v.recordsList',result);  
                    } else {
                        component.set('v.selectedRecord', result[0]);   
                        component.set('v.tripReport.Account_Visited__c',result[0].value);
                        component.set('v.editDetails',true);
                        this.searchDetailsHelper( component, event, helper );
                    }
                } else {
                    component.set('v.message', "No Records Found for '" + searchString + "'");
                }
            } else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            // To open the drop down list of records
            if( $A.util.isEmpty(value) )
                $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
            $A.util.addClass(component.find("Spinner"), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    //Get and set the details of selected Account
    searchDetailsHelper: function(component, event) {
        var accountRecord= component.get('v.selectedRecord');
        var accountId= accountRecord.value;
        var action = component.get("c.getResult");  
        action.setParams({
            'SelectedAccountId' :accountId          
        });
        action.setCallback(this, function(response1) {    
            var state = response1.getState();        
            if (component.isValid() && state === "SUCCESS"){ 
                var tripDetail = response1.getReturnValue(); 
                var resultData=tripDetail.tripReport;
                var rows =tripDetail.tripContactList;
                component.set('v.columns', [
                    {label: 'Contact Name', fieldName: 'Name', type: 'text'},
                    {label: 'Phone', fieldName: 'Phone', type: 'Phone'},
                    {label: 'Mobile', fieldName: 'MobilePhone', type: 'Phone'},
                ]);
                    component.set('v.data', rows);                 
                    component.set("v.tripReport.Electric_Bus_Plans__c", resultData.Electric_Bus_Plans__c );
                    component.set("v.tripReport.Artic_Bus_Plans__c", resultData.Artic_Bus_Plans__c);
                    component.set("v.tripReport.Fleet_Performance__c", resultData.Fleet_Performance_Updates__c);
                    component.set("v.tripReport.Fleet_Replacement_Plans__c", resultData.Fleet_Replacement_Plans__c);
                    component.set("v.tripReport.Key_Contact_Updates__c", resultData.Key_Contact_Updates__c);
                    component.set("v.tripReport.General_Account_Updates__c", resultData.General_Account_Updates__c);
                    component.set("v.tripReport.Ridership__c", resultData.Ridership__c);
                    component.set("v.tripReport.Part_Sales_YTD__c", resultData.Part_Sales_YTD__c);
                    component.set("v.tripReport.Part_Sales_Prior_Year__c", resultData.Part_Sales_Prior_Year__c);
                    component.set("v.tripReport.Parts_Sales_2_Years_Prior__c",resultData.Parts_Sales_2_Years_Prior__c);
                    component.set("v.tripReport.Retrofits__c",resultData.Retrofits__c);
                    component.set("v.tripReport.Part_Sales_Updates__c",resultData.Part_Sales_Updates__c);
                    component.set("v.tripReport.Field_Service_Items__c",resultData.Field_Service_Items__c);
                    component.set("v.tripReport.Publications_Info__c",resultData.Publications_Info__c);
                    component.set("v.tripReport.Customer_Experience__c",resultData.Customer_Experience__c);
                    component.set("v.tripReport.Fuel_Cell_Bus_Plans__c",resultData.Fuel_Cell_Bus_Plans__c);
                    }            
                    });
                    $A.enqueueAction(action);
                    }
                    })