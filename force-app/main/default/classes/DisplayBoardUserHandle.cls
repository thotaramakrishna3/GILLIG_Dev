public with sharing class DisplayBoardUserHandle { 
	
	private DisplayBoardUserHandle() { }
	
	public static List<DisplayBoardUserDetails> getDisplayBoardUsers() {
		
		List<User> displayBoardUsers = [ SELECT 	Id, 
													Name 
													FROM User 
													WHERE 
													Display_Board_Manager__c = true];
		List<DisplayBoardUserDetails> userDetailsList = new List<DisplayBoardUserDetails>();
		DisplayBoardUserDetails userDetails = null;											
		For( User dbUser: displayBoardUsers) {
			userDetails = new DisplayBoardUserDetails();
			userDetails.userName = dbUser.Name;
			userDetails.recordID = dbUser.Id;
			userDetailsList.add( userDetails);
		}
		
		return userDetailsList;
	} // getDisplayBoardUsers
	
	
	public static Boolean validatePassword( String userRecordID, String password) {

		List<User> displayBoardUsers = [ SELECT 	Id, 
													Name, 
													Display_Board_Password__c 
													FROM User 
													WHERE 
													Id = :userRecordID
													AND
													Display_Board_Manager__c = true
													];
													
		if ( displayBoardUsers.size() != 1) {
			return false;
		} // if
		
		if ( displayBoardUsers[0].Display_Board_Password__c == null) {
			return false;
		} // if
		
		if ( displayBoardUsers[0].Display_Board_Password__c == password) {
			return true;
		} else {
			return false;
		} // if
	} // function
} // class