trigger Opportunity_Sales_Order on Opportunity_Sales_Order__c (
    before insert, 
    before update, 
//    before delete, 
    after insert, 
    after update
//    after delete, 
//    after undelete
    ) {

    Opportunity_Sales_Order__c oldOSO = new Opportunity_Sales_Order__c();
    List<Opportunity_Sales_Order__c> addbus = new List<Opportunity_Sales_Order__c>();
    List<Opportunity_Sales_Order__c> removebus = new List<Opportunity_Sales_Order__c>();
//    map<Opportunity_Sales_Order__c, Opportunity_Sales_Order__c> moveBus = new map<Opportunity_Sales_Order__c, Opportunity_Sales_Order__c>();
    for (Opportunity_Sales_Order__c tOSO:Trigger.new) {

        if (Trigger.isBefore) {
            //call your handler.before method
        
        } else if (Trigger.isAfter) {
            if (!Trigger.isInsert) {
                oldOSO = Trigger.oldMap.get(tOSO.Id);
                if (tOSO.Quantity__c > oldOSO.Quantity__c) {
                    addbus.add(tOSO);
                } else if (tOSO.Quantity__c < oldOSO.Quantity__c) {
                    removebus.add(tOSO);
                } 
            }
        }
    }
    if (addbus.size()>0) {
        bus.add(addbus);
    }
    if (removebus.size()>0) {
        bus.reduceQty(removebus);
    }
}