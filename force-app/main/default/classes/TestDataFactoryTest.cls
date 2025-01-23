/***********************************************************************************************************************************
Developer :Suyati
Name      : TestDataFactoryTest
Associated Apex Class:TestDataFactory
Date      : October 2019   
************************************************************************************************************************************/ 
@isTest
public class TestDataFactoryTest {
    /***********************************************************************************************************************************
Method Name  : createAccountTest
Method Tested  : createAccount() 
************************************************************************************************************************************/   
    static testMethod void createAccountTest() {
        test.startTest();
        Account TestAccount = TestDataFactory.createAccount();
        test.stopTest();
        List<Account> QueryAccount = [select id,name from account  where  id=:TestAccount.id];
        system.assertEquals(true , QueryAccount.size()>0);
    }
    /***********************************************************************************************************************************
Method Name  : createTripReportTest
Method Tested  : createTripReport(String) 
************************************************************************************************************************************/   
    static testMethod void createTripReportTest() {
        test.startTest();
        Account TestAccount = TestDataFactory.createAccount();
        Trip_Report__c TestTripReport=TestDataFactory.createTripReport(TestAccount.id);
        test.stopTest();
        Trip_Report__c TripReport = [select id,Account_Visited__c,Account_Visited__r.name from Trip_Report__c where Account_Visited__c = :TestAccount.id];
        Account queryAccount=[select id, name from Account];
        system.assertEquals(queryAccount.name , TripReport.Account_Visited__r.name);
    }
}