public with sharing class DisplayBoardConstants {  
    
    public static final String DB_BUS_OBJECT_NAME = 'Bus__c';
    public static final String DB_SEARCH_FILTER_FSET = 'Board_Search_Filters';
    
    public static final String DB_OPPLINE_OBJECT_NAME = 'Opportunity_Line__c';
    public static final String DB_OPPLINE_SEARCH_FILTER_FSET = 'Board_Search_Filters';
    
    public static final String DB_SALESORDER_OBJECT_NAME = 'Sales_Order__c';
    public static final String DB_SALESORDER_SEARCH_FILTER_FSET = 'Board_Search_Filters';
    
    public static final String DB_HOVER_DIALOG_FSET = 'Hover_Dialog_Fields';
    
    public static final Integer MIN_SLOTS_PER_DAY = Integer.valueOf( DisplayBoardMetadataUtils.boardSettings.get( 'display.minSlotsPerDay'));
    public static Integer MAX_SLOTS_PER_WEEK = -1;
    
    public static Map<String, Exception_Day__c> PLANT_DAYS; 
    public static List<DisplayBoardSlotsPerDayRangeDetails> SLOTS_PER_DAY_RANGE;
    
    public static final Date DB_START_DATE = Date.parse( DisplayBoardMetadataUtils.boardSettings.get( 'display.start_date'));
    public static final Date DB_LIFE_END_DATE = Date.parse( DisplayBoardMetadataUtils.boardSettings.get( 'display.life_end_date'));
     
    public static final Integer WEEKS_PER_ROW = Integer.valueOf( DisplayBoardMetadataUtils.boardSettings.get( 'display.maxWeeksPerRow'));
	// public static final Integer slotsPerWeek = Integer.valueOf( DisplayBoardMetadataUtils.boardSettings.get( 'display.maxSlotsPerWeek'));
	public static final Integer MIN_WEEKS_PER_ROW = Integer.valueOf( DisplayBoardMetadataUtils.boardSettings.get( 'display.minWeeksPerRow'));
	public static final Integer VISIBLE_SLOTS_PER_WEEK = Integer.valueOf( DisplayBoardMetadataUtils.boardSettings.get( 'display.visibleSlots'));
    public static final Integer MAX_WEEKS_DATA = Integer.valueOf( DisplayBoardMetadataUtils.boardSettings.get( 'display.maxWeeksData'));
    
    public static final Integer CUSTOMER_NAME_LENGTH = Integer.valueOf( DisplayBoardMetadataUtils.boardSettings.get( 'display.customerNameLength'));

    public static final Boolean DEBUG = Boolean.valueOf( DisplayBoardMetadataUtils.boardSettings.get('display.debug'));
    
    public static final String EXCEPTIONDAY_TYPE_WD = 'Working Day';
    public static final String EXCEPTIONDAY_TYPE_H = 'Holiday';
    public static final String EXCEPTIONDAY_TYPE_SW = 'Scheduled Week';
    public static final String EXCEPTIONDAY_TYPE_DSPD = 'Default Slots Per Day';
    public static final String EXCEPTIONDAY_TYPE_SPWC = 'Slots Per Week Constant';
    
    static {
		initializeexceptionDays();
    }
    
    private DisplayBoardConstants() { }
    
	@TestVisible private static void initializeexceptionDays() {
        
        if ( PLANT_DAYS != null ) {
            // return;
        }
        
        PLANT_DAYS = new Map<String, Exception_Day__c>();
        List<Exception_Day__c> exceptionDays = [SELECT  Id, 
                                                    Name, 
                                                    Type__c, 
                                                    Exception_Date__c,
                                                    Slots__c  
                                                    FROM 
                                                    Exception_Day__c
                                                    ORDER BY 
                                                    Exception_Date__c];
                                                    
        for( Exception_Day__c exceptionDay: exceptionDays ) {
            String key = plantDayKey( exceptionDay.Exception_Date__c, exceptionDay.Type__c);
            PLANT_DAYS.put ( key, exceptionDay);
            if ( exceptionDay.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_SPWC) {
            	MAX_SLOTS_PER_WEEK = Integer.valueOf( exceptionDay.Slots__c);
            } // if
        } // for

        if ( MAX_SLOTS_PER_WEEK == -1) {
        	MAX_SLOTS_PER_WEEK = Integer.valueOf( DisplayBoardMetadataUtils.boardSettings.get( 'display.maxSlotsPerWeek'));
        } // if                                         

        buildDefaultSlotsPerDayRange( exceptionDays);
    }
    
    public static String plantDayKey( Date specialDate, String dayType) {
    	return String.valueOf( specialDate) + dayType;
    }
    
    public static void rebuildDefaultSlotsPerDayRange( Date newDate, Integer newSlotsCount) {
    	// System.debug( 'rebuildDefaultSlotsPerDayRange()');
    	
        List<Exception_Day__c> exceptionDays = [SELECT  Id, 
                                                    Name, 
                                                    Type__c, 
                                                    Exception_Date__c,
                                                    Slots__c  
                                                    FROM 
                                                    Exception_Day__c
                                                    ORDER BY 
                                                    Exception_Date__c];
 		Exception_Day__c newExceptionDay = new Exception_Day__c();
 		newExceptionDay.Exception_Date__c =  newDate;
 		newExceptionDay.Slots__c = newSlotsCount;
 		newExceptionDay.Type__c = DisplayBoardConstants.EXCEPTIONDAY_TYPE_DSPD;
 		
 		Boolean inserted = false;
 		Integer listSize = exceptionDays.size();
 		
 		// delete the existing value if present .. takes care update
 		for ( Integer i = 0; i < listSize; i++) {
 			if ( exceptionDays[i].Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_DSPD && 
 					exceptionDays[i].Exception_Date__c == newDate ) {
 				exceptionDays.remove( i);
 				// System.debug( 'existing default slots date removed');
 				break;
 			} // if
 		} // for
 		
 		listSize = exceptionDays.size();
 		// add new value  ... takes care insert scenario
 		for ( Integer i = 0; i < listSize; i++) {
 			if ( inserted == false && exceptionDays[i].Exception_Date__c > newDate) {
 				inserted = true;
 				exceptionDays.add( i, newExceptionDay);
 				// System.debug( 'New ExceptionDay inserted ');
 				break;
 			} // if
 		} // for
 		
 		if ( inserted == false) {
 			// System.debug('Did not get added in the loop. Add it now');
 			exceptionDays.add( newExceptionDay);
 		}
 		
 		buildDefaultSlotsPerDayRange( exceptionDays);
    }
    
    @testVisible private static void buildDefaultSlotsPerDayRange( List<Exception_Day__c> allExceptionDays) {

    	SLOTS_PER_DAY_RANGE = new List<DisplayBoardSlotsPerDayRangeDetails>();
    	List<Exception_Day__c> justSlotsPerDayRecords = new List<Exception_Day__c>();
    	for ( Exception_Day__c exceptionDay: allExceptionDays) {
    		if ( exceptionDay.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_DSPD) {
    			justSlotsPerDayRecords.add( exceptionDay);
    		} // if 
    	} // for 
    	
    	DisplayBoardSlotsPerDayRangeDetails slotDetails = new DisplayBoardSlotsPerDayRangeDetails();
    	slotDetails.startDate = Date.newInstance( 1974, 11, 30);
    	slotDetails.endDate = null;
    	slotDetails.maxSlotsPerDay = DisplayBoardConstants.MIN_SLOTS_PER_DAY;
    	SLOTS_PER_DAY_RANGE.add( slotDetails);
    	
    	for ( Integer i = 0; i < justSlotsPerDayRecords.size(); i++) {
    		slotDetails = SLOTS_PER_DAY_RANGE[ SLOTS_PER_DAY_RANGE.size() - 1]; 
    		slotDetails.endDate = justSlotsPerDayRecords[i].Exception_Date__c;
    		
    		slotDetails = new DisplayBoardSlotsPerDayRangeDetails();
	    	slotDetails.startDate = justSlotsPerDayRecords[i].Exception_Date__c;
	    	slotDetails.endDate = null;
	    	slotDetails.maxSlotsPerDay = Integer.valueOf(justSlotsPerDayRecords[i].Slots__c);
	    	SLOTS_PER_DAY_RANGE.add( slotDetails);
    	} // for
    	
		slotDetails = SLOTS_PER_DAY_RANGE[ SLOTS_PER_DAY_RANGE.size() - 1];
		slotDetails.endDate = DB_LIFE_END_DATE;
    } // function
}