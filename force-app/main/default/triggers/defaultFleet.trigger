trigger defaultFleet on Fleet__c (before insert, before update) {

    map<id,recordtype> recordtypeMap = new map<id,recordtype>([select id, Name from recordtype where SOBJECTTYPE = 'Fleet__c']);
    map<id,Competitor__c> competitorNameMap = new map<id,Competitor__c>([select id, Name from Competitor__c]);

    set<Id> aidset = new set<Id>();
    for (Fleet__c f:Trigger.new) {
        aidset.add(f.Account__c);
    }
    map<id, Account> acctMap = new map<id, Account>([select id, Project_Sales_Manager__c from Account where Id in :aidset]);

    // Loop through all records that caused this trigger
    for (Fleet__c Fleets: Trigger.new) {

        // Find if GILLIG or a Competitor build the fleet
        // to-do fix exception when no record type exists
        // recordtype rType = [select name from recordtype where id = :Fleets.RecordTypeID];
        string rType = recordtypeMap.get(Fleets.RecordTypeID).Name;

        // Set name to the competitor who manufactured the bus and the year it was built
        If (rType == 'Competitor') {
            string cName = competitorNameMap.get(Fleets.Competitor__c).Name;
            Fleets.Name = cName + ' - ' + Fleets.Competitor_Date_Delivered__c.year();
        } Else if (Fleets.Start_Date__c != Null) {
            integer fleetYR;
            string tName;
            fleetYR = Fleets.Start_Date__c.year();
            tName = String.valueOf(fleetYR) + ' ' + Fleets.Length_GILLIG__c 
                                + ' ' + Fleets.Mode__c;
            Fleets.Name = 'GILLIG - ' + tName;
        }
        if (Trigger.isInsert) { 
            Fleets.Ownerid = acctMap.get(Fleets.Account__c).Project_Sales_Manager__c;
        }
    }
}