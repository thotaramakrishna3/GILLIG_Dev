public class DisplayBoardController {     
	
	transient public String displayBoardSettings; 
	public String saveString { get; set; }
	public String saveInputJson { get; set;}
	public String pingTime { get; set;}
	public Boolean validManager { get; set;} 
	public String userRecordID { get; set; }
    public String password { get; set; }
	Integer count = 0; // for polling counter
	
	/* 
    public String getOneYearLayout() {
        String jsonString = JSON.serialize( getDisplayBoardSettings());
        return jsonString;
    }
    */
    
    public String getDisplayBoardData() {
    	
    	if ( ApexPages.currentPage() != null) { 
	    	String historyID = ApexPages.currentPage().getParameters().get('historyid');
	    	if ( historyID != null && DisplayBoardFunctions.IsAlphaNumeric(historyID)) {
		    	ID hID = ID.valueOf( historyID);
	    		return DisplayBoardHistoryHandle.getHistorySnapShot( historyID);
	    	}
    	} // if
    	
    	DisplayBoardData dbData = new DisplayBoardData();
    	
    	// build displayboard settings
    	DisplayBoardSettings dbSettings = getDisplayBoardSettingsDetails();
		dbData.settings =  dbSettings;
		
		// build display board cell details
		DisplayBoardWeekDetailsWRogues dbWeekDetailsWRogues = getFutureHoldingAndScheduledDataDetails();
		dbData.schedules = dbWeekDetailsWRogues.weekDetailsList;
		dbData.rogueBusesDetails = dbWeekDetailsWRogues.rogueBuses; 
		
		// future count
		dbSettings.futureHoldingCount = DisplayBoardDataHandler.futureHoldingCount;
		dbSettings.busesCount = DisplayBoardDataHandler.busesCount;
    	String jsonOut = JSON.serialize( dbData);
    	return jsonOut;
    }
    
    
//     private List<DisplayWeekDetails> getFutureHoldingAndScheduledDataDetails() {
    private DisplayBoardWeekDetailsWRogues getFutureHoldingAndScheduledDataDetails() {
    	DisplayBoardSettings settings = getDisplayBoardSettingsDetails();
    	List<DisplayWeekDetails> futureHoldingsData = DisplayBoardDataHandler.getFutureHoldingsData( 0, settings.weeksPerRow, settings.slotsPerWeek);
		Date d1 = DisplayBoardConstants.DB_START_DATE;
		// Integer daysForEndDate = settings.weeksPerRow * 7 * 2;
		Integer daysForEndDate = settings.maxWeeksData * 7 ;
		Date d2 = d1.addDays( daysForEndDate);

        // List<DisplayWeekDetails> scheduledWeeksData = DisplayBoardDataHandler.getData( settings.weeksPerRow, d1, d2);
 		DisplayBoardWeekDetailsWRogues dbWeekDetailsWRogues = DisplayBoardDataHandler.getData( settings.weeksPerRow, d1, d2);
        futureHoldingsData.addAll( dbWeekDetailsWRogues.weekDetailsList);
        
        dbWeekDetailsWRogues.weekDetailsList = futureHoldingsData;
        return dbWeekDetailsWRogues;
    }
    
    
    /*
    private String getDisplayBoardSettings() {
        String jsonString = JSON.serialize( getDisplayBoardSettingsDetails());
        return jsonString;
    }
    */
    
    private DisplayBoardSettings getDisplayBoardSettingsDetails() {

		Integer weeksPerRow = DisplayBoardConstants.WEEKS_PER_ROW;
		Integer slotsPerWeek = DisplayBoardConstants.MAX_SLOTS_PER_WEEK;
		Integer minWeeksPerRow = DisplayBoardConstants.MIN_WEEKS_PER_ROW;
		Integer visibleSlots = DisplayBoardConstants.VISIBLE_SLOTS_PER_WEEK;
		Integer maxWeeksData = DisplayBoardConstants.MAX_WEEKS_DATA;
		Integer numRows = 3;
		Integer numWeeks = 3 * weeksPerRow;
		
        DisplayBoardSettings dbSettings = getDisplayBoardSettingsInternal(numRows, 
        																	numWeeks, 
        																	weeksPerRow, 
        																	slotsPerWeek, 
        																	minWeeksPerRow, 
        																	visibleSlots,
        																	maxWeeksData);    	
    	return dbSettings;
    }
    
    /*
    public DisplayBoardSettings getDisplayBoardSettingsTestNoUSE() {
     
        String jsonString = JSON.serialize( getDisplayBoardSettingsInternal(2, 8, 4, 49, 10, 49));        
        DisplayBoardSettings dbSettings = getDisplayBoardSettingsInternal(2, 8, 4, 49, 10, 49);
        return dbSettings;
    }
 	*/
 	
    private DisplayBoardSettings getDisplayBoardSettingsInternal( 
    											Integer numRows, 
    											Integer numWeeks, 
    											Integer weeksPerRow,
    											Integer slotsPerWeek,
    											Integer minWeeksPerRow, 
    											Integer visibleSlots,
    											Integer maxWeeksData ) {
        
        
       	DisplayBoardSettings settings = new DisplayBoardSettings();
       	DisplayBoardColorSettings colors = new DisplayBoardColorSettings();
       	
        colors.emptySlot = DisplayBoardMetadataUtils.boardSettings.get('colors.emptySlot'); 
        colors.holiday = DisplayBoardMetadataUtils.boardSettings.get('colors.holiday');

        colors.mode = DisplayBoardMetadataUtils.boardSettings.get('colors.mode');
        colors.cng = DisplayBoardMetadataUtils.boardSettings.get('colors.cng');
        colors.diesel = DisplayBoardMetadataUtils.boardSettings.get('colors.diesel');
        colors.baehybrid = DisplayBoardMetadataUtils.boardSettings.get('colors.baehybrid');
        colors.allisonhybrid = DisplayBoardMetadataUtils.boardSettings.get('colors.allisonHybrid');
        colors.electric = DisplayBoardMetadataUtils.boardSettings.get('colors.electric');
        
        colors.q1 = DisplayBoardMetadataUtils.boardSettings.get('colors.q1');
        colors.q2 = DisplayBoardMetadataUtils.boardSettings.get('colors.q2');
        colors.q3 = DisplayBoardMetadataUtils.boardSettings.get('colors.q3');
        colors.q4 = DisplayBoardMetadataUtils.boardSettings.get('colors.q4');
        colors.shutdown = DisplayBoardMetadataUtils.boardSettings.get('colors.shutdown');
        colors.weekHeaderOverbooked = DisplayBoardMetadataUtils.boardSettings.get('colors.weekHeaderOverbooked');
        colors.scheduledWeekHeader = DisplayBoardMetadataUtils.boardSettings.get( 'colors.scheduledWeekHeader'); 
        colors.unscheduledWeekHeader = DisplayBoardMetadataUtils.boardSettings.get( 'colors.unscheduledWeekHeader'); 
        colors.toolBar = DisplayBoardMetadataUtils.boardSettings.get( 'colors.toolBar'); 
        colors.titleBar = DisplayBoardMetadataUtils.boardSettings.get( 'colors.titleBar'); 
        colors.futureHoldingsWeek = DisplayBoardMetadataUtils.boardSettings.get( 'colors.futureHoldingsWeek'); 
        colors.toolBarDirty = DisplayBoardMetadataUtils.boardSettings.get( 'colors.toolBarDirty'); 
        colors.slotSelected = DisplayBoardMetadataUtils.boardSettings.get( 'colors.slotSelected'); 
        colors.reserved = DisplayBoardMetadataUtils.boardSettings.get( 'colors.reserved');
        colors.futureHolding = DisplayBoardMetadataUtils.boardSettings.get( 'colors.futureHolding');
        colors.scheduled = DisplayBoardMetadataUtils.boardSettings.get( 'colors.scheduled');
        colors.toolBarHistory = DisplayBoardMetadataUtils.boardSettings.get( 'colors.toolBarHistory'); 
        colors.weekHeaderFont = DisplayBoardMetadataUtils.boardSettings.get( 'colors.weekHeaderFont'); 
        colors.pageBackGround = DisplayBoardMetadataUtils.boardSettings.get( 'colors.pageBackGround');

        settings.numRows = numRows;	
        settings.numWeeks = numWeeks;
		settings.weeksPerRow = weeksPerRow; // number of rows
		settings.slotsPerWeek = slotsPerWeek;
		settings.colors = colors;
		settings.minWeeksPerRow = minWeeksPerRow;
		
		settings.visibleSlots = visibleSlots; // per week 
		settings.maxWeeksData = maxWeeksData; // per row ** not getting used
		settings.touchMoveBuffer = Integer.valueOf( DisplayBoardMetadataUtils.boardSettings.get( 'display.touchMoveBuffer'));
		
		settings.busLine1Font = DisplayBoardMetadataUtils.boardSettings.get( 'display.busLine1Font');
		settings.busLine2Font = DisplayBoardMetadataUtils.boardSettings.get( 'display.busLine2Font');
		settings.dragDelay = DisplayBoardMetadataUtils.boardSettings.get( 'display.dragDelay');

		// first row is always future holding
		// second and third are data rows 
		// settings.startDate
		// formula :  settings.endDate
		// settings.weeksPerRow   // 52 
		// settings.slotsPerWeek  // 100 max
	
		// formula : settings.futureholding.startIndex = 0
		// formula : settings.futureholding.endIndex = weeksPerRow - 1
		// formula : settings.sch-unsch.startIndex = weeksPerRow
		// formula : settings.sch-unsch.endIndex = totalWeeks - 1
		
		// formula : settings.totalScheUnscheWeeks ( including futureholding for as row 1 with weeksPerRow)
		// formula : settings.totalWeeks = weeksPerRow + totalScheUnscheWeeks ( round to the next 52 factor)
		// make sure minimum totalWeeks should be 3 * weeksPerRow
		
		// default view contains two rows always 2nd and 3rd
		// number of weeks per row is constant i.e 52
		// start row for the display is always weeksPerRow i.e data starting point
		// settings.visible.defaultview.rows = 2  ** no configuration
		// settings.visible.defaultview.row.slotsPerWeek = 49
		
		// settings.visible.fullview.rows = 1 ** no configuration
		// settings.visible.fullview.row.slotsPerWeek = slotsPerWeek 
		// will talk start date from ToolBar UI
		
		
		// future holding view 
		// 1st row is future holding.... could have its own visible slots per week
		// 2nd row is data row ... could have its own visible slots per week 
		// both will have 52 weeks per row
		// settings.visible.futureholdingview.row1.slotsPerWeek
		// settings.visible.futureholdingview.row2.slotsPerWeek
		// could take start date from ToolBar UI
		
		settings.debug = DisplayBoardConstants.DEBUG;
		settings.lastRefreshedTime = String.valueOf( DateTime.now());  
        settings.jsonFieldNameLabels = DisplayBoardMetadataUtils.jsonFieldNameLabels;
        
        // hover dialog box fields set
        settings.hoverFields = DisplayBoardMetadataUtils.getDisplayBoardHoverFields();
        return settings; 
    }
    
    public String getDisplayBoardFilterFields() {
    	List<DisplayBoardFilterField> filterFields = DisplayBoardMetadataUtils.getDisplayBoardFilterFields();
        String jsonOut = JSON.serialize( filterFields);
        return jsonOut; 
    }
    
    public String getDisplayBoardUserDetails() {
    	List<DisplayBoardUserDetails> userDetails = DisplayBoardUserHandle.getDisplayBoardUsers();
    	String jsonOut = JSON.serialize( userDetails);
    	return jsonOut;
    }

    public String getDisplayBoardHistoryDetails() {
    	List<DisplayBoardHistoryDetails> userDetails = DisplayBoardHistoryHandle.getHistoryList();
    	String jsonOut = JSON.serialize( userDetails);
    	return jsonOut;
    }
    
    /*
    private String getDisplayBoardSettingsNOUSE( String key) { 
    	return Display_Board_Settings__c.getValues( key).value__c;
    }
    */
    
   	/*
   	public String getRefreshDisplayBoard() {
		Date d1 = DisplayBoardConstants.DB_START_DATE;
		Date d2 = d1.addDays( 365 * 2);
        List<DisplayWeekDetails> weeks = DisplayBoardDataHandler.getData( 0, d1, d2);
        String jsonOut = JSON.serialize( weeks);
        return jsonOut;  
    }
	*/
   	/*
   	public String getRefreshDisplayBoardTest() { 
        
        Date d1 = Date.newInstance( 2017, 03, 27);
		Date d2 = Date.newInstance( 2017, 04, 27);
        List<DisplayWeekDetails> weeks = DisplayBoardDataHandler.getData( 0, d1, d2);
        String jsonOut = JSON.serialize( weeks);
        return jsonOut;
    }
    */
    
   /* 
   public String getFutureHoldingDataNOUSE() {
        List<DisplayWeekDetails> weeks = DisplayBoardDataHandler.getFutureHoldingsData( 0, 3, 4);
        String jsonOut = JSON.serialize( weeks);
        return jsonOut; 
    }
    */

   /*
    public String getFutureHoldingAndScheduledDataNOUSE() {
        List<DisplayWeekDetails> futureHoldingsData = getFutureHoldingAndScheduledDataDetails();
        String jsonOut = JSON.serialize( futureHoldingsData);
        return jsonOut; 
    }
    */
    

   /*
   public List<DisplayWeekDetails> getFutureHoldingAndScheduledDataTestNOUSE() {

   		DisplayBoardSettings settings = getDisplayBoardSettingsInternal(2, 8, 4, 49, 10, 49);
        List<DisplayWeekDetails> futureHoldingsData = DisplayBoardDataHandler.getFutureHoldingsData( 0, 4, 49);
        Date d1 = Date.newInstance( 2017, 03, 10);
		Date d2 = Date.newInstance( 2017, 04, 31);
        List<DisplayWeekDetails> scheduledWeeksData = DisplayBoardDataHandler.getData( 4, d1, d2);
        futureHoldingsData.addAll( scheduledWeeksData);
        return futureHoldingsData; 
    }
    */
    
    
    /*
    public String getDisplayBoardDataTestNOUSE() {
    	DisplayBoardData dbData = new DisplayBoardData();
    	
    	// build displayboard settings
    	DisplayBoardSettings dbSettings = getDisplayBoardSettingsTestNOUSE();
		dbData.settings =  dbSettings;
		
		// build display board cell details
		List<DisplayWeekDetails> weekDetails = getFutureHoldingAndScheduledDataTestNOUSE();
		dbData.schedules = weekDetails;
		
    	String jsonOut = JSON.serialize( dbData);
    	return jsonOut;
    }
    */
    
    public String save() {
    	List<DisplayCellDetails> updatedCellDetails = (List<DisplayCellDetails>) System.JSON.deserialize( saveInputJson, List<DisplayCellDetails>.class);
 		DisplayBoardDataHandler.buildUpdateBusRecord( userRecordID, updatedCellDetails);
    	String originalJSON = getDisplayBoardData();
    	DisplayBoardHistoryHandle.saveHistorySnapShot( userRecordID, originalJSON);
    	return null; 
    }
    
    public String validatePassword( String userRecordID, String password) {
    	validManager = DisplayBoardUserHandle.validatePassword( userRecordID, password);
    	return null;
    }

    public String validatePassword() {
    	validManager = DisplayBoardUserHandle.validatePassword( userRecordID, password);
    	return null;
    }
    
    public String ping() {
		return null;
	} 

	public PageReference incrementCounter() {
        count++;
        return null;
    }
			
    public Integer getCount() {
        return count;
    }
    
}