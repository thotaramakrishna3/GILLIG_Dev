public with sharing class DisplayBoardDataHandler {   
	
	private static Map<String, String> modeStyleMap = null; 
	public static Integer futureHoldingCount = 0;
	public static Integer busesCount = 0;
	
	static {
		if ( modeStyleMap == null) {
			modeStyleMap = new Map<String, String>();
			modeStyleMap.put( 'CNG', 'CNG');
			modeStyleMap.put('DIESEL', 'D');
			modeStyleMap.put('ALLISON HYBRID', 'HYB');
			modeStyleMap.put('BAE HYBRID', 'BAE');
			modeStyleMap.put('ELECTRIC', 'ELEC');
			modeStyleMap.put('LOW FLOOR', 'LF');
			modeStyleMap.put('LOW FLOOR BRT', 'BRT');
			modeStyleMap.put('BRT PLUS', 'BRT+');
			modeStyleMap.put('BRTPLUS', 'BRT+');
			modeStyleMap.put('TROLLEY', 'TRLY');
			modeStyleMap.put('LOW FLOOR PLUS', 'LF+');
		} // if
	} // static
	
	private DisplayBoardDataHandler() { }
	 
// 	private static List<DisplayWeekDetails> getData( Date startDate, Date endDate) {
	private static DisplayBoardWeekDetailsWRogues getData( Date startDate, Date endDate) {
		return getData( 0, startDate, endDate);
	} // function
	
// 	public static List<DisplayWeekDetails> getData( Integer startWeekIndex, Date startDate, Date endDate) {
	public static DisplayBoardWeekDetailsWRogues getData( Integer startWeekIndex, Date startDate, Date endDate) {
		// get startDateOfWeek 
		// get Query to return all values
		// build a MAP with StartDateOfWeek as Key and List
		// build the Full list by going thru the holidays 
		// 	    if holiday, make 7 slots as holiday
		
		String rogueBuses = '';
		Date weekStartDate1 = DisplayBoardFunctions.getWeekStartDate( startDate);
		Date weekStartDate2 = DisplayBoardFunctions.getWeekStartDate( endDate);
		DisplayBoardWeekDetailsWRogues dbWeekDetailsWRogues = new DisplayBoardWeekDetailsWRogues();
		List<Bus__c> buses = [ SELECT 	Id, 
												Name,
												Bus_Length__c,
												Slot_Index__c,
												Slot_Index_In_Day__c,
												Pilot__c,
												is_Reserved__c,
												is_Firm__c,
												is_Future_Holding__c,
												is_Scheduled__c,
												Mode__c,
												Quantity__c,
												Sequence__c, 
												Slots__c,
												Start_Date__c,
												Style__c,  
												Week_Start_Date__c,
												Current_Owner__r.Internal_Name__c, 
												Current_Owner__r.Display_Board_Color__c,
												Brakes__c,
												Engine__c,
												HVAC_System__c,
												ITS_System__c,
												ITS_System_Type__c,
												Preproduction_Meeting_Date__c,
												Sales_Order_Release_Date__c,
												Transmission__c,
												Wheelchair_Ramp__c,
												Saved_By__r.Name,
												First_Bus__c, 
												Project_Sales_Manager__c,
												Passenger_Seating_Manufacturer__c,
												Rear_Door__c
												
												FROM Bus__c 
												WHERE  
												Week_Start_Date__c >= :weekStartDate1
												AND 
												Week_Start_Date__c <= :weekStartDate2
												AND
												is_Future_Holding__c = false
												ORDER BY 
												Week_Start_Date__c,
												Start_Date__c,
												Slot_Index_In_Day__c];
												
		Map<String, Bus__c> busMap = new Map<String, Bus__c>();
		List<DisplayWeekDetails> masterWeeksList = new List<DisplayWeekDetails>();
		
		busesCount = buses.size();
		 
		String mapKey = null;
		Bus__c dupBus = null;
		for ( Bus__c bus : buses) {
			mapKey = generateMapKey( bus.Start_Date__c, Integer.valueOf(bus.Slot_Index_In_Day__c));
			dupBus = busMap.get( mapKey);
			if ( dupBus != null) {
				rogueBuses = rogueBuses + 'Double Booked Slot: ' + 
							bus.Current_Owner__r.Internal_Name__c + '/' +
							bus.Name + '/' + 
							bus.Sequence__c + '/' + 
							String.valueOf(bus.Start_Date__c) + '/' + 
							bus.Slot_Index_In_Day__c + 
							' vs ' +
							dupBus.Current_Owner__r.Internal_Name__c + '/' +
				 			dupBus.Name + '/' + 
				 			dupBus.Sequence__c + '/' + 
							String.valueOf(bus.Start_Date__c) + '/' + 
				 			dupBus.Slot_Index_In_Day__c + 
				 			'\\n';
			}
			busMap.put( mapKey, bus);
		} // for
		
		// build the entire JSON objects
		// start with first week
		//     build the celldetails with holidays and empty cells and non-emptycells
		//     during the celldetails build, capture the working days and count
		//     build the weekDetails object
		
		Integer diffBwtWeeks = (weekStartDate1.daysBetween( weekStartDate2) / 7 ) + 1;
		Integer finalWeekIndex = startWeekIndex + diffBwtWeeks;
		Integer weeks = -1;
		DisplayWeekDetails dwd = null;
		for ( Integer weekIndex = startWeekIndex; weekIndex  < finalWeekIndex; weekIndex++) {
			weeks++;
			Date processingWeek = weekStartDate1.addDays( 7 * weeks);
			Boolean isScheduledWeek = DisplayBoardFunctions.isScheduledWeek( processingWeek);
			// Integer totalWorkingDays = 0;
			// Integer totalScheduledSlots = 0;
			// Integer maxSchedulableBuses = 0;
			List<DisplayCellDetails> weekCells = new List<DisplayCellDetails>();
			
			if ( isScheduledWeek == true) {
				dwd = buildScheduledWeekDetails( weekIndex, processingWeek, busMap, false);
				masterWeeksList.add( dwd);
			} else {
				dwd = buildUnScheduledWeekDetails( weekIndex, processingWeek, busMap);
				masterWeeksList.add( dwd);
			}
		} // if
												
		// return masterWeeksList;
		dbWeekDetailsWRogues.weekDetailsList = masterWeeksList;
		
		// get list of buses became rogues
		rogueBuses = rogueBuses + getUnprocessedBuses( buses);
		if ( String.isBlank( rogueBuses)) {
			rogueBuses = null;
		}
		
		dbWeekDetailsWRogues.rogueBuses = rogueBuses;
		return dbWeekDetailsWRogues;
	} // function
	
	public static DisplayWeekDetails buildScheduledWeekDetails( 	Integer weekIndex, 
																	Date processingWeek, 
																	Map<String, Bus__c> busMap,
																	Boolean isUnToScheduleConversion) { 
			//    check if week is scheduled
			//    if yes
			//      loop 7 days 
			//    	get day slots count
			//    	loop thru the day slot count and build the slot 
			//      check if the indexCount is less that max
			//      loop thru rest of the slots sunday and index last day index
			//  

			Boolean isScheduledWeek = DisplayBoardFunctions.isScheduledWeek( processingWeek);
			Integer totalWorkingDays = 0;
			Integer totalScheduledSlots = 0;
			Integer maxSchedulableBuses = 0;
			List<DisplayCellDetails> weekCells = new List<DisplayCellDetails>();
			Integer slotInWeekIndex = -1;
			Integer slotInDayIndex = 0;
			String mapKey = null;
			Date processDate = null;
			Integer maxAllowed = 0;
			Integer slotInWeekIndexRead = -1;
			
			for( Integer daysWInWeeks = 0;  daysWInWeeks < 7; daysWInWeeks++) {
				processDate = processingWeek.addDays( daysWInWeeks);
				// check if Day is holiday
				// if yes, call functions to build holiday concept
				if ( DisplayBoardFunctions.isHoliday( processDate)) {
					totalWorkingDays--;
					Integer defaultSlotsPerDay = DisplayBoardFunctions.maxSlotsForDay( processDate);
					if ( defaultSlotsPerDay == 0) {
						defaultSlotsPerDay = DisplayBoardFunctions.getDefaultSlotsPerDay( processDate);
					} 
					for ( slotInDayIndex = 0; slotInDayIndex < defaultSlotsPerDay ; slotInDayIndex++) {
						// logic will take if any holiday overrides existing bus
						if ( isUnToScheduleConversion == true ) { 
							mapKey = generateMapKey( processingWeek, slotInWeekIndex + 1);
							Bus__c busObject = busMap.get( mapKey);	
							if ( busObject == null) {
								slotInWeekIndex++;
							}
						}
						slotInWeekIndexRead++;
						weekCells.add( getHolidayCellDetails(
															weekIndex,
										 					slotInWeekIndexRead,
										 					slotInDayIndex,
										 					processingWeek,
										 					processDate,
										 					defaultSlotsPerDay));
					} // for
				} else { 
				
					// if not, get data from Map, 
					// if missing, put empty slot
					// if present, put non-empty slot, incremnet count
					// System.debug( ' Found as working day ' + processDate);
					maxAllowed = DisplayBoardFunctions.maxSlotsForDay( processDate);
					// Integer maxAllowed = 0;
					if ( maxAllowed > 0) {
						totalWorkingDays++;
						maxSchedulableBuses += maxAllowed; 
					} else {
						maxAllowed = DisplayBoardFunctions.getDefaultSlotsPerDay( processDate);
						// System.debug( 'processDate' + processDate);
						// System.debug( 'maxAllowed' + maxAllowed);
					}// if
					for ( slotInDayIndex = 0; slotInDayIndex < maxAllowed ; slotInDayIndex++) {
						// System.debug( ' building non-holiday processDate : slotInDayIndex ' + processDate + ' : ' + slotInDayIndex);
						if ( isUnToScheduleConversion == false ) { 
							mapKey = generateMapKey( processDate, slotInDayIndex);
						} else {
							mapKey = generateMapKey( processingWeek, slotInWeekIndex + 1);
						}
						Bus__c busObject = busMap.get( mapKey);
						if ( busObject == null) {
							slotInWeekIndex++;
							slotInWeekIndexRead++;
							weekCells.add( getEmptyCellDetails(
															weekIndex,
										 					slotInWeekIndexRead,
										 					slotInDayIndex,
										 					processingWeek,
										 					processDate,
										 					isScheduledWeek,
										 					maxAllowed));
						} else {
							for ( Integer multiSlotSequence = 0 ; multiSlotSequence < busObject.Slots__c; multiSlotSequence++) { 
								if ( isUnToScheduleConversion == true && 
									slotInDayIndex == ( maxAllowed - 1) && 
									busObject.Slots__c > 1 && 
									multiSlotSequence == 0) {
									break;
								} else {
									slotInWeekIndex++;
									slotInWeekIndexRead++;
									slotInDayIndex = slotInDayIndex + multiSlotSequence;
									weekCells.add( getNonEmptyCellDetails( 	weekIndex, 
																			slotInWeekIndexRead, 
																			slotInDayIndex, 
																			busObject,
																			processDate, 
																			multiSlotSequence, 
																			isScheduledWeek,
																			maxAllowed));
									totalScheduledSlots++;
								} 
							} // for 
						} // if
					} // for
				
				} // if-else 
			} // for 
  
			if ( slotInWeekIndexRead >= DisplayBoardConstants.MAX_SLOTS_PER_WEEK) { 
				// System.debug( ' All cells are processed.');
			} else {
				//slotInDayIndex++; continue from the previous value
				Integer remainingSlots = DisplayBoardConstants.MAX_SLOTS_PER_WEEK - (slotInWeekIndexRead + 1);
				remainingSlots = slotInDayIndex + remainingSlots;
				for ( ;slotInDayIndex < remainingSlots; slotInDayIndex++) {
					// get if data existing otherwise create empty cell;
						// System.debug('Outside weeks range. slotInDayIndex = ' + slotInDayIndex);
						if ( isUnToScheduleConversion == false ) { 
							mapKey = generateMapKey( processDate, slotInDayIndex);
						} else {
							mapKey = generateMapKey( processingWeek, slotInWeekIndex + 1);
						}
						// mapKey = generateMapKey( processDate, slotInDayIndex);
						Bus__c busObject = busMap.get( mapKey);
						if ( busObject == null) {
							slotInWeekIndex++;
							slotInWeekIndexRead++;
							weekCells.add( getEmptyCellDetails(
															weekIndex,
										 					slotInWeekIndexRead,
										 					slotInDayIndex,
										 					processingWeek,
										 					processDate,
										 					isScheduledWeek,
										 					maxAllowed));
						} else {
							for ( Integer multiSlotSequence = 0 ; multiSlotSequence < busObject.Slots__c; multiSlotSequence++) { 
								slotInWeekIndex++;
								slotInWeekIndexRead++;
								slotInDayIndex = slotInDayIndex + multiSlotSequence;
								weekCells.add( getNonEmptyCellDetails( 	weekIndex, 
																		slotInWeekIndexRead, 
																		slotInDayIndex, 
																		busObject,
																		processDate, 
																		multiSlotSequence, 
																		isScheduledWeek,
																		maxAllowed));
								totalScheduledSlots++;
							} // for 
						} // if
					
				} // for 
			} // if			
			// build the weekDetails
			DisplayWeekDetails dwd1 = new DisplayWeekDetails();
            dwd1.weekIndex = weekIndex;
//            Datetime processingWeekDT = DisplayBoardFunctions.convertToDatetime( processingWeek);
//            dwd1.weekDisplayString = processingWeekDT.format( 'MMM dd, YY');
			
			dwd1.weekDisplayString = DisplayBoardFunctions.getDisplayDataMMMDDYY( processingWeek);
            dwd1.weekStartDate = processingWeek;
            dwd1.totalWorkingDays = totalWorkingDays;
            dwd1.totalScheduledBuses = totalScheduledSlots;
            dwd1.maxSchedulableBuses = maxSchedulableBuses;
            dwd1.isOverbooked = isOverbooked( dwd1.maxSchedulableBuses, totalScheduledSlots);
 			dwd1.slots = weekCells;
 			dwd1.isScheduledWeek = isScheduledWeek;
 			dwd1.weekQuarter = DisplayBoardFunctions.getQuarterDetails( processingWeek);
			
			return dwd1;	
	}
	
    private static DisplayWeekDetails buildUnScheduledWeekDetails( Integer weekIndex, Date processingWeek, Map<String, Bus__c> busMap) { 
			//    check if week is scheduled
			//    if yes
			//      loop 7 days 
			//    	get day slots count
			//    	loop thru the day slot count and build the slot 
			//      check if the indexCount is less that max
			//      loop thru rest of the slots sunday and index last day index
			//  

			Boolean isScheduledWeek = DisplayBoardFunctions.isScheduledWeek( processingWeek);
			Integer totalWorkingDays = 0;
			Integer totalScheduledSlots = 0;
			Integer maxSchedulableBuses = 0;
			List<DisplayCellDetails> weekCells = new List<DisplayCellDetails>();
			Integer slotInWeekIndex = -1;
			Integer slotInDayIndex = 0;
			String mapKey = null;
			Date processDate = null;
			Integer maxAllowed = 0;
			
			for( Integer daysWInWeeks = 0;  daysWInWeeks < 7; daysWInWeeks++) {
				processDate = processingWeek.addDays( daysWInWeeks);
				// check if Day is holiday
				// if yes, call functions to build holiday concept
				if ( DisplayBoardFunctions.isHoliday( processDate)) {
					totalWorkingDays--; 
					Integer defaultSlotsPerDay = DisplayBoardFunctions.maxSlotsForDay( processDate);
					if ( defaultSlotsPerDay == 0) {
						defaultSlotsPerDay = DisplayBoardFunctions.getDefaultSlotsPerDay( processDate);
					}
					for ( slotInDayIndex = 0; slotInDayIndex < defaultSlotsPerDay ; slotInDayIndex++) {
						slotInWeekIndex++;
						weekCells.add( getHolidayCellDetails(
															weekIndex,
										 					slotInWeekIndex,
										 					slotInDayIndex,
										 					processingWeek,
										 					processDate,
										 					defaultSlotsPerDay));
					} // for
				} else { 
				
					// if not, get data from Map, 
					// if missing, put empty slot
					// if present, put non-empty slot, incremnet count
					maxAllowed = DisplayBoardFunctions.maxSlotsForDay( processDate); // to calculate the load and slots. no workingday concept in unscheduled week
					if ( maxAllowed > 0) {
						totalWorkingDays++;
						maxSchedulableBuses += maxAllowed; 
					} else {
						maxAllowed = DisplayBoardFunctions.getDefaultSlotsPerDay( processDate);
					}
					
					for ( slotInDayIndex = 0; slotInDayIndex < maxAllowed ; slotInDayIndex++) {
						mapKey = generateMapKey( processingWeek, slotInWeekIndex + 1);
						Bus__c busObject = busMap.get( mapKey);
						if ( busObject == null) {
							slotInWeekIndex++;
							weekCells.add( getEmptyCellDetails(
															weekIndex,
										 					slotInWeekIndex,
										 					slotInWeekIndex,
										 					processingWeek,
										 					processingWeek,
										 					isScheduledWeek,
										 					maxAllowed));
						} else {
							for ( Integer multiSlotSequence = 0 ; multiSlotSequence < busObject.Slots__c; multiSlotSequence++) { 
								slotInWeekIndex++;
								slotInDayIndex = slotInDayIndex + multiSlotSequence;
								weekCells.add( getNonEmptyCellDetails( 	weekIndex, 
																		slotInWeekIndex, 
																		slotInWeekIndex, 
																		busObject,
																		processingWeek, 
																		multiSlotSequence, 
																		isScheduledWeek,
																		maxAllowed));
								totalScheduledSlots++;
							} // for 
						} // if
					} // for
				
				} // if-else 
			} // for 

/*			System.debug( 		'slotInWeekIndex ' + 
								DisplayBoardConstants.MAX_SLOTS_PER_WEEK + ' ' + 
								processingWeek + ' ' + 
								slotInWeekIndex + ' ' + 
								slotInDayIndex);
*/
			if ( slotInWeekIndex >= DisplayBoardConstants.MAX_SLOTS_PER_WEEK) { 
				// System.debug( ' All cells are processed.');
			} else {
				// slotInDayIndex++;
				Integer remainingSlots = DisplayBoardConstants.MAX_SLOTS_PER_WEEK - ( slotInWeekIndex + 1);
				remainingSlots = slotInDayIndex + remainingSlots;
/*				System.debug( 	'remainingSlots ' + 
								DisplayBoardConstants.MAX_SLOTS_PER_WEEK + ' ' + 
								processingWeek + ' ' + 
								remainingSlots);
*/
				for ( ;slotInDayIndex < remainingSlots; slotInDayIndex++) {
					// get if data existing otherwise create empty cell;
						mapKey = generateMapKey( processingWeek, slotInWeekIndex + 1);
						System.debug( 'mapKey = ' + mapKey); 
						Bus__c busObject = busMap.get( mapKey);
						if ( busObject == null) {
							slotInWeekIndex++;
							weekCells.add( getEmptyCellDetails(
															weekIndex,
										 					slotInWeekIndex,
										 					slotInWeekIndex,
										 					processingWeek,
										 					processingWeek,
										 					isScheduledWeek,
										 					maxAllowed));
						} else {
							for ( Integer multiSlotSequence = 0 ; multiSlotSequence < busObject.Slots__c; multiSlotSequence++) { 
								slotInWeekIndex++;
								slotInDayIndex = slotInDayIndex + multiSlotSequence;
								weekCells.add( getNonEmptyCellDetails( 	weekIndex, 
																		slotInWeekIndex, 
																		slotInWeekIndex, 
																		busObject,
																		processingWeek, 
																		multiSlotSequence, 
																		isScheduledWeek,
																		maxAllowed));
								totalScheduledSlots++;
							} // for 
						} // if
					
				} // for 
			} // if			
			// build the weekDetails
			DisplayWeekDetails dwd1 = new DisplayWeekDetails();
            dwd1.weekIndex = weekIndex;
            // Datetime processingWeekDT = DisplayBoardFunctions.convertToDatetime( processingWeek);
            // dwd1.weekDisplayString = processingWeekDT.format( 'MMM dd, YY');
 
  			dwd1.weekDisplayString = DisplayBoardFunctions.getDisplayDataMMMDDYY( processingWeek);
            dwd1.weekStartDate = processingWeek;
            dwd1.totalWorkingDays = totalWorkingDays;
            dwd1.totalScheduledBuses = totalScheduledSlots;
            dwd1.maxSchedulableBuses = maxSchedulableBuses;
            dwd1.isOverbooked = isOverbooked( dwd1.maxSchedulableBuses, totalScheduledSlots);
 			dwd1.slots = weekCells;
 			dwd1.isScheduledWeek = isScheduledWeek;
 			dwd1.weekQuarter = DisplayBoardFunctions.getQuarterDetails( processingWeek);
			
			return dwd1;	
	}
		
	
	private static Boolean isOverbooked( Integer maxSchedulableBuses, Integer totalScheduledSlots) {
		
		if ( totalScheduledSlots > maxSchedulableBuses) {
			return true;
		} else {
			return false;
		}
		return false;
	} // function
	
	private static DisplayCellDetails getHolidayCellDetails(
											Integer weekIndex,
											Integer slotInWeekIndex,
											Integer slotInDayIndex,
											Date startDateOfWeek,
											Date processDate,
											Integer maxAllowed) {
												
		DisplayCellDetails holidayCell = new DisplayCellDetails();
		holidayCell.sWeekIndex = weekIndex;
        holidayCell.slotIndex = slotInWeekIndex;
        holidayCell.slotInDayIndex = slotInDayIndex;
		holidayCell.isHoliday = true;
        holidayCell.isEmpty = false;
        holidayCell.isMovable = false;
        holidayCell.sWeekStartDate = startDateOfWeek;
        holidayCell.slotDate = processDate;
        holidayCell.maxSlots = maxAllowed;
        holidayCell.bus = null;
		return holidayCell;
	}
	
	private static DisplayCellDetails getEmptyCellDetails(
											Integer weekIndex,
											Integer slotInWeekIndex,
											Integer slotInDayIndex,
											Date startDateOfWeek,
											Date processDate,
											Boolean isScheduledWeek,
											Integer maxAllowed) {
												
		DisplayCellDetails emptyCell = new DisplayCellDetails();
		emptyCell.sWeekIndex = weekIndex;
        emptyCell.slotIndex = slotInWeekIndex;
        emptyCell.slotInDayIndex = slotInDayIndex;
		emptyCell.isHoliday = false;
        emptyCell.isEmpty = true;
        emptyCell.isMovable = false;
        emptyCell.sWeekStartDate = startDateOfWeek;
        emptyCell.slotDate = processDate;
        emptyCell.maxSlots = maxAllowed;
        emptyCell.bus = null;
        emptyCell.isScheduledSlot = isScheduledWeek;
		return emptyCell;
	}
	
	private static DisplayCellDetails getNonEmptyCellDetails( 	
											Integer weekIndex,
											Integer slotInWeekIndex,
											Integer slotInDayIndex, 
											Bus__c busObject,  
											Date processDate,
											Integer multiSlotSequence,
											Boolean isScheduledWeek,
											Integer maxAllowed) {
		
		// System.debug( ' getNonEmptyCellDetails() processDate : slotInDayIndex ' + processDate + ' : ' + slotInDayIndex);
		DisplayBoardBusDetails bus = new DisplayBoardBusDetails();
		bus.recordID = busObject.ID; 
		if ( busObject.Current_Owner__r.Internal_Name__c != null) { 
			String bName = busObject.Current_Owner__r.Internal_Name__c;
			bName = bName.replace(' ', '');
			if ( bName.length() > DisplayBoardConstants.CUSTOMER_NAME_LENGTH ) { 
		    	bus.companyName = bName.substring(0, DisplayBoardConstants.CUSTOMER_NAME_LENGTH).replace('\'','');
			} else { 
		    	bus.companyName = bName.replace('\'','');
			} // if
		} else {
			bus.companyName = 'NO NAME';
		}
        bus.isPilot = busObject.Pilot__c;
        bus.isReserved = busObject.is_Reserved__c;
        if ( busObject.Mode__c != null) { 
        	bus.mode = DisplayBoardFunctions.removeExtraCommas( busObject.Mode__c);
        } else {
        	bus.mode = '-';
        }
        if ( busObject.Sequence__c != null) {
        	bus.sequenceNumber = busObject.Sequence__c + '/' + busObject.Quantity__c;
        } else {                                  
       		bus.sequenceNumber = '-/' + busObject.Quantity__c;
        }
        bus.sequence = Integer.valueOf( busObject.Sequence__c);
        bus.quantity = Integer.valueOf( busObject.Quantity__c);
        bus.serialNumber = busObject.Name;
        if ( busObject.Style__c != null) {
        	bus.style = DisplayBoardFunctions.removeExtraCommas( busObject.Style__c);
        } else {
        	bus.style = '-';
        }
		// for display only
		if ( bus.style.contains( ',')) {
			bus.styleDisplay = 'TBD';
		} else {
			bus.styleDisplay = buildStyleString( bus.style);
		}
        
        bus.slotSize = Integer.valueOf( busObject.Slots__c);
        bus.multiSlotSequence = multiSlotSequence + 1 ; 
		bus.isFutureHolding = busObject.is_Future_Holding__c; 
		if (busObject.Bus_Length__c != null) {
			bus.busLength = DisplayBoardFunctions.removeExtraCommas( busObject.Bus_Length__c);
		} else {
			bus.busLength = '-';
		}
		// for display only
		if ( bus.busLength.contains( ',')) {
			bus.lengthDisplay = 'TBD';
		} else {
			bus.lengthDisplay = bus.busLength;
		}
		
		if ( busObject.Current_Owner__r.Display_Board_Color__c == null) { 
			bus.companyColor = '#FFFFFF';
		} else {
			bus.companyColor = busObject.Current_Owner__r.Display_Board_Color__c;
		}
        bus.modeStyleDisplay = buildModeStyleString( bus.mode, bus.style);
		bus.isFirm = busObject.is_Firm__c;
		bus.isScheduled = busObject.is_Scheduled__c;
		
		// new field 03/30/2017
		bus.brakes = busObject.Brakes__c;
		bus.engine = busObject.Engine__c;
		bus.HVACSystem = busObject.HVAC_System__c;
		bus.ITSSystem = busObject.ITS_System__c;
		bus.ITSSystemType = busObject.ITS_System_Type__c;
		bus.preprodMeetingDate = busObject.Preproduction_Meeting_Date__c;
		bus.SOReleaseDate = busObject.Sales_Order_Release_Date__c; 
		bus.transmission = busObject.Transmission__c;
		bus.wheelchairRamp = busObject.Wheelchair_Ramp__c; 
		bus.savedBy = busObject.Saved_By__r.Name;
		bus.firstBus = busObject.First_Bus__c;
		bus.projectSalesMgr = busObject.Project_Sales_Manager__c;

		DisplayCellDetails nonEmptyCell = new DisplayCellDetails();
		nonEmptyCell.sWeekIndex = weekIndex;
        nonEmptyCell.slotIndex = slotInWeekIndex;
        nonEmptyCell.slotInDayIndex = slotInDayIndex;
       	nonEmptyCell.sWeekStartDate = busObject.Week_Start_Date__c;
   	
		nonEmptyCell.isHoliday = false;
        nonEmptyCell.isEmpty = false;
        nonEmptyCell.isMovable = true;
        
        nonEmptyCell.slotDate = processDate;
        nonEmptyCell.maxSlots = maxAllowed;
        nonEmptyCell.bus = bus;
        
        nonEmptyCell.isScheduledSlot = isScheduledWeek;
        
 		if ( busObject.Slots__c == ( multiSlotSequence + 1)) {  
 			busObject.Name = 'DISPLAYED'; 
 		}
		return nonEmptyCell; 
	} 
	
	private static String buildModeStyleString( String mode, String style) {
		String modeShortCut = '-';
		String styleShortCut = '-';
		if ( mode != null && mode != '-') {
			modeShortCut = modeStyleMap.get( mode.toUpperCase());
		}
		if ( style != null && style != '-') {
			styleShortCut = modeStyleMap.get( style.toUpperCase());
		}
		return modeShortCut + '/' + styleShortCut; 
	}
	
	private static String buildStyleString( String style) {
		String styleShortCut = '-';
		if ( style != null && style != '-') {
			styleShortCut = modeStyleMap.get( style.toUpperCase());
		}
		return styleShortCut; 
	}
	
	private static String generateMapKey( Datetime mDate, Integer slotIndex) {
		return generateMapKey( DisplayBoardFunctions.convertToDate( mDate), slotIndex);
	}
	
	private static String generateMapKey( Date mDate, Integer slotIndex) {
		return String.valueOf( mDate) + '-'+ String.valueOf(slotIndex);
	}
	
	public static void buildUpdateBusRecord( String userRecordID, List<DisplayCellDetails> updatedCells) {
		
		Set<String> listOfRecordIDs = new Set<String>();
		For( DisplayCellDetails cellDetails: updatedCells) {
			if ( cellDetails.bus != null ) { 
				listOfRecordIDs.add( cellDetails.bus.recordID);
			}
		}
		
		Map<ID, Bus__c> updatedBuses = new Map<ID, Bus__c>( [SELECT 	Id, 
												Name,
												Bus_Length__c,
												Slot_Index__c,
												Slot_Index_In_Day__c,
												Pilot__c,
												is_Reserved__c,
												is_Firm__c,
												is_Future_Holding__c,
												Mode__c,
												Quantity__c,
												Sequence__c, 
												Slots__c,
												Start_Date__c,
												Style__c,  
												Week_Start_Date__c,
												Saved_By__c
												  
												FROM Bus__c 
												WHERE  
												Id IN :listOfRecordIDs]);
		
		List<Bus__c>	udpatedObjects = new List<Bus__c>();
		
		Id futureHoldingRecordTypeId = Schema.SObjectType.Bus__c.getRecordTypeInfosByName().get('To Be Scheduled').getRecordTypeId();

		Id reservedRecordTypeId = Schema.SObjectType.Bus__c.getRecordTypeInfosByName().get('Reserved').getRecordTypeId();
		Id scheduledRecordTypeId = Schema.SObjectType.Bus__c.getRecordTypeInfosByName().get('Scheduled').getRecordTypeId();
		Id firmRecordTypeId = Schema.SObjectType.Bus__c.getRecordTypeInfosByName().get('Firm').getRecordTypeId();


		
		For( DisplayCellDetails cellDetails : updatedCells) {
			Bus__c bus = updatedBuses.get( cellDetails.bus.recordID);
			
			if ( cellDetails.bus.slotSize > 1 && cellDetails.bus.multiSlotSequence > 1) {
				// System.debug( 'Found multislot bus. Skip the sub slots.');
				continue;
			}
			
			if ( cellDetails.isFutureHoldingSlot == true) {
				bus.Week_Start_Date__c = null;
				bus.Start_Date__c = null;
				bus.Slot_Index__c = 0;
				bus.Slot_Index_In_Day__c = 0;
//				bus.RecordTypeID = futureHoldingRecordTypeId;
			} else { 
				if ( bus.is_Future_Holding__c == true) {
					// System.debug( 'Moving future holding into Scheduled / unscheduled');
				} // if
				bus.Week_Start_Date__c = cellDetails.sWeekStartDate;
				bus.Start_Date__c = cellDetails.slotDate;
				bus.Slot_Index__c = cellDetails.slotIndex;
				bus.Slot_Index_In_Day__c = cellDetails.slotInDayIndex;
//				if ( cellDetails.isScheduledSlot == true) {
//					bus.RecordTypeID = firmRecordTypeId;
//				} else {
//					bus.RecordTypeID = scheduledRecordTypeId;
//				}
			} // if
			bus.Saved_By__c = userRecordID;
			udpatedObjects.add( bus);
		}									
		
		update udpatedObjects;
		return;
	}
	
	
	public static List<DisplayWeekDetails> getFutureHoldingsData( Integer startWeekIndex, Integer weeks, Integer cols) {
		// get startDateOfWeek 
		// get Query to return all values
		// build a MAP with StartDateOfWeek as Key and List
		// build the Full list by going thru the holidays 
		// 	    if holiday, make 7 slots as holiday
		
		List<Bus__c> buses = [ SELECT 	Id, 
												Name,
												Bus_Length__c,
												Slot_Index__c,
												Slot_Index_In_Day__c, 
												Pilot__c,
												is_Reserved__c,
												is_Firm__c,
												is_Scheduled__c,
												is_Future_Holding__c,
												Mode__c,
												Quantity__c,
												Sequence__c, 
												Slots__c,
												Start_Date__c,
												Style__c,  
												Week_Start_Date__c,
												Current_Owner__r.Internal_Name__c,
												Current_Owner__r.Display_Board_Color__c,
												Brakes__c,
												Engine__c,
												HVAC_System__c,
												ITS_System__c,
												ITS_System_Type__c,
												Preproduction_Meeting_Date__c,
												Sales_Order_Release_Date__c,
												Transmission__c,
												Wheelchair_Ramp__c,
												Saved_By__r.Name,
												First_Bus__c,
												Project_Sales_Manager__c,
												Passenger_Seating_Manufacturer__c,
												Rear_Door__c
												 
												FROM Bus__c 
												WHERE  
												is_Future_Holding__c = true
												ORDER BY 
												Current_Owner__r.Internal_Name__c];
												
		// get the max rows per week
		// calculate the weeks 
		// rest of them make as empty cells with proper 
		
		Integer busesCount = buses.size();
		futureHoldingCount = buses.size();
		// System.debug( 'busesCount = ' + busesCount);
		Integer busIndex = 0;
		Integer	finalIndex = startWeekIndex + weeks; 
		List<DisplayWeekDetails> masterWeeksList = new List<DisplayWeekDetails>();
		for ( Integer weekIndex = 0; weekIndex < finalIndex; weekIndex++) {
			
			List<DisplayCellDetails> slots = new List<DisplayCellDetails>();
			DisplayCellDetails slot = null;
			for ( Integer slotIndex = 0; slotIndex < cols; slotIndex++) {
				if ( busIndex >= busesCount) {
					// build empty slot
					slot = new DisplayCellDetails();
					slot.isFutureHoldingSlot = true;
					slot.sWeekIndex = weekIndex;
					slot.slotIndex = slotIndex;
					slot.slotInDayIndex = slotIndex;
					slot.slotDate = null;
					slot.isEmpty = true;
					slot.bus = null;
				} else {
					slot = getNonEmptyCellDetails( weekIndex, slotIndex, slotIndex, buses.get( busIndex), null, 0, false, 0);
					slot.isFutureHoldingSlot = true;
					slot.slotIndex = slotIndex;
					busIndex++;
				}
				slots.add( slot);
			} // for j
			
			DisplayWeekDetails dwd1 = new DisplayWeekDetails();
            dwd1.weekIndex = weekIndex;
            dwd1.weekDisplayString = '';
            dwd1.weekStartDate = null;
            dwd1.weekQuarter = 0;
            dwd1.totalWorkingDays = 0;
            dwd1.totalScheduledBuses = 0;
            dwd1.maxSchedulableBuses = 0;
            dwd1.isOverbooked = false;
            dwd1.isFutureHoldingWeek = true;
            dwd1.slots = slots;
			masterWeeksList.add( dwd1);
		} // for i
		
		return masterWeeksList;
	} // function
	
	private Static String getUnprocessedBuses( List<Bus__c> buses) {
		// System.debug( 'getUnprocessedBuses()');
		String rogues = ''; 
		For( Bus__c busObject: buses) {
			if ( busObject.Name != 'DISPLAYED') {
				rogues = rogues + 'Missing From DisplayBoard: ' + 
						busObject.Current_Owner__r.Internal_Name__c + '/' +
						busObject.Name + '/' + 
						busObject.Sequence__c + '/' + 
						String.valueOf(busObject.Start_Date__c) + '/' +
						busObject.Slot_Index_In_Day__c + 
						'\\n';
			}
		}
		
		return rogues;
	}
} // class