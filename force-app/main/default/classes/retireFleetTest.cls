@istest (seeAlldata=false)
public class retireFleetTest {
    
    static List<Opportunity_Line__c> tOppLine;
    static Account tAccount;
    
    static void init() {
        
        User rRep;
        User pRep;
        
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
        tAccount = new account(Name='Test Account', Owner = rRep, Project_Sales_Manager__c = pRep.Id, Internal_Name__c = 'test, st'
                             );
        insert tAccount;
        
        recordtype rType = [select id from recordtype where Name = 'GILLIG' and SOBJECTTYPE = 'Customer_Contract__c' limit 1];

        Customer_Contract__c cContract = new Customer_Contract__c (name = 'Test Contract', ownerid = rRep.Id, RecordTypeID = rType.ID,
                                                                  Lead_Agency__c = tAccount.Id, Project_Sales_Manager__c = pRep.Id,
                                                                  Bid_Status__c = 'Bid', Bid_Stage__c = 'Award GILLIG', Bid_Submission_Type__c = 'Email');
        insert cContract;

        opportunity tOpportunity = new opportunity (AccountID=tAccount.ID,Name='Test Opp',StageName='Forecast', Reference_Contract__c=cContract.id,
                                                    Type = 'Existing Business', Order_Probability__c = '1. High Probability',
                                                    CloseDate=system.today(), ownerid = rRep.Id);
        insert tOpportunity;
        
        tOppLine = new List<Opportunity_Line__c>();
        // Opportunity line with Date Booked when record created
        tOppLine.add(new Opportunity_Line__c (Opportunity_Line__c = tOpportunity.Id, 
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

    }

    static testmethod void retireFleet () {
        
        init();

        test.startTest();
        set<Id> toppId = new set<Id>();
        for (Opportunity_Line__c t:tOppLine) {
            toppId.add(t.Id);
        }
        List<Opportunity_Line__c> topp = [select Id, Fleet__c from Opportunity_Line__c where Id in :toppId];
        Fleet__c newFleet = [select Id, Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c 
                                     from Fleet__c where Id=:tOpp[0].Fleet__c];

        Fleet__c uFleet = [select id, Account__c, Retired__c from Fleet__c where Id=:newFleet.Id];
        uFleet.Retired__c = true;
        update uFleet;

        // check that the Fleet was retired
        Fleet__c resultingFleet = [select id, Account__c, Retired__c from Fleet__c where Id=:newFleet.Id];
        system.assertEquals(true, resultingFleet.Retired__c);

        // Check that the busses retired too
        List<Bus__c> resultingBus = [select ID, Name, Fleet__c, Sales_Order__c, Retired__c from Bus__c where Fleet__c = :resultingFleet.Id];

        for (Bus__c rBus:resultingBus) {
                    system.assertEquals(true, rBus.Retired__c);
        }
        test.stopTest();
    }
}