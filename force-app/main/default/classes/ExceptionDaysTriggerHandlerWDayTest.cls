@isTest
private class ExceptionDaysTriggerHandlerWDayTest {

//	@testSetup
	static void init() {
		
		DisplayBoardDataTest.initCustomMetaData( '01/02/2017');		
        Exception_Day__c workingDay = new Exception_Day__c( Name = 'Working Day',
        													Exception_Date__c = Date.newInstance( 2017, 01, 04),
        													Type__c = 'Working Day',
        													Slots__c = 9
        													);
  		Insert workingDay;
  		DisplayBoardConstants.initializeexceptionDays();
  		
	}
	
	@isTest
	static void test_InsertWorkingDay_Good() {
		init();
		test.startTest();
//		init();
        Exception_Day__c day = new Exception_Day__c( Name = 'Working Day',
        													Exception_Date__c = Date.newInstance( 2017, 04, 12),
        													Type__c = 'Working Day',
        													Slots__c = 10);
 		Insert  day;      													
        System.assert( day.Id != null, 'Failed to create record');
		test.stopTest();
	}
	
	@isTest
	static void test_InsertWorkingDay_Bad() {
		init();
		test.startTest();
//		init();
        Exception_Day__c day = new Exception_Day__c( Name = 'Working Day',
        													Exception_Date__c = Date.newInstance( 2017, 01, 04),
        													Type__c = 'Working Day',
        													Slots__c = 10);
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
	static void test_UpdateWorkingDay_Good() {
		init();
		test.startTest();
//		init();
        Exception_Day__c day = new Exception_Day__c( Name = 'Working Day',
        													Exception_Date__c = Date.newInstance( 2017, 04, 12),
        													Type__c = 'Working Day',
        													Slots__c = 10);
        Database.Insert( day);
        day.Slots__c = 12;
        Database.SaveResult result;
        try { 													
	        result = Database.Update( day);
	        System.Assert( result.isSuccess());
        } catch( System.DMLException e) {
        	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        }
        test.stopTest();
	}

	@isTest
	static void test_UpdateWorkingDay_Bad() {
		init();
		test.startTest();
//		init();
        Exception_Day__c day = new Exception_Day__c( Name = 'Working Day',
        													Exception_Date__c = Date.newInstance( 2017, 04, 12),
        													Type__c = 'Working Day',
        													Slots__c = 10);
        Database.Insert( day);
        day.Exception_Date__c = Date.newInstance( 2017, 04, 13);
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
	static void test_DeleteWorkingDay_Good() {
		init();
		test.startTest();
//		init();
        Exception_Day__c day = new Exception_Day__c( Name = 'Working Day',
        													Exception_Date__c = Date.newInstance( 2017, 04, 12),
        													Type__c = 'Working Day',
        													Slots__c = 10);
        Database.Insert(day);
        DisplayBoardConstants.initializeexceptionDays();
        Database.DeleteResult result = Database.delete( day);
        System.assert( result.isSuccess(), 'Should not have create record');
		test.stopTest();
	}

	@isTest
	static void test_InsertWorkingDayOnExistingBusesScheduled_Good() {
		init();
		test.startTest();
		DisplayBoardDataTest.createBusesInUnscheduledWeek(); 
		Exception_Day__c scheduledWeek = new Exception_Day__c( Name = 'Scheduled Week',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Scheduled Week'
        													);
 		Insert scheduledWeek;
        Exception_Day__c workingDay = new Exception_Day__c( Name = 'Working Day',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Working Day',
        													Slots__c = 9
        													);
        Database.SaveResult result;
        Boolean errorFound = false;
        try { 													
	        result = Database.Insert(workingDay);
        } catch( System.DMLException e) {
         	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        	errorFound = true;
       }
       System.assert( errorFound == false, 'Working Day Insert should have gone thru.');
	   test.stopTest();
	}
		
	@isTest
	static void test_InsertWorkingDayOnExistingBusesScheduled_Bad() {
		init();
		test.startTest();
		DisplayBoardDataTest.createBusesInUnscheduledWeek();
		Exception_Day__c scheduledWeek = new Exception_Day__c( Name = 'Scheduled Week',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Scheduled Week'
        													);
 	   Insert scheduledWeek;
 	   DisplayBoardConstants.initializeexceptionDays();
       Exception_Day__c workingDay = new Exception_Day__c( Name = 'Working Day',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Working Day',
        													Slots__c = 5
        													);
        Database.SaveResult result;
        Boolean errorFound = false;
        try { 													
	        result = Database.Insert(workingDay);
        } catch( System.DMLException e) {
         	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        	errorFound = true;
       }
       System.assert( errorFound == true, 'Working Day Insert should have failed.');
	   test.stopTest();
	}
	
	@isTest
	static void test_InsertOnExistingBusesUnScheduled_Good() {
		init();
		test.startTest();
		DisplayBoardDataTest.createBusesInUnscheduledWeek();
 		
       Exception_Day__c workingDay = new Exception_Day__c( Name = 'Working Day',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Working Day',
        													Slots__c = 9
        													);
         Database.SaveResult result;
        Boolean errorFound = false;
        try { 													
	        result = Database.Insert(workingDay);
        } catch( System.DMLException e) {
         	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        	errorFound = true;
       }
       System.assert( errorFound == false, 'Holiday Insert should have gone thru.');
	   test.stopTest();
	}
	
	@isTest
	static void test_InsertOnExistingBusesUnScheduled_Bad() {
		init();
		test.startTest();
		DisplayBoardDataTest.createBusesInUnscheduledWeek();
        Exception_Day__c workingDay = new Exception_Day__c( Name = 'Working Day',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Working Day',
        													Slots__c = 6
        													);
        Database.SaveResult result;
        Boolean errorFound = false;
        try { 													
	        result = Database.Insert(workingDay);
        } catch( System.DMLException e) {
         	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        	errorFound = true;
       }
       System.assert( errorFound == false, 'Working day Insert should have gone thru.');
	   test.stopTest();
	}
}