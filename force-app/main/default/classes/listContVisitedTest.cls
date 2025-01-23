@isTest (seeAllData=false)
private class listContVisitedTest {

    public static account tAccount;
    public static contact tContact;
    public static Trip_Report__c tTrip;
    private static list<contact> tconts;
    
    public static ID objId;
    
    static void init() {
        tAccount = new account (Name='Test Account');
        insert tAccount;
        system.debug(tAccount);

        tconts = new List<Contact>();
        for (Integer i = 0; i < 101; i++) {
            tconts.add(new contact (AccountID=tAccount.ID,FirstName='Test - '+i.format(),
                                    LastName='Contact'+i.format()));
        }
        insert tconts;

        tTrip = new Trip_Report__c(Account_Visited__c=tAccount.ID, Date_of_Visit__c=system.today());
        insert tTrip;
		system.debug(tTrip);
        objId = tTrip.ID;
        system.debug(objId);
    }
    
    public static testMethod void testContVisited () {
        init();
        Test.startTest();
		
        listContVisited cVisit = new listContVisited();
        cVisit.objId = objId;
        cVisit.getlistContVisited();

        system.debug(cVisit);
        
        Test.stopTest();
        
    }
}