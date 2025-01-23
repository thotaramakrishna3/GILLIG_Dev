public with sharing class DisplayBoardFunctions {
 	
	private static String[] months = new String[]{ '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
	
	private DisplayBoardFunctions() { }
    
    public static String generateMapKey( Date mDate, Integer slotIndex) {
		return String.valueOf( mDate) + '-'+ String.valueOf(slotIndex);
	}
    
 
    public static Boolean isScheduledWeek( Date mDate) {
        Date weekStartDate = getWeekStartDate(mDate);
        String key = String.valueOf( weekStartDate) + 'Scheduled Week';
        Exception_Day__c value = DisplayBoardConstants.PLANT_DAYS.get( key);
        if ( value == null ) {
            return false;
        } else {
            return true;
        } // if
    } // function
    
    
    public static Boolean isHoliday( Date mDate) {
        String key = String.valueOf( mDate) + 'Holiday';
        Exception_Day__c value = DisplayBoardConstants.PLANT_DAYS.get( key);
        if ( value == null ) {
            return false;
        } else {
            return true;
        } // if
    }
    
    public static Boolean isWorkingDay( Date mDate) {
        String key = String.valueOf( mDate) + 'Working Day';
        Exception_Day__c value = DisplayBoardConstants.PLANT_DAYS.get( key);
        if ( value == null ) {
            return false;
        } else {
            return true;
        } // if
    }
    
    // does not include saturday and sunday   
    public static Integer  maxSlotsForDay(Date mDate) {
        
        // if configured , return the slots
        // if not confired and days are between monday to friday, return more than 0
        String key = String.valueOf( mDate) + 'Working Day';
        Exception_Day__c value = DisplayBoardConstants.PLANT_DAYS.get( String.valueOf( key));
        Integer dayInWeek = getDayInWeek(mDate);
        if ( value == null) { 
        	// removed to support slots per day range setting
            if (dayInWeek >= 1 && dayInWeek <= 5) {
                return getDefaultSlotsPerDay( mDate);
            } else {
                return 0;
            }
        } else { 
            return Integer.valueOf( value.Slots__c);
        } // if
    } // function
    
    public static Date getWeekStartDate( Date mDate) {
        Datetime dt = Datetime.newInstance( mDate.year(), mDate.month(), mDate.day()).addHours(12);
        Date startOfWeek = dt.date().toStartOfWeek();
        
        if ( mDate == startOfWeek) { 
            startOfWeek = startOfWeek.addDays(-6);
        } else  {
            startOfWeek = startOfWeek.addDays(1);
        } 
        return startOfWeek;
    }
    
    public static Integer getWeekInYear( Date mDate) {
        Datetime dt = Datetime.newInstance( mDate.year(), mDate.month(), mDate.day()).addHours(12);
        return Integer.valueOf(dt.format('w'));
        // return week;
    } // function
    
    
    public static Datetime convertToDatetime( Date inDate) {
        // return Datetime.newInstance( inDate.year(), inDate.month(), inDate.day()).addHours(12);
        // System.debug( 'Tiru' + Datetime.newInstance( inDate.year(), inDate.month(), inDate.day(), 0, 0, 0));
        return Datetime.newInstance( inDate.year(), inDate.month(), inDate.day(), 0, 0, 0);
    } // function

    public static Date convertToDate( Datetime inDatetime) {
    	Datetime newDateTime = null;
    	if ( inDatetime.hour() == 0) { 
    		newDateTime = inDatetime.addHours(12);
    	} else {
    		newDateTime = inDateTime;
    	}// if
    	
        return Date.newInstance( newDateTime.year(), newDateTime.month(), newDateTime.day());
    } // function
    
    public static Integer getDayInWeek( Date mDate) {
        // return Monday 1 .. Sunday 7
        Datetime dt = convertToDatetime( mDate);
        return Integer.valueOf(dt.format('u')); // 1 = monday
    }
    
    public static Integer getQuarterDetails( Date mDate) {
        Integer month = mDate.month();
        if ( month == 1 || month == 2 || month == 3) {
            return 1;
        } else if ( month == 4 || month == 5 || month == 6) {
            return 2;
        } else if ( month == 7 || month == 8 || month == 9) { 
            return 3;
        } else {
            return 4;
        } // if
    } // function
     
    
    public static Integer getDefaultSlotsPerDay( Date mDate) {
    	For ( DisplayBoardSlotsPerDayRangeDetails defaultSlotNumberRange: DisplayBoardConstants.SLOTS_PER_DAY_RANGE) {
    		if ( mDate >= defaultSlotNumberRange.startDate && 
    			 mDate < defaultSlotNumberRange.endDate) {
    			return defaultSlotNumberRange.maxSlotsPerDay;
    		} // if
    	} // for
    	return DisplayBoardConstants.MIN_SLOTS_PER_DAY;
    } // function
    
    // ignores all workingday slots count in unscheduled week
    public static Integer[] getStartEndIndexInUnscheduledWeek( Date mDate) {
    	Integer[] startEndIndex = new Integer[2];
    	Date weekStartDate = DisplayBoardFunctions.getWeekStartDate( mDate);
    	Date processingDate = null;
    	Integer startIndex = 0;
    	Integer slotsPerDay = 0;
    	for ( Integer i = 0; i < 7; i++) {
    		processingDate = weekStartDate.addDays( i);
    		slotsPerDay = DisplayBoardFunctions.getDefaultSlotsPerDay( processingDate);
    		if ( processingDate == mDate) {
    			startEndIndex[0] = startIndex;
    			startEndIndex[1] = startIndex + slotsPerDay - 1;
    		}
    		startIndex = startIndex + slotsPerDay;
    	}
    	
    	return startEndIndex;
    }
    
    public static Boolean IsAlphaNumeric(string field) {
        if( !String.isEmpty(field))
            return (Pattern.matches('^[a-zA-Z0-9]+$', field));
        return false;
    }
    
    public static String getDisplayDataMMMDDYY( Date inDate) {
    	if ( inDate.day() <= 9) {
	    	return months[inDate.month()] + ' 0' + inDate.day() + ', ' + Math.Mod(inDate.year(), 100);
    	} else {
	    	return months[inDate.month()] + ' ' + inDate.day() + ', ' + Math.Mod(inDate.year(), 100);
    	}
    }
    
    public static String removeExtraCommas( String input) {
    	
    	if ( String.isBlank( input)) {
    		return input;
    	}
    	
 		List<String> testArray = input.split(',');
 		String output = '';
		for(String str : testArray) {
		    if ( !String.isBlank(str) ) {
		        if ( String.isBlank( output)) {
		        	output = str;
		        } else {
		        	output = output + ',' + str;
		        } // if 
		    } // if
		} // for
		System.debug( output);
		return output;
    } 
}