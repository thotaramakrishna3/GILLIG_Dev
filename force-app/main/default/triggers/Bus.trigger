trigger Bus on Bus__c (after delete, before update) {
    
    if (Trigger.isUpdate) {

        Set<Id> opplSet = new Set<Id>();
        set<Id> soSet = new Set<Id>();
        set<Id> prodOrderSet = new Set<Id>();
        for (Bus__c thisBus:Trigger.new) {
            Bus__c oldbus = Trigger.oldMap.get(thisBus.Id);
            if (thisBus.Start_Date__c != oldbus.Start_Date__c) {
                opplSet.add(thisBus.Opportunity_Line__c);
                if (thisBus.Sales_Order__c!=Null && thisBus.Start_Date__c != oldbus.Start_Date__c) {
                    soSet.add(thisBus.Sales_Order__c);
                    if (thisBus.Production_Order__c!=Null) {
                        prodOrderSet.add(thisBus.Production_Order__c);
                    }
                }
            }
        }

        if (opplSet.size()>0) {
            List<Opportunity_Line__c> tOppl = [select Id, Start_Date__c, Date_Booked__c, Serial_Number__c from Opportunity_Line__c where Id in :opplSet and Date_Booked__c=Null];
            boolean updOppl=false;
            for (Bus__c uBus:Trigger.new) {
                Bus__c oldBus = Trigger.oldMap.get(uBus.Id);
                for (Opportunity_Line__c thisOppl:tOppl) {
                    if (thisOppl.Id == uBus.Opportunity_Line__c) {
                        if ((uBus.Name==thisOppl.Serial_Number__c && thisOppl.Serial_Number__c!=Null) || 
                            (uBus.Reservation_ID__c==0 && thisOppl.Serial_Number__c==Null)) {
                                thisOppl.Start_Date__c=uBus.Start_Date__c;
                                updOppl=True;
                        }
                        uBus.recordtypeid = bus.determineRecordType(uBus, thisOppl);
                        break;
                    }
                }
            }
            if (updOppl) {
                update tOppl;   
            }
        }

        if (soSet.size()>0) {
            List<Sales_Order__c> uSO = [select Id, Name, Start_Date__c from Sales_Order__c where Id in :soSet];
            boolean updSO = False;
            for (Bus__c sBus:Trigger.new) {             
                for (Sales_Order__c thisSO:uSO) {
                    if (sBus.Name==thisSO.Name && thisSO.Start_Date__c != sBus.Start_Date__c) {
                        thisSO.Start_Date__c = sBus.Start_Date__c;
                    }
                }
            }
            update uSO;
        }
        if (prodOrderSet.size()>0) {
            List<Production_Order__c> uProdO = [select Id, Start_Date__c from Production_Order__c where Id in :prodOrderSet];
            for (Bus__c sBus:Trigger.new) {
                for (Production_Order__c thisProdOrder:uProdO) {
                    if (sBus.Sequence__c==1) {
                        thisProdOrder.Start_Date__c=sBus.Start_Date__c;
                    }
                }
            }
        }
    }
}