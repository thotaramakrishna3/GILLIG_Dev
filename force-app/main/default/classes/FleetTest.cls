@isTest
private class FleetTest
{

	static Opportunity tOpportunity;
    static Customer_Contract__c cContract;
    static Account tAccount;
    static User rRep;
    static User pRep;
    static List<Opportunity_Line__c> tOppLine;
    static Schema.RecordTypeInfo busFirmRecordType;
    static Schema.RecordTypeInfo busTBSRecordType;
    static Schema.RecordTypeInfo busScheduledRecordType;
    static Schema.RecordTypeInfo busReservedRecordType;
    static Schema.RecordTypeInfo busForecastedRecordType;

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
        tAccount = new account(Name='Test Account', Owner = rRep, Internal_Name__c = 'test, st',
                             Project_Sales_Manager__c = pRep.Id);
        insert tAccount;
        
        tOpportunity = new opportunity (AccountID=tAccount.ID,Name='Test Opp',StageName='Forecast', 
                                                    Type = 'Existing Business', Order_Probability__c = '1. High Probability',
                                                    CloseDate=system.today(), ownerid = rRep.Id);
        insert tOpportunity;
       
        recordtype rType = [select id from recordtype where Name = 'GILLIG' and SOBJECTTYPE = 'Customer_Contract__c' limit 1];

        cContract = new Customer_Contract__c (name = 'Test Contract', ownerid = rRep.Id, RecordTypeID = rType.ID,
                                                                  Lead_Agency__c = tAccount.Id, Project_Sales_Manager__c = pRep.Id,
                                                                  Bid_Status__c = 'Bid', Bid_Stage__c = 'Award GILLIG', Bid_Submission_Type__c = 'Email');
        insert cContract;
        tOppLine = new List<Opportunity_Line__c>();
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        busFirmRecordType = busMap.get('Firm');
        busTBSRecordType = busMap.get('To Be Scheduled');
        busScheduledRecordType = busMap.get('Scheduled');
        busReservedRecordType = busMap.get('Reserved');
        busForecastedRecordType = busMap.get('Forecasted');

    }

    static void initScheduled (Integer n, Integer qty) {
        for (Integer i = 0; i < n; i++) {
            tOppLine.add(new Opportunity_Line__c (Name=tOpportunity.Name+' - '+String.valueOf(i+1),
                                            Opportunity_Line__c = tOpportunity.Id, 
                                            Date_Booked__c = null,
                                            Quantity__c = qty,
                                            Serial_Number__c = String.valueOf(i*qty),
                                            Mode__c = 'Diesel',
                                            PO_Amount__c = 150, 
                                            PO_Date__c = system.today(), 
                                            PO_Reference__c = 'Test PO',
                                            Quoted_Price__c = 100, 
                                            Reference_Contract__c = cContract.Id,
                                            Style__c = 'LF',
                                            Length__c = '40',
                                            Start_Date__c = system.today()));
        }
        insert tOppLine;
    }

	@isTest
	static void itShouldDeletetheFleet()
	{
        init();

        test.startTest();

        initScheduled(10,10);

        set<Id> toppId = new set<Id>();
        for (Opportunity_Line__c t:tOppLine) {
            toppId.add(t.Id);
        }
        List<Opportunity_Line__c> topp = [select Id, Fleet__c from Opportunity_Line__c where Id in :toppId];
        set<Id> tFleet = new set<Id>();
        for (Opportunity_Line__c oppl:topp) {
        	tFleet.add(oppl.Fleet__c);
        }

        List<Fleet__c> resultingFleet = [select Id, Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c 
                                     from Fleet__c where Id in :tFleet];
 		system.assertNotEquals(0,resultingFleet.size());

        // When the fleet is deleted

        Fleet.deleteFleet(resultingFleet);

        //Then the Fleet will be gone

        List<Fleet__c> deletedFleet;
        try {
        	deletedFleet = [select Id, Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c 
                                     from Fleet__c where Id in :tFleet];
        } catch (Exception e) {
        	system.assertNotEquals(null,e);
        }

        system.assertEquals(0, deletedFleet.size());

        test.stopTest();

	}

    @isTest
    static void itShouldDeleteScheduledFleet()
    {
        init();
        test.startTest();
        //Given an Opportunity Line that is not yet booked, and has a Serial Number and a start date

        initScheduled(10, 10);

        set<Id> toppId = new set<Id>();
        for (Opportunity_Line__c t:tOppLine) {
            toppId.add(t.Id);
        }
        List<Opportunity_Line__c> topp = [select Id, Serial_Number__c, Fleet__c from Opportunity_Line__c where Id in :toppId];

        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c, Fleet__c
                                        from Bus__c where Opportunity_Line__c in :toppId Order By Opportunity_Line__c, Reservation_ID__c];

        set<Id> fleetSet = new set<Id>();
        for (Bus__c fbus:resultingBus) {
            fleetSet.add(fbus.Fleet__c);
        }

        List<Fleet__c> resultingFleet = [select Id, Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c 
                                     from Fleet__c where Id in :fleetSet];
        system.assertNotEquals(0,resultingFleet.size());

        Integer serialNum;
        Integer i=0;
        Id opplID;
        for (Bus__c rBus:resultingBus) {
            if (rBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        serialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        i=0;
                        break;
                    }
                }
            }

            system.assertEquals(String.valueOf(serialNum + i), rBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), rBus.RecordTypeID);
            system.assertEquals(i, rBus.Reservation_ID__c);
            i++;
        }

        // When the start date is removed
        for (Opportunity_Line__c uOPPL:tOppLine) {
            uOPPL.Serial_Number__c = null;
            uOPPL.Start_Date__c = null;
        }
        update tOppLine;
        
        // Then the busses should be deleted
        List<Bus__c> deletedBus = new List<Bus__c>();
        try {
            deletedBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c
                                        from Bus__c where Opportunity_Line__c in :toppId];
        } catch (Exception e) {
            system.assertNotEquals(null,e);
        }

        system.assertEquals(0,deletedBus.size());

        //And the Fleet will be gone

        List<Fleet__c> deletedFleet;
        try {
            deletedFleet = [select Id, Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c 
                                     from Fleet__c where Id in :fleetSet];
        } catch (Exception e) {
            system.assertNotEquals(null,e);
        }

        system.assertEquals(0, deletedFleet.size());        

        test.stopTest();

    }

    @isTest
    static void itShouldNotDeleteFleet()
    {
        init();
        test.startTest();

        //Given an Opportunity Line that is not yet booked, and has a Serial Number and a start date
        initScheduled(10, 10);

        set<Id> toppId = new set<Id>();
        for (Opportunity_Line__c t:tOppLine) {
            toppId.add(t.Id);
        }
        List<Opportunity_Line__c> topp = [select Id, Serial_Number__c, Fleet__c, Quantity__c from Opportunity_Line__c where Id in :toppId];

        List<Bus__c> resultingBus = [select Id, Fleet__c, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                        from Bus__c where Opportunity_Line__c in :toppId Order By Opportunity_Line__c, Reservation_ID__c];

        set<Id> flSet = new set<Id>();
        for (Bus__c rb:resultingBus) {
            flSet.add(rb.Fleet__c);
        }

        List<Fleet__c> resultingFleet = [select Id, Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c 
                                     from Fleet__c where Id in :flSet];

        system.assertNotEquals(0, resultingFleet.size());

        // When the quantity is decreased

        tOpp[0].Quantity__c = 2;
        update tOpp;

        // Then the fleet should not be deleted

        Fleet__c updatedFleet = [select Id, Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c, Quantity__c
                                     from Fleet__c where Id=:tOpp[0].Fleet__c];
        system.assertEquals(2, updatedFleet.Quantity__c);

        test.stopTest();
    }


    static testmethod void itShouldRetiretheFleet () {
        init();
        
        test.startTest();

        // Opportunity line list
        List<Opportunity_Line__c> tOppLine = new List<Opportunity_Line__c>();

        tOppLine.add(new Opportunity_Line__c (Opportunity_Line__c = tOpportunity.Id, 
                                            Quantity__c = 2,
                                            Serial_Number__c = '123456',
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

}