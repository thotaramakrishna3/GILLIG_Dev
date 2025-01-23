@isTest
public class DisplayBoardDataTest {
	
	public static Exception_Day__c scheduledWeek1;
	public static Exception_Day__c scheduledWeek2;
	public static Exception_Day__c holiday1;
	public static Exception_Day__c holiday2;
	public static Exception_Day__c workingDay1;
	public static Exception_Day__c workingDay2;
	public static Exception_Day__c slotsPerWeek;
	public static Exception_Day__c slotsPerDayRange1;
	public static Exception_Day__c slotsPerDayRange2;	
	
	static Opportunity tOpportunity;
    static Customer_Contract__c cContract;
    static Account tAccount;
    static User rRep;
    static User pRep;
    
    
    public static void initCustomMetaData( String displayBoardStartDate) {
    	
    	DisplayBoardMetadataUtils.boardSettings.put( 'display.keepHistorySnapShots', '10');
    	DisplayBoardMetadataUtils.boardSettings.put( 'display.life_end_date', '01/01/2050');
    	DisplayBoardMetadataUtils.boardSettings.put( 'display.maxSlotsPerDay', '7');
    	DisplayBoardMetadataUtils.boardSettings.put( 'display.maxSlotsPerWeek', '100');
    	DisplayBoardMetadataUtils.boardSettings.put( 'display.maxWeeksData', '104');
    	DisplayBoardMetadataUtils.boardSettings.put( 'display.maxWeeksPerRow', '26');
    	DisplayBoardMetadataUtils.boardSettings.put( 'display.minSlotsPerDay', '7');
    	DisplayBoardMetadataUtils.boardSettings.put( 'display.minWeeksPerRow', '10');
    	DisplayBoardMetadataUtils.boardSettings.put( 'display.showHistorySnapShots', '8');
    	DisplayBoardMetadataUtils.boardSettings.put( 'display.start_date', displayBoardStartDate);
    	DisplayBoardMetadataUtils.boardSettings.put( 'display.visibleSlots', '60');
    }
	

	public static void init() {
		
		// 01/02/2017 --- scheduled
		// 01/09/2017 --- scheduled
		// 01/09/2017 --- holiday on scheduled week
		
		// 01/16/2017 --- unscheduled
		// 01/23/2017 --- unscheduled
		// 01/30/2017 --- unscheduled
		// 01/30/2017 --- unscheduled holiday
		// 01/31/2017 --- unscheduled working day with 9
		
		initCustomMetaData( '01/02/2017');
    	
		
        scheduledWeek1 = new Exception_Day__c( Name = 'Scheduled Week 04/10/2017',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Scheduled Week'
        													);
        scheduledWeek2 = new Exception_Day__c( Name = 'Scheduled Week 04/10/2017',
        													Exception_Date__c = Date.newInstance( 2017, 01, 09),
        													Type__c = 'Scheduled Week'
        													);
        holiday1 = new Exception_Day__c( Name = 'Holiday Monday Week 04/10/2017',
        													Exception_Date__c = Date.newInstance( 2017, 01, 09),
        													Type__c = 'Holiday'
        													);
        holiday2 = new Exception_Day__c( Name = 'Holiday Monday Week 04/17/2017',
        													Exception_Date__c = Date.newInstance( 2017, 01, 30),
        													Type__c = 'Holiday' 
        													);
        workingDay1 = new Exception_Day__c( Name = 'Working Day Monday Week 04/11/2017',
        													Exception_Date__c = Date.newInstance( 2017, 01, 10),
        													Type__c = 'Working Day',
        													Slots__c = 10
        													);
        workingDay2 = new Exception_Day__c( Name = 'Working Day Monday Week 04/11/2017',
        													Exception_Date__c = Date.newInstance( 2017, 01, 31),
        													Type__c = 'Working Day',
        													Slots__c = 11
        													);

        slotsPerWeek = new Exception_Day__c( Name = 'Define slots per WEEK.',
        													Exception_Date__c = Date.newInstance( 2017, 01, 01),
        													Type__c = 'Slots Per Week Constant',
        													Slots__c = 55
        													);
        slotsPerDayRange1 = new Exception_Day__c( Name = 'Working Day Monday Week 04/11/2017',
        													Exception_Date__c = Date.newInstance( 2017, 01, 04),
        													Type__c = 'Default Slots Per Day',
        													Slots__c = 8
        													);
        slotsPerDayRange2 = new Exception_Day__c( Name = 'Working Day Monday Week 04/11/2017',
        													Exception_Date__c = Date.newInstance( 2018, 01, 01),
        													Type__c = 'Default Slots Per Day',
        													Slots__c = 9
        													);

  		Insert holiday1;
  		Insert holiday2;
  		// DisplayBoardConstants.PLANT_DAYS.put( DisplayBoardConstants.plantDayKey( holiday2.Exception_Date__c, holiday2.Type__c), holiday2);

  		Insert workingDay1;
  		// DisplayBoardConstants.PLANT_DAYS.put( DisplayBoardConstants.plantDayKey( workingDay1.Exception_Date__c, workingDay1.Type__c), workingDay1);

  		Insert workingDay2;
  		// DisplayBoardConstants.PLANT_DAYS.put( DisplayBoardConstants.plantDayKey( workingDay2.Exception_Date__c, workingDay2.Type__c), workingDay2);

  		Insert scheduledWeek1;
  		// DisplayBoardConstants.PLANT_DAYS.put( DisplayBoardConstants.plantDayKey( scheduledWeek1.Exception_Date__c, scheduledWeek1.Type__c), scheduledWeek1);

  		// Insert scheduledWeek2;
  		// DisplayBoardConstants.PLANT_DAYS.put( DisplayBoardConstants.plantDayKey( scheduledWeek2.Exception_Date__c, scheduledWeek2.Type__c), scheduledWeek2);
	
		Insert slotsPerWeek;
		
		Insert slotsPerDayRange1;
		
		Insert slotsPerDayRange2;
		
		DisplayBoardConstants.initializeexceptionDays();
	}
	
	public static void createBusesInUnscheduledWeek() {  
        
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
        
        List<Opportunity_Line__c> tOppLine = new List<Opportunity_Line__c>();
        tOppLine.add(new Opportunity_Line__c (Opportunity_Line__c = tOpportunity.Id,
                                            Quantity__c = 15,
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
		// System.debug( 'buses size() = ' + buses.size());
         For( Bus__C bus: buses) {
        	bus.Start_Date__c = Date.newInstance( 2017, 01, 02);
        	bus.Slot_Index_In_Day__c = -1;
        	bus.Week_Start_Date__c = Date.newInstance( 2017, 01, 02);
        }
        update buses;
        buses = [ SELECT Id, Name, Slots__c, Start_Date__c, Slot_Index_In_Day__c, Week_Start_Date__c, is_Future_Holding__c FROM Bus__c];       
         
        Date startDate = Date.newInstance( 2017, 01, 02);

        DisplayBoardBusPlacementHandler.initializeBusList( buses);
        DisplayBoardBusPlacementHandler.placeBusesInUnscheduledWeeks( startDate,
        																10,
        																buses);
	
	    buses = [ SELECT Id, Name, Slots__c, Start_Date__c, Slot_Index_In_Day__c, Week_Start_Date__c, is_Future_Holding__c FROM Bus__c ORDER BY Week_Start_Date__c, Start_Date__c, Slot_Index_In_Day__c];       
        For( Bus__C bus: buses) {
        	System.debug( 
        	bus.Name + ' / ' + 
        	bus.Start_Date__c + ' / ' + 
        	bus.Slot_Index_In_Day__c + ' / ' + 
        	bus.Week_Start_Date__c );
        }
	
	
	}
	
	public static void createFutureHoldingBuses() {  
        
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
        
        List<Opportunity_Line__c> tOppLine = new List<Opportunity_Line__c>();
        tOppLine.add(new Opportunity_Line__c (Opportunity_Line__c = tOpportunity.Id,
                                            Quantity__c = 15,
                                            Serial_Number__c = '123456',
                                            Date_Booked__c = null, 
                                            Mode__c = 'Diesel',
                                            PO_Amount__c = 150, 
                                            PO_Date__c = system.today(), 
                                            PO_Reference__c = 'Test PO',
                                            Quoted_Price__c = 100, 
                                            Reference_Contract__c = cContract.Id,
                                            Style__c = 'LF',
                                            Length__c = '40',
                                            Start_Date__c = null));
        insert tOppLine;

		// When the create fleet class is called
		// createFleet.insertFleet(tOppLine);
        // serialize.serializeBus(tOppLine);
        ////  createSO.insertSO(tOppLine); 

        List<Bus__c> buses = [ SELECT Id, Name, Slots__c, Start_Date__c, Slot_Index_In_Day__c, Week_Start_Date__c, is_Future_Holding__c FROM Bus__c];       
		System.debug( 'buses size() = ' + buses.size());
         For( Bus__C bus: buses) {
        	bus.Start_Date__c = null;
        	bus.Slot_Index_In_Day__c = 0;
        	bus.Week_Start_Date__c = null;
        	// bus.RecordType = 'To Be Scheduled';
        }
        update buses;
	}
	
	@isTest
	static void testSystemData() {
		
		User thisUser = [SELECT ID from User WHERE ID = :UserInfo.getUserId()];
		
		System.runAs( thisUser) {
			Profile p = [SELECT Id, Name FROM Profile WHERE Name='Regional Sales Manager'];
			System.debug( 'Profile p = ' + p);
		} 
		
	}

}