trigger defaultContactOwner on Contact (before insert) {
	
    set<id> idset = new set<id>();
    for(Contact cAcct:trigger.new){
        idset.add(cAcct.AccountID);
    }
    
    map<id,Account> contactAcctMap = new map<id,Account>([select ID, OwnerID from Account where id in :idset]);

    for (Contact cnt:trigger.new) {
        if (cnt.AccountId!=null) {
            cnt.OwnerId = contactAcctMap.get(cnt.AccountId).OwnerID;
        }
    }
}