@isTest
private class DisplayBoardDataHandlerTest { 
	
	@isTest
	static void test_getData_Scheduled_Good() {
		DisplayBoardDataTest.initCustomMetaData( '01/02/2017');
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
		Date date1 = Date.newInstance( 2017, 01, 01);
		Date date2 = Date.newInstance( 2019, 01, 01);
// 		List<DisplayWeekDetails> schedules = DisplayBoardDataHandler.getData( 0, date1, date2);
		DisplayBoardWeekDetailsWRogues dbWeekDetailsWRogues = DisplayBoardDataHandler.getData( 0, date1, date2);
		List<DisplayWeekDetails> schedules = dbWeekDetailsWRogues.weekDetailsList;
		
		System.debug( 'schedules[0].slots[0] ' + schedules[0].slots[0]);
		System.debug( 'schedules[0].slots[9] ' + schedules[0].slots[9]);

		System.debug( 'schedules[1].slots[0].bus ' + schedules[1].slots[0].bus);
		System.debug( 'schedules[1].slots[9].bus ' + schedules[1].slots[9].bus);

		System.debug( 'schedules[1].slots[0] ' + schedules[1].slots[0]);
		System.debug( 'schedules[1].slots[9] ' + schedules[1].slots[9]);
		
		System.debug( ' schedules.size() ' + schedules.size());
		System.debug( ' schedules[0].slots.size() ' + schedules[0].slots.size());
		System.debug( ' schedules[10].slots.size() ' + schedules[10].slots.size());

		System.assert( schedules.size() >= 104, 'total weeks did not match to 104');

		System.assertEquals( slotsPerWeekConstant.Slots__c, schedules[0].slots.size(), 'slots per week did not match');
		System.assertEquals( slotsPerWeekConstant.Slots__c, schedules[10].slots.size(), 'slots per week did not match');
		System.assertEquals( slotsPerWeekConstant.Slots__c, schedules[20].slots.size(), 'slots per week did not match');
		
		System.assert( schedules[1].slots[0].bus != null, 'missing bus at schedules[1].slots[0]');
		System.assert( schedules[1].slots[5].bus != null, 'missing bus at schedules[1].slots[5]');
		System.assert( schedules[1].slots[9].bus != null, 'missing bus at schedules[1].slots[9]');
		System.assert( schedules[1].slots[10].bus == null, 'should not found bus at schedules[1].slots[10]');

		System.assertEquals( Date.newInstance( 2017, 01, 02) ,schedules[1].slots[0].slotDate, ' Date did not match schedules[1].slots[0]');
		System.assertEquals( Date.newInstance( 2017, 01, 02), schedules[1].slots[5].slotDate, 'Date did not match schedules[1].slots[5]');
		System.assertEquals( Date.newInstance( 2017, 01, 02), schedules[1].slots[6].slotDate, 'Date did not match schedules[1].slots[6]');
		System.assertEquals( Date.newInstance( 2017, 01, 03), schedules[1].slots[7].slotDate, 'Date did not match schedules[1].slots[7]');
		System.assertEquals( Date.newInstance( 2017, 01, 03), schedules[1].slots[9].slotDate, 'Date did not match schedules[1].slots[9]');
		System.assertEquals( Date.newInstance( 2017, 01, 03), schedules[1].slots[10].slotDate, 'Date did not matchs chedules[1].slots[10]');

		System.assert( schedules[2].slots[0].bus != null, 'missing bus at schedules[0].slots[0]');
		System.assert( schedules[2].slots[4].bus != null, 'missing bus at schedules[0].slots[5]');
		System.assert( schedules[2].slots[10].bus == null, 'should not found bus at schedules[0].slots[10]');

		System.assertEquals( Date.newInstance( 2017, 01, 09) ,schedules[2].slots[0].slotDate, ' Date did not match schedules[2].slots[0]');
		System.assertEquals( Date.newInstance( 2017, 01, 09), schedules[2].slots[4].slotDate, 'Date did not match schedules[2].slots[4]');
		System.assertEquals( Date.newInstance( 2017, 01, 10), schedules[2].slots[10].slotDate, 'Date did not match schedules[2].slots[10]');
		
		test.stopTest();
	}

	@isTest
	static void test_getData_Unscheduled_Good() {
		DisplayBoardDataTest.initCustomMetaData( '01/02/2017');
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

		Date date1 = Date.newInstance( 2017, 01, 01);
		Date date2 = Date.newInstance( 2019, 01, 01);
// 		List<DisplayWeekDetails> schedules = DisplayBoardDataHandler.getData( 0, date1, date2);
		DisplayBoardWeekDetailsWRogues dbWeekDetailsWRogues = DisplayBoardDataHandler.getData( 0, date1, date2);
		List<DisplayWeekDetails> schedules = dbWeekDetailsWRogues.weekDetailsList;

		System.debug( 'schedules[0].slots[0] ' + schedules[0].slots[0]);
		System.debug( 'schedules[0].slots[9] ' + schedules[0].slots[9]);

		
		System.debug( 'schedules[1].slots[0].bus ' + schedules[1].slots[0].bus);
		System.debug( 'schedules[1].slots[9].bus ' + schedules[1].slots[9].bus);

		System.debug( 'schedules[1].slots[0] ' + schedules[1].slots[0]);
		System.debug( 'schedules[1].slots[9] ' + schedules[1].slots[9]);
		
		System.debug( ' schedules.size() ' + schedules.size());
		System.debug( ' schedules[0].slots.size() ' + schedules[0].slots.size());
		System.debug( ' schedules[10].slots.size() ' + schedules[10].slots.size());

		System.assert( schedules.size() >= 104, 'total weeks did not match to 104');

		System.assertEquals( slotsPerWeekConstant.Slots__c, schedules[0].slots.size(), 'slots per week did not match');
		System.assertEquals( slotsPerWeekConstant.Slots__c, schedules[10].slots.size(), 'slots per week did not match');
		System.assertEquals( slotsPerWeekConstant.Slots__c, schedules[20].slots.size(), 'slots per week did not match');
		
		System.assert( schedules[1].slots[0].bus != null, 'missing bus at schedules[1].slots[0]');
		System.assert( schedules[1].slots[5].bus != null, 'missing bus at schedules[1].slots[5]');
		System.assert( schedules[1].slots[9].bus != null, 'missing bus at schedules[1].slots[9]');
		System.assert( schedules[1].slots[10].bus == null, 'should not found bus at schedules[1].slots[10]');

		System.assertEquals( Date.newInstance( 2017, 01, 02) ,schedules[1].slots[0].slotDate, ' Date did not match schedules[1].slots[0]');
		System.assertEquals( Date.newInstance( 2017, 01, 02), schedules[1].slots[5].slotDate, 'Date did not match schedules[1].slots[5]');
		System.assertEquals( Date.newInstance( 2017, 01, 02), schedules[1].slots[6].slotDate, 'Date did not match schedules[1].slots[6]');
		System.assertEquals( Date.newInstance( 2017, 01, 02), schedules[1].slots[7].slotDate, 'Date did not match schedules[1].slots[7]');
		System.assertEquals( Date.newInstance( 2017, 01, 02), schedules[1].slots[9].slotDate, 'Date did not match schedules[1].slots[9]');
		System.assertEquals( Date.newInstance( 2017, 01, 02), schedules[1].slots[10].slotDate, 'Date did not matchs chedules[1].slots[10]');

		System.assert( schedules[2].slots[0].bus != null, 'missing bus at schedules[0].slots[0]');
		System.assert( schedules[2].slots[4].bus != null, 'missing bus at schedules[0].slots[5]');
		System.assert( schedules[2].slots[10].bus == null, 'should not found bus at schedules[0].slots[10]');

		System.assertEquals( Date.newInstance( 2017, 01, 09) ,schedules[2].slots[0].slotDate, ' Date did not match schedules[2].slots[0]');
		System.assertEquals( Date.newInstance( 2017, 01, 09), schedules[2].slots[4].slotDate, 'Date did not match schedules[2].slots[4]');
		System.assertEquals( Date.newInstance( 2017, 01, 10), schedules[2].slots[10].slotDate, 'Date did not match schedules[2].slots[10]');
		
		test.stopTest();
	}

	@isTest
	static void test_FutureHolding_Good() {
		DisplayBoardDataTest.initCustomMetaData( '01/02/2017');
		test.startTest();
		DisplayBoardDataTest.createFutureHoldingBuses(); 
		List<DisplayWeekDetails> schedules = DisplayBoardDataHandler.getFutureHoldingsData( 0, 10, 50);
		System.debug( ' schedules.size() ' + schedules.size());
		System.debug( ' schedules[0].slots.size() ' + schedules[0].slots.size());
		System.debug( ' schedules[10].slots.size() ' + schedules[9].slots.size());
		
		System.debug( schedules[0].slots[0]);
		System.debug( schedules[0].slots[15]);
		System.debug( schedules[0].slots[16]);
		
		System.assert(schedules[0].slots[0].bus.isFutureHolding == true, 'failed to find bus at schedules[0].slots[0].bus');
		System.assert(schedules[0].slots[1].bus.isFutureHolding == true, 'failed to find bus at schedules[0].slots[1].bus');
		System.assert(schedules[0].slots[5].bus.isFutureHolding == true, 'failed to find bus at schedules[0].slots[5].bus');
		System.assert(schedules[0].slots[7].bus.isFutureHolding == true, 'failed to find bus at schedules[0].slots[7].bus');
		System.assert(schedules[0].slots[10].bus.isFutureHolding == true, 'failed to find bus at schedules[0].slots[10].bus');
		System.assert(schedules[0].slots[14].bus.isFutureHolding == true, 'failed to find bus at schedules[0].slots[14].bus');
		
		System.debug( 'WHY 15th slot ' + schedules[0].slots[15].bus);
		System.assert(schedules[0].slots[15].bus == null, 'should not have found bus object atschedules[0].slots[15].bus');
		
		test.stopTest();
	}
 
}