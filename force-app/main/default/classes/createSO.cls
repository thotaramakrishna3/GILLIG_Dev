public with sharing class createSO {

    @InvocableMethod(label='Create Sales Order' description='Create Sales Order from Opportunity Line')
    public static void insertSO(List<Opportunity_Line__c> opportunityLine) {
        
    	system.debug('Inside insertSO ::');
        set<id> oidset = new set<id>();
      set<id> olset = new set<id>();
    set<Id> flset = new set<Id>();
        for (Opportunity_Line__c o:opportunityLine) {
            oidset.add(o.Opportunity_Line__c);
      flset.add(o.Fleet__c);
        }
    
    // find all of the accounts for the opportunities
    List <Opportunity> allAccts = new List<Opportunity>([select ID, Accountid, RecordTypeID, Reference_Contract__c, Name, Total_Lines__c, Options_Used__c from Opportunity where ID in :oidset]);
    set<Id> acctPSM = new set<Id>();
    for (opportunity tOpp:allAccts) {
      acctPSM.add(tOpp.AccountId);
    }
    map<id,Account> oppAcctMap = new map<id,Account>([select ID, Project_Sales_Manager__c from Account where id in :acctPSM]);

    Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
    Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();        
    Schema.RecordTypeInfo busFirmRecordType = busMap.get('Firm');
    Schema.RecordTypeInfo busTBSRecordType = busMap.get('To Be Scheduled');
    Schema.RecordTypeInfo busScheduledRecordType = busMap.get('Scheduled');
    Schema.RecordTypeInfo busReservedRecordType = busMap.get('Reserved');
    Schema.RecordTypeInfo busForecastedRecordType = busMap.get('Forecasted');

    Schema.DescribeSObjectResult fleetSchema = Schema.SObjectType.Fleet__c;
    Map<String,Schema.RecordTypeInfo> fleetMap = fleetSchema.getRecordTypeInfosByName();        
    Schema.RecordTypeInfo fleetFirmRecordType = fleetMap.get('Firm');
    Schema.RecordTypeInfo fleetPlannedRecordType = fleetMap.get('Planned Build');

    Schema.DescribeSObjectResult soSchema = Schema.SObjectType.Sales_Order__c;
    Map<String,Schema.RecordTypeInfo> soMap = soSchema.getRecordTypeInfosByName();
    Schema.RecordTypeInfo soRecordType = soMap.get('Planned');

    Schema.DescribeSObjectResult oppSchema = Schema.SObjectType.Opportunity;
    Map<Id,Schema.RecordTypeInfo> oppMap = oppSchema.getRecordTypeInfosById();

        List<Sales_Order__c> newSo = new List<Sales_Order__c>();
    List<Opportunity_Sales_Order__c> newOSO = new List<Opportunity_Sales_Order__c>();
    system.debug('Inside insertSO 45::');    
    for (Opportunity_Line__c OppLine:opportunityLine) {
            for (Opportunity findopp:allAccts) {
                if (findopp.Id == OppLine.Opportunity_Line__c) {
          if (OppLine.Book_with_Sales_Order__c==null && OppLine.Date_Booked__c!=null) {
            Schema.RecordTypeInfo oppRecordType = oppMap.get(findopp.RecordTypeID);
                    newSo.add(new Sales_Order__c(RecordTypeID=soRecordType.getRecordTypeId(),
                                          Ownerid=oppAcctMap.get(findopp.AccountId).Project_Sales_Manager__c,
                                          Name = OppLine.Serial_Number__c,
                                          Opportunity__c = findopp.Id,
                                          Account__c = findOpp.AccountId,
                                          Mode__c = OppLine.Mode__c,
                                          Date_Booked__c = OppLine.Date_Booked__c,
                                          PO_Amount__c = OppLine.PO_Amount__c,
                                          PO_Date__c  = OppLine.PO_Date__c,
                                          PO_Reference__c  = OppLine.PO_Reference__c,
                                          Current_Price__c = OppLine.Quoted_Price__c,
                                          Spare_Tooling_Budget__c = OppLine.Spare_Tooling_Budget__c,
                                          Current_Tax__c = OppLine.Current_Tax__c,
                                          Quoted_Price__c = OppLine.Quoted_Price__c,
                                          Reference_Contract__c = findOpp.Reference_Contract__c,
                                          Style__c = OppLine.Style__c,
                                          Start_Date__c  = OppLine.Start_Date__c,
                                          Length__c = OppLine.Length__c,
                                          Contract_Option__c = OppLine.Contract_Option__c,
                                          Contract_Type__c = oppRecordType.getName(),
                                          Parts_Manual_Processor__c=Null,
                                          Service_Manual_Processor__c=Null,
                                          Schematics_Manual_Processor__c=Null,
                                          Lo_No_Grant__c = OppLine.Lo_No_Grant__c));
            olset.add(OppLine.Id);
                  } else if (OppLine.Book_with_Sales_Order__c!=null && OppLine.Date_Booked__c!=null) {
            newOSO.add(new Opportunity_Sales_Order__c(Opportunity_Line__c=OppLine.Id,
                        Sales_Order__c = OppLine.Book_with_Sales_Order__c,
                        Quantity__c=OppLine.Quantity__c));
            olset.add(OppLine.Id);
          }
        break;
                }
            }
        }
        if (newSo.size()>0) {
            insert newSo;
        }
        system.debug('After insert newSO ::');

    // Create all xreferences for Sales Orders just created
    for (Sales_Order__c nSO:newSO) {
        for (opportunity_line__c OppLine2:opportunityLine) {
        if (OppLine2.Serial_Number__c == nSO.name && OppLine2.Book_with_Sales_Order__c==null && OppLine2.Date_Booked__c!=null) {
                newOSO.add(new Opportunity_Sales_Order__c(Opportunity_Line__c=OppLine2.Id,
                            Sales_Order__c = nSO.Id,
                            Quantity__c=OppLine2.Quantity__c));
        break;
            }
        }
    }
	system.debug('Before insert newOSO ::'+newOSO.size());
    if (newOSO.size()>0) {
        system.debug('Before insert newOSO101 ::'+newOSO);
        try{
        	insert newOSO;
                }
        catch(Exception e){
            system.debug('After insert newOSO101 ::' +e);
        }
        system.debug('After insert newOSO101 ::');
    }

    List<Bus__c> chngBusStatus = new List<Bus__c>([select id, RecordTypeID, Sales_Order__c, Opportunity_Line__c, Name, Reservation_ID__c, Start_Date__c, Fleet__c from Bus__c where Opportunity_Line__c in :olset]);
    for (Bus__c tbus:chngBusStatus) {
        for (Opportunity_Line__c olines:opportunityLine) {
        if (tbus.Opportunity_Line__c == olines.Id) {

//          if (tbus.RecordTypeID!=busTBSRecordType.getRecordTypeId()) {
//            tbus.RecordTypeID = bus.determineRecordType(olines);
//          }

          if (olines.Book_with_Sales_Order__c!=null) {
            tbus.Sales_Order__c=olines.Book_with_Sales_Order__c;
          }
          for (Opportunity_Sales_Order__c tOSO:newOSO) {
            if (tOSO.Opportunity_Line__c == tbus.Opportunity_Line__c) {
                        tbus.Sales_Order__c = tOSO.Sales_Order__c;
                break;
                }
          }
        break;
        }
        }
    }
    
    if (chngBusStatus.size()>0) {
        Update chngBusStatus;
    }

    List<Fleet__c> setFleetSO = [select id, Sales_Order__c from Fleet__c where Id in:flset];
    for (Fleet__c f:setFleetSO) {
      for (Bus__c tBus:chngBusStatus) {
        if (f.id == tBus.Fleet__c) {
          f.Sales_Order__c = tBus.Sales_Order__c;
        break;
        }
      }
    }

    if (setFleetSO.size()>0) {
      Update setFleetSO;
    }

    return;
    }
}