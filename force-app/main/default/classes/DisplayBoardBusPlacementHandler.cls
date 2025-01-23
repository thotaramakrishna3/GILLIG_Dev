public with sharing class DisplayBoardBusPlacementHandler { 
	
	private static final String SLOT_EMPTY = 'EMPTY';
	private static final String SLOT_HOLIDAY = 'HOLIDAY';
	private static final String SLOT_OCCUPIED = 'OCCUPIED'; 
	
	private static Map<Date, List<Bus__c>> totalBusesMap;
	
	private  DisplayBoardBusPlacementHandler() { }
	
	public static void initializeBusList( List<Bus__c> totalBuses) {
		
		// get the start date from the entire buslist
		// get the data greater then the date
		// create list of buses based on week-start-date
		// insert into the map
		
		Date startDate = Date.newInstance( 01, 01, 2050);
		for( Bus__c bus: totalBuses) {
			if ( startDate > bus.Start_Date__c) {
				startDate = bus.Start_Date__c;
			}
		}
		
		System.debug( 'Start date = ' + startDate);
		startDate = DisplayBoardFunctions.getWeekStartDate( startDate);
		System.debug( 'Start Date of week = ' + startDate);
		
		List<Bus__c> buses = [ SELECT 	Id, 
										Name,
										Bus_Length__c,
										Slot_Index__c,
										Slot_Index_In_Day__c,
										is_Reserved__c,
										is_Firm__c,
										is_Future_Holding__c,
										Mode__c,
										Quantity__c,
										Sequence__c, 
										Slots__c,
										Start_Date__c,
										Style__c,  
										Week_Start_Date__c
										FROM Bus__c 
										WHERE  
										Week_Start_Date__c >= :startDate
										AND
										Slot_Index_In_Day__c >= 0
										ORDER BY 
										Week_Start_Date__c,
										Slot_Index_In_Day__c];
										
		totalBusesMap = new Map<Date, List<Bus__c>>();
		List<Bus__c> weekBusesList = new List<Bus__c>();
		
		For( Bus__c bus: buses) {
			if ( startDate == bus.Week_Start_Date__c) {
				weekBusesList.add( bus);
			} else {
				totalBusesMap.put( startDate, weekBusesList);
				weekBusesList = new List<Bus__c>();
				startDate = bus.Week_Start_Date__c;
				weekBusesList.add( bus);
			}
		}
		
		// last date will not be processed by the for loop. Default write it  into the the Map
		totalBusesMap.put( startDate, weekBusesList);
	}
	
	private static void updateTotalBusesMap( List<Bus__c> updatedBuses) {
		
		// get the week-start date 
		// insert all of the buses into the list based on the startdate
		Date weekStartDate;
		List<Bus__c> weekBusesList;
		 
		For( Bus__c bus : updatedBuses) { 
			weekStartDate = bus.Week_Start_Date__c;
			weekBusesList = getTotalBusesInWeek( weekStartDate);
			if ( weekBusesList == null || weekBusesList.size() == 0) {
				weekBusesList = new List<Bus__c>();
			}
			weekBusesList.add( bus);
			totalBusesMap.put(weekStartDate, weekBusesList);
		} 
	}
	
	private static List<Bus__c> getTotalBusesInWeek( Date weekStartDate) {
		System.debug( 'Working with build map ' + weekStartDate);
		List<Bus__c> weekBusesList = totalBusesMap.get( weekStartDate);
		if ( weekBusesList ==  null ) {
			weekBusesList = new List<Bus__c>();
			totalBusesMap.put( weekStartDate, weekBusesList);
		}
		return weekBusesList;
	}
	
	public static void placeBusesInUnscheduledWeeks( Date startDate, 
													Integer perWeekMax, 
													List<Bus__c> customerBuses ) {
														
		// remove all future holding buses from placement here
		// calculate number of slots to make sure multislot buses slots are included.
														
		// get the weekStartDate
		// make sure week is unscheduled week
		// calculate the number of weeks needed to place the buses count / perWeekMax
		// loop thru each week
		//		get weeks empty slots list
		//		put an empty slot index and give for a bus
		//		once 
		
		For ( Integer i = 0; i < customerBuses.size(); i++)  {
			Bus__c bus = customerBuses[i];
			if ( bus.is_Future_Holding__c == true) {
				customerBuses.remove( i);
			}
		}
		
		Date weekStartDate = DisplayBoardFunctions.getWeekStartDate( startDate);					
		
		Integer i = 0;
		Integer processingCount = customerBuses.size();
		Integer needEmptySlotsCount = 0;
		Integer weekCount = 0;
		while ( i < processingCount ) {
			Date processingWeek = weekStartDate.addDays( weekCount * 7);
			Integer maxBusesForWeek = 0;
			if ( (processingCount - i) > perWeekMax ) {
				maxBusesForWeek = perWeekMax;
			} else {
				maxBusesForWeek =  processingCount - i;
			} // if

			// need to include multislotbus slots count too while calculating needed empty buses
			Integer busSlotsCount = 0;
			For( Integer k = 0; k < maxBusesForWeek; k++) {
				busSlotsCount = busSlotsCount + Integer.valueOf(customerBuses[i + k].Slots__c);
			}
			needEmptySlotsCount = busSlotsCount;

			
			// look for double slot buses in the list ???
			Integer[] emptySlots = getEmptySlots( processingWeek, needEmptySlotsCount);
			System.debug( 'processingWeek = ' + processingWeek);
			System.debug( ' empty slots ' + emptySlots);
			if ( emptySlots == null || emptySlots.size() != needEmptySlotsCount) {
				weekCount++;
				continue;
			} // if
			
			for( Integer j =0 ; j < emptySlots.size(); j++) {
				Bus__c bus = customerBuses.get( i);
				bus.Slot_Index_In_Day__c = emptySlots[j];
				bus.Start_Date__c = processingWeek;
				bus.Week_Start_Date__c = processingWeek;
				if ( bus.Slots__c == 2) {
					j++;
				}
				i++; 
			} // for
			
			weekCount++;
		} // while
		
		if ( i > 0 ) { 
			Update customerBuses; 
			updateTotalBusesMap( customerBuses);
		}
	}
    

    
    public static Integer[] getEmptySlots( Date mDate, Integer perWeekMax) {
		// build the holidays first and then see the index
		
		Date weekStartDate = DisplayBoardFunctions.getWeekStartDate( mDate);					
		
		if ( DisplayBoardFunctions.isScheduledWeek( weekStartDate) == true) {
			return null;
		} 
    	
    	/*
		List<Bus__c> buses = [ SELECT 	Id, 
										Name,
										Bus_Length__c,
										Slot_Index__c,
										Slot_Index_In_Day__c,
										is_Reserved__c,
										is_Firm__c,
										is_Future_Holding__c,
										Mode__c,
										Quantity__c,
										Sequence__c, 
										Slots__c,
										Start_Date__c,
										Style__c,  
										Week_Start_Date__c
										FROM Bus__c 
										WHERE  
										Week_Start_Date__c = :weekStartDate
										ORDER BY 
										Week_Start_Date__c,
										Slot_Index_In_Day__c];
		*/
		
		List<Bus__c> buses = getTotalBusesInWeek( weekStartDate);
		// creating the weeks array
		// default it to EMPTY								
		String[] weekAlloment = new String[DisplayBoardConstants.MAX_SLOTS_PER_WEEK];
		// Integer i = 0;
		for( Integer i = 0; i < weekAlloment.size() ; i++) {
			weekAlloment[i] = SLOT_EMPTY;
		}	
		
		// Place all OCCUPIED Slots
		for( Bus__c bus : buses) {
			weekAlloment[ bus.Slot_Index_In_Day__c.intValue()] = SLOT_OCCUPIED;
			if ( bus.Slots__c == 2) {
				weekAlloment[ bus.Slot_Index_In_Day__c.intValue() + 1] = SLOT_OCCUPIED;
			}
		}						
	
		// Build all holiday slots .. no workingday slots considered in unscheduledweek
		Integer startDaySlotIndex = 0;
		for( Integer i = 0; i < 7; i++) {
			Date processingDate = weekStartDate.addDays( i);
			Boolean isHoliday = DisplayBoardFunctions.isHoliday( processingDate);
			Integer maxSlotsForDay = DisplayBoardFunctions.maxSlotsForDay( processingDate); // on workingday count concept 
			if ( maxSlotsForDay == 0) {
				maxSlotsForDay = DisplayBoardFunctions.getDefaultSlotsPerDay( processingDate);
			}
			if ( isHoliday) {
				for ( Integer j = 0; j < maxSlotsForDay; j++) {
					Integer slotIndex = j + startDaySlotIndex;
					if ( weekAlloment[slotIndex] == SLOT_EMPTY) { 
						weekAlloment[ j + startDaySlotIndex ] = SLOT_HOLIDAY;
					} else {
						// System.debug( ' Strange: Slot is NOT Holiday. Check the logic');
					}
				}
			} 
			startDaySlotIndex = startDaySlotIndex + maxSlotsForDay;
		}
		
		// get consecutive slots perWeekMax 
		Integer consecutiveEmptySlots = 0;
		Integer startConsectiveSlotIndex = -1;
		for ( Integer i = 0; i < weekAlloment.size(); i++) {
			if ( weekAlloment[i] == SLOT_EMPTY) {
				consecutiveEmptySlots++;
				if ( startConsectiveSlotIndex == -1) {
					startConsectiveSlotIndex = i;
				} // if
				if ( consecutiveEmptySlots == perWeekMax) {
					break;
				} // if
			} else {
				consecutiveEmptySlots = 0;
				startConsectiveSlotIndex = -1;
			} // if
		}
		
		if ( startConsectiveSlotIndex == -1 || consecutiveEmptySlots != perWeekMax) {
			return null;
		} 
		
		Integer[] emptySlots = new Integer[ perWeekMax];
		for ( Integer i = 0; i < emptySlots.size(); i++) {
			emptySlots[i] = startConsectiveSlotIndex + i;
		}
    	return emptySlots;	
    }
    
    /* Existing logic with SOQL
    public static Integer[] getEmptySlots( Date mDate, Integer perWeekMax) {
		// build the holidays first and then see the index
		
		Date weekStartDate = DisplayBoardFunctions.getWeekStartDate( mDate);					
		
		if ( DisplayBoardFunctions.isScheduledWeek( weekStartDate) == true) {
			return null;
		} 
    	
		List<Bus__c> buses = [ SELECT 	Id, 
										Name,
										Bus_Length__c,
										Slot_Index__c,
										Slot_Index_In_Day__c,
										is_Reserved__c,
										is_Firm__c,
										is_Future_Holding__c,
										Mode__c,
										Quantity__c,
										Sequence__c, 
										Slots__c,
										Start_Date__c,
										Style__c,  
										Week_Start_Date__c
										FROM Bus__c 
										WHERE  
										Week_Start_Date__c = :weekStartDate
										ORDER BY 
										Week_Start_Date__c,
										Slot_Index_In_Day__c];
		
		// creating the weeks array
		// default it to EMPTY								
		String[] weekAlloment = new String[DisplayBoardConstants.MAX_SLOTS_PER_WEEK];
		// Integer i = 0;
		for( Integer i = 0; i < weekAlloment.size() ; i++) {
			weekAlloment[i] = SLOT_EMPTY;
		}	
		
		// Place all OCCUPIED Slots
		for( Bus__c bus : buses) {
			weekAlloment[ bus.Slot_Index_In_Day__c.intValue()] = SLOT_OCCUPIED;
			if ( bus.Slots__c == 2) {
				weekAlloment[ bus.Slot_Index_In_Day__c.intValue() + 1] = SLOT_OCCUPIED;
			}
		}						
	
		// Build all holiday slots .. no workingday slots considered in unscheduledweek
		Integer startDaySlotIndex = 0;
		for( Integer i = 0; i < 7; i++) {
			Date processingDate = weekStartDate.addDays( i);
			Boolean isHoliday = DisplayBoardFunctions.isHoliday( processingDate);
			Integer maxSlotsForDay = DisplayBoardFunctions.getDefaultSlotsPerDay( processingDate); // on workingday count concept 
			if ( maxSlotsForDay == 0) {
				maxSlotsForDay = DisplayBoardFunctions.getDefaultSlotsPerDay( processingDate);
			}
			if ( isHoliday) {
				for ( Integer j = 0; j < maxSlotsForDay; j++) {
					Integer slotIndex = j + startDaySlotIndex;
					if ( weekAlloment[slotIndex] == SLOT_EMPTY) { 
						weekAlloment[ j + startDaySlotIndex ] = SLOT_HOLIDAY;
					} else {
						// System.debug( ' Strange: Slot is NOT Holiday. Check the logic');
					}
				}
			} 
			startDaySlotIndex = startDaySlotIndex + maxSlotsForDay;
		}
		
		// get consecutive slots perWeekMax 
		Integer consecutiveEmptySlots = 0;
		Integer startConsectiveSlotIndex = -1;
		for ( Integer i = 0; i < weekAlloment.size(); i++) {
			if ( weekAlloment[i] == SLOT_EMPTY) {
				consecutiveEmptySlots++;
				if ( startConsectiveSlotIndex == -1) {
					startConsectiveSlotIndex = i;
				} // if
				if ( consecutiveEmptySlots == perWeekMax) {
					break;
				} // if
			} else {
				consecutiveEmptySlots = 0;
				startConsectiveSlotIndex = -1;
			} // if
		}
		
		if ( startConsectiveSlotIndex == -1 || consecutiveEmptySlots != perWeekMax) {
			return null;
		} 
		
		Integer[] emptySlots = new Integer[ perWeekMax];
		for ( Integer i = 0; i < emptySlots.size(); i++) {
			emptySlots[i] = startConsectiveSlotIndex + i;
		}
    	return emptySlots;	
    }
    */
}