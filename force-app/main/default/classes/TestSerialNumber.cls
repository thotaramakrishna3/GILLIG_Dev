public with sharing class TestSerialNumber {
    public static void abc(List<ID> ids) {
        List<String> busChassino = new List<String>();
        List<Bus__c> busses = [SELECT id, Name FROM Bus__c WHERE Id in :ids];
        for (Bus__c bus : busses) {
            busChassino.add(bus.Name);
        }
        system.debug('busChassino : '+busChassino);
    }

    @AuraEnabled
    public static EcardOperationlog xyz(string busChassino){
        EcardOperationlog log = new EcardOperationlog();
        AuthorisationData.Token tokendata = userAuthentication.getAccesstoken();
        system.debug('Line 15 '+ tokendata);
        string endpoint = System.Label.EcardAppendpoint+'api/ecardbychassisno/B199828';
        system.debug('Line 16 '+ endpoint);
        userAuthentication.ResponseWrapper statusresponse = userAuthentication.getData(endpoint+busChassino, 'GET', tokendata.access_token, tokendata.refresh_token);
        system.debug('Line 19 '+ statusresponse.responseBody); 
        system.debug('Line 19 '+ statusresponse.statusCode); 
        if(statusresponse.isError){
            log.isError = statusresponse.isError;
            log.operationlogresponse = statusresponse.responseBody;
            log.responsebody = statusresponse.responseBody;
            log.errorMessage = statusresponse.statusCode;
            if(statusresponse.statusCode == '401'){
                // Some error has happened
            }
            else{
                // Serious authentication error
            }
        }
        else{
            log.isError = statusresponse.isError;
            log.operationlogresponse = statusresponse.responseBody;
            log.responsebody = statusresponse.responseBody;
        }
        return log;
    }

    public class EcardOperationlog{
        @auraEnabled
        public boolean isError{get;set;}
        @auraEnabled
        public Object operationlogresponse{get;set;}
         @auraEnabled
        public string responsebody{get;set;}
        @auraEnabled
        public string errorMessage{get;set;}
    }
}