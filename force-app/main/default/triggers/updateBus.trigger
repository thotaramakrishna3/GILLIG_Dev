trigger updateBus on Bus__c (before update, before insert) {
    //    List <Fleet__c> fleets = new List<Fleet__c>();
    List <Fleet__c> newFleets = new List<Fleet__c>();
    
    boolean ownerChg=false;
    set<id> busSet = new set<id>();
    set<id> opplSet = new set<Id>();
    List<Bus__c> busVINReset = new List<Bus__c>();

    for(Bus__c b:trigger.new){
        Bus__c oldbus = new Bus__c();
        busSet.add(b.Fleet__c);
        if (!Trigger.isInsert) {
            Bus__c oldB = Trigger.oldMap.get(b.Id);
            oldbus = oldB;
            if (oldB.Current_Owner__c != b.Current_Owner__c) {
                ownerChg = true;
            }            
        }
        
        if (b.Opportunity_Line__c != null) {
            opplSet.add(b.Opportunity_Line__c);
        }
        
        if(b.Name != oldbus.Name || b.Green_Sheet_Date__c != oldbus.Green_Sheet_Date__c
           || (b.Sales_Order__c != Null || b.Sales_Order__c != oldbus.Sales_Order__c)){
                  busVINReset.add(b);  
//                busVINReset.add(b.id, b.VIN__c, b.Bus_Length__c. b.Engine__c, b.Brakes__c, b.Name, b.Green_Sheet_Date__c);
//               b.VIN__c = bus.recalculateVin(b);
           } 
    }

    if (busVINReset.size() > 0) {
        bus.initVinCodemap();
        bus.recalculateVin(busVINReset);
    }
    
    if (ownerChg) {
        
        // allows for finding matching fleets by Sales Order ID
        set<id> soSet = new set<id>();
        List <Fleet__c> soFleets = new List<Fleet__c>([select Sales_Order__c from Fleet__c where id in :busSet]);
        for (Fleet__c thisSOFleet:soFleets) {
            soSet.add(thisSOFleet.Sales_Order__c);
        }
        
        // Create a list for cloning 
        List <Fleet__c> transFleet = new List<Fleet__c>([select id,
                                                         OwnerID, RecordTypeID, Name, Sales_Order__c,
                                                         Account__c, Competitor__c, Competitor_Date_Delivered__c, Length_GILLIG__c,
                                                         Length_Competitor__c, Mode__c, Active_Quantity_Competitor__c, Retired__c,
                                                         Style_GILLIG__c, Style_Competitor__c
                                                         from Fleet__c where Sales_Order__c in :soSet]);
        // Check if we need to clone fleet for a change in bus owner
        set<id> cloneSet = new set<id>();
        
        for (Bus__c fleetadd:trigger.new) {
            Bus__c oldFleetBus = Trigger.oldMap.get(fleetadd.Id);
            
            // Check if there is a change in owner
            if (oldFleetBus.Current_Owner__c != fleetadd.Current_Owner__c) {
                boolean nofleet = true;
                // Find the new owners matching fleet
                for (Fleet__c findFleet:transFleet) {
                    if (findFleet.Account__c == fleetadd.Current_Owner__c && 
                        findFleet.Sales_Order__c == fleetadd.Sales_Order__c) {
                            nofleet = false;
                        }
                }
                
                // Create a new fleet if first bus in the fleet for the new owner
                // This allows the link back to the origingal Sales Order etc.
                if (nofleet) {
                    if (!cloneset.contains(fleetadd.Fleet__c)) {
                        for (Fleet__c cloneFleet:transFleet) {
                            if (cloneFleet.id == fleetadd.Fleet__c) {
                                Fleet__c newFleet = cloneFleet.clone(false, false, false, false);
                                newfleet.Account__c = fleetadd.Current_Owner__c;
                                newFleets.add(newfleet);
                                cloneset.add(fleetadd.Fleet__c);
                                break;
                            }
                        }
                    }
                }
            }        
        }
        
        if (newFleets.size() > 0) {
            insert newFleets;
            transFleet.clear();
            transFleet = [select id, Account__c, Sales_Order__c from Fleet__c where Sales_Order__c in :soSet];
        }
        
        // Loop through all records in this trigger
        for(Bus__c busses:trigger.new) {
            Bus__c oldBus = Trigger.oldMap.get(busses.Id);
            
            // Move the bus to a difference fleet if the owner changes
            
            if (oldBus.Current_Owner__c != busses.Current_Owner__c) {
                for (Fleet__c checkFleet:transFleet) {
                    if (checkFleet.Account__c == busses.Current_Owner__c) {
                        busses.Fleet__c = checkFleet.id;
                        break;
                    }
                }
            }
        }
    }
    
    List<Opportunity_Line__c> oppl = [select Id, Serial_Number__c, Date_Booked__c, Start_Date__c from Opportunity_Line__c where id in:opplSet];
    
    for (Bus__c busses:trigger.new) {
        if (busses.Opportunity_Line__c!=null) {
            for (Opportunity_Line__c thisOppl:oppl) {
                if (busses.Opportunity_Line__c == thisOppl.Id && busses.Start_Date__c!=Null) {
                    busses.recordtypeid=bus.determineRecordType(busses, thisOppl);
                    break;
                }
            }
        }
    }
}