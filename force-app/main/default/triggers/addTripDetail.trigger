trigger addTripDetail on Trip_Report__c (after insert) {

    set<id> aidset = new set<id>();
    for(Trip_Report__c t:trigger.new){
        aidset.add(t.Account_Visited__c);
    }

    List<TripContact__c> TripC = new List<TripContact__c> ();
    List<TripOpportunity__c> TripO = new List<TripOpportunity__c> ();
    List<Contact> tCont = new List<Contact>([select ID, AccountId from Contact where Left_Company__c = false and AccountId in :aidset]);
    List<Opportunity> tOpp = new List<Opportunity>([select ID, AccountId from Opportunity where isClosed = false and AccountId in :aidset]);

    for (Trip_Report__c Trips : Trigger.new) {

        for (Contact c:tCont) {
            if (c.AccountId == Trips.Account_Visited__c) {
                TripC.add(new TripContact__c(TripContact__c = c.ID,TripReport__c = Trips.ID));
            }
        }
        
        for (Opportunity o:tOpp) {
            if (o.AccountId == Trips.Account_Visited__c) {
                TripO.add(new TripOpportunity__c(Opportunity__c = o.ID, TripReport__c = Trips.ID));
            }   
        }
    }
    insert TripC;
    insert TripO;
}