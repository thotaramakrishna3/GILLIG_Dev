/***********************************************************************************************************************************
Developer :Suyati
Name      : NewTripReportController
Usage     : Apex Controller to fetch records, creating a new trip report ,create trip contacts associated with trip report created,query contact created and to get recordtype Id 
Associated Component:NewTripReportComponent
Date      : October 2019   
************************************************************************************************************************************/  
public class NewTripReportController {
   
    /***********************************************************************************************************************************
Method Name  : fetchRecords
Parameters   : String , String , String , String 
Return Type  : List<RecordsDataWrapper>  
Method call  : fetchRecords(objectName, filterField, searchString, value)
Description  : Fetch all records of sObject
************************************************************************************************************************************/   
    @AuraEnabled
    public static List<RecordsDataWrapper> fetchRecords(String objectName, String[] filterField, String searchString, String value) {
        try {
            List<RecordsDataWrapper> recordsDataList = new List<RecordsDataWrapper>();
            String query = 'SELECT Id, ' + filterField[0]+','+ filterField[1] + ' FROM '+objectName;
            if(String.isNotBlank(value)) {
                query += ' WHERE Id = \''+ value + '\' LIMIT 49999';
            } else {
                query += ' WHERE '+'('+filterField[0]+
                    ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) +'%\')'+'OR'+'('+filterField[1]+
                    ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\') LIMIT 49999';
            }
            for(SObject s : Database.query(query)) {
                 recordsDataList.add( new RecordsDataWrapper((String)s.get(filterField[0]),(String)s.get(filterField[1]), (String)s.get('id')) );
            }
            return recordsDataList;
        } catch (Exception err) {
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
        }
    }
    /***********************************************************************************************************************************
Class Name   : RecordsDataWrapper
Description  : To store value of filter fields(Name,InternalName) and their respective id
Usage        : Used in fetch records method
************************************************************************************************************************************/  
   public class RecordsDataWrapper {
        @AuraEnabled public String label;
         @AuraEnabled public String fieldLabel;
        @AuraEnabled public String value;
        public RecordsDataWrapper(String label,String fieldLabel, String value) {
            this.label = label;
            this.fieldLabel = fieldLabel;
            this.value = value;
        }
    }

    /***********************************************************************************************************************************
Method Name  : getResult
Parameters   : String 
Return Type  : tripDetailwrapper 
Method call  : getResult(SelectedAccountId)
Description  : Returns a wrapper based on Id of selected Account
************************************************************************************************************************************/   
    @AuraEnabled
    public static tripDetailwrapper  getResult(string SelectedAccountId){
        try
        {
            tripDetailwrapper tripDetailwrapperObj =new tripDetailwrapper();
            list< Trip_Report__c> trip_report=[SELECT Id, Account_Visited__r.Electric_Bus_Plans__c	,Account_Visited__r.Fuel_Cell_Bus_Plans__c, Account_Visited__r.Artic_Bus_Plans__c,Account_Visited__r.Fleet_Replacement_Plans__c,Account_Visited__r.Fleet_Performance_Updates__c, Account_Visited__c, Account_Visited__r.Ridership__c,CreatedDate  FROM Trip_Report__c where Account_Visited__c=:SelectedAccountId order by CreatedDate desc limit 1 ];
         
                Account accountWithoutTripReport=[select id,Electric_Bus_Plans__c,Fuel_Cell_Bus_Plans__c,Artic_Bus_Plans__c,Fleet_Replacement_Plans__c,Fleet_Performance_Updates__c,Ridership__c from account where id=:SelectedAccountId limit 1];
                Trip_Report__c tripReport=new Trip_Report__c();
                tripReport.Account_Visited__c=SelectedAccountId;
                tripReport.Electric_Bus_Plans__c=accountWithoutTripReport.Electric_Bus_Plans__c;
                tripReport.Fuel_Cell_Bus_Plans__c=accountWithoutTripReport.Fuel_Cell_Bus_Plans__c;
                tripReport.Artic_Bus_Plans__c=accountWithoutTripReport.Artic_Bus_Plans__c;
                tripReport.Fleet_Replacement_Plans__c=accountWithoutTripReport.Fleet_Replacement_Plans__c;
                tripReport.Fleet_Performance__c=accountWithoutTripReport.Fleet_Performance_Updates__c; 
                tripReport.Ridership__c=accountWithoutTripReport.Ridership__c;  
                tripDetailwrapperObj.tripReport=tripReport;
            
            tripDetailwrapperObj.tripContactList=[SELECT Id, Left_Company__c, AccountId,phone,mobilephone,Name FROM Contact where Left_Company__c=False and AccountId=:SelectedAccountId];
            return  tripDetailwrapperObj;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage()); 
        }
    } 
    /***********************************************************************************************************************************
Class Name   : tripDetailwrapper
Description  : To store Trip Report and their list of trip Contact 
Usage        : Used in getResult method
************************************************************************************************************************************/  
    public class tripDetailwrapper{
        @AuraEnabled
        public Trip_Report__c tripReport{get;set;}
        @AuraEnabled
        public list<Contact> tripContactList =new list<contact>();
    }
    /***********************************************************************************************************************************
Method Name  : createTripReport
Parameters   : Trip_Report__c, list<contact>
Return Type  : Trip_Report__c 
Method call  : createTripReport(tripReport,selectedcontact)
Description  : Creation of trip report and associated trip contacts
************************************************************************************************************************************/   
    @AuraEnabled
    public static Trip_Report__c createTripReport(Trip_Report__c tripReport,list<contact> selectedcontact){
        list<TripContact__c> tripContactList = new list<TripContact__c>();
        try{
            insert tripReport;            
            for(integer i=0;i<selectedcontact.size();i++){
                TripContact__c updatedTripContact= new TripContact__c();
                updatedTripContact.TripReport__c=tripReport.Id;
                updatedTripContact.TripContact__c=selectedcontact[i].Id;
                updatedTripContact.Visited__c=true;
                tripContactList.add(updatedTripContact);
            }
            insert tripContactList;
        }catch(DMLException e){
            throw new AuraHandledException(e.getDMLMessage(0)); 
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage()); 
        }
        return tripReport;
    }
    /***********************************************************************************************************************************
Method Name  : getcreatedcontact
Parameters   : string
Return Type  : contact 
Method call  : getcreatedcontact(contactId)
Description  : Query the created contact
************************************************************************************************************************************/   
    @AuraEnabled
    public static contact getcreatedcontact(string contactId){
        contact contactObj = new contact();
        contactObj=[select id,Name,phone,mobilephone from contact where id=:contactId];
        return contactObj;
    }
    /***********************************************************************************************************************************
Method Name  : getRecordtypeId
Parameters   : None
Return Type  : String  
Method call  : getRecordtypeId()
Description  : Get the RecordtypeId 
************************************************************************************************************************************/  
    @AuraEnabled
    public static String getRecordtypeId(){
        String recordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();        
        return recordId;
    }
}