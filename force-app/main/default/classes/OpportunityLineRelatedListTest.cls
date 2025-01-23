/***********************************************************************************************************************************
     Developer :Suyati
     Name      : OpportunityLineRelatedListTest
     Associated Apex Class:OpportunityLineRelatedList
     Date      : October 2019   
************************************************************************************************************************************/ 
@isTest
public class OpportunityLineRelatedListTest {
@testsetup
    static void setup(){
       Account testAccount= TestDataFactory.createAccount();
        Trip_Report__c tripReport= TestDataFactory.createTripReport(testAccount.id);     
        Opportunity testOpportunity = new Opportunity(
           StageName = 'Sourcing Demand',
            AccountId  = testAccount.Id,
            Name = 'Test Opportunity',
            Type='Existing Business',
            Order_Probability__c = '1. High Probability',
            CloseDate=date.today()
        );
        insert testOpportunity;
        Opportunity_line__c opportunityLine = new Opportunity_line__c();
        opportunityLine.Opportunity_Line__c=testOpportunity.Id;
        opportunityLine.Name='Opportunity test';
        opportunityLine.Mode__c='Diesel';
        opportunityLine.Length__c= '40';
        opportunityLine.Style__c='Low Floor BRT';
        opportunityLine.Quantity__c= 1;
        insert opportunityLine;
    }
    
    /***********************************************************************************************************************************
     Method Name  : getOpportunityLinesTest
    
     Method Tested  : getOpportunityLinesTest(String) 
   ************************************************************************************************************************************/   
    static testMethod void getOpportunityLinesTest()
    {
        Account testAccount=[select id from account ];
        Trip_Report__c trip_report=[select id from Trip_Report__c where Account_Visited__c=:testAccount.id];
        try{
            test.startTest();
            List<Opportunity_Line__c> opportunityLine=OpportunityLineRelatedList.getOpportunityLines(trip_report.Id);    
            List<Opportunity_Line__c> opportunityLine2=OpportunityLineRelatedList.getOpportunityLines(null); 
            test.stopTest();
            system.assertEquals(true, opportunityLine.size()>0);
            system.assertEquals(false, opportunityLine2.size()>0);

        }
        catch(exception e)
        {
            system.debug('Message'+e.getMessage());
        }
    }
     
}