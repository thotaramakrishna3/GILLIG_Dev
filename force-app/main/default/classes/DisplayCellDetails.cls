public class DisplayCellDetails {
    
    public Integer sWeekIndex;
    public Integer slotIndex; // holds the place within the week 
    public Date slotDate;  // holds processing date
    public Integer maxSlots; // holds public 
    public Integer slotInDayIndex; // holds slot number within that day

    public Boolean isFutureHoldingSlot = false; // default unless build for it
    public Boolean isScheduledSlot = false; // default unless build for it
    
    public Date sWeekStartDate; // 
    
    public Boolean isHoliday;
    public Boolean isMovable; // for past weeks, flag will be false
    public Boolean isEmpty; // indicates if the cell accepts the drop
    
 	public DisplayBoardBusDetails bus;  
	
	public Boolean isRendered = false;
	public Boolean isSaved = true;  
 
}