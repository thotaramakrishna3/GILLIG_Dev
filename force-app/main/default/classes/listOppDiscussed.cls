public class listOppDiscussed {

    public ID objId {get; set;}
    public Opportunity op {get; set;}
    public List<TripOpportunity__c> tOpp {get; set;}
    public List<TripOppDiscussed> ODList{get; set;}
    
    public List<TripOppDiscussed> getlistOppDiscussed() {
        List<TripOppDiscussed> ODList = new List<TripOppDiscussed>();
        for (TripOpportunity__c a : [Select ID, Comments__c, Opportunity__c, Opportunity__r.CloseDate
                                     from TripOpportunity__c where TripReport__c = :objId
                                     order by Opportunity__r.CloseDate]){
            op = [Select CloseDate, Name, StageName, Discovery_Completed__c, ROI_Analysis_Completed__c, Total_Qty__c from Opportunity where ID = :a.Opportunity__c];
            ODList.add(new TripOppDiscussed(op, a));
        }
//        ODList.sort();
        return ODList;
    }
    
    public class TripOppDiscussed {
    	public Opportunity opp {get; set;}
    	public TripOpportunity__c oppD {get; set;}
    	public TripOppDiscussed(Opportunity o, TripOpportunity__c t) {
        opp = o;
        oppD = t;
        }
    }
}