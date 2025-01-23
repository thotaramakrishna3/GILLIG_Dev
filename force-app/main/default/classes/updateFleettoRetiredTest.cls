@isTest (seeAlldata=false)
public class updateFleettoRetiredTest {
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

    static testmethod void testUpdateBus () {
        init();
        
        test.startTest();
        
        // First of 2 busses created by trigger. Set it to retired
        Bus__c bus1 = [select Name, Fleet__c, Retired__c  from Bus__c where Name = '123456'];
        bus1.Retired__c = true;
        update bus1;
        
        // Get the fleet associated with the bus and check if fleet is not retired. Shouldn't be since second bus is active
        Fleet__c aFleet = [select id, Name, Retired__c from fleet__c where id = :bus1.Fleet__c];
        system.assert(!aFleet.Retired__c);
        
        // Get the second bus and retire it.
        Bus__c bus2 = [select Name, Fleet__c, Retired__c  from Bus__c where Name = '123457'];
        bus2.Retired__c = true;
        update bus2;

        // Get the fleet associated with the second bus. It should now be retired since all busses are retired.
        Fleet__c rFleet = [select id, Name, Quantity__c, Retired__c from fleet__c where id = :bus2.Fleet__c];
        
        List<Bus__c> fbus = [select id, name, Retired__c from Bus__c where Fleet__c = :rFleet.Id];

        system.assert(rFleet.Retired__c);        
        
        test.stopTest();
    }

    static testmethod void testMatchFleet () {
        init();

        account nAccount = new account(Name='New Test Account', Owner = rRep, Project_Sales_Manager__c = pRep.Id, Internal_Name__c = 'test2, st2');
        insert nAccount;

        test.startTest();
        
       // Get the second bus created by trigger. Set to new account where there is a matching fleet
        Bus__c bus2 = [select Id, Name, Fleet__c, Current_Owner__c  from Bus__c where Name = '123457'];

        Fleet__c oldeFleet = [Select OwnerID, RecordTypeID, Name, Sales_Order__c,
                                     	Account__c, Competitor__c, Start_Date__c, Competitor_Date_Delivered__c, Length_GILLIG__c,
                                     	Length_Competitor__c, Mode__c, Active_Quantity_Competitor__c, Retired__c,
                                     	Style_GILLIG__c, Style_Competitor__c from Fleet__c where ID = :bus2.Fleet__c];

//        Fleet__c newbeFleet = oldeFleet.clone(false, false, false, false);
		Fleet__c newbeFleet = new Fleet__c( Account__c = nAccount.Id, OwnerID=oldeFleet.ownerid, 
											RecordTypeID=oldeFleet.recordtypeid, Name=oldeFleet.name, 
											Sales_Order__c=oldeFleet.Sales_Order__c,Competitor__c=oldeFleet.Competitor__c,
											Start_Date__c=oldeFleet.Start_Date__c, 
											Competitor_Date_Delivered__c=oldeFleet.Competitor_Date_Delivered__c, 
											Length_GILLIG__c=oldeFleet.Length_GILLIG__c,
                                     		Length_Competitor__c=oldeFleet.Length_Competitor__c, 
                                     		Mode__c=oldeFleet.Mode__c, 
                                     		Active_Quantity_Competitor__c=oldeFleet.Active_Quantity_Competitor__c, 
                                     		Retired__c=oldeFleet.Retired__c,
                                     		Style_GILLIG__c=oldeFleet.Style_GILLIG__c, 
                                     		Style_Competitor__c=oldeFleet.Style_Competitor__c );
//        newbeFleet.Account__c = nAccount.Id;
        insert newbefleet;        
       	integer newbebus = [select count() from Bus__c where Fleet__c = :newbefleet.ID];

		bus2.Current_Owner__c = nAccount.Id;
        update bus2;
        
        Bus__c newBus2 = [Select ID, Name, Fleet__c, Current_Owner__c from Bus__c where id = :bus2.Id];

        system.assertEquals(newbefleet.Id, newBus2.Fleet__c);
         
        test.stopTest();
    }    
}