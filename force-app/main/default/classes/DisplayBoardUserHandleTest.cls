@isTest
private class DisplayBoardUserHandleTest {
    
    // static User user1, user2, user3, user4;
   	
   	@testSetup
    static void init() { 
    	
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
	static void test_getDisplayBoardUsers() {
        test.startTest();
		List<DisplayBoardUserDetails> userList = DisplayBoardUserHandle.getDisplayBoardUsers();
		Integer userCount = 0;
		For( DisplayBoardUserDetails userDetail: userList) {
			if ( userDetail.userName.startsWith( 'user')) {
				userCount++;
			}
		}
		System.assertEquals( 3, userCount);
		test.stopTest();
	}
	
	@isTest
	static void test_validatePassword_Good() {
        test.startTest();
        User user1 = [SELECT Id FROM User where email = 'user1.User@example.com'];
		Boolean result = DisplayBoardUserHandle.validatePassword( user1.Id, '1111');
		System.assertEquals( true, result);
		test.stopTest();
	}
	
	@isTest
	static void test_validatePassword_Bad() {
        test.startTest();
        User user1 = [SELECT Id FROM User where email = 'user1.User@example.com'];
		Boolean result = DisplayBoardUserHandle.validatePassword( user1.Id, '2222');
		System.assertEquals( false, result);
		test.stopTest();
	}
    
	@isTest
	static void testvalidatePasswordMissing() {
        test.startTest();
        User user4 = [SELECT Id FROM User where email = 'user4.User@example.com'];
		Boolean result = DisplayBoardUserHandle.validatePassword( user4.Id, '2222');
		System.assertEquals( false, result);
		test.stopTest();
	}
    
	@isTest
	static void testvalidatePasswordBadUser() {
        test.startTest();
        User user3 = [SELECT Id FROM User where email = 'user3.User@example.com'];
		Boolean result = DisplayBoardUserHandle.validatePassword( user3.Id, '2222');
		System.assertEquals( false, result);
		test.stopTest();
	}
} // class