trigger mergedSaleOrder on Sales_Order__c (before update) {
Map<Id,Sales_Order__c> oldRec = trigger.oldMap;
Map<Id,Sales_Order__c> newRec = trigger.newMap;
    for(Id ids : newRec.keySet()){
        if(oldRec.get(ids).RecordTypeId != newRec.get(ids).RecordTypeId) {
    recordtype soMergeRecType = [select id from recordtype where DEVELOPERNAME = 'Merged' and SOBJECTTYPE = 'Sales_Order__c'];
    Id newOwner = '00515000005ylK7AAI';

    for (Sales_Order__c salesOrder:trigger.new) {
        if (salesOrder.recordtypeid == soMergeRecType.Id) {
            salesOrder.ownerid = newOwner;
        }
    }
            }
    }

}