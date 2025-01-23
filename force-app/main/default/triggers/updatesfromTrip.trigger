trigger updatesfromTrip on Trip_Report__c (before update) {

  set<id> aidset = new set<id>();
  set<id> oidset = new set<id>();
  for(Trip_Report__c t:trigger.new){
      aidset.add(t.Account_Visited__c);
      oidset.add(t.id);
  }

  List<account> tAccount = new List<Account>();

  List<account> accountDetail = new List<account>([select id, Artic_Bus_Plans__c, Last_Articulated_Bus_Plan_Update__c,
                                 Electric_Bus_Plans__c, Last_Electric_Bus_Plan_Update__c,
                                 Fleet_Performance_Updates__c, Last_Fleet_Performance_Update__c,
                                 Fleet_Replacement_Plans__c, Ridership__c, Last_Ridership_Update__c
                                from account where id in :aidset]);
  List<TripOpportunity__c> TripOpps = new List<TripOpportunity__c>([select TripReport__c,Opportunity__r.ID, Comments__c from TripOpportunity__c where TripReport__c in :oidset]);

  for (Trip_Report__c Trips : Trigger.new){
        Trip_Report__c oldTrip = Trigger.oldMap.get(Trips.Id);
      
    if (!(Trips.Date_of_Visit__c == oldTrip.Date_of_Visit__c)){
            Trips.Name = Trips.Internal_Name__c + ' - ' + Trips.Date_of_Visit__c.format();
    }
      
    if (Trips.Status__c == 'Final'){
      for (TripOpportunity__c TripOpp : TripOpps){
        if (string.isNotBlank(TripOpp.Comments__c) && Trips.ID == TripOpp.TripReport__c) {
                    ConnectApi.FeedElement oppChatterpost = ConnectApiHelper.postFeedItemWithRichText(Network.getNetworkId(),
                                                                                                      TripOpp.Opportunity__r.ID,Trips.Name+' - '+
                                                                                                      TripOpp.Comments__c);
        }
      }
      if (string.isNotBlank(Trips.Artic_Bus_Plans__c) || 
                    string.isNotBlank(Trips.Electric_Bus_Plans__c) ||
                    string.isNotBlank(Trips.Fleet_Performance__c) ||
                    string.isNotBlank(Trips.Fleet_Replacement_Plans__c) ||
                    string.isNotBlank(Trips.Ridership__c)) {

        for (account t:accountDetail) {
          if (t.id == trips.Account_Visited__c) {
            if (string.isNotBlank(Trips.Artic_Bus_Plans__c) && 
                        !Trips.Artic_Bus_Plans__c.equals(t.Artic_Bus_Plans__c)) {
                        t.Artic_Bus_Plans__c = Trips.Artic_Bus_Plans__c;
                        t.Last_Articulated_Bus_Plan_Update__c = Trips.Date_of_Visit__c;
            }
            if (string.isNotBlank(Trips.Electric_Bus_Plans__c) &&
                        !Trips.Electric_Bus_Plans__c.equals(t.Electric_Bus_Plans__c)) {
                        t.Last_Electric_Bus_Plan_Update__c = Trips.Date_of_Visit__c;
                        t.Electric_Bus_Plans__c = Trips.Electric_Bus_Plans__c; 
            }
            if (string.isNotBlank(Trips.Fleet_Performance__c) &&
                        !Trips.Fleet_Performance__c.equals(t.Fleet_Performance_Updates__c)) {
                        t.Last_Fleet_Performance_Update__c = Trips.Date_of_Visit__c;
                        t.Fleet_Performance_Updates__c = Trips.Fleet_Performance__c;
            }
            if (string.isNotBlank(Trips.Fleet_Replacement_Plans__c) &&
                        !Trips.Fleet_Replacement_Plans__c.equals(t.Fleet_Replacement_Plans__c)) {
                        t.Last_Fleet_Replacement_Plan_Update__c = Trips.Date_of_Visit__c;
                        t.Fleet_Replacement_Plans__c = Trips.Fleet_Replacement_Plans__c;
            }
            if (string.isNotBlank(Trips.Ridership__c) &&
                        !Trips.Ridership__c.equals(t.Ridership__c)) {
                        t.Last_Ridership_Update__c = Trips.Date_of_Visit__c;
                        t.Ridership__c = Trips.Ridership__c;
            }            
          tAccount.add(t);                                                            
          }
        }
      }
    }
  }
    
  if (!tAccount.isEmpty()) {
    update tAccount;
  }
}