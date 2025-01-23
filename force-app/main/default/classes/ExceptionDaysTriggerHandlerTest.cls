@isTest
private class ExceptionDaysTriggerHandlerTest { 
	
	@testSetup
	static void init() {
		
		DisplayBoardDataTest.initCustomMetaData( '01/02/2017');
        Exception_Day__c scheduledWeek = new Exception_Day__c( Name = 'Scheduled Week',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Scheduled Week'
        													);
        Exception_Day__c holiday = new Exception_Day__c( Name = 'Holiday ',
        													Exception_Date__c = Date.newInstance( 2017, 01, 03),
        													Type__c = 'Holiday'
        													);
        Exception_Day__c workingDay = new Exception_Day__c( Name = 'Working Day',
        													Exception_Date__c = Date.newInstance( 2017, 01, 04),
        													Type__c = 'Working Day',
        													Slots__c = 9
        													);
        Exception_Day__c slotsPerWeekConstant = new Exception_Day__c( Name = 'Slots Per Week Constant',
        													Exception_Date__c = Date.newInstance( 2017, 01, 09),
        													Type__c = 'Slots Per Week Constant',
        													Slots__c = 100);
       Exception_Day__c slotsPerDay = new Exception_Day__c( Name = 'Default Slots Per Day',
        													Exception_Date__c = Date.newInstance( 2017, 01, 02),
        													Type__c = 'Default Slots Per Day',
        													Slots__c = 10);
   		Insert scheduledWeek;
  		Insert holiday;
  		Insert workingDay;
  		Insert slotsPerWeekConstant;
  		Insert slotsPerDay;
	}
	
	@isTest
	static void test_IsAlphaNumeric() {
		System.assert( DisplayBoardFunctions.IsAlphaNumeric( '123AA'));
		System.assert( DisplayBoardFunctions.IsAlphaNumeric( '123'));
		System.assert( DisplayBoardFunctions.IsAlphaNumeric( 'AA'));
		System.assert( !DisplayBoardFunctions.IsAlphaNumeric( '123 AA'));
		System.assert( !DisplayBoardFunctions.IsAlphaNumeric( '123 = AA'));
	}
	
	

}