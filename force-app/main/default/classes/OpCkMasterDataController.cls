public with sharing class OpCkMasterDataController {
    @AuraEnabled
    public static List<Operation_Check_Master_Data__c> getOperationCheckList() {
        List<Operation_Check_Master_Data__c> opcklist = [SELECT Id, Name, Department_ID__c,RecordTypeId, Build_Station_ID__c, isActive__c, Operation_Description__c, Customer_Name__c, Value_Required_Indicator__c, Value_Description__c, Bus_Mode__c, Operation_Sequence_Number__c, Transmission__c, Account__r.Internal_Name__c,Account__c,Inactive_Date__c,Active_Date__c FROM Operation_Check_Master_Data__c ORDER BY Name asc];
        return opcklist;
    }
    
    // Getting record types from Operation check master data record Object
    @AuraEnabled(cacheable=true)
    public static List<RecordType> getRecordTypes() {
        return [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Operation_Check_Master_Data__c' ORDER BY Id ASC];
    }

    @AuraEnabled
    public static List<Account> getAllAccounts(){
        List<Account> accountlist = [SELECT Id, Name, Internal_Name__c from Account WHERE RecordType.Name = 'Customer'];
        return accountlist;
    }
    
    @AuraEnabled
    public static List<Bus__c> getAllBuslists(){
        List<Bus__c> buslist = [SELECT Id, Name, fleet__r.Name, fleet__r.Account__c, Fleet__r.Account__r.Name, Fleet__r.Account__r.Id,
                                Fleet__r.Account__r.Internal_Name__c FROM Bus__c WHERE Status__c in ('Staging','WIP','Out of Factory')];
        return buslist;
    }
    
    @AuraEnabled
    public static List<Bus__c> getBuslistbyAccount(String customer_internal_name){
        List<Bus__c> buslist = [SELECT Id, Name, fleet__r.Name, fleet__r.Account__c, Fleet__r.Account__r.Name , Fleet__r.Account__r.Id,
                                Fleet__r.Account__r.Internal_Name__c,Status__c FROM Bus__c where Fleet__r.Account__r.Internal_Name__c = :customer_internal_name and Status__c in ('Staging','WIP','Out of Factory')];
        return buslist;
    }
    
    // Newly added for the Serial number update for the SOld buses.
    @AuraEnabled(cacheable=true) 
    public static Bus__c gePageRecordId(String recordId) 
    { 
        return [SELECT Id, Name FROM Bus__c WHERE Id = :recordId]; 
    }
    
    // Getting Customer Name, Ecard Id, chassis NO from the APi 
    @AuraEnabled
    public static BusDetailsToupdateSerialNumber getBusDetails(String chassis_no){
        AuthorisationData.Token tokendata = userAuthentication.getAccesstoken();
        string endpoint = System.Label.EcardAppendpoint+'api/ecardbychassisno/';
        userAuthentication.ResponseWrapper statusresponse = userAuthentication.getData(endpoint+chassis_no, 'GET', tokendata.access_token, tokendata.refresh_token);
        System.debug('statusresponse :'+endpoint+chassis_no);
        BusDetailsToupdateSerialNumber log = new BusDetailsToupdateSerialNumber();
        if(statusresponse.isError){
            log.statusCode = statusresponse.statusCode;
            log.responsebody = statusresponse.responseBody;
            if(statusresponse.statusCode == '404'){
                log.isError = false;
            }
            else{
                log.isError = statusresponse.isError;
            }
        }
        else{
            log.isError = statusresponse.isError;
            log.statusCode = statusresponse.statusCode;
            log.responsebody = statusresponse.responseBody;
        }
        return log;
    }
    
    public class BusDetailsToupdateSerialNumber{
        @auraEnabled
        public boolean isError{get;set;}
        @auraEnabled
        public string responsebody{get;set;}
        @auraEnabled
        public string statusCode{get;set;}
    }
    
}