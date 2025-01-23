/***********************************************************************************************************************************
     Developer :Suyati
     Name      : TripReporttriggertest
     Associated Trigger:TripReportTrigger
     Date      : October 2019   
************************************************************************************************************************************/
@isTest
public class TripReporttriggertest {
/***********************************************************************************************************************************
     Method Name  : tripReport_test
************************************************************************************************************************************/  
    static testmethod void tripReport_test()
    {
        Account testAccount = TestDataFactory.createAccount();
        Trip_Report__c tripReport = TestDataFactory.createTripReport(testAccount.id);
        Opportunity opp = new Opportunity(Name='test opp',AccountId=testAccount.Id,StageName='Forecast',Type='Existing Business',Order_Probability__c = '1. High Probability',CloseDate=System.today());
        insert opp;
        tripReport.Artic_Bus_Plans__c = 'No 62 ft. bus interest';
        tripReport.Status__c = 'Final';
        tripReport.Date_of_Visit__c = System.today()-3;
        test.startTest();
        update tripReport;
        test.stopTest();
        Account queryAccount = [select id ,Artic_Bus_Plans__c from Account];
        system.assertEquals('No 62 ft. bus interest' , queryAccount.Artic_Bus_Plans__c);
    }
}