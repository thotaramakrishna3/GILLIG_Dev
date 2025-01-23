@isTest
private class ExceptionDaysTriggerHandlerSDayTest {
	
//	@testSetup
	static void init() {
		DisplayBoardDataTest.initCustomMetaData( '01/02/2017');	
        Exception_Day__c scheduledWeek = new Exception_Day__c( Name = 'Scheduled Week',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Scheduled Week'
        													);
   		Insert scheduledWeek;
  		DisplayBoardConstants.initializeexceptionDays();
	}
	
	@isTest
	static void test_InsertScheduledWeek_Good() {
		init();
		test.startTest();
//		init();
        Exception_Day__c day = new Exception_Day__c( Name = 'Scheduled Week',
        													Exception_Date__c = Date.newInstance( 2017, 01, 09),
        													Type__c = 'Scheduled Week');
 		Insert  day;      													
        System.assert( day.Id != null, 'Failed to create record');
		test.stopTest();
	}

	@isTest
	static void test_InsertScheduledWeek_Bad() {
		init();
		test.startTest();
//		init();
        Exception_Day__c day = new Exception_Day__c( Name = 'Scheduled Week',
        													Exception_Date__c = Date.newInstance( 2017, 01, 10),
        													Type__c = 'Scheduled Week');
        Database.SaveResult result;
        try { 													
	        result = Database.Insert(day);
        } catch( System.DMLException e) {
         	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
       }
		test.stopTest();
	}

	@isTest
	static void test_InsertScheduledWeek_Bad2() {
		init();
		test.startTest();
//		init();
        Exception_Day__c day = new Exception_Day__c( Name = 'Scheduled Week',
        													Exception_Date__c = Date.newInstance( 2017, 04, 10),
        													Type__c = 'Scheduled Week');
        Database.SaveResult result;
        try { 													
	        result = Database.Insert(day);
        } catch( System.DMLException e) {
         	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
       }
		test.stopTest();
	}

	@isTest
	static void test_InsertScheduledWeek_Bad3() {
		init();
		test.startTest();
//		init();
        Exception_Day__c day = new Exception_Day__c( Name = 'Scheduled Week',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Scheduled Week');
        Database.SaveResult result;
        try { 													
	        result = Database.Insert(day);
        } catch( System.DMLException e) {
         	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
       }
		test.stopTest();
	}	

	@isTest
	static void test_UpdateScheduledWeek_Bad() {
		init();
		test.startTest();
//		init();
        Exception_Day__c day = new Exception_Day__c( Name = 'Scheduled Week',
        													Exception_Date__c = Date.newInstance( 2017, 01, 09),
        													Type__c = 'Scheduled Week');
        Database.Insert( day);
        day.Exception_Date__c = Date.newInstance( 2017, 04, 24);
        Database.SaveResult result;
        try { 													
	        result = Database.Update( day);
        } catch( System.DMLException e) {
        	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        }
        test.stopTest();
	}
	
	@isTest
	static void test_DeleteScheduledWeek_Bad() {
		init();
		test.startTest();
//		init();
        Exception_Day__c day = new Exception_Day__c( Name = 'Scheduled Week',
        													Exception_Date__c = Date.newInstance( 2017, 01, 09),
        													Type__c = 'Scheduled Week');
        Database.Insert(day);
        Database.DeleteResult result = null;
        try { 													
	        result = Database.delete( day);
        } catch( System.DMLException e) {
        	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        }
		test.stopTest();
	}

}