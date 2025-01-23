@isTest
private class DisplayBoardControllerTest {
	
	// @testSetup
	static void init() {
		// create user
		// create history records
		
		DisplayBoardDataTest.initCustomMetaData( '01/02/2017');
	}
	
	
	@isTest
	static void test_getDisplayBoardData_Good() {
		init();
		test.startTest();
		DisplayBoardDataTest.createBusesInUnscheduledWeek(); 
		Exception_Day__c slotsPerWeekConstant = new Exception_Day__c( Name = 'Slots Per Week Constant',
        													Exception_Date__c = Date.newInstance( 2017, 01, 09),
        													Type__c = 'Slots Per Week Constant',
        													Slots__c = 50);
		Insert slotsPerWeekConstant;
		Exception_Day__c holiday = new Exception_Day__c( Name = 'Holiday ',
        													Exception_Date__c = Date.newInstance( 2017, 01, 04),
        													Type__c = 'Holiday'
        													);
		Insert holiday;
		Exception_Day__c holiday1 = new Exception_Day__c( Name = 'Holiday ',
        													Exception_Date__c = Date.newInstance( 2017, 01, 10),
        													Type__c = 'Holiday'
        													);
		Insert holiday1;
		DisplayBoardConstants.initializeexceptionDays();
		// move buses into scheduled week
		Exception_Day__c scheduledWeek = new Exception_Day__c( Name = 'Scheduled Week',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Scheduled Week'
        													);
 		Insert scheduledWeek;
 		
		DisplayBoardConstants.initializeexceptionDays();
		
		DisplayBoardController cntller = new DisplayBoardController();
		String jsonOutput = cntller.getDisplayBoardData();	

		System.assert( jsonOutput != null, 'JsonOutput should not have been null');
			
		DisplayBoardData dbData = ( DisplayBoardData) JSON.deserialize( jsonOutput, DisplayBoardData.class);
		System.assert( dbData.settings != null, 'settings should not be null');
		System.assert( dbData.schedules != null, 'schedules should not be null');

		// add settings check including colors etc...		
				
		test.stopTest();
	}
	
	@isTest
	static void test_getDisplayBoardFilterFields_Good() {
		init();
		test.startTest();
		DisplayBoardController cntller = new DisplayBoardController();
		String jsonOutput = cntller.getDisplayBoardFilterFields();	

		System.assert( jsonOutput != null, 'JsonOutput should not have been null');
			
		List<DisplayBoardFilterField> fileterData = ( List<DisplayBoardFilterField>) JSON.deserialize( jsonOutput, List<DisplayBoardFilterField>.class);
		test.stopTest();		
	}

    static void test_getDisplayBoardUserDetails_Setup() { 
        
    	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        system.runAs(thisUser) {
            Profile p = [SELECT Id FROM Profile WHERE Name='Regional Sales Manager'];
            User user1 = new user(LastName = 'user1', 
            			Username = 'user1.User@example.com', 
            			Email = 'user1.User@example.com', 
                        Alias = 'user1', 
                        CommunityNickname = 'user1', 
                        TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                       	EmailEncodingKey = 'ISO-8859-1', ProfileId = p.ID,
                       	LanguageLocaleKey = 'en_US', 
                       	Display_Board_Manager__c = true,
                       	Display_Board_Password__c = '1111');
            insert user1;
            Profile pm = [SELECT Id FROM Profile WHERE Name='Project Sales Manager'];
            User user2 = new user(LastName = 'user2', 
            			Username = 'user2.User@example.com', 
            			Email = 'user2.User@example.com', 
                        Alias = 'user2', 
                        CommunityNickname = 'user2', 
                        TimeZoneSidKey = 'America/Los_Angeles', 
                        LocaleSidKey = 'en_US',
                       	EmailEncodingKey = 'ISO-8859-1', 
                       	ProfileId = pm.ID,
                       	LanguageLocaleKey = 'en_US',
                       	Display_Board_Manager__c = true,
                       	Display_Board_Password__c = '2222');
            insert user2;
            User user3 = new user(LastName = 'user3', 
            			Username = 'user3.User@example.com', 
            			Email = 'user3.User@example.com', 
                        Alias = 'user3', CommunityNickname = 'user3', 
                        TimeZoneSidKey = 'America/Los_Angeles', 
                        LocaleSidKey = 'en_US',
                       	EmailEncodingKey = 'ISO-8859-1', 
                       	ProfileId = pm.ID,
                       	LanguageLocaleKey = 'en_US',
                       	Display_Board_Manager__c = false);
            insert user3;
            User user4 = new user(LastName = 'user4', 
            			Username = 'user4.User@example.com', 
            			Email = 'user4.User@example.com', 
                        Alias = 'user4', CommunityNickname = 'user4', 
                        TimeZoneSidKey = 'America/Los_Angeles', 
                        LocaleSidKey = 'en_US',
                       	EmailEncodingKey = 'ISO-8859-1', 
                       	ProfileId = pm.ID,
                       	LanguageLocaleKey = 'en_US',
                       	Display_Board_Manager__c = true,
                       	Display_Board_Password__c = null);
            insert user4;
        }
    } // init()

	@isTest
	static void test_getDisplayBoardUserDetails_Good() {
		
		init();
		test.startTest();
		test_getDisplayBoardUserDetails_Setup();
		DisplayBoardController cntller = new DisplayBoardController();
		String jsonOutput = cntller.getDisplayBoardUserDetails();	

		System.assert( jsonOutput != null, 'JsonOutput should not have been null');
			
		List<DisplayBoardUserDetails> dbManagerList = ( List<DisplayBoardUserDetails>) JSON.deserialize( jsonOutput, List<DisplayBoardUserDetails>.class);
		System.assert( dbManagerList.size() > 0 , 'dbManagerList list is empty');
		test.stopTest();		
	}
	
	@isTest 
	static void test_validatePassword_Good() {
		
		init();
		test.startTest();
		test_getDisplayBoardUserDetails_Setup();
		User user1 = [SELECT Id FROM User where email = 'user1.User@example.com'];
		DisplayBoardController cntller = new DisplayBoardController();
		cntller.userRecordID = user1.Id;
		cntller.password = '1111';
		cntller.validatePassword();
		Boolean result = cntller.validManager;
		System.assert( result == true, 'Failed to validate user password');
		test.stopTest();
	}

	@isTest 
	static void test_validatePassword_Bad() { 
		init();
		test.startTest();
		test_getDisplayBoardUserDetails_Setup();
		User user1 = [SELECT Id FROM User where email = 'user1.User@example.com'];
		DisplayBoardController cntller = new DisplayBoardController();
		cntller.validatePassword( user1.Id, '2222');	
		Boolean result = cntller.validManager;
		System.assert( result == false, 'Failed to validate user password');
		test.stopTest();
	}
	
	static void test_getDisplayBoardHistoryDetails_Setup() {
		// create user
		// create history records
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        system.runAs(thisUser) {
		
		    Profile p = [SELECT Id FROM Profile WHERE Name='Regional Sales Manager'];
	        User user1 = new user(LastName = 'user1', 
	        			Username = 'user1.User@example.com', 
	        			Email = 'user1.User@example.com', 
	                    Alias = 'user1', 
	                    CommunityNickname = 'user1', 
	                    TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
	                   	EmailEncodingKey = 'ISO-8859-1', ProfileId = p.ID,
	                   	LanguageLocaleKey = 'en_US', 
	                   	Display_Board_Manager__c = true,
	                   	Display_Board_Password__c = '1111');
	        insert user1;
        }
        
        User user1 = [SELECT Id FROM User where email = 'user1.User@example.com'];
		Integer showSnapShotsCount = Integer.valueOf( DisplayBoardMetadataUtils.boardSettings.get( 'display.showHistorySnapShots'));
		
		Integer totalInserts = showSnapShotsCount + 2;
		for ( Integer i = 0; i < totalInserts; i++) { 
			DisplayBoardHistoryHandle.saveHistorySnapShot( user1.ID, 'this is test json');
		} 
 	}
	
	@isTest
	static void test_getDisplayBoardHistoryDetails_Good() {
		init();
		test.startTest();
		test_getDisplayBoardHistoryDetails_Setup();
		DisplayBoardController cntller = new DisplayBoardController();
		String jsonOutput = cntller.getDisplayBoardHistoryDetails();	

		System.assert( jsonOutput != null, 'JsonOutput should not have been null');
		List<DisplayBoardHistoryDetails> history = ( List<DisplayBoardHistoryDetails>) JSON.deserialize( jsonOutput, List<DisplayBoardHistoryDetails>.class);
		System.assert( history.size() > 0, 'hisotory list is empty');
		test.stopTest();		
	}
	
	

}