public with sharing class DisplayBoardHistoryHandle {
	
	private DisplayBoardHistoryHandle() { }
	
	public static List<DisplayBoardHistoryDetails> getHistoryList() {
		Integer showSnapShotsCount = Integer.valueOf( DisplayBoardMetadataUtils.boardSettings.get( 'display.showHistorySnapShots'));
		
		List<Display_Board_History__c> historyList = [SELECT Id, Name, Saved_by__r.Name FROM Display_Board_History__c ORDER BY Name DESC LIMIT :showSnapShotsCount];
		List<DisplayBoardHistoryDetails> historyDetailsList = new List<DisplayBoardHistoryDetails>();
		DisplayBoardHistoryDetails historyDetails = null;
		For( Display_Board_History__c history: historyList) {
			historyDetails = new DisplayBoardHistoryDetails();
			historyDetails.savedTime = history.Name;
			historyDetails.savedByName = history.Saved_by__r.Name;
			historyDetails.historyRecordId = history.ID;
			historyDetailsList.add( historyDetails);
		}
		return historyDetailsList;
	}
	
	public static String saveHistorySnapShot( String userRecordId, String jsonInput) {
		
		Display_Board_History__c history = new Display_Board_History__c();
		history.Name = String.valueOf( DateTime.now());
		history.Saved_by__c = userRecordId;
		
		Insert history;
		
/*		Commented out due to error from Json file becoming too large of a blob

		Blob b = Blob.valueOf( jsonInput);
		Attachment attach1= new Attachment();
		attach1.ParentId = history.ID;
		attach1.Name = history.Name;
		attach1.Body = b;
		
		insert attach1;
*/
		deleteOldSnapShots();
		return history.ID;
	}
	
	public static String getHistorySnapShot( String historyRecordID) {
		
		List<Attachment> attachList = [ SELECT ID, Name, Body FROM ATTACHMENT WHERE ParentId = :historyRecordID];
		if ( attachList == null || attachList.size() == 0) {
			return null;
		}
		String jsonOutput = attachList[0].body.tostring();
		return jsonOutput;
	}

	private static void deleteOldSnapShots() {
		Integer keepSnapShotsCount = Integer.valueOf( DisplayBoardMetadataUtils.boardSettings.get( 'display.keepHistorySnapShots'));
		 
		List<Display_Board_History__c> historyList = [SELECT Id FROM Display_Board_History__c WHERE Keep_The_Snapshot__c = false ORDER BY Name DESC];
		if ( historyList.size() < keepSnapShotsCount) {
			return;
		} // if
		
		List<Display_Board_History__c> toBeDeleted = new List<Display_Board_History__c>();
		for ( Integer i = keepSnapShotsCount ; i < historyList.size(); i++) {
			toBeDeleted.add( historyList[i]);
		} // for
		
		if ( toBeDeleted.size() > 0) {
			Delete toBeDeleted; 
		} // if
	}
	
	
	@TestVisible private static List<DisplayBoardHistoryDetails> getHistoryListFullList() {
		Integer showSnapShotsCount = Integer.valueOf( DisplayBoardMetadataUtils.boardSettings.get( 'display.showHistorySnapShots'));
		
		List<Display_Board_History__c> historyList = [SELECT Id, Name, Saved_by__r.Name FROM Display_Board_History__c ORDER BY Name DESC];
		List<DisplayBoardHistoryDetails> historyDetailsList = new List<DisplayBoardHistoryDetails>();
		DisplayBoardHistoryDetails historyDetails = null;
		For( Display_Board_History__c history: historyList) {
			historyDetails = new DisplayBoardHistoryDetails();
			historyDetails.savedTime = history.Name;
			historyDetails.savedByName = history.Saved_by__r.Name;
			historyDetails.historyRecordId = history.ID;
			historyDetailsList.add( historyDetails);
		} // for
		return historyDetailsList;
	} // function
	
}