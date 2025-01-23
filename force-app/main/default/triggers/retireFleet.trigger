trigger retireFleet on Fleet__c (after update) {
    List <Bus__c> busses = new List<Bus__c>();

    set<id> idset = new set<id>();
    for(Fleet__c f:trigger.new){
        if (f.Retired__c) {
            idset.add(f.id);
        }
    }

    if (!idset.isEmpty()) {

        busses = [select id, Retired__c from Bus__c where Fleet__C in :idset and Retired__c=false];

        if (busses.size()>0) {
            for (Bus__c rBus : busses) {
                rBus.Retired__c = true;
            }
            update busses;
        }
    }
}