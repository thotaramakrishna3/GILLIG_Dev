trigger Sales_Order on Sales_Order__c (
    before insert, 
    before update, 
    //  before delete, 
    after insert, 
    after update
    //    after delete, 
    //    after undelete
) {  
    Set<Id> soSet = new Set<Id>();
    Set<Id> soSetforVin = new Set<Id>();
    set<Id> acctSet = new Set<Id>();
    set<Id> acctBSet = new Set<Id>();
    if (Trigger.isAfter) {

        List<Sales_Order__c> soList = new List<Sales_Order__c>();
        for (Sales_Order__c so:trigger.new) {
            Sales_Order__c oldSO = new Sales_Order__c();
            Boolean updatebusvin = false;
            if (!Trigger.isInsert) {
                oldSO = Trigger.oldMap.get(so.Id);
            }
            if (so.name != oldSO.name) {
                soSet.add(so.Id);
                soList.add(so);
            }
            if (so.BOM_Processing_Hours__c!=oldSO.BOM_Processing_Hours__c) {
                acctSet.add(so.Account__c);
            }
            if(so.Engine__c != oldSO.Engine__c){
                updatebusvin = true;
            }
            if(so.Length__c != oldSO.Length__c){
                updatebusvin = true;
            }
            if(so.Letter_Code__c != oldSO.Letter_Code__c){
                updatebusvin = true;
            }
            if(updatebusvin){
                soSetforVin.add(so.Id);
            
            }
        }
    
        if (soSet.size()>0) {
            List<Bus__c> changeBus = [select Id, Name, Sales_Order__c from Bus__c where Sales_Order__c in:soSet];
            if (changeBus.size()>0) {
                changeBus = bus.changeName(soList, changeBus);
                update changeBus;            
            }
        }
    
        if (acctSet.size()>0) {
            List<Account> bomAvg = [select id, AVG_BOM_Processing_Hours__c from Account where Id in:acctSet];
                AggregateResult[] avgBOMtime = [SELECT Account__c, AVG(BOM_Processing_Hours__c)abt
                                        FROM Sales_Order__c
                                        Where BOM_Processing_Hours__c!=Null
                                        GROUP BY Account__c];
            for (AggregateResult abt : avgBOMtime)  {
                for (Account thisAccoout:bomAvg) {
                    if (thisAccoout.Id==abt.get('Account__c')) {
                        thisAccoout.AVG_BOM_Processing_Hours__c = (decimal)abt.get('abt');
                        break;
                    }
                }
            }
            update bomAvg;
        }
    
        if(soSetforVin.size() > 0){
            List<Bus__c> updateBus = [select Id, Name, Sales_Order__c,Bus_Length__c, Engine__c,Sales_Order__r.Letter_Code__c,VIN__c,Brakes__c, Green_Sheet_Date__c, Scheduled_Green_Sheet_Date__c, Start_Date__c from Bus__c where Sales_Order__c in:soSetforVin];
            if (updateBus.size()>0) {
                updateBus = bus.recalculateVin(updateBus);
                update updateBus;            
            }
        }
    }
    if (Trigger.isInsert && Trigger.isbefore) {
        acctSet.clear();
        soSet.clear();
        set<Id> foundAcctSet = new Set<Id>();

        for (Sales_Order__c thisSO:trigger.new) {
            acctSet.add(thisSO.Account__c);
        }
        if (acctSet.size()>0) {

            List<Sales_Order__c> soList = [select Id,Account__c, Mode__c, Start_date__c,Customer_Legacy_Status__c 
                from Sales_Order__c 
                where Account__c in:acctSet and Start_date__c != null order by Account__c, Start_date__c asc];
            
            boolean isReturn = false;
            boolean isNewMode = false;
            boolean isExisting = false;
            boolean isComparable = false;

            for (Sales_Order__c so:trigger.new) {
                isReturn = false;
                isNewMode = true;
                isExisting = false;
                isComparable = foundAcctSet.contains(so.Account__c);
                for (Sales_Order__c soD:soList) {
                    if (so.Account__c == soD.Account__c && 
                            (math.abs(soD.Start_date__c.year()-so.Start_date__c.year())) <= 12 && 
                            so.Start_date__c <> null && soD.Start_date__c <> null) {
                        if (math.abs((soD.Start_date__c.year()-so.Start_date__c.year())) > 6) {
                            isReturn = true;
                        }
                        if (math.abs((soD.Start_date__c.year()-so.Start_date__c.year())) <= 6) {
                            isExisting = true;
                        }
                        if (math.abs((soD.Start_date__c.year()-so.Start_date__c.year())) <= 6 && so.Mode__c == soD.Mode__C) {
                            isNewMode = false;
                        }
                    }
                    if (so.Account__c == soD.Account__c) {
                        isComparable = true;
                    }
                }
                if ((isExisting || foundAcctSet.contains(so.Account__c)) && !isNewMode && isComparable) {
                    so.Customer_Legacy_Status__c = 'Existing Customer';
                } else if(isNewMode && isComparable) {
                    so.Customer_Legacy_Status__c = 'New Mode for Existing Customer';
                } else if (isReturn && isComparable) {
                    so.Customer_Legacy_Status__c = 'Return Customer';
                } else if (!isComparable && !foundAcctSet.contains(so.Account__c)) {
                    so.Customer_Legacy_Status__c = 'New Customer';
                }
                if (!foundAcctSet.contains(so.Account__c)) {
                    foundAcctSet.add(so.Account__c);
                }
            }
        }
    } 
    
      //MODEL ID GENERATE AND UPDATE
          if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            Sales_Order.updateModelField(Trigger.new);
          }
}