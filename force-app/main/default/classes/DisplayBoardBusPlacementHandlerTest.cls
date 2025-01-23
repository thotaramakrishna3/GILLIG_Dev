@isTest
private with sharing class DisplayBoardBusPlacementHandlerTest {
	
	static Opportunity tOpportunity;
    static Customer_Contract__c cContract;
    static Account tAccount;
    static User rRep;
    static User pRep;
     
    static void init () { 
    	
    	DisplayBoardDataTest.initCustomMetaData( '01/01/2035');
        
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
                                                    Type = 'Existing Business',Order_Probability__c = '1. High Probability', 
                                                    CloseDate=system.today(), ownerid = rRep.Id);
        insert tOpportunity;
       
        recordtype rType = [select id from recordtype where Name = 'GILLIG' and SOBJECTTYPE = 'Customer_Contract__c' limit 1];

        cContract = new Customer_Contract__c (name = 'Test Contract', ownerid = rRep.Id, RecordTypeID = rType.ID,
                                                                  Lead_Agency__c = tAccount.Id, Project_Sales_Manager__c = pRep.Id,
                                                                  Bid_Status__c = 'Bid', Bid_Stage__c = 'Award GILLIG', Bid_Submission_Type__c = 'Email');
        insert cContract;
        
//        DisplayBoardDataTest.init(); 
    }
    
    // test future_holding buses placement.  on hold.... due to the question
    
    // test 2 slot bus in the process
   	@isTest
	static void testPlacementInUnScheduledWeekMultiSlotBus() {
		init();		
		// System.debug( 'testPlacementInUnScheduledWeek');
		// Given an exisitng Opportinity Line
        test.startTest();
        // Opportunity line list
        List<Opportunity_Line__c> tOppLine = new List<Opportunity_Line__c>();
        tOppLine.add(new Opportunity_Line__c (Opportunity_Line__c = tOpportunity.Id,
                                            Quantity__c = 4,
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
                                            Start_Date__c = Date.newInstance( 2017, 01, 02)));
        insert tOppLine;

		// When the create fleet class is called
		// createFleet.insertFleet(tOppLine);
        // serialize.serializeBus(tOppLine);
        // createSO.insertSO(tOppLine); 
        
        List<Bus__c> buses = [ SELECT Id, Name, Slots__c, Start_Date__c, Slot_Index_In_Day__c, Week_Start_Date__c, is_Future_Holding__c FROM Bus__c];       
        system.assertEquals( buses.size(), 4);
        // Date startDate = Date.newInstance( 2017, 01, 02);
        Date startDate = Date.newInstance( 2035, 01, 01);
        For( Bus__C bus: buses) {
        	bus.Start_Date__c = startDate;
        	bus.Slot_Index_In_Day__c = -1;
        	bus.Week_Start_Date__c = startDate;
        }
        
        buses[0].Slots__c = 2;
        update buses;
        buses = [ SELECT Id, Name, Slots__c, Start_Date__c, Slot_Index_In_Day__c, Week_Start_Date__c, is_Future_Holding__c FROM Bus__c];       
        
        DisplayBoardBusPlacementHandler.initializeBusList( buses);
        DisplayBoardBusPlacementHandler.placeBusesInUnscheduledWeeks( startDate,
        																2,
        																buses);
        
        buses = [ SELECT Id, Name, Slots__c, Start_Date__c, Slot_Index_In_Day__c, Week_Start_Date__c FROM Bus__c ORDER BY Start_Date__c, Slot_Index_In_Day__c];       
        Integer i = 0;
        Integer weeksCount = 0;
        Date placedDate = DisplayBoardFunctions.getWeekStartDate( startDate);

		// validateBusesPlacement( buses[0], 0, Date.newInstance( 2017, 01, 02));       
		// validateBusesPlacement( buses[1], 2, Date.newInstance( 2017, 01, 02));       
		// validateBusesPlacement( buses[2], 0, Date.newInstance( 2017, 01, 09));       
		// validateBusesPlacement( buses[3], 1, Date.newInstance( 2017, 01, 09));       

		validateBusesPlacement( buses[0], 0, Date.newInstance( 2035, 01, 01));       
		validateBusesPlacement( buses[1], 2, Date.newInstance( 2035, 01, 01));       
		validateBusesPlacement( buses[2], 0, Date.newInstance( 2035, 01, 08));       
		validateBusesPlacement( buses[3], 1, Date.newInstance( 2035, 01, 08));       

        																
		test.stopTest();
	}
    // test future_holding skipping 
    
    @isTest
	static void testPlacementInUnScheduledWeekHoliday() {
		init();		
		// Given an exisitng Opportinity Line
        test.startTest();
        Exception_Day__c holiday1 = new Exception_Day__c( Name = 'Holiday Monday Week 04/10/2017',
//        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Exception_Date__c = Date.newInstance( 2035, 01, 01),
        													Type__c = 'Holiday'
        													);
        
        Insert holiday1;
  		DisplayBoardConstants.PLANT_DAYS.put( DisplayBoardConstants.plantDayKey( holiday1.Exception_Date__c, holiday1.Type__c), holiday1);
        
        // Opportunity line list
        List<Opportunity_Line__c> tOppLine = new List<Opportunity_Line__c>();
        tOppLine.add(new Opportunity_Line__c (Opportunity_Line__c = tOpportunity.Id,
                                            Quantity__c = 4,
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
                                            Start_Date__c = Date.newInstance( 2035, 01, 01)));
        insert tOppLine;

		// When the create fleet class is called
		// createFleet.insertFleet(tOppLine);
        // serialize.serializeBus(tOppLine);
        // createSO.insertSO(tOppLine); 
        
        List<Bus__c> buses = [ SELECT Id, Name, Slots__c, Start_Date__c, Slot_Index_In_Day__c, Week_Start_Date__c FROM Bus__c];       
        system.assertEquals( buses.size(), 4);
//         Date startDate = Date.newInstance( 2017, 01, 02);
        Date startDate = Date.newInstance( 2035, 01, 01);
        For( Bus__C bus: buses) {
        	bus.Start_Date__c = startDate;
        	bus.Slot_Index_In_Day__c = -1;
        	bus.Week_Start_Date__c = startDate;
        }
        update buses;
        buses = [ SELECT Id, Name, Slots__c, Start_Date__c, Slot_Index_In_Day__c, Week_Start_Date__c, is_Future_Holding__c FROM Bus__c];       
        
        DisplayBoardBusPlacementHandler.initializeBusList( buses);
        DisplayBoardBusPlacementHandler.placeBusesInUnscheduledWeeks( startDate,
        																2,
        																buses);
        
        buses = [ SELECT Id, Name, Slots__c, Start_Date__c, Slot_Index_In_Day__c, Week_Start_Date__c FROM Bus__c ORDER BY Start_Date__c, Slot_Index_In_Day__c];       
        Integer i = 0;
        Integer weeksCount = 0;
        Date placedDate = DisplayBoardFunctions.getWeekStartDate( startDate);

/*
		validateBusesPlacement( buses[0], 7, Date.newInstance( 2017, 01, 02));       
		validateBusesPlacement( buses[1], 8, Date.newInstance( 2017, 01, 02));       
		validateBusesPlacement( buses[2], 0, Date.newInstance( 2017, 01, 09));       
		validateBusesPlacement( buses[3], 1, Date.newInstance( 2017, 01, 09));       
*/        																

		validateBusesPlacement( buses[0], 7, Date.newInstance( 2035, 01, 01));       
		validateBusesPlacement( buses[1], 8, Date.newInstance( 2035, 01, 01));       
		validateBusesPlacement( buses[2], 0, Date.newInstance( 2035, 01, 08));       
		validateBusesPlacement( buses[3], 1, Date.newInstance( 2035, 01, 08));       


		test.stopTest();
	}

	@isTest
	static void testPlacementInScheduledWeek() {
		init();		
		// Given an exisitng Opportinity Line
        test.startTest();
        
        /*
        String key = DisplayBoardConstants.plantDayKey( Date.newInstance( 2034, 12, 25), 'Scheduled Week');
        Exception_Day__c eDate = new Exception_Day__c( name='test', Type__c = 'Scheduled Week', Exception_Date__c = Date.newInstance( 2034, 12, 25));
        
        DisplayBoardConstants.PLANT_DAYS.put( key, eDate);
        */
      
        
        Exception_Day__c scheduledWeek1 = new Exception_Day__c( Name = 'Scheduled Week 04/10/2017',
//													Exception_Date__c = Date.newInstance( 2017, 01, 02),
													Exception_Date__c = Date.newInstance( 2035, 01, 01),
													Type__c = 'Scheduled Week'
													);
        Insert scheduledWeek1;
  		DisplayBoardConstants.PLANT_DAYS.put( DisplayBoardConstants.plantDayKey( scheduledWeek1.Exception_Date__c, scheduledWeek1.Type__c), scheduledWeek1);
        
        // Opportunity line list
        List<Opportunity_Line__c> tOppLine = new List<Opportunity_Line__c>();
        tOppLine.add(new Opportunity_Line__c (Opportunity_Line__c = tOpportunity.Id,
                                            Quantity__c = 4,
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
                                            Start_Date__c = Date.newInstance( 2035, 01, 01)));
        insert tOppLine;

		// When the create fleet class is called
		// createFleet.insertFleet(tOppLine);
        // serialize.serializeBus(tOppLine);
        // createSO.insertSO(tOppLine); 
        
        List<Bus__c> buses = [ SELECT Id, Name, Slots__c, Start_Date__c, Slot_Index_In_Day__c, Week_Start_Date__c FROM Bus__c];       
        system.assertEquals( buses.size(), 4);
//        Date startDate = Date.newInstance( 2017, 01, 02);
        Date startDate = Date.newInstance( 2035, 01, 01);
        For( Bus__C bus: buses) {
        	bus.Start_Date__c = startDate;
        	bus.Slot_Index_In_Day__c = -1;
        	bus.Week_Start_Date__c = startDate;
        }
        
        update buses;
        buses = [ SELECT Id, Name, Slots__c, Start_Date__c, Slot_Index_In_Day__c, Week_Start_Date__c, is_Future_Holding__c FROM Bus__c];       
        
        // Date startDate = Date.newInstance( 2017, 01, 02);
        DisplayBoardBusPlacementHandler.initializeBusList( buses);
        DisplayBoardBusPlacementHandler.placeBusesInUnscheduledWeeks( startDate,
        																2,
        																buses);
        
        buses = [ SELECT Id, Name, Slots__c, Start_Date__c, Slot_Index_In_Day__c, Week_Start_Date__c FROM Bus__c ORDER BY Start_Date__c, Slot_Index_In_Day__c];       
        Integer i = 0;
        Integer weeksCount = 0;
        Date placedDate = DisplayBoardFunctions.getWeekStartDate( startDate);

/*
		validateBusesPlacement( buses[0], 0, Date.newInstance( 2017, 01, 09));       
		validateBusesPlacement( buses[1], 1, Date.newInstance( 2017, 01, 09));       
		validateBusesPlacement( buses[2], 0, Date.newInstance( 2017, 01, 16));       
		validateBusesPlacement( buses[3], 1, Date.newInstance( 2017, 01, 16));       
 */       																

		validateBusesPlacement( buses[0], 0, Date.newInstance( 2035, 01, 08));       
		validateBusesPlacement( buses[1], 1, Date.newInstance( 2035, 01, 08));       
		validateBusesPlacement( buses[2], 0, Date.newInstance( 2035, 01, 15));       
		validateBusesPlacement( buses[3], 1, Date.newInstance( 2035, 01, 15));       

		test.stopTest();
	}
	
	    @isTest
	static void testPlacementInUnScheduledWeek() {
		init();		
		// Given an exisitng Opportinity Line
        test.startTest();
        // Opportunity line list
        List<Opportunity_Line__c> tOppLine = new List<Opportunity_Line__c>();
        tOppLine.add(new Opportunity_Line__c (Opportunity_Line__c = tOpportunity.Id,
                                            Quantity__c = 4,
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
                                            Start_Date__c = Date.newInstance( 2035, 01, 01)));
        insert tOppLine;

		// When the create fleet class is called
		// createFleet.insertFleet(tOppLine);
        // serialize.serializeBus(tOppLine);
        // createSO.insertSO(tOppLine); 
        
        List<Bus__c> buses = [ SELECT Id, Name, Slots__c, Start_Date__c, Slot_Index_In_Day__c, Week_Start_Date__c, is_Future_Holding__c FROM Bus__c];       
        system.assertEquals( buses.size(), 4);
//         Date startDate = Date.newInstance( 2017, 01, 02);
        Date startDate = Date.newInstance( 2035, 01, 01);
        For( Bus__C bus: buses) {
        	bus.Start_Date__c = startDate;
        	bus.Slot_Index_In_Day__c = -1;
        	bus.Week_Start_Date__c = startDate;
        }
        
        update buses;
        buses = [ SELECT Id, Name, Slots__c, Start_Date__c, Slot_Index_In_Day__c, Week_Start_Date__c, is_Future_Holding__c FROM Bus__c];       
        
        
        DisplayBoardBusPlacementHandler.initializeBusList( buses);
        DisplayBoardBusPlacementHandler.placeBusesInUnscheduledWeeks( startDate,
        																2,
        																buses);
        
        buses = [ SELECT Id, Name, Slots__c, Start_Date__c, Slot_Index_In_Day__c, Week_Start_Date__c FROM Bus__c ORDER BY Start_Date__c, Slot_Index_In_Day__c];       
        Integer i = 0;
        Integer weeksCount = 0;
        Date placedDate = DisplayBoardFunctions.getWeekStartDate( startDate);

/*
		validateBusesPlacement( buses[0], 0, Date.newInstance( 2017, 01, 02));       
		validateBusesPlacement( buses[1], 1, Date.newInstance( 2017, 01, 02));       
		validateBusesPlacement( buses[2], 0, Date.newInstance( 2017, 01, 09));       
		validateBusesPlacement( buses[3], 1, Date.newInstance( 2017, 01, 09));       
*/
		validateBusesPlacement( buses[0], 0, Date.newInstance( 2035, 01, 01));       
		validateBusesPlacement( buses[1], 1, Date.newInstance( 2035, 01, 01));       
		validateBusesPlacement( buses[2], 0, Date.newInstance( 2035, 01, 08));       
		validateBusesPlacement( buses[3], 1, Date.newInstance( 2035, 01, 08));       
        																
		test.stopTest();
	}
	
	@isTest
	static void testPlacementInUnScheduledWeekTEST() {
		System.debug( 'TEST METHOD');
		init();		
		// Given an exisitng Opportinity Line
        test.startTest();
        // Opportunity line list
        List<Opportunity_Line__c> tOppLine = new List<Opportunity_Line__c>();
        tOppLine.add(new Opportunity_Line__c (Opportunity_Line__c = tOpportunity.Id,
                                            Quantity__c = 4,
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
                                            Start_Date__c = Date.newInstance( 2035, 01, 01)));
        insert tOppLine;

		// When the create fleet class is called
		// createFleet.insertFleet(tOppLine);
        // serialize.serializeBus(tOppLine);
        // createSO.insertSO(tOppLine); 
        
        List<Bus__c> buses = [ SELECT Id, Name, Slots__c, Start_Date__c, Slot_Index_In_Day__c, Week_Start_Date__c, is_Future_Holding__c FROM Bus__c];       
        system.assertEquals( buses.size(), 4);
 		System.debug( 'After Trigger update');
		For( Bus__c bus: buses) {
			System.debug( bus);
		} 
		
//		Date startDate = Date.newInstance( 2017, 01, 02);
		Date startDate = Date.newInstance( 2035, 01, 01);
        For( Bus__C bus: buses) {
        	bus.Start_Date__c = startDate;
        	bus.Slot_Index_In_Day__c = -1;
        	bus.Week_Start_Date__c = startDate;
        }
        
        update buses;
        buses = [ SELECT Id, Name, Slots__c, Start_Date__c, Slot_Index_In_Day__c, Week_Start_Date__c, is_Future_Holding__c FROM Bus__c];       
        System.debug( 'After resetting the data');
        For( Bus__c bus: buses) {
			System.debug( bus);
		} 
		
        DisplayBoardBusPlacementHandler.initializeBusList( buses);
        DisplayBoardBusPlacementHandler.placeBusesInUnscheduledWeeks( startDate,
        																2,
        																buses);
        
        buses = [ SELECT Id, Name, Slots__c, Start_Date__c, Slot_Index_In_Day__c, Week_Start_Date__c FROM Bus__c ORDER BY Start_Date__c, Slot_Index_In_Day__c];       
        Integer i = 0;
        Integer weeksCount = 0;
        Date placedDate = DisplayBoardFunctions.getWeekStartDate( startDate);

		For( Bus__c bus: buses) {
			System.debug( bus);
		} 

/*		
		validateBusesPlacement( buses[0], 0, Date.newInstance( 2017, 01, 02));       
		validateBusesPlacement( buses[1], 1, Date.newInstance( 2017, 01, 02));       
		validateBusesPlacement( buses[2], 0, Date.newInstance( 2017, 01, 09));       
		validateBusesPlacement( buses[3], 1, Date.newInstance( 2017, 01, 09));       
*/        																 
		validateBusesPlacement( buses[0], 0, Date.newInstance( 2035, 01, 01));       
		validateBusesPlacement( buses[1], 1, Date.newInstance( 2035, 01, 01));       
		validateBusesPlacement( buses[2], 0, Date.newInstance( 2035, 01, 08));       
		validateBusesPlacement( buses[3], 1, Date.newInstance( 2035, 01, 08));       
        																
		test.stopTest();
	}
	
	private static void validateBusesPlacement( Bus__c placedBus, Integer expectedSlotIndex, Date expectedStartDate ) {
		System.assertEquals( expectedSlotIndex, 
							 placedBus.Slot_Index_In_Day__c , 
							 expectedSlotIndex + ' = SlotIndex did not match' + placedBus);
		System.assertEquals( 	expectedStartDate, 
								placedBus.Start_Date__c,
								expectedStartDate + ' = expectedStartDate did not match' + placedBus );
	}
	
	
    
}