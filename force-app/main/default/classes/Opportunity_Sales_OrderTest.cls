@isTest
private class Opportunity_Sales_OrderTest
{

    static Opportunity tOpportunity;
    static List<Opportunity_Line__c> tOppLine;
    static Customer_Contract__c cContract;
    static User rRep;
    static User pRep;
    static Schema.RecordTypeInfo busFirmRecordType;
    static Schema.RecordTypeInfo busTBSRecordType;
    static Schema.RecordTypeInfo busScheduledRecordType;
    static Schema.RecordTypeInfo busReservedRecordType;
    static Schema.RecordTypeInfo busForecastedRecordType;

    static void init() {
    
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
        
        account leadAgency = new account(Name='Test Lead Agency', Owner = rRep, Project_Sales_Manager__c = pRep.Id, Internal_Name__c = 'test, st'
                             );
        insert leadAgency;

        tOpportunity = new opportunity (AccountID=tAccount.ID,Name='Test Opp',StageName='Forecast', 
                                                    Type = 'Existing Business', Order_Probability__c = '1. High Probability',
                                                    CloseDate=system.today(), ownerid = rRep.Id);
        insert tOpportunity;
       
        recordtype rType = [select id from recordtype where Name = 'GILLIG' and SOBJECTTYPE = 'Customer_Contract__c' limit 1];

        cContract = new Customer_Contract__c (name = 'Test Contract', ownerid = rRep.Id, RecordTypeID = rType.ID,
                                                                  Lead_Agency__c = leadAgency.Id, Project_Sales_Manager__c = pRep.Id,
                                                                  Bid_Status__c = 'Bid', Bid_Stage__c = 'Award GILLIG', Bid_Submission_Type__c = 'Email');
        insert cContract;

        Contract_Option__c contractOption = new Contract_Option__c(Member_Agency__c = tAccount.Id, Customer_Contract__c = cContract.Id, Quantity__c = 4);
        insert contractOption;

		tOppLine = new List<Opportunity_Line__c>(); 
        tOppLine.add(new Opportunity_Line__c (Opportunity_Line__c = tOpportunity.Id,
                                            Quantity__c = 2,
                                            Mode__c = 'Diesel',
                                            PO_Amount__c = 150, 
                                            PO_Date__c = system.today(), 
                                            PO_Reference__c = 'Test PO',
                                            Quoted_Price__c = 100, 
                                            Reference_Contract__c = cContract.Id,
                                            Contract_Option__c = contractOption.Id,
                                            Style__c = 'LF',
                                            Length__c = '40'));
        tOppLine.add(new Opportunity_Line__c (Opportunity_Line__c = tOpportunity.Id, 
                                            Quantity__c = 2,
                                            Mode__c = 'Diesel',
                                            PO_Amount__c = 150, 
                                            PO_Date__c = system.today(), 
                                            PO_Reference__c = 'Test PO',
                                            Quoted_Price__c = 100, 
                                            Reference_Contract__c = cContract.Id,
                                            Contract_Option__c = contractOption.Id,
                                            Style__c = 'LF',
                                            Length__c = '40'));
        insert tOppLine;

        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        busFirmRecordType = busMap.get('Firm');
        busTBSRecordType = busMap.get('To Be Scheduled');
        busScheduledRecordType = busMap.get('Scheduled');
        busReservedRecordType = busMap.get('Reserved');
        busForecastedRecordType = busMap.get('Forecasted');
    }

	@isTest
	static void itShouldChangeQty() {

		// Given any number of Opportunity Lines
		init();

		test.startTest();

        tOppLine[0].Start_Date__c = system.today();
        tOppLine[1].Start_Date__c = system.today();
        tOppLine[0].Serial_Number__c = '123456';
        tOppLine[1].Serial_Number__c = '123458';
        tOppLine[0].Date_Booked__c = system.today();
        tOppLine[1].Date_Booked__c = system.today();

        //When the Opportunity Lines are booked
        update tOppLine;

        createSO.insertSO(tOppLine);

        set<Id> oppLines = new set<Id>();
        oppLines.add(tOppLine[0].Id);
        oppLines.add(tOppLine[1].Id);

        List<Opportunity_Sales_Order__c> resultingOSO = [select Id, Opportunity_Line__c, Sales_Order__c, Quantity__c from Opportunity_Sales_Order__c where Opportunity_Line__c in :oppLines];
        
        // Then there should be a Oopportunity Sales Order for each Opportunity Line
        system.assertEquals(tOppLine.size(), resultingOSO.size());

        for (Opportunity_Sales_Order__c checkQty:resultingOSO) {
        	for (Opportunity_Line__c olQty:tOppLine) {
        		if (checkQty.Opportunity_Line__c == olQty.Id) {
        // Then the Opportunity Sales Order quantity should match the Opportunity Line Qty
        			system.assertEquals(olQty.Quantity__c,checkQty.Quantity__c);
        		break;
        		}
        	}
        }

        resultingOSO[0].Quantity__c=1;
        resultingOSO[1].Quantity__c=3;
        update resultingOSO;

        List<Opportunity_Line__c> topp = [select Id, Serial_Number__c, Fleet__c from Opportunity_Line__c where Id in :oppLines];

        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                        from Bus__c where Opportunity_Line__c in :oppLines Order By Opportunity_Line__c, Reservation_ID__c];

        Integer serialNum;
        Integer i=0;
        Id opplID;
        for (Bus__c rBus:resultingBus) {
            if (rBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=toppl.Id;
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

		test.stopTest();
	}

	@isTest
	static void itShouldDeleteQty() {

		// Given any number of Opportunity Lines
		init();

		test.startTest();

        tOppLine[0].Start_Date__c = system.today();
        tOppLine[1].Start_Date__c = system.today();
        tOppLine[0].Serial_Number__c = '123456';
        tOppLine[1].Serial_Number__c = '123458';
        tOppLine[0].Date_Booked__c = system.today();
        tOppLine[1].Date_Booked__c = system.today();

        //When the Opportunity Lines are booked
        update tOppLine;

        createSO.insertSO(tOppLine);

        set<Id> oppLines = new set<Id>();
        oppLines.add(tOppLine[0].Id);
        oppLines.add(tOppLine[1].Id);

        List<Opportunity_Sales_Order__c> resultingOSO = [select Id, Opportunity_Line__c, Sales_Order__c, Quantity__c from Opportunity_Sales_Order__c where Opportunity_Line__c in :oppLines];
        
        // Then there should be a Oopportunity Sales Order for each Opportunity Line
        system.assertEquals(tOppLine.size(), resultingOSO.size());

        for (Opportunity_Sales_Order__c checkQty:resultingOSO) {
        	for (Opportunity_Line__c olQty:tOppLine) {
        		if (checkQty.Opportunity_Line__c == olQty.Id) {
        // Then the Opportunity Sales Order quantity should match the Opportunity Line Qty
        			system.assertEquals(olQty.Quantity__c,checkQty.Quantity__c);
        		break;
        		}
        	}
        }

        Id resultingSO = resultingOSO[0].Sales_Order__c;

        Opportunity_Sales_Order__c delOSO = [select Id from Opportunity_Sales_Order__c where id=:resultingOSO[0].Id];
        delete delOSO;

        List<Opportunity_Line__c> topp = [select Id, Serial_Number__c, Fleet__c from Opportunity_Line__c where Id in :oppLines];

        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                        from Bus__c where Opportunity_Line__c in :oppLines Order By Opportunity_Line__c, Reservation_ID__c];

        Integer serialNum;
        Integer i=0;
        Id opplID;
        for (Bus__c rBus:resultingBus) {
            if (rBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=toppl.Id;
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

        Sales_Order__c finalSO = [select Id, Name, Quantity__c from Sales_Order__c where Id=:resultingSO];

		test.stopTest();
	}
}