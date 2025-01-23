/***********************************************************************************************************************************
     Developer :Suyati
     Name      : ContactVisitedComponentControllerTest
     Associated Apex Class:ContactVisitedComponentController
     Date      : October 2019   
************************************************************************************************************************************/ 
@isTest
public class ContactVisitedComponentControllerTest {
    @testsetup
    static void setup(){
        Account testAccount= TestDataFactory.createAccount();
        Trip_Report__c tripReport= TestDataFactory.createTripReport(testAccount.id);
        Contact testCon= new Contact();
        testCon.LastName='TestContact';
        testCon.AccountId=testAccount.Id;
        testCon.Left_Company__c=False;
        insert testCon;
        Contact testContact= new Contact();
        testContact.LastName='TestContact2';
        testContact.AccountId=testAccount.Id;
        testContact.Left_Company__c=False;
        insert testContact;
        TripContact__c tripCon = new TripContact__c();
        tripCon.TripContact__c=testCon.Id;
        tripCon.TripReport__c=tripReport.Id;
        tripCon.visited__c=true;
        insert tripCon;
        
    }
    /***********************************************************************************************************************************
     Method Name  : getrecordTypeTest
    
     Method Tested  : getrecordTypeId() 
   ************************************************************************************************************************************/   
    static testMethod void getrecordTypeTest()
    {
        Id recordType=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        try{
            string tripReportId=[select id from Trip_Report__c].Id;   
            test.startTest();
            string recordtypeId= ContactVisitedComponentController.getRecordtypeId();
            test.stopTest();
            system.assertEquals(recordType, recordtypeId);            
        }
        catch(exception e)
        {
            system.debug('Message'+e.getMessage());
        }
    }
    /***********************************************************************************************************************************
     Method Name  : getTripContactsTest
    
     Method Tested  : getTripContacts(Id) 
   ************************************************************************************************************************************/   
    static testMethod void getTripContactsTest()
    {
        Account testaccount=[select id from Account];
        try{
            string tripReportId=[select id from Trip_Report__c].Id;   
            test.startTest();
            list<ContactVisitedComponentController.VisitedContactWrapper> visitedWrapper=ContactVisitedComponentController.getTripContacts(tripReportId);
            test.stopTest();
            system.assertEquals(testaccount.id, visitedWrapper[0].accountId);  
            System.assertEquals(true,visitedWrapper[0].isVisited);
        }
        catch(exception e)
        {
            system.debug('Message'+e.getMessage());
        }
    }
    /***********************************************************************************************************************************
     Method Name  : createTripContactTest
    
     Method Tested  : createTripContact(String,String) 
   ************************************************************************************************************************************/   
    static testMethod void createTripContactTest()
    {
        string tripReportId=[select id from Trip_Report__c].Id;
        string contactId=[select id from Contact where LastName='TestContact2' limit 1].Id;
        string accountId=[select id from Account].Id;    
        string tripContactId=[select id from TripContact__c].Id;
        string jsonContactList1 = '[{"accountId":"'+accountId+'","contactId":"'+contactId+'","contactName":"Jeffrey T Starr","email":"jstarr@a1limo.com","isVisited":true,"mobilePhone":"609-865-2250","phone":"609-919-2003","tripContactId":"'+tripContactId+'","tripReportId":"'+tripReportId+'"}]';
        string jsonContactList2 = '[{"accountId":"'+accountId+'","contactId":"'+contactId+'","contactName":"Jeffrey T Starr","email":"jstarr@a1limo.com","isVisited":true,"mobilePhone":"609-865-2250","phone":"609-919-2003","tripReportId":"'+tripReportId+'"}]'; 
        string jsonContactList3 = '[{"accountId":"'+accountId+'","contactId":"'+contactId+'","contactName":"Jeffrey T Starr","email":"jstarr@a1limo.com","isVisited":false,"mobilePhone":"609-865-2250","phone":"609-919-2003","tripReportId":"'+tripReportId+'"}]'; 
         try{
            test.startTest();
            list<ContactVisitedComponentController.VisitedContactWrapper>  visitedWrapper1=ContactVisitedComponentController.createTripContact(jsonContactList1,tripReportId);
            list<ContactVisitedComponentController.VisitedContactWrapper>  visitedWrapper2=ContactVisitedComponentController.createTripContact(jsonContactList2,tripReportId);
            list<ContactVisitedComponentController.VisitedContactWrapper>  visitedWrapper3=ContactVisitedComponentController.createTripContact(jsonContactList3,tripReportId);
            list<ContactVisitedComponentController.VisitedContactWrapper>  visitedWrapper4=ContactVisitedComponentController.createTripContact(jsonContactList2,null);
            test.stopTest();
            system.assertNotEquals(null, visitedWrapper1[0].tripContactId);
            system.assertEquals(accountId, visitedWrapper2[0].accountId);
            system.assertNotEquals(null, visitedWrapper3[0].tripReportId);     
            system.assertEquals(null, visitedWrapper4[0].tripReportId); 
        }
        catch(exception e)
        {
            system.debug('Message'+e.getMessage());
        }
    }
}