@isTest 
private class DisplayBoardFunctionsTest {

	@testSetup
	static void init() {
		DisplayBoardDataTest.initCustomMetaData( '01/02/2017');
	}
	
	@isTest
    static void test_IsScheduledWeek() {
        DisplayBoardDataTest.init();  		
        test.startTest();
        Date justDate = Date.newInstance( 2017, 01, 02);
        Boolean testResult = DisplayBoardFunctions.isScheduledWeek( justDate);
        System.assertEquals( true, testResult);
        test.stopTest();
        
    }
    
    @isTest
    static void testNOT_IsScheduledWeek() {
        DisplayBoardDataTest.init();  		
        test.startTest();
        Date justDate = Date.newInstance( 2017, 01, 16);
        Boolean testResult = DisplayBoardFunctions.isScheduledWeek( justDate);
        System.assertEquals( false, testResult);
        test.stopTest();
    }
    
    @isTest
    static void test_IsHoliday() {
        DisplayBoardDataTest.init();  		
        test.startTest();
        Date justDate = Date.newInstance( 2017, 01, 09);
        Boolean testResult = DisplayBoardFunctions.isHoliday( justDate);
        System.assertEquals( true, testResult);
        test.stopTest();
    }
    
    @isTest
    static void testNOT_IsHoliday() {
        DisplayBoardDataTest.init();  		
        test.startTest();
        Date justDate = Date.newInstance( 2017, 01, 10);
        Boolean testResult = DisplayBoardFunctions.isHoliday( justDate);
        System.assertEquals( false, testResult);
        test.stopTest();
    }
    
    @isTest
    static void test_maxSlotsForDay() {
        DisplayBoardDataTest.init();  		
        test.startTest();
        Date justDate = Date.newInstance( 2017, 04, 11);
        Integer maxSlots = DisplayBoardFunctions.maxSlotsForDay( justDate);
        System.assertEquals( Integer.valueOf( DisplayBoardDataTest.slotsPerDayRange1.Slots__c) , maxSlots);
        test.stopTest();
        
    }
     
    @isTest
    static void testDefault_maxSlotsForDay() {
        DisplayBoardDataTest.init();  		
        test.startTest();
        Date justDate = Date.newInstance( 2017, 01, 02);
        Integer maxSlots = DisplayBoardFunctions.maxSlotsForDay( justDate);
        System.assertEquals( DisplayBoardConstants.MIN_SLOTS_PER_DAY, maxSlots); 
        test.stopTest();
    }

	@isTest
    static void test_getWeekStartDate() {
        test.startTest();
        DisplayBoardDataTest.init();  		
        Date justDate = Date.newInstance( 2017, 04, 10);
        Date weekStartDate = DisplayBoardFunctions.getWeekStartDate( justDate);
        System.assertEquals( Date.newInstance( 2017, 04, 10), weekStartDate);

        justDate = Date.newInstance( 2017, 04, 11);
        weekStartDate = DisplayBoardFunctions.getWeekStartDate( justDate);  
        System.assertEquals( Date.newInstance( 2017, 04, 10), weekStartDate);

        justDate = Date.newInstance( 2017, 04, 12);
        weekStartDate = DisplayBoardFunctions.getWeekStartDate( justDate);
        System.assertEquals( Date.newInstance( 2017, 04, 10), weekStartDate);

        justDate = Date.newInstance( 2017, 04, 13);
        weekStartDate = DisplayBoardFunctions.getWeekStartDate( justDate);
        System.assertEquals( Date.newInstance( 2017, 04, 10), weekStartDate);

        justDate = Date.newInstance( 2017, 04, 14);
        weekStartDate = DisplayBoardFunctions.getWeekStartDate( justDate);
        System.assertEquals( Date.newInstance( 2017, 04, 10), weekStartDate);

        justDate = Date.newInstance( 2017, 04, 15);
        weekStartDate = DisplayBoardFunctions.getWeekStartDate( justDate);
        System.assertEquals( Date.newInstance( 2017, 04, 10), weekStartDate);

        justDate = Date.newInstance( 2017, 04, 16);
        weekStartDate = DisplayBoardFunctions.getWeekStartDate( justDate);
        System.assertEquals( Date.newInstance( 2017, 04, 10), weekStartDate);

        justDate = Date.newInstance( 2017, 04, 17);
        weekStartDate = DisplayBoardFunctions.getWeekStartDate( justDate);
        System.assertNotEquals( Date.newInstance( 2017, 04, 10), weekStartDate);

        test.stopTest();
    }
    
    @isTest
    static void test_getWeekInYear() {
        DisplayBoardDataTest.init();  		
        test.startTest();
        Date justDate = Date.newInstance( 2017, 01, 10);
        Integer weekInYear = DisplayBoardFunctions.getWeekInYear( justDate);
        System.assertEquals( 2, weekInYear);
        test.stopTest();
    }
    
    
    @isTest
    static void test_convertToDate() {
        DisplayBoardDataTest.init();  		
        test.startTest();
        Date justDate = DisplayBoardFunctions.convertToDate( Datetime.now());
        System.assertEquals( Date.today(), justDate);
        test.stopTest();
    }

    
    @isTest
    static void test_getDayInWeek() {
        DisplayBoardDataTest.init();  		
        test.startTest();
        Date justDate = Date.newInstance( 2017, 04, 10);
        Integer dayInWeek = DisplayBoardFunctions.getDayInWeek( justDate);
        System.assertEquals( 1, dayInWeek);
        
        justDate = Date.newInstance( 2017, 04, 11);
        dayInWeek = DisplayBoardFunctions.getDayInWeek( justDate);
        System.assertEquals( 2, dayInWeek);

        justDate = Date.newInstance( 2017, 04, 12);
        dayInWeek = DisplayBoardFunctions.getDayInWeek( justDate);
        System.assertEquals( 3, dayInWeek);

        justDate = Date.newInstance( 2017, 04, 13);
        dayInWeek = DisplayBoardFunctions.getDayInWeek( justDate);
        System.assertEquals( 4, dayInWeek);

        justDate = Date.newInstance( 2017, 04, 14);
        dayInWeek = DisplayBoardFunctions.getDayInWeek( justDate);
        System.assertEquals( 5, dayInWeek);

        justDate = Date.newInstance( 2017, 04, 15);
        dayInWeek = DisplayBoardFunctions.getDayInWeek( justDate);
        System.assertEquals( 6, dayInWeek);

        justDate = Date.newInstance( 2017, 04, 16);
        dayInWeek = DisplayBoardFunctions.getDayInWeek( justDate);
        System.assertEquals( 7, dayInWeek);

        test.stopTest();
    }
    
    @isTest
    static void test_getQuarterDetails() {
        DisplayBoardDataTest.init();  		
        test.startTest();
        Date justDate = Date.newInstance( 2017, 01, 10);
        Integer quarter = DisplayBoardFunctions.getQuarterDetails( justDate);
        System.assertEquals( 1, quarter);
        
        justDate = Date.newInstance( 2017, 04, 11);
        quarter = DisplayBoardFunctions.getQuarterDetails( justDate);
        System.assertEquals( 2, quarter);

        justDate = Date.newInstance( 2017, 07, 11);
        quarter = DisplayBoardFunctions.getQuarterDetails( justDate);
        System.assertEquals( 3, quarter);

        justDate = Date.newInstance( 2017, 12, 11);
        quarter = DisplayBoardFunctions.getQuarterDetails( justDate);
        System.assertEquals( 4, quarter);

        test.stopTest();
    }
    
    @isTest
    static void test_getStartEndIndexInUnscheduledWeek_Good() {
        DisplayBoardDataTest.init();  		
    	test.startTest();
    	Date tuesday = Date.newInstance( 2017, 01, 03);
    	Integer[] indexes = DisplayBoardFunctions.getStartEndIndexInUnscheduledWeek( tuesday);
    	System.assertEquals( 7, indexes[0]);
    	System.assertEquals( 13, indexes[1]);
    	test.stopTest();
    }
    
    @isTest
    static void test_RemoveExtraCommas_1() {
    	test.startTest();
    	String input = ',,TEST,,';
    	String output = DisplayBoardFunctions.removeExtraCommas( input);
    	test.stopTest();	
    	
    	System.assert( output == 'TEST');
    }
    
    @isTest
    static void test_RemoveExtraCommas_2() {
    	test.startTest();
    	String input = ',,TEST,,TEST,';
    	String output = DisplayBoardFunctions.removeExtraCommas( input);
    	test.stopTest();	
    	
    	System.assert( output == 'TEST,TEST');
    }
    
    @isTest
    static void test_RemoveExtraCommas_3() {
    	test.startTest();
    	String input = 'TEST,TEST';
    	String output = DisplayBoardFunctions.removeExtraCommas( input);
    	test.stopTest();	
    	
    	System.assert( output == 'TEST,TEST');
    }
    
    @isTest
    static void test_RemoveExtraCommas_4() {
    	test.startTest();
    	String input = ',,,,';
    	String output = DisplayBoardFunctions.removeExtraCommas( input);
    	test.stopTest();	
    	
    	System.assert( output == '');
    }
    
    @isTest
    static void test_RemoveExtraCommas_5() {
    	test.startTest();
    	String input = 'TEST';
    	String output = DisplayBoardFunctions.removeExtraCommas( input);
    	test.stopTest();	
    	
    	System.assert( output == 'TEST');
    }
    
    @isTest
    static void test_RemoveExtraCommas_6() {
    	test.startTest();
    	String input = null;
    	String output = DisplayBoardFunctions.removeExtraCommas( input);
    	test.stopTest();	
    	
    	System.assert( output == null);
    }
    
    @isTest
    static void test_RemoveExtraCommas_7() {
    	test.startTest();
    	String input = ' ';
    	String output = DisplayBoardFunctions.removeExtraCommas( input);
    	test.stopTest();	
    	
    	System.assert( output == ' ');
    }
}