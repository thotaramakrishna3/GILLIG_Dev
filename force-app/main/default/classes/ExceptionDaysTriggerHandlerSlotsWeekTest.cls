@isTest
private class ExceptionDaysTriggerHandlerSlotsWeekTest {

//	@testSetup
	static void init() {
		DisplayBoardDataTest.initCustomMetaData( '01/02/2017');
        Exception_Day__c slotsPerWeekConstant = new Exception_Day__c( Name = 'Slots Per Week Constant',
        													Exception_Date__c = Date.newInstance( 2017, 01, 09),
        													Type__c = 'Slots Per Week Constant',
        													Slots__c = 100);
  		Insert slotsPerWeekConstant;
  		DisplayBoardConstants.initializeexceptionDays();
  		
	}
	
	@isTest
	static void test_InsertSlotsPerWeekConstant_Good() {
		init();
		test.startTest();
//		init();
        List<Exception_Day__c> dayList = [ SELECT 	Id, 
        											Slots__c 
        											FROM 
        											Exception_Day__c
        											WHERE 				
													Type__c = 'Slots Per Week Constant'];
        System.assertEquals( 1, dayList.size(), 'Failed to create or read record');
        System.assertEquals( 100, dayList[0].Slots__c, 'Failed to set right value 100');
		test.stopTest();
	}

	@isTest
	static void test_InsertSlotsPerWeekConstant_Bad() {
		init();
		test.startTest();
//		init();
        Exception_Day__c day = new Exception_Day__c( Name = 'Slots Per Week Constant',
        													Exception_Date__c = Date.newInstance( 2017, 01, 10),
        													Type__c = 'Slots Per Week Constant',
        													Slots__c = 101);
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
	static void test_UpdateSlotsPerWeekConstant_Good() {
		init();
		test.startTest();
// 		init();
        List<Exception_Day__c> dayList = [ SELECT 	Id, 
        											Slots__c 
        											FROM 
        											Exception_Day__c
        											WHERE 				
													Type__c = 'Slots Per Week Constant'];
        dayList[0].Slots__c = 101;
        Database.SaveResult result;
        result = Database.Update( dayList[0]);
    
        dayList = [ SELECT 	Id,
							Slots__c 
							FROM 
							Exception_Day__c
							WHERE 				
							Type__c = 'Slots Per Week Constant'];
        System.assertEquals( 1, dayList.size(), 'Failed to create or read record');
        System.assertEquals( 101, dayList[0].Slots__c, 'Failed to set right value 100');
        test.stopTest();
	}

	@isTest
	static void test_UpdateSlotsPerWeekConstant_Bad() {
		init();
		test.startTest();
//		init();
        List<Exception_Day__c> dayList = [ SELECT 	Id, 
        											Slots__c 
        											FROM 
        											Exception_Day__c
        											WHERE 				
													Type__c = 'Slots Per Week Constant'];
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
	static void test_DeleteSlotsPerWeekConstant_Bad() {
		init();
		test.startTest();
// 		init();
        List<Exception_Day__c> dayList = [ SELECT 	Id, 
        											Slots__c 
        											FROM 
        											Exception_Day__c
        											WHERE 				
													Type__c = 'Slots Per Week Constant'];
        Database.DeleteResult result = null;
        try { 													
	        result = Database.delete( dayList[0]);
        } catch( System.DMLException e) {
        	Boolean expectedExceptionThrown =  e.getMessage() != null ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        }
		test.stopTest();
	}
}