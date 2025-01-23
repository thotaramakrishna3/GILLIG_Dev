@isTest (seeAlldata=true)
public class updatesfromTripTest {
    
    static user rRep;
    static user pRep;
    static account tAccount;
    static account preUpd;
    static account postUpd;
    static Trip_Report__c TripReport;
    static Opportunity commentOpp;
    static Opportunity nocommentOpp;
    static TripOpportunity__c oppDiscussed;

    static void init(){
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        system.runAs(thisUser) {
            Profile p = [SELECT Id FROM Profile WHERE Name='Regional Sales Manager'];
            rRep = new user(LastName = 'National Sales Rep', Username = 'NationalSales.User@example.com', Email = 'NationalSales.User@example.com', 
                        Alias = 'rRep', CommunityNickname = 'rRep', 
                        TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                       	EmailEncodingKey = 'ISO-8859-1', ProfileId = p.ID,
                       	LanguageLocaleKey = 'en_US');
            insert rRep;
            Profile pm = [SELECT Id FROM Profile WHERE Name='Project Sales Manager'];
            pRep = new user(LastName = 'Project Sales Rep', Username = 'ProjectSales.User@example.com', Email = 'ProjectSales.User@example.com', 
                        Alias = 'pRep', CommunityNickname = 'pRep', 
                        TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                        EmailEncodingKey = 'ISO-8859-1', ProfileId = pm.ID,
                        LanguageLocaleKey = 'en_US');
            insert pRep;
        }
        tAccount = new account(Name='Test Account', Internal_Name__c='Test, Ca', 
                                OwnerId = rRep.Id, Project_Sales_Manager__c = pRep.Id,
                                Artic_Bus_Plans__c = 'Artic plan', 
                                Electric_Bus_Plans__c = 'Electric Plan', Fleet_Performance_Updates__c = 'Fleet Perf Plan', 
                                Fleet_Replacement_Plans__c= 'Fleet Repl Plan');
        insert tAccount;
        List<Contact> tconts = new List<Contact>();
        for (Integer i = 0; i < 101; i++) {
            tconts.add(new contact (AccountID=tAccount.ID,FirstName='Test - '+i.format(),
                                    LastName='Contact'+i.format()));
        }
        insert tconts;
        commentOpp = new opportunity(AccountID = tAccount.Id, Name='Opp with comment',StageName='Forecast', 
                                                    Type = 'Existing Business', Order_Probability__c = '1. High Probability',
                                                    CloseDate=system.today());
        insert commentOpp;
        nocommentOpp = new opportunity(AccountID = tAccount.Id, Name='Opp without comment',StageName='Forecast', 
                                                    Type = 'Existing Business', Order_Probability__c = '1. High Probability',
                                                    CloseDate=system.today());
        insert nocommentOpp;
        TripReport = new Trip_Report__c(Account_Visited__c=tAccount.Id, Date_of_Visit__c=system.today());
        insert TripReport;
        oppDiscussed = [select TripReport__c, Opportunity__c, Comments__c 
                                               from TripOpportunity__c where TripReport__c=:TripReport.Id AND Opportunity__c =:commentOpp.Id ];
        oppDiscussed.Comments__c = 'Test comment';
        update oppDiscussed;

        recordtype rType = [select id from recordtype where Name = 'GILLIG' and SOBJECTTYPE = 'Customer_Contract__c' limit 1];

        Customer_Contract__c cContract = new Customer_Contract__c (name = 'Test Contract', ownerid = rRep.Id, RecordTypeID = rType.ID,
                                                                  Lead_Agency__c = tAccount.Id, Project_Sales_Manager__c = pRep.Id,
                                                                  Bid_Status__c = 'Bid', Bid_Stage__c = 'Award GILLIG', Bid_Submission_Type__c = 'Email');
        insert cContract;
        
        // Opportunity line with Date Booked when record created
        List<Opportunity_Line__c> tOppLine = new List<Opportunity_Line__c>();
        tOppLine.add(new Opportunity_Line__c (Opportunity_Line__c = commentOpp.Id, 
                                            Quantity__c = 2,
                                            Serial_Number__c = '123456',
                                            Date_Booked__c = system.today(), 
                                            Mode__c = 'Diesel',
                                            PO_Amount__c = 150, 
                                            PO_Date__c = system.today(), 
                                            PO_Reference__c = 'Test PO',
                                            Quoted_Price__c = 100, 
                                            Reference_Contract__c = cContract.Id,
                                            Style__c = 'LF',
                                            Length__c = '40',
                                            Start_Date__c = system.today()));

        insert tOppLine;
        createSO.insertSO(tOppLine);
        list<Sales_Order__c> resultingSO = new list<Sales_Order__c>([select id, Name  from Sales_Order__c where Name = :tOppLine[0].Serial_Number__c]);

    }
    
    static testmethod void testAcctUpdate (){
        init();
        
        test.startTest();
        
        preUpd = [select ID, Artic_Bus_Plans__c, 
                               Electric_Bus_Plans__c, Fleet_Performance_Updates__c, 
                               Fleet_Replacement_Plans__c from account where id=:tAccount.Id];
        
        system.assertEquals('Artic plan', preUpd.Artic_Bus_Plans__c);
        system.assertEquals('Electric Plan', preUpd.Electric_Bus_Plans__c);
        system.assertEquals('Fleet Perf Plan', preUpd.Fleet_Performance_Updates__c);
        system.assertEquals('Fleet Repl Plan', preUpd.Fleet_Replacement_Plans__c);
        
        Trip_Report__c Trip = [select ID, Name, Account_Visited__c, OwnerID, Status__c,Artic_Bus_Plans__c,Electric_Bus_Plans__c,
                                Fleet_Performance__c, Fleet_Replacement_Plans__c 
                                from Trip_Report__c where id = :TripReport.id];

        Trip.Status__c = 'Final';
        Trip.Artic_Bus_Plans__c = 'Artic_Bus_Plans__c';
        Trip.Electric_Bus_Plans__c = 'Electric_Bus_Plans__c';
        Trip.Fleet_Performance__c = 'Fleet_Performance__c';
        Trip.Fleet_Replacement_Plans__c = 'Fleet_Replacement_Plans__c';

        update Trip;
        
        postUpd = [select ID, Artic_Bus_Plans__c, 
                               Electric_Bus_Plans__c, Fleet_Performance_Updates__c, 
                               Fleet_Replacement_Plans__c from account where id = :tAccount.Id];
        system.assertNotEquals('Artic plan', postUpd.Artic_Bus_Plans__c);
        system.assertNotEquals('Electric Plan', postUpd.Electric_Bus_Plans__c);
        system.assertNotEquals('Fleet Perf Plan', postUpd.Fleet_Performance_Updates__c);
        system.assertNotEquals('Fleet Repl Plan', postUpd.Fleet_Replacement_Plans__c);
        system.assertEquals('Artic_Bus_Plans__c', postUpd.Artic_Bus_Plans__c);
        system.assertEquals('Electric_Bus_Plans__c', postUpd.Electric_Bus_Plans__c);
        system.assertEquals('Fleet_Performance__c', postUpd.Fleet_Performance_Updates__c);
        system.assertEquals('Fleet_Replacement_Plans__c', postUpd.Fleet_Replacement_Plans__c);
            
        test.stopTest();
    }
}