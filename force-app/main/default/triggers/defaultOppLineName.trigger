trigger defaultOppLineName on Opportunity_Line__c (before insert, before update) {

    set<id> oidset = new set<id>();
    set<id> aidset = new set<id>();
    set<id> olset = new set<id>();
    set<Id> soSet = new set<Id>();
    set<String> serialNums = new set<String>();    
    
    for(opportunity_line__c c:trigger.new){
        if (c.id != Null) {
            olset.add(c.id);
        }
        if (c.Book_with_Sales_Order__c !=Null) {
            soSet.add(c.Book_with_Sales_Order__c);
        }
        if (Trigger.isInsert) {
            oidset.add(c.Opportunity_Line__c);
            if (c.Serial_Number__c != null && c.Serial_Number__c.isnumeric()) {
                Integer baseSN = Integer.valueOf(c.Serial_Number__c);
                for (Integer i = 0; i < c.Quantity__c; i++) {
                    serialNums.add(String.valueOf(baseSN+i));
                }
            }
        } else {
            Opportunity_Line__c oldOppl = Trigger.oldMap.get(c.ID);
            if (OldOppl.Serial_Number__c == null  && c.Serial_Number__c != null && c.Serial_Number__c.isnumeric()) {
                Integer baseSN = Integer.valueOf(c.Serial_Number__c);
                for (Integer i = 0; i < c.Quantity__c; i++) {
                    serialNums.add(String.valueOf(baseSN+i));
                }
            }
        }
    }


    // check if dulicate serial number
    List<Bus__c> invalidSO = new List<Bus__c>();
    List<Sales_Order__c> matchSO = new List<Sales_Order__c>();

    if (serialNums.size()>0) {
        for (Bus__c thisbus:[select name from Bus__c where Name in :serialNums]) {
            invalidSO.add(thisbus);
        }
        if (soSet.size()>0) {
            for (Sales_Order__c thisSO:[select Id, Length__c, Mode__c, Style__c from Sales_Order__c where Id in :soSet]) {
                matchSO.add(thisSO);
            }
        }
    }

    map<id,String> oppNameMap = new map<id,String>();
    map<id,Decimal> oppLineMap = new map<id,Decimal>();
    map<id,Id> oppOptionMap = new map<id,Id>();
    map<id,Id> oppRefContractMap = new map<id,Id>();
    map<Id,Id> oppAcct = new map<Id,Id>();

    if (oidset.size()>0) {
        for (Opportunity mapOpp:[select Id, Name, Total_Lines__c, Options_Used__c, Reference_Contract__c, AccountId from opportunity where id in :oidset]) {
            oppNameMap.put(mapOpp.Id, mapOpp.Name);
            oppLineMap.put(mapOpp.Id, mapOpp.Total_Lines__c);
            oppOptionMap.put(mapOpp.Id, mapOpp.Options_Used__c);
            oppRefContractMap.put(mapOpp.Id, mapOpp.Reference_Contract__c);
            oppAcct.put(mapOpp.id, mapOpp.AccountId);
            aidset.add(mapOpp.AccountId);
        }
    }

    // to-do change over to 
    Schema.DescribeSObjectResult opplSchema = Schema.SObjectType.Opportunity_Line__c;
    Map<String,Schema.RecordTypeInfo> opplMap = opplSchema.getRecordTypeInfosByName();
    Schema.RecordTypeInfo opplRecordType;
    opplRecordType = opplMap.get('Forecasted'); 
    ID openRecType = opplRecordType.getRecordTypeId();
    opplRecordType = opplMap.get('Serialized');
    ID serialRecType = opplRecordType.getRecordTypeId();
  
    // Determine if there is a duplicate serial number
    for (Opportunity_Line__c newFleet:trigger.new) { 
        // check for duplicate serial numbers
        if (invalidSO.size()>0) {
            for (Bus__c serialError:invalidSO) {
                if (newFleet.Serial_Number__c == serialError.name) {
                        newFleet.adderror('Duplicate serial number ' + newFleet.Serial_Number__c);
                        break;
                }
            }
        }
        if (newFleet.Book_with_Sales_Order__c !=null) {
            for (Sales_Order__c tSo:matchSO) {
                if (tSo.Id == newFleet.Book_with_Sales_Order__c) {
                    if (!compareOppLinetoSalesOrder.match(newFleet, tSo)) {
                        newFleet.adderror('Opportunity Line does not match Sales Order');
                    } 
                break;
                }
            }
        }
    }
    
    for (opportunity_line__c oppLines: Trigger.new) {
        if (Trigger.isInsert) {
            string tOpp = oppNameMap.get(oppLines.Opportunity_Line__c);
            decimal tOppLine = oppLineMap.get(oppLines.Opportunity_Line__c);
            decimal nextLine = tOppLine + 1;
            string tName = tOpp.abbreviate(71) + ' - ' + nextLine.format();
            oppLines.Name = tName;
            oppLines.Contract_Option__c = oppOptionMap.get(oppLines.Opportunity_Line__c);
            oppLines.Reference_Contract__c = oppRefContractMap.get(oppLines.Opportunity_Line__c);
            if (oppLines.Serial_Number__c==Null && oppLines.Start_Date__c==Null) {
                oppLines.RecordTypeID = openRecType;
            } else {
                oppLines.RecordTypeID = serialRecType;                
            }
        } else if (oppLines.Serial_Number__c <> Null || oppLines.Start_Date__c <> Null) {
            oppLines.RecordTypeID = serialRecType;
        }
    }
}