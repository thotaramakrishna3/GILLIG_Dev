public class UploadBusPdf {
    @InvocableMethod(label='Get Bus details' description='Get the list of Buses corresponding to the specified account IDs.' category='Bus__c')
    public static void getBuses(List<ID> ids) {
        system.debug('starting UploadBusPdf------');
        List<String> busChassino = new List<String>();
        List<Bus__c> busses = [SELECT id, Name FROM Bus__c WHERE Id in :ids];
        for (Bus__c bus : busses) {
            busChassino.add(bus.Name);
            UploadBusPdf.uploadGeneratedBusPdf(bus.Name);
        }
        system.debug('busChassino : '+busChassino);
    }
    
    @future(callout=true)
    public static void uploadGeneratedBusPdf(String busChassisNumber){        
        try{
            AuthorisationData authData = EcardPdfAutomationController.EcardLogin();
            System.debug('chassis before trim : '+busChassisNumber);           
            busChassisNumber = EncodingUtil.urlEncode(busChassisNumber.trim(), 'UTF-8').replace('+', '%20');
            if(busChassisNumber.length() == 5){
                busChassisNumber = 'B0' + busChassisNumber;
            }else{
                busChassisNumber = 'B' + busChassisNumber;
            } 
            String endpoint = System.Label.EcardAppendpoint+'api/inspection_report/'+busChassisNumber;
            System.debug('chassis after trim : '+busChassisNumber);
            System.debug('Inside the uploadGeneratedPdf method');
            System.debug('Bus Chassis Number : '+busChassisNumber);
            System.debug('uploadGeneratedBusPdf End point: '+endpoint);
            System.debug('Auth token : '+authData.data.token.access_token);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndPoint(endpoint);
            System.debug('1');
            request.setMethod('GET');
            System.debug('2');
            request.setTimeout(50000);
            System.debug('3');
            String authorizationHeader = 'Bearer ' + authData.data.token.access_token;
            System.debug('Access token :' +authorizationHeader);
            request.setHeader('Authorization', authorizationHeader);
            HttpResponse response = http.send(request);
            System.debug('uploadGeneratedBusPdf status code :'+response.getStatusCode());
            if(response.getStatusCode() == 200){
                System.debug(response.getBody());
                if(response.getBody()!=null){
                    InspectionResponseWrapper wrpObj = InspectionResponseWrapper.parse(response.getBody());
                    System.debug('Status : '+ wrpObj.data.upload_status);
                    System.debug('Bus Chassis Number : '+wrpObj.data.chassis_no);
                }
                
            }
            else if(response.getStatusCode() == 401){              
                System.debug('Authorisation error :');
            }
            else{
                System.debug('Exception occured for Chassis :'+busChassisNumber);
                
            }
        }
        catch(Exception ex){
            System.debug('Exception occured in try block');
            System.debug(ex.getMessage());            
        }
        
    }
    
    @AuraEnabled
    public static EcardGreenSheetlog getBusGreensheetLink(String chassis_no){
        AuthorisationData.Token tokendata = userAuthentication.getAccesstoken();
        string endpoint = System.Label.EcardAppendpoint+'api/inspection_link_v2/';
        userAuthentication.ResponseWrapper statusresponse = userAuthentication.getData(endpoint+chassis_no, 'GET', tokendata.access_token, tokendata.refresh_token);
        System.debug('statusresponse :'+endpoint+chassis_no);
        EcardGreenSheetlog log = new EcardGreenSheetlog();
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
            log.operationlogresponse = statusresponse.responseBody;
            log.responsebody = statusresponse.responseBody;
        }
        return log;
    }

    @AuraEnabled(cacheable = true)
    public static Bus__c getBusData(String recordBusId){
        Bus__c bus = [SELECT Name, Internal_Name__c from Bus__c where Id=: recordBusId LIMIT 1];
        System.debug('Inside---1');
        return bus;
    }

    public class EcardGreenSheetlog{
        @auraEnabled
        public boolean isError{get;set;}
        @auraEnabled
        public Object operationlogresponse{get;set;}
         @auraEnabled
        public string responsebody{get;set;}
        @auraEnabled
        public string statusCode{get;set;}
    }
}