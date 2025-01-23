public with sharing class DisplayBoardBusDetails {
	
	public String recordID;
    public String companyName;
    public String mode;
    public String style;
    public String busLength;
    public String sequenceNumber; // Number in the total order 1/10
    public String serialNumber; // 
    
    public Integer sequence;
    public Integer quantity;
    
    public Integer slotSize;
    public Integer multiSlotSequence; 
    
	public Boolean isPilot;
    public Boolean isReserved; // RED DOT ... Start Date but no Serial Number
    public Boolean isFutureHolding = false;
    public Boolean isFirm = false;
    public Boolean isScheduled = false;
    
    public String companyColor;
    public String modeStyleDisplay; 
    
    // new fields 03/30/2017
	public String brakes;
	public String engine;
	public String HVACSystem;
	public String ITSSystem;
	public String ITSSystemType; 
	public Date preprodMeetingDate;
	public Date SOReleaseDate;
	public String transmission;
	public String wheelchairRamp;  
	
	public String savedBy; 
	
	public String styleDisplay;
	public String lengthDisplay;

	public Boolean firstBus;
	public String projectSalesMgr;
	public String seatingMfg;
	public String rearDoorSize;
}