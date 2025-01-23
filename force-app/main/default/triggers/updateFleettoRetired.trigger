trigger updateFleettoRetired on Bus__c (after update) {

    set<id> busSet = new set<id>();
    for(Bus__c b:trigger.new){
        if (b.Retired__c) {
            busSet.add(b.Fleet__c);
        }
    }

    if (!busSet.isEmpty()) {

        List <Fleet__c> fleets = new List<Fleet__c>();
        List <Fleet__c> finalFleet = new list<Fleet__c>([select id, Quantity__c, Retired__c from Fleet__c where id in :busSet]);
        List <Bus__c> busFleet = new list<Bus__c>([select id, Fleet__C, Retired__c from Bus__c where fleet__c in :busSet]);

        set<id> retireSet = new set<id>();

        for(Bus__c busses:trigger.new) {

            // Retire the fleet if all busses are retired

            if (busses.Retired__c) {        
                boolean isRetired = true;
                // find the Fleet and if the Fleet is already retired then no further action needed
                for (Bus__c chkRetired:busFleet) {
                    if (chkRetired.Fleet__c == busses.Fleet__c) {
                        if (!chkRetired.Retired__c) {
                            isRetired = false;
                            break;
                        }
                    }
                }
                // otherwise the fleet needs to be retired
                if (isRetired) {
                    if (!retireSet.contains(busses.Fleet__c)) {
                        for (Fleet__c justRetire:finalFleet) {
                            if (busses.Fleet__c == justRetire.ID) {
                                justRetire.Retired__c = true;
                                fleets.add(justRetire);
                                retireSet.add(busses.Fleet__c);
                                break;
                            }
                        }
                    }            
                }
            }
        }
        if (fleets.size() > 0) {
            update fleets;
        }
    }
}