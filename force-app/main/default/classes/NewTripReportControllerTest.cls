/***********************************************************************************************************************************
     Developer :Suyati
     Name      : NewTripReportControllerTest
     Associated Apex Class:NewTripReportController
     Date      : October 2019   
************************************************************************************************************************************/ 
@isTest
public class NewTripReportControllerTest {
    @testSetup static void setup() {
        Account testAccount= TestDataFactory.createAccount();
        Trip_Report__c tripReport= TestDataFactory.createTripReport(testAccount.id);
        Account testAccount2= TestDataFactory.createAccount();
        Contact testContact1=new Contact(Left_Company__c=False, AccountId=testAccount.id,lastName='test1');
        insert testContact1;
        Contact testContact2=new Contact(Left_Company__c=False, AccountId=testAccount.id,lastName='test2');
        insert testContact2;
    }
     /***********************************************************************************************************************************
     Method Name  : fetchRecordsPositiveTest
    
     Method Tested  : fetchRecords(String,String,String,String) 
   ************************************************************************************************************************************/   
    @isTest static void fetchRecordsPositiveTest() {
        List<account> testAccount=[select id from account ];
        try{
            test.startTest();
            String [] fieldSets = new List<String>();
            fieldSets.add('Name');
            fieldSets.add('Internal_Name__c');
            List<NewTripReportController.RecordsDataWrapper> recordData= NewTripReportController.fetchRecords('Account', fieldSets, 'test Account', testAccount[0].id );
            test.stopTest();
            system.assertNotEquals(null, recordData) ;   
        }
        catch(exception e)
        {
            system.debug('Message'+e.getMessage());
        }
    }    
      /***********************************************************************************************************************************
     Method Name  : fetchRecordsNegative1Test
    
     Method Tested  : fetchRecords(String,String,String,String) 
   ************************************************************************************************************************************/   
    @isTest static void fetchRecordsNegative1Test() {
        try{
            test.startTest();
            String [] fieldSets = new List<String>();
            fieldSets.add('Name');
            fieldSets.add('Internal_Name__c');
            List<NewTripReportController.RecordsDataWrapper> recordData= NewTripReportController.fetchRecords('Account', fieldSets, 'test Account', null );
            test.stopTest();
            system.assertNotEquals(null,  recordData);
        }
        catch(exception e)
        {
            system.debug('Message'+e.getMessage());
        }
    }  
      /***********************************************************************************************************************************
     Method Name  : fetchRecordsNegative2Test
    
     Method Tested  : fetchRecords(String,String,String,String) 
   ************************************************************************************************************************************/   
    @isTest static void fetchRecordsNegative2Test() {
        try{
            test.startTest();
            String [] fieldSets = new List<String>();
            fieldSets.add('Name');
            fieldSets.add('Internal_Name__c');
            List<NewTripReportController.RecordsDataWrapper> recordData= NewTripReportController.fetchRecords('Account', fieldSets, 'test Account', null );
            test.stopTest();
            system.assertNotEquals(Null,  recordData);
        }
        catch(exception e)
        {
            system.debug('Message'+e.getMessage());
        }
    }    
       /***********************************************************************************************************************************
     Method Name  : getResultTest
    
     Method Tested  : getResult(String) 
   ************************************************************************************************************************************/   
    @isTest static void getResultTest() {
        List<account> testAccount=[select id from account];
        Trip_Report__c tripReport=[select id ,account_visited__c from Trip_Report__c where account_visited__c=:testAccount[0].id];
        try
        {
            test.startTest();
            NewTripReportController.tripDetailwrapper tripWrapper= NewTripReportController.getResult(testAccount[0].id);
            test.stopTest();
            system.assertEquals(testAccount[0].Id,tripReport.Account_Visited__c) ;
        }
        catch(exception e)
        {
            System.debug('Message'+e.getMessage());
        }
    }  
      /***********************************************************************************************************************************
     Method Name  : getResultNegativeTest
    
     Method Tested  : getResult(String) 
   ************************************************************************************************************************************/   
    @isTest static void getResultNegativeTest() {
        List<account> testAccount=[select id from account];
        try
        {
            test.startTest();
            NewTripReportController.tripDetailwrapper tripWrapper= NewTripReportController.getResult(testAccount[1].id);
            test.stopTest();
            system.assertNotEquals(null, tripWrapper.tripReport) ;
        }
        catch(exception e)
        {
            System.debug('Message'+e.getMessage());
        }
        
    }  
       /***********************************************************************************************************************************
     Method Name  : createTripReportTest
    
     Method Tested  : createTripReport(Trip_Report__c,list<contact>) 
   ************************************************************************************************************************************/  
    @isTest static void createTripReportTest() {
        List<account> testAccount=[select id from account];
        Trip_Report__c trip_report= new Trip_Report__c();
        trip_report.Account_Visited__c=testAccount[0].Id;
        trip_report.Date_of_Visit__c=System.today()+1; 
        list<contact> contactList=[select id,name from contact where AccountId =:testAccount[0].Id]; 
        try
        {
            test.startTest();
            Trip_Report__c  tripReport= NewTripReportController.createTripReport(trip_report,contactList);
            test.stopTest();
            TripContact__c tripContact=[select id,name,Visited__c from TripContact__c where TripContact__c=:contactList[0].id ];
            System.assertEquals(True, tripContact.Visited__c);
        }
        catch(exception e)
        {
            System.debug('Message'+e.getMessage());
        }
    }  
     /***********************************************************************************************************************************
     Method Name  : createTripReportNegative1Test
    
     Method Tested  : createTripReport(Trip_Report__c,list<contact>) 
   ************************************************************************************************************************************/  
    @isTest static void createTripReportNegative1Test() {
        try
        {
            List<account> testAccount=[select id from account];
            Trip_Report__c trip_report= new Trip_Report__c();
            trip_report.Account_Visited__c=testAccount[1].Id;
            trip_report.Date_of_Visit__c=System.today()+1; 
            list<contact> contactList=[select id,name from contact where AccountId =:testAccount[1].Id];
            test.startTest();
            Trip_Report__c  tripReport= NewTripReportController.createTripReport(trip_report,null);
            test.stopTest();
            TripContact__c tripContact=[SELECT Id, TripReport__c, Name FROM TripContact__c where TripReport__c=:tripReport.id];
            system.assertEquals(null, tripContact);
        }
        catch(Exception e)
        {
            System.debug('error');
        }
    } 
     /***********************************************************************************************************************************
     Method Name  : createTripReportNegative2Test
    
     Method Tested  : createTripReport(Trip_Report__c,list<contact>) 
   ************************************************************************************************************************************/  
    @isTest static void createTripReportNegative2Test() {
        try
        {
            List<account> testAccount=[select id from account];
            Trip_Report__c trip_report= new Trip_Report__c();
            trip_report.Account_Visited__c=testAccount[0].Id;
            test.startTest();
            Trip_Report__c  tripReport= NewTripReportController.createTripReport(trip_report,null);
            test.stopTest();
            system.assertEquals(null, tripReport.id);
        }
        catch(Exception e)
        {
            System.debug('error'+e.getMessage());
        }
    } 
      /***********************************************************************************************************************************
     Method Name  : getcreatedcontactTest
    
     Method Tested  : getcreatedcontact(String) 
   ************************************************************************************************************************************/  
    @isTest static void getcreatedcontactTest() {
        List<account> testAccount=[select id from account];
        contact testContact=[select id,name from contact where AccountId =:testAccount[0].id limit 1];  
        try
        {
            test.startTest();
            contact queryContact=NewTripReportController.getcreatedcontact(testContact.id);
            test.stopTest();
            system.assertEquals(testContact,queryContact ) ;
        } catch(exception e)
        {
            System.debug('error'+e.getMessage());
        }
    }  
      /***********************************************************************************************************************************
     Method Name  : getRecordtypeTest
    
     Method Tested  : getRecordtypeId() 
   ************************************************************************************************************************************/  
    @isTest  static  void getRecordtypeTest()
    {
        try{
            Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            test.startTest();
            String recordType=NewTripReportController.getRecordtypeId();
            test.stopTest();
            system.assertEquals(RecordTypeIdContact,recordType);
        }
        catch(Exception e)
        {
            System.debug('error');
        }
    }
}