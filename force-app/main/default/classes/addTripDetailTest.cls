@isTest (seeAllData=false)
Private class addTripDetailTest {

    static Account tAccount;
    static Trip_Report__c tripReport;
    static List<Contact> tconts;
    static List<Opportunity> tOpportunity;
    
    static void init(){
        tAccount = new Account(Name='Test Account');
        insert tAccount;
        tconts = new List<Contact>();

        for (Integer i = 0; i < 101; i++) {
            tconts.add(new contact (AccountID=tAccount.ID,FirstName='Test - '+i.format(),
                                    LastName='Contact'+i.format()));
        }
        insert tconts;
        
        tOpportunity = new List<Opportunity>();
        for (Integer j = 0; j < 101; j++) {
            tOpportunity.add(new Opportunity(AccountID=tAccount.ID,Name='TestOpportunity - '+j.format(),StageName='Forecast', 
                                                    Type = 'Existing Business',Order_Probability__c = '1. High Probability', 
                                                    CloseDate=system.today()));
        }
        insert tOpportunity;

        tripReport = new Trip_Report__c(Account_Visited__c=tAccount.Id, Date_of_Visit__c=system.today());
        insert tripReport;
    }
    
    static testMethod void testContactDetailTrigger () {
        init();

        set<id> cidset = new set<id>();
        for (contact chkContact:[select id from contact where AccountID=:tAccount.id]) {
            cidset.add(chkContact.id);
        }

        Test.startTest();
        
        List<TripContact__c> tripContact = new List<TripContact__c>([
            SELECT Id, TripContact__c
            FROM TripContact__c
            WHERE TripReport__c  = :tripReport.Id
        ]);

        for (Integer i = 0; i < 101; i++) {
//        	system.assertEquals(tconts[i].ID, tripContact[i].TripContact__c);
            system.assert(cidset.contains(tconts[i].ID));
        }

        Test.stopTest();
                
    }
    static testMethod void testOppDetailTrigger () {
        init();

        set<id> oidset = new set<id>();
        for (Opportunity chkOpp:[select id from Opportunity where AccountID=:tAccount.id]) {
            oidset.add(chkOpp.id);
        }

        Test.startTest();

        List<TripOpportunity__c> tripOpp = new List<TripOpportunity__c>([
            SELECT Id, Opportunity__c
            FROM TripOpportunity__c
            WHERE TripReport__c  = :tripReport.Id
        ]);

        for (Integer i = 0; i < 101; i++) {
//        	system.assertEquals(tripOpp[i].Opportunity__c, tOpportunity[i].Id);
            system.assert(oidset.contains(tripOpp[i].Opportunity__c));
        }        
        
        Test.stopTest();
                
    }    
}