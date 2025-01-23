/***********************************************************************************************************************************
     Developer :Suyati
     Usage : Handler class for TripReportTrigger trigger
     Date  : October 2019
     
************************************************************************************************************************************/   


public class TripReportTriggerHandler{
    
    public set<id> getAccountIds(list <Trip_Report__c > tripReportList)
    {
        set<id> accIdSet = new set<id>();
        for(Trip_Report__c trip:tripReportList){
            accIdSet.add(trip.Account_Visited__c);
        }
        return accIdSet;
    }
/********************************************************************************************************************************************************************* 
    MethodName:insertRelatedOpportunity
    Parameters:list <Trip_Report__c >,Set<>Accountids
    ReturnType:Null
    Usage     :Creates new opportunities for newly created trip reports
********************************************************************************************************************************************************************* */
    
    public void insertRelatedOpportunity(list <Trip_Report__c > tripReportList,set<id> accountIdSet)
    {
        List<TripOpportunity__c> tripOpportunityList = new List<TripOpportunity__c> ();
             
        List<Opportunity> Opportunities = new List<Opportunity>([select ID, AccountId from Opportunity where isClosed = false and AccountId in :accountIdSet]);
        for (Trip_Report__c Trips : tripReportList) 
        {
            for (Opportunity opp:Opportunities)
            {
                if (opp.AccountId == Trips.Account_Visited__c)
                    tripOpportunityList.add(new TripOpportunity__c(Opportunity__c = opp.ID, TripReport__c = Trips.ID));
            }
        }
        insert tripOpportunityList;
    }
    
    
/********************************************************************************************************************************************************************* 
  MethodName:updatesfromTrip
  Parameters:list <Trip_Report__c >,map<id,Trip_Report__c> oldMapFromTrigger
  ReturnType:Null
  Usage     :Updates existing account with updates from recent Trip Report
********************************************************************************************************************************************************************* */
    
    public void updatesfromTrip(List<Trip_Report__c>trip_report_from_trigger, map<id,Trip_Report__c> oldMapFromTrigger,boolean isupdate)
    { 
        set<id> aidset = new set<id>();
        aidset=getAccountIds(trip_report_from_trigger);
        set<id> oidset = new set<id>();
        for(Trip_Report__c t:trip_report_from_trigger)
        {
            oidset.add(t.id);
        }
        List<account> accountList = new List<Account>();
        
        List<account> accountDetail = new List<account>([select id, Artic_Bus_Plans__c, Last_Articulated_Bus_Plan_Update__c,
                                                         Electric_Bus_Plans__c, Last_Electric_Bus_Plan_Update__c,
                                                         Fleet_Performance_Updates__c, Last_Fleet_Performance_Update__c,
                                                         Fleet_Replacement_Plans__c, Ridership__c, Last_Ridership_Update__c,Fuel_Cell_Bus_Plans__c
                                                         from account where id in :aidset]);
        List<TripOpportunity__c> TripOpps = new List<TripOpportunity__c>([select TripReport__c,Opportunity__r.ID, Comments__c from TripOpportunity__c where TripReport__c in :oidset]);  
        for (Trip_Report__c Trips : trip_report_from_trigger){
            if(isupdate)
             {
              Trip_Report__c oldTrip = oldMapFromTrigger.get(Trips.Id);
                if (!(Trips.Date_of_Visit__c == oldTrip.Date_of_Visit__c)){
                  Trips.Name = Trips.Internal_Name__c + ' - ' + Trips.Date_of_Visit__c.format();
                  }
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
                        
                        for (account tripAccount:accountDetail) {
                            if (tripAccount.id == trips.Account_Visited__c) {
                                if (string.isNotBlank(Trips.Artic_Bus_Plans__c) && 
                                    !Trips.Artic_Bus_Plans__c.equals(tripAccount.Artic_Bus_Plans__c)) {
                                        tripAccount.Artic_Bus_Plans__c = Trips.Artic_Bus_Plans__c;
                                        tripAccount.Last_Articulated_Bus_Plan_Update__c = Trips.Date_of_Visit__c;
                                    }
                                if (string.isNotBlank(Trips.Electric_Bus_Plans__c) &&
                                    !Trips.Electric_Bus_Plans__c.equals(tripAccount.Electric_Bus_Plans__c)) {
                                        tripAccount.Last_Electric_Bus_Plan_Update__c = Trips.Date_of_Visit__c;
                                        tripAccount.Electric_Bus_Plans__c = Trips.Electric_Bus_Plans__c; 
                                    }
                                if (string.isNotBlank(Trips.Fleet_Performance__c) &&
                                    !Trips.Fleet_Performance__c.equals(tripAccount.Fleet_Performance_Updates__c)) {
                                        tripAccount.Last_Fleet_Performance_Update__c = Trips.Date_of_Visit__c;
                                        tripAccount.Fleet_Performance_Updates__c = Trips.Fleet_Performance__c;
                                    }
                                if (string.isNotBlank(Trips.Fleet_Replacement_Plans__c) &&
                                    !Trips.Fleet_Replacement_Plans__c.equals(tripAccount.Fleet_Replacement_Plans__c)) {
                                        tripAccount.Last_Fleet_Replacement_Plan_Update__c = Trips.Date_of_Visit__c;
                                        tripAccount.Fleet_Replacement_Plans__c = Trips.Fleet_Replacement_Plans__c;
                                    }
                                if (string.isNotBlank(Trips.Ridership__c) &&
                                    !Trips.Ridership__c.equals(tripAccount.Ridership__c)) {
                                        tripAccount.Last_Ridership_Update__c = Trips.Date_of_Visit__c;
                                       tripAccount.Ridership__c = Trips.Ridership__c;
                                    }   
                                if (string.isNotBlank(Trips.Fuel_Cell_Bus_Plans__c) &&
                                    !Trips.Fuel_Cell_Bus_Plans__c.equals(tripAccount.Fuel_Cell_Bus_Plans__c)) {
                                       tripAccount.Last_Fuel_Cell_Bus_Plan_Update__c = Trips.Date_of_Visit__c;
                                       tripAccount.Fuel_Cell_Bus_Plans__c = Trips.Fuel_Cell_Bus_Plans__c;
                                    }            
                                accountList.add(tripAccount);                                                            
                            }
                        }
                    }
            }
        }
        
        if (!accountList.isEmpty()) {
            update accountList;
        }
    }
    /********************************************************************************************************************************************************************* 
  	MethodName:defaultTripfields
 	Parameters:list <Trip_Report__c >,Set<id> AccountIds
  	ReturnType:Null
    Usage     :Set value for newly created Trip Report
********************************************************************************************************************************************************************* */
    
    public void defaultTripfields(List<Trip_Report__c> trip_report, set<id> account_set)
    {
        
        List<Account> Account_list = new List<Account>([select ID, Internal_Name__c, Artic_Bus_Plans__c, 
                                                        Electric_Bus_Plans__c, Fleet_Performance_Updates__c, 
                                                        Fleet_Replacement_Plans__c, Part_Sales_Rep__r.Email, 
                                                        Part_Sales_Supervisor__r.Email, Ridership__c 
                                                        from account where id in :account_set]);
        
        for (Trip_Report__c Trips : trip_report) {
            for (Account theAccount:Account_list) {
                if (Trips.Account_Visited__c == theAccount.id) {
                    Trips.Name = theAccount.Internal_Name__c + ' - ' + Trips.Date_of_Visit__c.format();
                    break;
                }
            }
        }
    }
}