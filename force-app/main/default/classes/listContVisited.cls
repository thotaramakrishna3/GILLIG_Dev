public class listContVisited {

    public ID objId {get; set;}
    public TripContact__c[] getlistContVisited () {
        return [SELECT ID, Visited__c, Visited_Y_N__c, TripContact__c, 
                ContactName__c, Title__c, Phone__c, Mobile__c, Email__c  
                FROM TripContact__c WHERE TripReport__c = :objId order by ContactName__c];    
        }
}