@isTest (seeAllData=false)
public class listOppDiscussedTest {

    public static account tAccount;
    public static opportunity tOpportunity;
    public static Trip_Report__c tTrip;
    
    public static ID objId;
    
    public static void init() {
        tAccount = new account (Name='Test Account');
        insert tAccount;
        system.debug(tAccount);
        tOpportunity = new opportunity (AccountID=tAccount.ID,Name='Test Opp',StageName='Forecast', 
                                                    Type = 'Existing Business', Order_Probability__c = '1. High Probability',
                                                    CloseDate=system.today());
		insert tOpportunity;
        system.debug(tOpportunity);
        tTrip = new Trip_Report__c(Account_Visited__c=tAccount.ID, Date_of_Visit__c=system.today());
        insert tTrip;
		system.debug(tTrip);
        objId = tTrip.ID;
        system.debug(objId);
    }

    public static testmethod void testOppDiscussed() {
        init();
        Test.startTest();
        
        listOppDiscussed cOppD = new listOppDiscussed();
        cOppD.objId = objId;
        cOppD.getlistOppDiscussed();
        
        system.debug(cOppD);
        
        system.assertEquals(tOpportunity.ID, cOppD.op.ID);
        system.assertEquals(Null, cOppd.ODList);
        system.assertEquals(Null, cOppd.tOpp);
        
        Test.stopTest();

    }
}