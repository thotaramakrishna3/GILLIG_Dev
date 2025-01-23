@isTest
private class ExceptionDaysTriggerHandlerSlotsDayTest {

//	@testSetup
	static void init() {
		DisplayBoardDataTest.initCustomMetaData( '01/02/2017');
       Exception_Day__c slotsPerDay = new Exception_Day__c( Name = 'Default Slots Per Day',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Default Slots Per Day',
        													Slots__c = 10);
  		Insert slotsPerDay;
  		DisplayBoardConstants.initializeexceptionDays();
  		
	}
	@isTest
	static void test_InsertSlotsPerDay_Good() {
		init();
		test.startTest();
//		init();
        List<Exception_Day__c> dayList = [ SELECT 	Id, 
        											Slots__c 
        											FROM 
        											Exception_Day__c
        											WHERE 				
													Type__c = 'Default Slots Per Day'];
        System.assertEquals( 1, dayList.size(), 'Failed to create or read record');
        System.assertEquals( 10, dayList[0].Slots__c, 'Failed to set right value 100');
		test.stopTest();
	}
	
	@isTest
	static void test_InsertSlotsPerDay_Bad() {
		init();
		test.startTest();
//		init();
        Exception_Day__c slotsPerDay = new Exception_Day__c( Name = 'Default Slots Per Day',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Default Slots Per Day',
        													Slots__c = 12);
        Database.SaveResult result;
        try { 													
	        result = Database.Insert(slotsPerDay);
        } catch( System.DMLException e) {
         	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
       }
		test.stopTest();
	}

	@isTest
	static void test_UpdateSlotsPerDay_Good() {
		init();
		test.startTest();
//		init();
        List<Exception_Day__c> dayList = [ SELECT 	Id, 
        											Slots__c 
        											FROM 
        											Exception_Day__c
        											WHERE 				
													Type__c = 'Default Slots Per Day'];
        dayList[0].Slots__c = 15;
        Database.SaveResult result;
        try { 													
	        result = Database.Update( dayList[0]);
        } catch( System.DMLException e) {
        	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        }
        
        dayList = [ SELECT 	Id, 
							Slots__c 
							FROM 
							Exception_Day__c
							WHERE 				
							Type__c = 'Default Slots Per Day'];
        System.assertEquals( 1, dayList.size() , 'Should be just 1 record' );
     	System.assertEquals( 15, dayList[0].Slots__c, 'Update failed.' );   
        test.stopTest();
	}

	@isTest
	static void test_UpdateSlotsPerDay_Bad() {
		init();
		test.startTest();
// 		init();
        List<Exception_Day__c> dayList = [ SELECT 	Id, 
        											Slots__c 
        											FROM 
        											Exception_Day__c
        											WHERE 				
													Type__c = 'Default Slots Per Day'];
        dayList[0].Exception_Date__c = Date.newInstance( 2017, 04, 24);
        Database.SaveResult result;
        try { 													
	        result = Database.Update( dayList[0]);
        } catch( System.DMLException e) {
        	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        }
        test.stopTest();
	}
	
	@isTest
	static void test_UpdateSlotsPerDay_Bad2() {
		init();
		test.startTest();
// 		init();
        List<Exception_Day__c> dayList = [ SELECT 	Id, 
        											Slots__c 
        											FROM 
        											Exception_Day__c
        											WHERE 				
													Type__c = 'Default Slots Per Day'];
        Integer belowAllowedValue = DisplayBoardConstants.MIN_SLOTS_PER_DAY - 1;
        dayList[0].Slots__c = belowAllowedValue;
        Database.SaveResult result;
        try { 													
	        result = Database.Update( dayList[0]);
        } catch( System.DMLException e) {
        	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        }
        test.stopTest();
	}
	
	@isTest
	static void test_InsertSlotsPerDayOnExistingBusesScheduled_Good() {
		DisplayBoardDataTest.initCustomMetaData( '01/02/2017');
		test.startTest();
		DisplayBoardDataTest.createBusesInUnscheduledWeek(); 
		Exception_Day__c slotsPerDay = new Exception_Day__c( Name = 'Default Slots Per Day',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Default Slots Per Day',
        													Slots__c = 8);
		Insert slotsPerDay;
		DisplayBoardConstants.initializeexceptionDays();
		
		Exception_Day__c scheduledWeek = new Exception_Day__c( Name = 'Scheduled Week',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Scheduled Week'
        													);
 		
		Insert scheduledWeek;
		DisplayBoardConstants.initializeexceptionDays(); 
		List<Bus__c> buses = [SELECT 	Id,
										Start_Date__c,
										Slot_Index_In_Day__c 
										FROM 
										Bus__c 
										ORDER BY 
										Start_Date__c, 
										Slot_Index_In_Day__c];

		
		For( Bus__c bus: buses) {
			System.debug( bus);
		}
		
		System.assertEquals( Date.newInstance( 2017, 01, 02), buses[0].Start_Date__c, 'Start date did not match for buses[0]');
		System.assertEquals( Date.newInstance( 2017, 01, 02), buses[1].Start_Date__c, 'Start date did not match for buses[1]');
		System.assertEquals( Date.newInstance( 2017, 01, 02), buses[7].Start_Date__c, 'Start date did not match for buses[7]');
		System.assertEquals( Date.newInstance( 2017, 01, 03), buses[8].Start_Date__c, 'Start date did not match for buses[8]');
		System.assertEquals( Date.newInstance( 2017, 01, 03), buses[9].Start_Date__c, 'Start date did not match for buses[9]');

		System.assertEquals( Date.newInstance( 2017, 01, 09), buses[10].Start_Date__c, 'Start date did not match for buses[10]');
		System.assertEquals( Date.newInstance( 2017, 01, 09), buses[11].Start_Date__c, 'Start date did not match for buses[11]');
		System.assertEquals( Date.newInstance( 2017, 01, 09), buses[14].Start_Date__c, 'Start date did not match for buses[14]');

		System.assertEquals( 0, buses[0].Slot_Index_In_Day__c, 'Slot_Index_In_Day__c did not match for buses[0]');
		System.assertEquals( 1, buses[1].Slot_Index_In_Day__c, 'Slot_Index_In_Day__c did not match for buses[1]');
		System.assertEquals( 7, buses[7].Slot_Index_In_Day__c, 'Slot_Index_In_Day__c did not match for buses[7]');
		System.assertEquals( 0, buses[8].Slot_Index_In_Day__c, 'Slot_Index_In_Day__c did not match for buses[8]');
		System.assertEquals( 1, buses[9].Slot_Index_In_Day__c, 'Slot_Index_In_Day__c did not match for buses[9]');

		System.assertEquals( 0, buses[10].Slot_Index_In_Day__c, 'Slot_Index_In_Day__c did not match for buses[10]');
		System.assertEquals( 1, buses[11].Slot_Index_In_Day__c, 'Slot_Index_In_Day__c did not match for buses[11]');
		System.assertEquals( 4, buses[14].Slot_Index_In_Day__c, 'Slot_Index_In_Day__c did not match for buses[14]');
	}
	

	@isTest
	static void test_UpdateSlotsPerDayOnExistingBusesScheduled_Bad() {
		// init();
		DisplayBoardDataTest.initCustomMetaData( '01/02/2017');
		test.startTest();
		DisplayBoardDataTest.createBusesInUnscheduledWeek(); 
		Exception_Day__c slotsPerDay = new Exception_Day__c( Name = 'Default Slots Per Day',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Default Slots Per Day',
        													Slots__c = 8);
		Insert slotsPerDay;
		DisplayBoardConstants.initializeexceptionDays();
		
//		DisplayBoardDataTest.createBusesInUnscheduledWeek(); 
		Exception_Day__c scheduledWeek = new Exception_Day__c( Name = 'Scheduled Week',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Scheduled Week'
        													);
 		
		Insert scheduledWeek;
		DisplayBoardConstants.initializeexceptionDays();
		
		// update the slots to decrement 
		slotsPerDay.Slots__c = 7;
															
        Database.SaveResult result;
        Boolean errorFound = false;
        try { 													
	        result = Database.Update( slotsPerDay);
        } catch( System.DMLException e) {
        	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        	errorFound = true;
        }
        													
		DisplayBoardConstants.initializeexceptionDays();
		System.assert( errorFound == true, 'Should not have updated the record with 7');
		List<Bus__c> buses = [SELECT 	Id,
										Start_Date__c,
										Slot_Index_In_Day__c 
										FROM 
										Bus__c 
										ORDER BY 
										Start_Date__c, 
										Slot_Index_In_Day__c];
		
		System.assertEquals( Date.newInstance( 2017, 01, 02), buses[0].Start_Date__c);
		System.assertEquals( Date.newInstance( 2017, 01, 02), buses[1].Start_Date__c);
		System.assertEquals( Date.newInstance( 2017, 01, 02), buses[7].Start_Date__c);
		System.assertEquals( Date.newInstance( 2017, 01, 03), buses[8].Start_Date__c);
		System.assertEquals( Date.newInstance( 2017, 01, 03), buses[9].Start_Date__c);

		System.assertEquals( Date.newInstance( 2017, 01, 09), buses[10].Start_Date__c);
		System.assertEquals( Date.newInstance( 2017, 01, 09), buses[11].Start_Date__c);
		System.assertEquals( Date.newInstance( 2017, 01, 09), buses[14].Start_Date__c);

		System.assertEquals( 0, buses[0].Slot_Index_In_Day__c);
		System.assertEquals( 1, buses[1].Slot_Index_In_Day__c);
		System.assertEquals( 7, buses[7].Slot_Index_In_Day__c);
		System.assertEquals( 0, buses[8].Slot_Index_In_Day__c);
		System.assertEquals( 1, buses[9].Slot_Index_In_Day__c);

		System.assertEquals( 0, buses[10].Slot_Index_In_Day__c);
		System.assertEquals( 1, buses[11].Slot_Index_In_Day__c);
		System.assertEquals( 4, buses[14].Slot_Index_In_Day__c);
	}

	@isTest
	static void test_UpdateSlotsPerDayOnExistingBusesScheduled_Good() {
		DisplayBoardDataTest.initCustomMetaData( '01/02/2017');
		test.startTest();
		Exception_Day__c slotsPerDay = new Exception_Day__c( Name = 'Default Slots Per Day',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Default Slots Per Day',
        													Slots__c = 8);
		Insert slotsPerDay;
		DisplayBoardConstants.initializeexceptionDays();
		
		DisplayBoardDataTest.createBusesInUnscheduledWeek(); 
		Exception_Day__c scheduledWeek = new Exception_Day__c( Name = 'Scheduled Week',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Scheduled Week'
        													);
 		
		Insert scheduledWeek;
		DisplayBoardConstants.initializeexceptionDays();
		
		// update the slots to decrement 
		slotsPerDay.Slots__c = 10;
															
        Database.SaveResult result;
        Boolean errorFound = false;
        try { 													
	        result = Database.Update( slotsPerDay);
        } catch( System.DMLException e) {
        	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        	errorFound = true;
        }
        													
		DisplayBoardConstants.initializeexceptionDays();
		System.assert( errorFound == false, 'Should  have updated the record with 10');
		List<Bus__c> buses = [SELECT 	Id,
										Start_Date__c,
										Slot_Index_In_Day__c 
										FROM 
										Bus__c 
										ORDER BY 
										Start_Date__c, 
										Slot_Index_In_Day__c];

		
		System.assertEquals( Date.newInstance( 2017, 01, 02), buses[0].Start_Date__c);
		System.assertEquals( Date.newInstance( 2017, 01, 02), buses[1].Start_Date__c);
		System.assertEquals( Date.newInstance( 2017, 01, 02), buses[7].Start_Date__c);
		System.assertEquals( Date.newInstance( 2017, 01, 03), buses[8].Start_Date__c);
		System.assertEquals( Date.newInstance( 2017, 01, 03), buses[9].Start_Date__c);

		System.assertEquals( Date.newInstance( 2017, 01, 09), buses[10].Start_Date__c);
		System.assertEquals( Date.newInstance( 2017, 01, 09), buses[11].Start_Date__c);
		System.assertEquals( Date.newInstance( 2017, 01, 09), buses[14].Start_Date__c);

		System.assertEquals( 0, buses[0].Slot_Index_In_Day__c);
		System.assertEquals( 1, buses[1].Slot_Index_In_Day__c);
		System.assertEquals( 7, buses[7].Slot_Index_In_Day__c);
		System.assertEquals( 0, buses[8].Slot_Index_In_Day__c);
		System.assertEquals( 1, buses[9].Slot_Index_In_Day__c);

		System.assertEquals( 0, buses[10].Slot_Index_In_Day__c);
		System.assertEquals( 1, buses[11].Slot_Index_In_Day__c);
		System.assertEquals( 4, buses[14].Slot_Index_In_Day__c);
	}
}