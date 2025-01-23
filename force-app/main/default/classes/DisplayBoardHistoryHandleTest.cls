@isTest
private class DisplayBoardHistoryHandleTest {
	 
	@testSetup
	static void init() {
		// create user
		// create history records
		
		DisplayBoardDataTest.initCustomMetaData( '01/02/2017');
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
	}
	
/*  Removed due to json blob too large

	@isTest
	static void testgetHistoryListSingle() {
		test.startTest();
		User user1 = [SELECT Id FROM User where email = 'user1.User@example.com'];
		String historyID = DisplayBoardHistoryHandle.saveHistorySnapShot( user1.ID, 'this is test json');
		List<DisplayBoardHistoryDetails> hDetails = DisplayBoardHistoryHandle.getHistoryList();
		System.assertEquals( 1, hDetails.size(), 'Failed to match record count');
		System.assertEquals( 'user1', hDetails[0].savedByName, 'Failed to match SavedByName');
		System.assertEquals( historyID, hDetails[0].historyRecordID, 'Failed to match historyRecordID');
		test.stopTest();
	}

	@isTest
	static void test_getHistorySnapShot_Good() {
		test.startTest();
		User user1 = [SELECT Id FROM User where email = 'user1.User@example.com'];
		String historyID = DisplayBoardHistoryHandle.saveHistorySnapShot( user1.ID, 'this is test json');
		String jsonOutput = DisplayBoardHistoryHandle.getHistorySnapShot(historyID);
		System.assertEquals( 'this is test json', jsonOutput, 'Failed to match json content');
		test.stopTest();
	}

	@isTest
	static void test_getHistorySnapShot_Bad() {
		test.startTest();
		User user1 = [SELECT Id FROM User where email = 'user1.User@example.com'];
		String historyID = DisplayBoardHistoryHandle.saveHistorySnapShot( user1.ID, 'this is test json');
		String jsonOutput = DisplayBoardHistoryHandle.getHistorySnapShot(historyID + 'BAD');
		System.assertEquals( null, jsonOutput, 'Failed to match null return');
		test.stopTest();
	}

*/
 
	@isTest 
	static void test_getHistoryListShowCount() {
		test.startTest();
		User user1 = [SELECT Id FROM User where email = 'user1.User@example.com'];
		Integer showSnapShotsCount = Integer.valueOf( DisplayBoardMetadataUtils.boardSettings.get( 'display.showHistorySnapShots'));
		
		Integer totalInserts = showSnapShotsCount + 2;
		for ( Integer i = 0; i < totalInserts; i++) { 
			DisplayBoardHistoryHandle.saveHistorySnapShot( user1.ID, 'this is test json');
		} 

		List<DisplayBoardHistoryDetails> hDetails = DisplayBoardHistoryHandle.getHistoryList();
		System.assertEquals( showSnapShotsCount, hDetails.size(), 'FAiled to match show record count');
		test.stopTest();
	}

	@isTest
	static void test_getHistoryListKeepCount() {
		test.startTest();
		User user1 = [SELECT Id FROM User where email = 'user1.User@example.com'];
		Integer keepSnapShotsCount = Integer.valueOf( DisplayBoardMetadataUtils.boardSettings.get( 'display.keepHistorySnapShots'));
		
		Integer totalInserts = keepSnapShotsCount + 2;
		For( Integer i = 0; i < totalInserts; i++) { 
			DisplayBoardHistoryHandle.saveHistorySnapShot( user1.ID, 'this is test json');
		} 

		List<DisplayBoardHistoryDetails> hDetails = DisplayBoardHistoryHandle.getHistoryListFullList();
		System.assertEquals( keepSnapShotsCount, hDetails.size(), 'Failed to match keep record count');
		test.stopTest();
	}

}