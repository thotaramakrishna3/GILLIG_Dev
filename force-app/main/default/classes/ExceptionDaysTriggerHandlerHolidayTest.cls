@isTest
private class ExceptionDaysTriggerHandlerHolidayTest {

//	@testSetup
	static void init() {
		
		DisplayBoardDataTest.initCustomMetaData( '01/02/2017');		
		
        Exception_Day__c holiday = new Exception_Day__c( Name = 'Holiday ',
        													Exception_Date__c = Date.newInstance( 2017, 01, 03),
        													Type__c = 'Holiday'
        													);
  		Insert holiday;
  		DisplayBoardConstants.initializeexceptionDays();
  		
	}

	@isTest
	static void test_InsertHoliday_Good() {
		init();
		test.startTest();
//		init();
        Exception_Day__c holiday1 = new Exception_Day__c( Name = 'Holiday',
        													Exception_Date__c = Date.newInstance( 2017, 01, 10),
        													Type__c = 'Holiday');
 		Insert  holiday1;      													
        System.assert( holiday1.Id != null, 'Failed to create record');
		test.stopTest();
	}

	@isTest
	static void test_InsertHoliday_Bad() {
		
		init();
		test.startTest();
//		init();
        Exception_Day__c holiday1 = new Exception_Day__c( Name = 'Holiday',
        													Exception_Date__c = Date.newInstance( 2017, 01, 03),
        													Type__c = 'Holiday');
        Database.SaveResult result;
        Boolean errorFound = false;
        try { 													
	        result = Database.Insert(holiday1);
        } catch( System.DMLException e) {
         	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        	errorFound = true;
       }
       
       System.assert( errorFound, 'Insert should have failed');
	   test.stopTest();
	}

	@isTest
	static void test_UpdateHoliday_Bad() {
		init();
		test.startTest();
// 		init();
        Exception_Day__c holiday1 = new Exception_Day__c( Name = 'Holiday',
        													Exception_Date__c = Date.newInstance( 2017, 04, 12),
        													Type__c = 'Holiday');
        Database.Insert( holiday1);
        holiday1.Exception_Date__c = Date.newInstance( 2017, 04, 13);
        Database.SaveResult result;
        Boolean errorFound = false;
        try { 													
	        result = Database.Update( holiday1);
        } catch( System.DMLException e) {
        	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        	errorFound = true;
        }
        
       System.assert( errorFound, 'Update should have failed.');
       test.stopTest();
	}
	
	@isTest
	static void test_DeleteHoliday_Good() {
		init();
		test.startTest();
// 		init();
        Exception_Day__c holiday1 = new Exception_Day__c( Name = 'Holiday ',
        													Exception_Date__c = Date.newInstance( 2017, 04, 12),
        													Type__c = 'Holiday');
        Database.Insert(holiday1);
        Database.DeleteResult result = Database.delete( holiday1);
        System.assert( result.isSuccess(), 'Should have deleted record');
		test.stopTest();
	}

	@isTest
	static void test_InsertHolidayOnExistingBusesScheduled_Good() { 
		DisplayBoardDataTest.initCustomMetaData( '01/02/2017');
		test.startTest();
		DisplayBoardDataTest.createBusesInUnscheduledWeek(); 
		Exception_Day__c scheduledWeek = new Exception_Day__c( Name = 'Scheduled Week',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Scheduled Week'
        													);
 		Insert scheduledWeek;
 		DisplayBoardConstants.initializeexceptionDays();
        Exception_Day__c holiday1 = new Exception_Day__c( Name = 'Holiday',
        													Exception_Date__c = Date.newInstance( 2017, 01, 04),
        													Type__c = 'Holiday');
        Database.SaveResult result;
        Boolean errorFound = false;
        try { 													
	        result = Database.Insert(holiday1);
        } catch( System.DMLException e) {
         	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        	errorFound = true;
       }
       System.assert( errorFound == false, 'Holiday Insert should have gone thru.');
	   test.stopTest();
	}
		
	@isTest
	static void test_InsertHolidayOnExistingBusesScheduled_Bad() {
		DisplayBoardDataTest.initCustomMetaData( '01/02/2017');
		test.startTest();
		DisplayBoardDataTest.createBusesInUnscheduledWeek();
		Exception_Day__c scheduledWeek = new Exception_Day__c( Name = 'Scheduled Week',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Scheduled Week'
        													);
 		
        Exception_Day__c holiday1 = new Exception_Day__c( Name = 'Holiday',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Holiday');
        Database.SaveResult result;
        Boolean errorFound = false;
        try { 													
	        result = Database.Insert(holiday1);
        } catch( System.DMLException e) {
         	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        	errorFound = true;
       }
       System.assert( errorFound == true, 'Holiday Insert should have failed.');
	   test.stopTest();
	}
	
	@isTest
	static void test_InsertOnExistingBusesUnScheduled_Good() {
		test.startTest();
		DisplayBoardDataTest.createBusesInUnscheduledWeek();
 		
        Exception_Day__c holiday1 = new Exception_Day__c( Name = 'Holiday',
        													Exception_Date__c = Date.newInstance( 2017, 01, 04),
        													Type__c = 'Holiday');
        Database.SaveResult result;
        Boolean errorFound = false;
        try { 													
	        result = Database.Insert(holiday1);
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
		DisplayBoardDataTest.initCustomMetaData( '01/02/2017');
		test.startTest();
		DisplayBoardDataTest.createBusesInUnscheduledWeek();
        Exception_Day__c holiday1 = new Exception_Day__c( Name = 'Holiday',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Holiday');
        Database.SaveResult result;
        Boolean errorFound = false;
        try { 													
	        result = Database.Insert(holiday1);
        } catch( System.DMLException e) {
         	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        	errorFound = true;
       }
       System.assert( errorFound == true, 'Holiday Insert should have failed.');
	   test.stopTest();
	}
	
	@isTest
	static void test_UpdateWorkingDayToHoliday_Bad() {
		init();
		test.startTest();
// 		init();
        Exception_Day__c day = new Exception_Day__c( Name = 'Working Day',
        													Exception_Date__c = Date.newInstance( 2017, 04, 12),
        													Type__c = 'Working Day',
        													Slots__c = 10);
        Database.Insert( day);
        day.Type__c = 'Holiday';
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
	static void test_InsertSameHolidayAndWorkingDay_Bad() {
		init();
		test.startTest();
// 		init();
        Exception_Day__c workingDay = new Exception_Day__c( Name = 'Working Day',
        													Exception_Date__c = Date.newInstance( 2017, 04, 12),
        													Type__c = 'Working Day',
        													Slots__c = 10);
        Database.Insert( workingDay);
        Exception_Day__c holiday = new Exception_Day__c( Name = 'Holiday',
        													Exception_Date__c = Date.newInstance( 2017, 04, 12),
        													Type__c = 'Holiday');
        Database.SaveResult result;
        try { 													
	        result = Database.Insert( holiday);
        } catch( System.DMLException e) {
        	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        }
        test.stopTest();
	}
}