public with sharing class ExceptionDaysTriggerHandler implements ITrigger 
{
    // Constructor
    public ExceptionDaysTriggerHandler()
    {
    }
 
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore()
    {
        // If this a delete trigger Cache a list of Account Id's that are 'in use'
		if ( Trigger.isInsert) { 
		    Map<Date, Exception_Day__c> exceptionDays = new Map<Date, Exception_Day__c>();
		    Integer slotsPerWeekRows = 0;
		    List<Exception_Day__c> listObjs = ( List<Exception_Day__c>) Trigger.new;
		    for ( Exception_Day__c exceptionDay : listObjs) {
		        exceptionDays.put( exceptionDay.Exception_Date__c, exceptionDay);
		        if ( exceptionDay.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_SPWC) {
		        	slotsPerWeekRows++;
		        }
		    } // for

			if ( slotsPerWeekRows > 0) {
				// System.debug( 'Found in Insert trigger Slots Per Week Constant record');
	        	List<Exception_Day__c> slotsPerWeekRecords = [ SELECT Id FROM Exception_Day__c WHERE Type__c = :DisplayBoardConstants.EXCEPTIONDAY_TYPE_SPWC];
			    if ( slotsPerWeekRecords.isEmpty()) { 
			    	// skip the first one and rest mark as error 
			    	Boolean foundFirstOne = false;
				    for ( Exception_Day__c exceptionDay : listObjs) {
						if ( exceptionDay.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_SPWC) {
							if ( foundFirstOne == false) {
								// System.debug( 'Found first SlotsPerWeek row. Allow it be inserted');
								foundFirstOne = true;
							} else {
				        		exceptionDay.addError( 'Slots Per Week Constant record already exists. Second one can\'t be created.');
							}
						}
				    } // for
			    } else {
			    	// System.debug( 'Slots Per Week Constant record already exists. So reject all of them');
				    for ( Exception_Day__c exceptionDay : listObjs) {
						if ( exceptionDay.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_SPWC) {	
			        		exceptionDay.addError( 'Slots Per Week Constant record already exists. Second one can\'t be created.');
						}
				    } // for
			    }
			} // if

		    
		    for ( Exception_Day__c existingRecord: [SELECT Id, Name, Exception_Date__c, Type__c FROM  Exception_Day__c WHERE Exception_Date__c IN :exceptionDays.keySet()] ) {
		        Exception_Day__c newRecord = exceptionDays.get(  existingRecord.Exception_Date__c);
		        if ( (newRecord.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_H || newRecord.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_WD) && 
		             (existingRecord.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_H || existingRecord.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_WD)) { 
		            newRecord.Exception_Date__c.addError( '(' + existingRecord.Name + ') is already using the date as : ' + existingRecord.Type__c);
		        } else if ( newRecord.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_SW && existingRecord.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_SW) {
		            newRecord.Exception_Date__c.addError( '(' + existingRecord.Name + ') is already using the date as : ' + existingRecord.Type__c);
		        } else if ( newRecord.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_DSPD && existingRecord.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_DSPD) {
		            newRecord.Exception_Date__c.addError( '(' + existingRecord.Name + ') is already using the date as : ' + existingRecord.Type__c);
		        } // if
		    } // for
		    
		} // if
    }
 
 	/* executes after bulk process */
    public void bulkAfter()
    {
    }
 
    public void beforeInsert(SObject so)
    {
    	Exception_Day__c exceptionDay = ( Exception_Day__c) so;
		if ( exceptionDay.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_H) {
            String result = checkIfHolidayCanBeDeclared(exceptionDay.Exception_Date__c);
            if ( result != null )
                exceptionDay.Exception_Date__c.addError(result);
        } else if ( exceptionDay.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_WD) {
            String result = checkIfWorkDayCanBeDeclared(exceptionDay.Exception_Date__c, exceptionDay.Slots__c.intValue());
            if ( result != null )
                exceptionDay.Exception_Date__c.addError(result);
        } else if ( exceptionDay.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_SW) {
        	if ( exceptionDay.Exception_Date__c != DisplayBoardFunctions.getWeekStartDate(exceptionDay.Exception_Date__c)) {
                exceptionDay.Exception_Date__c.addError('Day has to be starting of the week (Monday)');
        	} else if ( checkIfPrevWeekScheduled( exceptionDay.Exception_Date__c) == false) {
                exceptionDay.Exception_Date__c.addError('Please make sure previous week is scheduled first.' + exceptionDay.Exception_Date__c);
        	} // if
        } else if ( exceptionDay.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_DSPD) {
        	String result = checkInsertDefaultSlotsPerDayRangeAllowed( exceptionDay.Exception_Date__c, 
        																Integer.valueOf(exceptionDay.Slots__c));
        	if ( result != null) {
        		exceptionDay.addError( result);
        	} // if
		} // if
    	
    }
 
    public void beforeUpdate(SObject oldSo, SObject so) {
    	Exception_Day__c exceptionDay = ( Exception_Day__c) so;
    	Exception_Day__c oldExceptionDay = ( Exception_Day__c) oldSo;
    	
		if ( exceptionDay.Exception_Date__c != oldExceptionDay.Exception_Date__c) {
			exceptionDay.Exception_Date__c.addError( ' Date can\'t be changed.');
		} else if ( exceptionDay.Type__c != oldExceptionDay.Type__c) { 
			exceptionDay.Type__c.addError( ' Type can\'t be changed.');
		} else if ( exceptionDay.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_SPWC && 
					exceptionDay.Slots__c < oldExceptionDay.Slots__c) {
			exceptionDay.Slots__c.addError( ' Slots count can\'t be less then previous value.');
		} else if ( exceptionDay.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_WD && exceptionDay.Slots__c != oldExceptionDay.Slots__c) {
            String result = checkIfWorkDayCanBeDeclared( 
            											exceptionDay.Exception_Date__c, 
            											exceptionDay.Slots__c.IntValue()
            											);
            if ( result != null ) {
                exceptionDay.Slots__c.addError(result);
            } // if
        } else if ( exceptionDay.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_DSPD) {
        	String result = checkUpdateDefaultSlotsPerDayRangeAllowed( exceptionDay.Exception_Date__c, 
        																Integer.valueOf(exceptionDay.Slots__c));
        	if ( result != null) {
        		exceptionDay.addError( result);
        	} // if
		} else {
			System.debug( ' Condition not checked ');
		} // if 
    }
 
    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so) {
    	Exception_Day__c exceptionDay = ( Exception_Day__c) so;
    	
		if ( exceptionDay.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_SW) {
			exceptionDay.addError( ' Scheduled week can\'t be deleted.');
		} else if ( exceptionDay.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_DSPD) {
			exceptionDay.addError( ' Default Slots Per Day record can\'t be deleted. If needed copy the previous record\'s Slots count into this record.');
		} else if ( exceptionDay.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_SPWC) { 
			exceptionDay.addError( ' Slots Per Week Constant record can\'t be deleted.');
//		} else if ( exceptionDay.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_H) { 
//		  	System.debug( 'Holidays can be deleted any time');
		} else if ( exceptionDay.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_WD) {
            String result = checkIfWorkDayCanBeDeclared(exceptionDay.Exception_Date__c, -1);
            if ( result != null )
                exceptionDay.addError(result);
		} else {
			System.debug( ' Condition not checked ');
		}
    }
 
    public void afterInsert(SObject so) {
		Exception_Day__c exceptionDay = ( Exception_Day__c) so;
		if ( exceptionDay.Type__c == DisplayBoardConstants.EXCEPTIONDAY_TYPE_SW) {
			convertWeekIntoScheduledWeek( exceptionDay.Exception_Date__c);
		}
    }
 
 	/* does not have update anything to perform after update yet*/
    public void afterUpdate(SObject oldSo, SObject so)
    {
    }
 
 	/* no post process after delete yet */
    public void afterDelete(SObject so)
    {
    }
 
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally()
    {
    }
    
    
   	private boolean checkIfPrevWeekScheduled( Date mDate) {
		// make sure previous week is already scheduled.
		Date weekStartDate = DisplayBoardFunctions.getWeekStartDate( mDate);
		Date prevWeekStartDate = weekStartDate.addDays(-7);
		// System.debug( 'prevWeekStartDate = ' + prevWeekStartDate);
		Boolean isScheduled = DisplayBoardFunctions.isScheduledWeek( prevWeekStartDate);
		// check if previous week is scheduled or not. If not, throw an error. 
		// Also make sure board start is considered before returning false;
		if ( isScheduled == true) {
			return true;
		} else {
			Date dbWeekStartDate = DisplayBoardFunctions.getWeekStartDate( DisplayBoardConstants.DB_START_DATE);
			return ( prevWeekStartDate <= dbWeekStartDate);
		} // if
	} // function
	
	private String checkInsertDefaultSlotsPerDayRangeAllowed( Date mDate, Integer newSlotsPerDay) {
		// in scheduled weeks
		// 		insert 
		//   		check if bus are configured in the slots above new slots value 
		//			from date to end of scheduled week
		// 		update
		//   		check if bus are configured in the slots above new slots value 
		//			from date to end of scheduled week
		// 		delete
		//   		not allowed. set it to previous record value 
		// in unscheduled weeks
		//  	insert
		//			7 or up is allowed.check if future holidays in unscheduled weeks need review
		// 		update
		//			up is allowed. check if future holidays in unscheduled weeks need review		
		//			decrement is allowed. check if future holidays in unscheduled weeks need review
		//  	delete 
		//			not allowed. 
		
		if ( newSlotsPerDay < DisplayBoardConstants.MIN_SLOTS_PER_DAY ) {
			return 'Slots count can\'t be below min slots per day count = ' + DisplayBoardConstants.MIN_SLOTS_PER_DAY;
		}
		
		Date weekStartDate = DisplayBoardFunctions.getWeekStartDate( mDate);
		Boolean isScheduled = DisplayBoardFunctions.isScheduledWeek( weekStartDate);
		String result = null;
		if ( isScheduled == true) {
			result = checkSlotsPerDayAllowedInScheduledWeek( mDate, newSlotsPerDay);
		} else { 
			result = checkSlotsPerDayAllowedInUnscheduledWeek( mDate, newSlotsPerDay);
		} 
		
		return result;
	}
	
	private String checkUpdateDefaultSlotsPerDayRangeAllowed( Date mDate, Integer newSlotsPerDay) {
		
		if ( newSlotsPerDay < DisplayBoardConstants.MIN_SLOTS_PER_DAY ) {
			return 'Slots count can\'t be below min slots per day count = ' + DisplayBoardConstants.MIN_SLOTS_PER_DAY;
		}
		
		Date weekStartDate = DisplayBoardFunctions.getWeekStartDate( mDate);
		Boolean isScheduled = DisplayBoardFunctions.isScheduledWeek( weekStartDate);
		String result = null;
		if ( isScheduled == true) {
			result = checkSlotsPerDayAllowedInScheduledWeek( mDate, newSlotsPerDay);
		} else { 
			result = checkSlotsPerDayAllowedInUnscheduledWeek( mDate, newSlotsPerDay);
		} 
		
		return result;
	}
	
	private String checkSlotsPerDayAllowedInScheduledWeek( Date mDate, Integer newSlotsPerDay) {
		
		// get the last scheduled week
		// from the record date till the last week date, get all the slots of buses who are configured 
		// in the slots above current value.
		// if so, return list and error
		// Otherwise process them with unscheduled list too 
		
		List<Exception_Day__c> lastScheduledWeek = [ SELECT Id, 
																		Exception_Date__c 
																		FROM 
																		Exception_Day__c 
																		WHERE
																		Type__c = 'Scheduled Week'
																		ORDER BY
																		Exception_Date__c DESC LIMIT 1];
		if ( lastScheduledWeek.isEmpty()) {
			return 'Check the code where logic thinks week is scheduled but no record found in Exception_Day__c table ';
		}
		
		Date sEndDate = lastScheduledWeek[0].Exception_Date__c;
		sEndDate = sEndDate.addDays( 7); // next monday which is unscheudled
		
		
		// get the next Default Slots Per Day record and stop before that date
		List<Exception_Day__c> nextDefaultSlotsPerDay = [ SELECT Id, 
															Exception_Date__c 
															FROM 
															Exception_Day__c 
															WHERE
															Type__c = 'Default Slots Per Day'
															AND
															Exception_Date__c > :mDate
															ORDER BY
															Exception_Date__c ASC LIMIT 1];		
		Date nextDefaultSlotsPerDayStartDate = null;
		if ( nextDefaultSlotsPerDay.isEmpty()) {
			nextDefaultSlotsPerDayStartDate = DisplayBoardConstants.DB_LIFE_END_DATE;
		} else {
			nextDefaultSlotsPerDayStartDate = nextDefaultSlotsPerDay[0].Exception_Date__c;
		}
		
		// take whichever date comes first bc we should not cross the next setting
		if ( nextDefaultSlotsPerDayStartDate < sEndDate) {
			sEndDate = nextDefaultSlotsPerDayStartDate;
		}
		
		// System.debug( 'Scheduled week end date = ' + sEndDate);
		
		List<Bus__c> occupiedBuses = [SELECT  Id,
												Start_Date__c,
												Name,
												Sequence__c,
												Slot_Index_In_Day__c,
												Current_Owner__r.Internal_Name__c
												FROM Bus__c 
												WHERE 
												Start_Date__c >= :mDate 
												and 
												Start_Date__c < :sEndDate
												AND
												Slot_Index_In_Day__c >= :newSlotsPerDay
												ORDER BY
												Start_Date__c, 
												Slot_Index_In_Day__c];

		String result = null;
		For( Bus__c bus: occupiedBuses) {
			// exclude all buses from working days
			Boolean isWorkingDay = DisplayBoardFunctions.isWorkingDay( bus.Start_Date__c);
			if ( isWorkingDay == true) {
				// System.debug('found bus in working day = ' + bus);
				continue;
			}
			if ( result == null) {
				result = '<span> Move out the following buses to different locations before configuring date </br>';
			}
			result = result + bus.Current_Owner__r.Internal_Name__c + ':' + String.valueOf(bus.Start_Date__c) + ':' + bus.Name + ':' + bus.Sequence__c + '</br>';
		}
		
		if  (result != null) {
			return result + '</span>';
		}
		
		Boolean isNextDSlotsDayScheduled = DisplayBoardFunctions.isScheduledWeek( nextDefaultSlotsPerDayStartDate);
		if ( isNextDSlotsDayScheduled == true) {
			// System.debug('Next Slot configuration is already scheduled. So need to check in unsched.');
			return null;
		}

		result = checkSlotsPerDayAllowedInUnscheduledWeek( mDate, newSlotsPerDay);
		return result;
	}


	private String checkSlotsPerDayAllowedInUnscheduledWeek( Date mDate, Integer newSlotsPerDay) {
		return checkSlotsPerDayAllowedInUnscheduledWeek( mDate, newSlotsPerDay, null, null);
	}	

	private String checkSlotsPerDayAllowedInUnscheduledWeek( Date mDate, 
															Integer newSlotsPerDay, 
															Date lastScheduledWeekDate,
															Date nextDSlotsPerDayDate) {

		// System.debug( 'checkSlotsPerDayAllowedInUnscheduledWeek ' + mDate + ' - ' + newSlotsPerDay);
		List<Bus__c> occupiedBuses = new List<Bus__c>();
		
		// get all holiday dates from the DB which are after mDate but before next slotsperday date
		// check if the holiday is in scheduled or unscheduled week
		// if unscheduled
		//     using newSlotsPerDay, find the startIndex and endIndex
		//     goto the DB and see if bus is scheduled on those indexes.
		//     if yes, keep the list of buses 
		
		Date slotRangeEndDate = null;
		if ( nextDSlotsPerDayDate == null ) { 
			List<Exception_Day__c> nextSlotsPerDayDefinitionList = [ SELECT Id, 
																		Exception_Date__c 
																		FROM 
																		Exception_Day__c 
																		WHERE
																		Exception_Date__c > :mDate 
																		AND
																		Type__c = 'Default Slots Per Day'
																		ORDER BY
																		Exception_Date__c ASC LIMIT 1];
			if ( nextSlotsPerDayDefinitionList.isEmpty()) {
				slotRangeEndDate = DisplayBoardConstants.DB_LIFE_END_DATE;
			} else {
				slotRangeEndDate = nextSlotsPerDayDefinitionList[0].Exception_Date__c;
			}
		} else {
			slotRangeEndDate = nextDSlotsPerDayDate;
		}
		
		// include entire week to capture the holidays and movement in slots due to holidays
		Date endWeekStartDate = DisplayBoardFunctions.getWeekStartDate( slotRangeEndDate);
		endWeekStartDate = endWeekStartDate.addDays( 7);
		slotRangeEndDate = endWeekStartDate; 
		
		Date slotRangeStartDate = null;
		if ( lastScheduledWeekDate == null) {
			slotRangeStartDate = mDate;
		} else {
			slotRangeStartDate = lastScheduledWeekDate;
		}
 		
		List<Exception_Day__c> holidayList = [ SELECT 	Id, 
														Exception_Date__c 
														FROM Exception_Day__c 
														WHERE
														Exception_Date__c >= :slotRangeStartDate 
														AND 
														Exception_Date__c < :slotRangeEndDate
														AND
														Type__c = :DisplayBoardConstants.EXCEPTIONDAY_TYPE_H
														ORDER BY
														Exception_Date__c ASC];
														
		// System.debug( 'Holidays List Size = ' + holidayList.size());
		
		if ( !holidayList.isEmpty()) {
			DisplayBoardConstants.rebuildDefaultSlotsPerDayRange( mDate, newSlotsPerDay);
		}
		
		// build dynamic query to avoid SOQL in loop
		String holidayCheckSOQL = '';
		String holidayCheckWMSlotsSOQL = '';
		For ( Exception_Day__c holiday: holidayList) {
			Date weekStartDate = DisplayBoardFunctions.getWeekStartDate( holiday.Exception_Date__c);
			Boolean isScheduledWeek = DisplayBoardFunctions.isScheduledWeek( weekStartDate);
			if ( isScheduledWeek == true) {
				continue;
			} // if
			
			// find starting and ending index 
			// Integer dayInWeek = DisplayBoardFunctions.getDayInWeek( holiday.Exception_Date__c);
			Integer[] startEndIndex = DisplayBoardFunctions.getStartEndIndexInUnscheduledWeek( holiday.Exception_Date__c);
			Integer startIndex = startEndIndex[0];
			Integer endIndex = startEndIndex[1];
			// System.debug( 'holiday = ' + holiday );
			// System.debug( startEndIndex);
			
			if ( !String.isBlank( holidayCheckSOQL) ) {
				holidayCheckSOQL = holidayCheckSOQL + ' OR ';
			} // if
			holidayCheckSOQL = holidayCheckSOQL + 
// 								'(Start_Date__c = ' + '\'' + String.valueOf( weekStartDate) + '\'' +
								'(Start_Date__c = ' + String.valueOf( weekStartDate)  +
								' AND ' + 
								' Slot_Index_In_Day__c >= ' + startIndex +
								' AND ' + 
								' Slot_Index_In_Day__c <= ' + endIndex + ') ';
								  
						
			// check if previous cell is 2 slots
			if ( startIndex == 0) {
				continue;
			}
			if ( !String.isBlank( holidayCheckWMSlotsSOQL) ) {
				holidayCheckWMSlotsSOQL = holidayCheckWMSlotsSOQL + ' OR ';
			} // if
			
			Integer previousSlot = startIndex - 1;
			holidayCheckWMSlotsSOQL = holidayCheckWMSlotsSOQL + 
// 								'(Start_Date__c = ' + '\'' + String.valueOf( weekStartDate) + '\'' +
								'(Start_Date__c = ' + String.valueOf( weekStartDate) +
								' AND ' + 
								' Slot_Index_In_Day__c = ' + previousSlot + 
								' AND ' + 
								' Slots__c > 1 )' ;
		} // for building SOQL
		
		if ( !String.isBlank(holidayCheckSOQL)) {
			holidayCheckSOQL = 	'SELECT  Id, ' + 
								'Start_Date__c, ' +
								' Name, ' +
								' Sequence__c, ' +
								' Current_Owner__r.Internal_Name__c ' + 
								' FROM Bus__c ' + 
								' WHERE ' + 
								holidayCheckSOQL + 
								' ORDER BY ' + 
								' Slot_Index_In_Day__c';
								
			// System.debug( holidayCheckSOQL);
			List<sObject> sobjList = Database.query( holidayCheckSOQL);	
			if ( !sobjList.isEmpty()) {
				For( sObject busObj : sobjList) { 
					Bus__c bus = (Bus__c) busObj;
					occupiedBuses.add( bus);
				} // for
			} // if
		}  // if

		if ( !String.isBlank(holidayCheckWMSlotsSOQL)) {
			holidayCheckWMSlotsSOQL = 	'SELECT  Id, ' + 
								'Start_Date__c, ' +
								' Name, ' +
								' Sequence__c, ' +
								' Current_Owner__r.Internal_Name__c ' + 
								' FROM Bus__c ' + 
								' WHERE ' + 
								holidayCheckWMSlotsSOQL + 
								' ORDER BY ' + 
								' Slot_Index_In_Day__c';
								
			// System.debug( holidayCheckWMSlotsSOQL);
			List<sObject> sobjList = Database.query( holidayCheckWMSlotsSOQL);	
			if ( !sobjList.isEmpty()) {
				For( sObject busObj : sobjList) { 
					Bus__c bus = (Bus__c) busObj;
					occupiedBuses.add( bus);
				} // for
			} // if
		} // if
		
/*		
		// SOQL in loop
		For ( Exception_Day__c holiday: holidayList) {
			Date weekStartDate = DisplayBoardFunctions.getWeekStartDate( holiday.Exception_Date__c);
			Boolean isScheduledWeek = DisplayBoardFunctions.isScheduledWeek( weekStartDate);
			if ( isScheduledWeek == true) {
				continue;
			} // if
			
			// find starting and ending index 
			// Integer dayInWeek = DisplayBoardFunctions.getDayInWeek( holiday.Exception_Date__c);
			Integer[] startEndIndex = DisplayBoardFunctions.getStartEndIndexInUnscheduledWeek( holiday.Exception_Date__c);
			Integer startIndex = startEndIndex[0];
			Integer endIndex = startEndIndex[1];
			// System.debug( 'holiday = ' + holiday );
			// System.debug( startEndIndex);
			List<Bus__c> occupiedWithInWeekBuses = [SELECT  Id,
															Start_Date__c,
															Name,
															Sequence__c,
															Current_Owner__r.Internal_Name__c
															FROM Bus__c 
															WHERE Start_Date__c = :weekStartDate
															AND
															Slot_Index_In_Day__c >= :startIndex
															AND 
															Slot_Index_In_Day__c <= :endIndex
															ORDER BY 
															Slot_Index_In_Day__c];
			if ( !occupiedWithInWeekBuses.isEmpty()) {
				occupiedBuses.addAll( occupiedWithInWeekBuses);
			} // if
			
			// check if previous cell is 2 slots
			if ( startIndex == 0) {
				continue;
			}
			
			Integer previousSlot = startIndex - 1;
			List<Bus__c> buses = [ SELECT 	Id, 
													Name,
													Slot_Index__c,
													Slot_Index_In_Day__c,
													Slots__c,
													Start_Date__c,
													Week_Start_Date__c,
													Sequence__c,
													Current_Owner__r.Internal_Name__c
	
													FROM Bus__c 
													WHERE  
													Start_Date__c = :weekStartDate 
													AND
													Slot_Index_In_Day__c = :previousSlot
													AND
													Slots__c > 1
													ORDER BY 
													Start_Date__c,
													Slot_Index_In_Day__c];
			if ( !buses.isEmpty()) {
				occupiedBuses.addAll( buses);
			}
		}
*/
			
		String result = null;
		For( Bus__c bus: occupiedBuses) {
			if ( result == null) {
				result = 'Move out the following buses to different locations before configuring date <BR/>';
			}
			result = result + bus.Current_Owner__r.Internal_Name__c + ':' + String.valueOf(bus.Start_Date__c) + ':' + bus.Name + ':' + bus.Sequence__c + '</br>';
		}
		
		return result;
	}
	
	public static String checkIfWorkDayCanBeDeclared( Date mDate, Integer maxSlots) {
		// get week start date
		// get if week is scheduled or not
		// if scheduled
		//    process based on startDate and SlotInDayIndex
		// if Unscheduled
		//	  process based on date start index and end index in the slotIndex and use weekstart date as processing date
		Integer newMaxSlots = maxSlots;
		Date weekStartDate = DisplayBoardFunctions.getWeekStartDate( mDate); 
		if ( maxSlots == -1) {
			// maxSlots = DisplayBoardConstants.MIN_SLOTS_PER_DAY;
			newMaxSlots = DisplayBoardFunctions.getDefaultSlotsPerDay( mDate);
		} 
		
		Boolean isScheduledWeek = DisplayBoardFunctions.isScheduledWeek( weekStartDate);
		
		if ( isScheduledWeek == true) { 
			return checkWorkingDayAllowedInScheduledWeek( mDate, newMaxSlots);
		} else {
			// check in the unschduled week
			// Increasing or reducing working day slots in un-scheduled weeks is fine
			// it effects only the over-load concept but not the slot vs slot days
			// System.debug('Week is still in un-scheduled. Okay to increase or decrease working day slots size');
			return null;
		}
		
		return null;
	} 
	
	private static String checkWorkingDayAllowedInScheduledWeek( Date mDate, Integer maxSlots) {
		
		// get list of buses scheduled with the date order by slotInDayIndex
		List<Bus__c> buses = [ SELECT 	Id, 
												Name,
												Slot_Index__c,
												Slot_Index_In_Day__c,
												Slots__c,
												Start_Date__c,
												Week_Start_Date__c,
												Current_Owner__r.Internal_Name__c

												FROM Bus__c 
												WHERE  
												Start_Date__c = :mDate 
												AND
												Slot_Index_In_Day__c >= :maxSlots
												ORDER BY 
												Start_Date__c,
												Slot_Index_In_Day__c];
		if ( buses.isEmpty()) {
			return null;
		}	
		
		String errorStr = null;
		for( Bus__c bus: buses) {
			for ( Integer i = 0; i < bus.Slots__c; i++) { 
				if ( ( bus.Slot_Index_In_Day__c + i) >= maxSlots) { 
					if ( errorStr == null) {
						errorStr  = 'Buses are already scheduled for day ( AccountName:SerialNumber) : ';
					}
					errorStr = errorStr + '('+ bus.Current_Owner__r.Internal_Name__c + ':' + bus.Name + ') ';
				} // if
			} // for
		} // for
		if ( errorStr != null) {
			errorStr = errorStr + '. Please move the buses into different days before setting work day max slots = ' + maxSlots;								
		}
		
		return errorStr;
		
	}
	
	public static String checkIfHolidayCanBeDeclared( Date mDate) {
		// get week start date
		// get if week is scheduled or not
		// if scheduled
		//    process based on startDate and SlotInDayIndex
		// if Unscheduled
		//	  process based on date start index and end index in the slotIndex and use weekstart date as processing date
		Date weekStartDate = DisplayBoardFunctions.getWeekStartDate( mDate); 
		Boolean isScheduledWeek = DisplayBoardFunctions.isScheduledWeek( weekStartDate);
		
		if ( isScheduledWeek == true) { 
			// check in the scheduled week
			return checkHolidayAllowedInScheduledWeek( mDate);
		} else {
			// check in the unschduled week
			return checkHolidayAllowedInUnScheduledWeek( mDate);
		} // if
		return null;
	}
	
	private static String checkHolidayAllowedInUnScheduledWeek( Date mDate) {
		Date weekStartDate = DisplayBoardFunctions.getWeekStartDate( mDate); 
		// get the weekStartDate
		// use the process to pick  
		Integer startIndex = 0;
		Integer endIndex = 0;
		Integer slotIndex = 0;
		Date processDate = null;
		for( Integer daysWInWeeks = 0;  daysWInWeeks < 7; daysWInWeeks++) {
			processDate = weekStartDate.addDays( daysWInWeeks);
			if ( processDate == mDate) {
				startIndex = slotIndex;
			}
			if ( DisplayBoardFunctions.isHoliday( processDate)) {
				slotIndex = slotIndex + DisplayBoardFunctions.getDefaultSlotsPerDay( processDate);
			} else {
				Integer maxAllowed = DisplayBoardFunctions.maxSlotsForDay( processDate); // no workingday slots matters in unscheduledweek
				// Integer maxAllowed = 0;
				if ( maxAllowed > 0) {
					// System.debug( ' Found day in the Bus Plant Day as working day. do increment the working days');
				} else {
					// System.debug( ' NOT Found in the Bus Plant Day as working day.');
					maxAllowed = DisplayBoardFunctions.getDefaultSlotsPerDay( processDate);
				}// if
				slotIndex += maxAllowed;
			} // if 
			if ( processDate == mDate) {
				endIndex = slotIndex - 1;
				break;
			} // if
		} // for

		List<Bus__c> buses = [ SELECT 	Id, 
												Name,
												Slot_Index__c,
												Slot_Index_In_Day__c,
												Slots__c,
												Start_Date__c,
												Week_Start_Date__c,
												Current_Owner__r.Internal_Name__c

												FROM Bus__c 
												WHERE  
												Start_Date__c = :weekStartDate 
												AND
												Slot_Index_In_Day__c >= :startIndex
												AND 
												Slot_Index_In_Day__c <= :endIndex
												ORDER BY 
												Start_Date__c,
												Slot_Index_In_Day__c];
		if ( !buses.isEmpty()) {
			String errorStr = 'Buses are scheduled for the day (AccountName:SerialNumber): ';
			For ( Bus__c bus : buses) {
				errorStr = errorStr + '(' + bus.Current_Owner__r.Internal_Name__c + ':' + bus.Name + ') ';
			}	
			errorStr = errorStr + '. Please move the buses into different days before declaring as holiday.';								
			return errorStr;	
		}
		
		// check if previous cell is 2 slots
		if ( startIndex == 0) {
			return null;
		}
		
		Integer previousSlot = startIndex - 1;
		buses = [ SELECT 	Id, 
												Name,
												Slot_Index__c,
												Slot_Index_In_Day__c,
												Slots__c,
												Start_Date__c,
												Week_Start_Date__c,
												Current_Owner__r.Internal_Name__c

												FROM Bus__c 
												WHERE  
												Start_Date__c = :weekStartDate 
												AND
												Slot_Index_In_Day__c = :previousSlot
												AND
												Slots__c > 1
												ORDER BY 
												Start_Date__c,
												Slot_Index_In_Day__c];
		if ( buses.isEmpty()) {
			return null;
		}
		
		if ( buses[0].Slots__c > 1) {
			String errorStr = 'Multislot bus is scheduled for the day (AccountName:SerialNumber): ';
			For ( Bus__c bus : buses) {
				errorStr = errorStr + '(' + bus.Current_Owner__r.Internal_Name__c + ':' + bus.Name + ') ';
			}	
			errorStr = errorStr + '. Please move the buses into different days before declaring as holiday.';								
			return errorStr;	
		}
		
		return null;

	}
	
	
	private static String checkHolidayAllowedInScheduledWeek( Date mDate) {
		// get the list of buses scheduled on date 
		// if list is more than 0, return error otherwise null
		List<Bus__c> buses = [ SELECT 	Id, 
												Name,
												Slot_Index__c,
												Slot_Index_In_Day__c,
												Slots__c,
												Start_Date__c,
												Week_Start_Date__c,
												Current_Owner__r.Internal_Name__c

												FROM Bus__c 
												WHERE  
												Start_Date__c = :mDate
												ORDER BY 
												Start_Date__c,
												Slot_Index_In_Day__c];
		if ( buses.isEmpty()) {
			return null;
		}
		String errorStr = 'Buses are scheduled for the day (AccountName:SerialNumber): ';
		For ( Bus__c bus : buses) {
			errorStr = errorStr + '(' + bus.Current_Owner__r.Internal_Name__c + ':' + bus.Name + ') '; 
		}									
		errorStr = errorStr + '. Please move the buses into different days before declaring as holiday.';								
		return errorStr;	
	} // function
	
	public static Boolean convertWeekIntoScheduledWeek( Date mDate) {
		Date weekStartDate = DisplayBoardFunctions.getWeekStartDate( mDate); 
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
												Week_Start_Date__c = :weekStartDate
												ORDER BY 
												Week_Start_Date__c,
												Start_Date__c,
												Slot_Index_In_Day__c];
												
		Map<String, Bus__c> busMap = new Map<String, Bus__c>();
		List<DisplayWeekDetails> masterWeeksList = new List<DisplayWeekDetails>();
		
		String mapKey = null;
		for ( Bus__c bus : buses) {
			mapKey = DisplayBoardFunctions.generateMapKey( bus.Start_Date__c , Integer.valueOf(bus.Slot_Index_In_Day__c));
			busMap.put( mapKey, bus);
		} // for
		 
		DisplayWeekDetails dwd = DisplayBoardDataHandler.buildScheduledWeekDetails( 0, 
															weekStartDate, 
															busMap,
															true);
		List<DisplayCellDetails> fullWeekSlots = dwd.slots;
		List<DisplayCellDetails> saveSales = new List<DisplayCellDetails>();
		
		for ( DisplayCellDetails slot: fullWeekSlots) {
			if ( slot.bus != null) {
				saveSales.add( slot);
			}
		}
		String jsonString = JSON.serialize( saveSales);
    	List<DisplayCellDetails> updatedCellDetails = (List<DisplayCellDetails>) 
    													System.JSON.deserialize( 
    																jsonString, 
    																List<DisplayCellDetails>.class);
		DisplayBoardDataHandler.buildUpdateBusRecord( null, updatedCellDetails);
		return false;
	} // function
 
} // class