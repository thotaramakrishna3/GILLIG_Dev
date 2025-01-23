@isTest (seeAlldata=false) 
public class updateBusTest {
    
    static user rRep;
    static user pRep;
    
    static void init () {

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
        account tAccount = new account(Name='Test Account', Owner = rRep, Project_Sales_Manager__c = pRep.Id, Internal_Name__c = 'test, st'
                             );
        insert tAccount;
        opportunity tOpportunity = new opportunity (AccountID=tAccount.ID,Name='Test Opp',StageName='Forecast', 
                                                    Type = 'Existing Business', Order_Probability__c = '1. High Probability',
                                                    CloseDate=system.today(),  ownerid = rRep.Id);
		insert tOpportunity;

        recordtype rType = [select id from recordtype where Name = 'GILLIG' and SOBJECTTYPE = 'Customer_Contract__c' limit 1];

        Customer_Contract__c cContract = new Customer_Contract__c (name = 'Test Contract', ownerid = rRep.Id, RecordTypeID = rType.ID,
                                                                  Lead_Agency__c = tAccount.Id, Project_Sales_Manager__c = pRep.Id,
                                                                  Bid_Status__c = 'Bid', Bid_Stage__c = 'Award GILLIG', Bid_Submission_Type__c = 'Email');
        insert cContract;      

        List<Opportunity_Line__c> tOppLine = new List<Opportunity_Line__c>();
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
        createSO.insertSO(tOppLine);
    }
    
    static testmethod void testOwnerChange () {
        init();
        
        account nAccount = new account(Name='New Test Account', Owner = rRep, Project_Sales_Manager__c = pRep.Id, Internal_Name__c = 'test2, st2');
        insert nAccount;
        
        test.startTest();

        // First of 2 busses created by trigger. Set it to new account where there is not a matching Fleet
        Bus__c bus1 = [select Name, Fleet__c, Current_Owner__c from Bus__c where Name = '123456'];
        bus1.Current_Owner__c  = nAccount.id;
        update bus1;

        Bus__c bus1u = [select Name, Fleet__c, Current_Owner__c from Bus__c where Name = '123456'];
        Fleet__c chngFleet = [Select ID, Account__c from Fleet__c where Account__c = :nAccount.Id];
        Bus__c newBus1 = [Select ID, Name, Fleet__c from Bus__c where Fleet__c = :chngFleet.Id];
        system.assertEquals(bus1u.Fleet__c, newBus1.Fleet__c);
               
        test.stopTest();
    }
}