trigger defaultTripfields on Trip_Report__c (before insert) {

    set<id> acctset = new set<id>();
    for(Trip_Report__c t:trigger.new){
        acctset.add(t.Account_Visited__c);
    }

    List<Account> tAccount = new List<Account>([select ID, Internal_Name__c, Artic_Bus_Plans__c, 
                                                        Electric_Bus_Plans__c, Fleet_Performance_Updates__c, 
                                                        Fleet_Replacement_Plans__c, Part_Sales_Rep__r.Email, 
                                                        Part_Sales_Supervisor__r.Email, Ridership__c 
                                                        from account where id in :acctset]);

    for (Trip_Report__c Trips : Trigger.new) {
        for (Account theAccount:tAccount) {
            if (Trips.Account_Visited__c == theAccount.id) {
                Trips.Name = theAccount.Internal_Name__c + ' - ' + Trips.Date_of_Visit__c.format();
                Trips.Artic_Bus_Plans__c = theAccount.Artic_Bus_Plans__c;
                Trips.Electric_Bus_Plans__c = theAccount.Electric_Bus_Plans__c;
                Trips.Fleet_Performance__c = theAccount.Fleet_Performance_Updates__c;
                Trips.Fleet_Replacement_Plans__c = theAccount.Fleet_Replacement_Plans__c;
                Trips.Part_Sales_Rep__c = theAccount.Part_Sales_Rep__r.Email;
                Trips.Part_Sales_Supervisor__c = theAccount.Part_Sales_Supervisor__r.Email;
                Trips.Ridership__c = theAccount.Ridership__c;
                break;
            }
        }
    }
}