public class DisplayBoardSettings {
	public Integer numRows; // always constant
    public Integer numWeeks; // formula 3 * weeksPerRow
	public Integer weeksPerRow; // 52 max 
	public Integer slotsPerWeek; // 100 max

	public Integer minWeeksPerRow;
	public Integer visibleSlots;
	public Integer maxWeeksData; 
	
	public DisplayBoardColorSettings colors;
	public Boolean debug = false;
	public String lastRefreshedTime;
	public Map<String,String> jsonFieldNameLabels;
	
	public List<DisplayBoardHoverField> hoverFields;
	
	public Integer touchMoveBuffer;
	
	public String busLine1Font;
	public String busLine2Font;
	public String dragDelay;
	
	public Integer futureHoldingCount;
	public Integer busesCount;
}