public class DisplayWeekDetails {

    public Integer weekIndex;
    
    public String weekDisplayString; // (02/26) , (03/05)
	public Date weekStartDate; // Monday date 02/26/2017, 03/05/2017
    // public String weekLoadDisplayString; // (total booked slots / total working days) 
    public Integer totalWorkingDays;
    public Integer totalScheduledBuses;
    public Integer maxSchedulableBuses; 
    public Integer weekQuarter; // 1 , 2, 3, or 4
    
    public List<DisplayCellDetails> slots;
    public Boolean isOverbooked = false;
    public Boolean isOutOfDisplay = false; 
    
    public Boolean isFutureHoldingWeek = false;
    public Boolean isScheduledWeek = false;
}