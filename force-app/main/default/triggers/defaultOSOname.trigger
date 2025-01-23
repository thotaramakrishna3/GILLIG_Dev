trigger defaultOSOname on Opportunity_Sales_Order__c (before insert, before update) {

    set<id> idset = new set<id>();
    set<ID> olSet = new set<Id>();
    for(Opportunity_Sales_Order__c c:trigger.new){
        idset.add(c.Sales_Order__c);
        olSet.add(c.Opportunity_Line__c);
    }

    map<id,Sales_Order__c> soNameMap = new map<id,Sales_Order__c>([select ID, Name from Sales_Order__c where id in :idset]);
    map<id,Sales_Order__c> soLineMap = new map<id,Sales_Order__c>([select ID, Total_Lines__c from Sales_Order__c where id in :idset]);
    List<Opportunity_Line__c> olMatch = new List<Opportunity_Line__c>([select Id, Length__c, Mode__c, Style__c from Opportunity_Line__c where ID in :olSet]);
    List<Sales_Order__c> soMatch = new List<Sales_Order__c>([select Id, Length__c, Mode__c, Style__c from Sales_Order__c where Id in:idset]);

    for (Opportunity_Sales_Order__c OSO:trigger.new) {
        string tSO = soNameMap.get(OSO.Sales_Order__c).Name;
        decimal tSOLine = soLineMap.get(OSO.Sales_Order__c).Total_Lines__c;
        decimal nextLine = tSOLine + 1;
        string tName = tSO.abbreviate(71) + ' - ' + nextLine.format();
        OSO.Name = tName;
/*        for (Opportunity_Line__c tempOL:olMatch) {
            if (OSO.Opportunity_Line__c == tempOL.Id) {
                for (Sales_Order__c tempSO:soMatch) {
                    if (OSO.Sales_Order__c == tempSO.Id) {
                        if (!compareOppLinetoSalesOrder.match(tempOL, tempSO)) {
                            OSO.adderror('Opportunity Line does not match Sales Order');
                        }
                    break;
                    }
                }
            break;
            }
        }
*/    }
}