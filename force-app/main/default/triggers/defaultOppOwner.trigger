trigger defaultOppOwner on Opportunity (before insert) {

    set<id> idset = new set<id>();
    for(Opportunity cOpp:trigger.new){
        idset.add(cOpp.AccountID);
    }
    
    map<id,Account> oppAcctMap = new map<id,Account>([select ID, OwnerID from Account where id in :idset]);

    for (Opportunity dOpp:trigger.new){

        try {
                dOpp.ownerid = oppAcctMap.get(dOpp.AccountId).OwnerID;
            } catch(Exception e) {
            }
    }
}