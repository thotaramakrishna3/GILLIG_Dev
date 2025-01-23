public with sharing class Fleet {

	public static void deleteFleet(List<Fleet__c> delFleet) {
		delete delFleet;
		return;
	}

	public static Fleet__c create(Opportunity_Line__c opportunityline, Id oppAcct) {

		// Opportunity for this Line
//    	Opportunity allAccts = [select ID, Accountid, RecordTypeID, Reference_Contract__c, Name, Total_Lines__c, Options_Used__c from Opportunity where ID =:opportunityline.Opportunity_Line__c];

		Schema.DescribeSObjectResult fleetSchema = Schema.SObjectType.Fleet__c;
		Map<String,Schema.RecordTypeInfo> fleetMap = fleetSchema.getRecordTypeInfosByName();
		Schema.RecordTypeInfo fleetRecordType;

		fleetRecordType = fleetMap.get('Planned Build');
		Id plannedRecType = fleetRecordType.getRecordTypeId();

/*		Schema.DescribeSObjectResult opplSchema = Schema.SObjectType.Opportunity_Line__c;
		Map<String,Schema.RecordTypeInfo> opplMap = opplSchema.getRecordTypeInfosByName();
		Schema.RecordTypeInfo opplRecordType;
		opplRecordType = opplMap.get('Serialized');
		Id serializedRecType = opplRecordType.getRecordTypeId();
*/
		Schema.DescribeSObjectResult oppSchema = Schema.SObjectType.Opportunity;
		Map<String,Schema.RecordTypeInfo> oppMap = oppSchema.getRecordTypeInfosByName();
		Schema.RecordTypeInfo oppRecordType;

		oppRecordType = oppMap.get('Competitor');
		Id compRecType = oppRecordType.getRecordTypeId();

		Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
		Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
		Schema.RecordTypeInfo busRecordType;
		busRecordType = busMap.get('Firm');
		Id firmRecType = busRecordType.getRecordTypeId();
		busRecordType = busMap.get('To Be Scheduled');
    	Id tobescheduledRecType = busRecordType.getRecordTypeId();
		busRecordType = busMap.get('Scheduled');
    	Id scheduledRecType = busRecordType.getRecordTypeId();
    	busRecordType = busMap.get('Reserved');
    	Id reservedRecType = busRecordType.getRecordTypeId();

      	Fleet__c newFleet = new Fleet__c();

		if (opportunityline.RecordTypeID!=compRecType) {

      		boolean isFirm = bus.determineRecordType(opportunityline)==firmRecType;
      		boolean isScheduled = bus.determineRecordType(opportunityline)==scheduledRecType;
      		boolean isToBeScheduled = bus.determineRecordType(opportunityline)==tobescheduledRecType;
      		boolean isReserved = bus.determineRecordType(opportunityline)==reservedRecType;

      		String fName;


			if (isFirm || isReserved || isScheduled || isToBeScheduled) {
					newFleet.RecordTypeID=plannedRecType;
     				if (isFirm) {
     					newFleet.Name = 'GILLIG - ' + String.valueOf(opportunityline.Start_Date__c.year()) + ' ' + opportunityline.Length__c 
                                + ' ' + opportunityline.Mode__c;
  					} else if (isScheduled || isToBeScheduled) {
      					newFleet.Name = opportunityline.Serial_Number__c;
      				} else {
        				newFleet.Name = opportunityline.Internal_Name__c;
      				}
                    newFleet.Account__c=oppAcct;
                    newFleet.Length_GILLIG__c = opportunityline.Length__c;
                    newFleet.Mode__c= opportunityline.Mode__c;
                    newFleet.Retired__c = false;
                    newFleet.Style_GILLIG__c = opportunityline.Style__c;
                    newFleet.Start_Date__c=opportunityline.Start_Date__c;
                    newFleet.Opportunity_Line__c=opportunityline.Id;
    			}
      		}
  		
		return newFleet;
	}
}