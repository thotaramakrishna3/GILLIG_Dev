trigger Opportunity_Line on Opportunity_Line__c (
// to-do move code out of defaultOppLineName trigger
//  before insert, 
//  before update, 
//  before delete, 
    after insert, 
    after update, 
//    after delete, 
    after undelete) {

    Schema.DescribeSObjectResult oppSchema = Schema.SObjectType.Opportunity;
    Map<String,Schema.RecordTypeInfo> oppRecMap = oppSchema.getRecordTypeInfosByName();
    Schema.RecordTypeInfo oppRecordType;
    oppRecordType = oppRecMap.get('Competitor');
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
    busRecordType = busMap.get('Forecasted');
    Id forecastedRecType = busRecordType.getRecordTypeId();    

    map<Id,date> opplStart = new map<Id,date>();

    set<id> olset = new set<id>();
    set<id> oppset = new set<id>();
    List<Opportunity_Line__c> opplChanged = new List<Opportunity_Line__c>();
    for (Opportunity_Line__c ol:trigger.new) {
        Opportunity_Line__c preChange = new Opportunity_Line__c();
        if (!Trigger.isInsert) {
            preChange = Trigger.oldMap.get(ol.Id);
        }
        if (ol.Start_Date__c!=preChange.Start_Date__c || ol.Serial_Number__c!=preChange.Serial_Number__c ||
            ol.Quantity__c!=preChange.Quantity__c) {
            opplChanged.add(ol);
            olset.add(ol.Id);
            opplStart.put(ol.Id, ol.Start_Date__c);
        }
        oppset.add(ol.Opportunity_Line__c);
    }

    map<Id, Opportunity> oppMap = new map<Id, Opportunity>([select Id, RecordTypeId, AccountId, CloseDate from Opportunity where id in:oppset]);
    List<Bus__c> opplBusses = new List<Bus__c>();
    if (opplChanged.size()>0) {
//        for (Opportunity tOpp:[select Id, RecordTypeId, AccountId, CloseDate from Opportunity where id in:oppset]) {
//            oppmap.put(tOpp.Id, tOpp);
//        }
        opplBusses = [Select Id, Name, Opportunity_Line__c, RecordTypeId, Reservation_ID__c, Start_Date__c, Sequence__c, Fleet__c from Bus__c where Opportunity_Line__c in :olset];
    }

    List<Bus__c> deleteBusses = new List<Bus__c>();
    set<Id> fleetSet = new set<Id>();
    Boolean updateBusses = false;
    List<Opportunity_Line__c> serilizeOppl = new List<Opportunity_Line__c>();
    List<Opportunity_Line__c> increaseQty = new List<Opportunity_Line__c>();
    List<Opportunity_Line__c> reduceQty = new List<Opportunity_Line__c>();

    List<Fleet__c> createFleet = new List<Fleet__c>();
    List<Opportunity_Line__c> updFleetId = new List<Opportunity_Line__c>();

    for (Opportunity_Line__c oppl:opplChanged) {

        Opportunity_Line__c oldOppl = new Opportunity_Line__c();
        if (!Trigger.isInsert) {
            oldOppl = Trigger.oldMap.get(oppl.Id);
        }

// 1a
        if (oppl.Start_Date__c != Null && 
            (oldOppl.Start_Date__c == Null) &&
            Oppl.Serial_Number__c == Null &&
            (oldOppl.Serial_Number__c == Null) &&
            oppl.Fleet__c == Null &&
            oppMap.get(oppl.Opportunity_Line__c).RecordTypeId!=compRecType) {
            createFleet.add(Fleet.create(oppl,oppMap.get(oppl.Opportunity_Line__c).AccountId));
            updFleetId.add(oppl);
        }
// 1b
        if (oppl.Start_Date__c == Null && 
            (oldOppl.Start_Date__c == Null) &&
            Oppl.Serial_Number__c != Null &&
            (oldOppl.Serial_Number__c == Null) &&
            oppl.Fleet__c == Null &&
            oppMap.get(oppl.Opportunity_Line__c).RecordTypeId!=compRecType) {
            createFleet.add(Fleet.create(oppl, oppMap.get(oppl.Opportunity_Line__c).AccountId));
            updFleetId.add(oppl);
        }
// 1c
        if (oppl.Start_Date__c != Null && 
            (oldOppl.Start_Date__c == Null) &&
            Oppl.Serial_Number__c != Null &&
            (oldOppl.Serial_Number__c == Null) &&
            oppl.Fleet__c == Null &&
            oppMap.get(oppl.Opportunity_Line__c).RecordTypeId!=compRecType) {
            createFleet.add(Fleet.create(oppl, oppMap.get(oppl.Opportunity_Line__c).AccountId));
            updFleetId.add(oppl);
        }
// 2a or 2f or 2j
        if (oppl.Date_Booked__c==Null &&
            (bus.determineRecordType(oppl)==reservedRecType ||
            bus.determineRecordType(oppl)==tobescheduledRecType ||
            bus.determineRecordType(oppl)==scheduledRecType) &&
            (oldOppl.Serial_Number__c != oppl.Serial_Number__c) &&
            oppMap.get(oppl.Opportunity_Line__c).RecordTypeId!=compRecType) {
            if (oppl.Fleet__c==Null) {
                createFleet.add(Fleet.create(oppl, oppMap.get(oppl.Opportunity_Line__c).AccountId));
                updFleetId.add(oppl);
            }
            serilizeOppl.add(oppl);
            updateBusses = True;
        }
// 2b or 2e or 2i
        if (oppl.Date_Booked__c==Null &&
            Oppl.Serial_Number__c == Null &&
            Oppl.Start_Date__c == Null &&
            (oldOppl.Serial_Number__c != Null ||
            oldOppl.Start_Date__c != Null)) {
            for (Bus__c dBus:opplBusses) {
                if (oppl.Id==dBus.Opportunity_Line__c) {
                    deleteBusses.add(dBus);
                    fleetSet.add(dBus.Fleet__c);
                }
            }
        }
// 2c and 2l
        if ((bus.determineRecordType(oppl)==reservedRecType ||
            bus.determineRecordType(oppl)==tobescheduledRecType ||
            bus.determineRecordType(oppl)==scheduledRecType) &&
            (oppl.Start_Date__c!=Null || oppl.Serial_Number__c!=Null) &&
            oppl.Date_Booked__c==Null &&
            Oppl.Quantity__c > oldOppl.Quantity__c &&
            oppMap.get(oppl.Opportunity_Line__c).RecordTypeId!=compRecType) {
            if (oppl.Fleet__c==Null) {
                createFleet.add(Fleet.create(oppl, oppMap.get(oppl.Opportunity_Line__c).AccountId));
                updFleetId.add(oppl);
            } Else {
                for (Integer i = (integer)oldOppl.Quantity__c; i < (integer)oppl.Quantity__c; i++) {
                    opplBusses.add(bus.create(oppl, i, oppMap.get(oppl.Opportunity_Line__c).AccountId,oppMap.get(oppl.Opportunity_Line__c).CloseDate));
                }
                updateBusses = True;
            }
        }
// Set back to To Be Schedule if start date removed
        if (oppl.Date_Booked__c==Null &&
            oppl.Start_Date__c == Null &&    
            oldOppl.Start_Date__c!= Null &&
            !Trigger.isInsert &&
            oppMap.get(oppl.Opportunity_Line__c).RecordTypeId!=compRecType) {
            if (oppl.Fleet__c==Null) {
                createFleet.add(Fleet.create(oppl, oppMap.get(oppl.Opportunity_Line__c).AccountId));
                updFleetId.add(oppl);
            } Else {
                for (Bus__c cBus:opplBusses) {
                    if (oppl.id==cBus.Opportunity_Line__c) {
                        cBus.RecordTypeId=bus.defaultRecordType();
                        cBus.Start_Date__c=Null;
                    }
                }
                updateBusses = True;
            }
        }

// 2k
        if ((bus.determineRecordType(oppl)==reservedRecType ||
            bus.determineRecordType(oppl)==tobescheduledRecType ||
            bus.determineRecordType(oppl)==scheduledRecType) &&
            (oppl.Start_Date__c!=Null || oppl.Serial_Number__c!=Null) &&
            oppl.Date_Booked__c==Null &&
            Oppl.Quantity__c < oldOppl.Quantity__c &&
            oppMap.get(oppl.Opportunity_Line__c).RecordTypeId!=compRecType) {
            if (oppl.Fleet__c==Null) {
                createFleet.add(Fleet.create(oppl, oppMap.get(oppl.Opportunity_Line__c).AccountId));
                updFleetId.add(oppl);
            } Else {
                reduceQty.add(oppl);
            }
        }
    }

    if (createFleet.size()>0) {
        insert createFleet;

        List<Opportunity_Line__c> opplFleetId = new List<Opportunity_Line__c>([select Id, Name, Start_Date__c, Serial_Number__c, Quantity__c, Internal_Name__c, Quoted_Price__c, Date_Booked__c, Fleet__c, Opportunity_Line__c from Opportunity_Line__c where id in:olset]);
        for (Opportunity_Line__c oppl:opplFleetId) {
            for (Fleet__c updFLid:createFleet) {
                if (oppl.Id==updFLid.Opportunity_Line__c) {
                    oppl.Fleet__c=updFLid.Id;
                    break;
                }
            }
        }
        if (opplFleetId.size()>0) {
            update opplFleetId;
        }

        List<Bus__c> busList = new List<Bus__c>();
        for (Fleet__c fleetBus:createFleet) {
            for (Opportunity_Line__c oppl:opplFleetId) {
                if (fleetBus.Id==oppl.Fleet__c) {
                    for (Integer i = 0; i < Oppl.Quantity__c; i++) {
                        busList.add(bus.create(oppl, i, fleetBus.Account__c, oppMap.get(oppl.Opportunity_Line__c).CloseDate));
                    }
                    break;
                }
            }
        }

        if (busList.size()>0) {
            insert busList;
        }
    }

    if (serilizeOppl.size()>0) {
        for (Opportunity_Line__c uOppl:serilizeOppl) {
            for (Bus__c thisBus:opplBusses) {
                if (thisBus.Opportunity_Line__c==uOppl.Id) {
                    thisBus.Name=bus.changeName(uOppl,(Integer)thisBus.Reservation_ID__c,oppMap.get(uOppl.Opportunity_Line__c).CloseDate);
                }
            }
        }
    }

    if (updateBusses) {
        upsert opplBusses;
    }

    if (deleteBusses.size()>0) {
        delete deleteBusses;

        set<Id> fleetSet = new set<Id>();

        for (Bus__c fb:deleteBusses) {
            fleetSet.add(fb.Fleet__c);
        }

        List<Fleet__c> delFeet = [select Id, Active_Quantity_GILLIG__c from Fleet__c where Id in :fleetSet and Active_Quantity_GILLIG__c=0];

        if (delFeet.size()>0) {
            Fleet.deleteFleet(delFeet);
        }
    }

    if (increaseQty.size()>0) {
        bus.add(increaseQty);
    }

    if (reduceQty.size()>0) {
        bus.reduceQty(reduceQty);
    }
}