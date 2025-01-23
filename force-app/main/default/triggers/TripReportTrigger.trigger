/***********************************************************************************************************************************
     Developer:Suyati
     Name     :TripReportTrigger
     object   :Trip_Report__c
     Description : Trigger on Trip_Report__c   
	 Date  : October 2019
************************************************************************************************************************************/   
trigger TripReportTrigger on Trip_Report__c (before insert,after insert,before update) {
    TripReportTriggerHandler TriggerHandler =  new TripReportTriggerHandler();
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            Set<id> accIdSet=TriggerHandler.getAccountIds(trigger.new);
            TriggerHandler.defaultTripfields(trigger.new, accIdSet);
            TriggerHandler.updatesfromTrip(Trigger.new, Trigger.oldMap,false);
        } 
        if (Trigger.isUpdate) {
            TriggerHandler.updatesfromTrip(Trigger.new, Trigger.oldMap,true);
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            Set<id> accIdSet=TriggerHandler.getAccountIds(trigger.new);
            TriggerHandler.insertRelatedOpportunity(trigger.new,accIdSet);
        } 
    }
}