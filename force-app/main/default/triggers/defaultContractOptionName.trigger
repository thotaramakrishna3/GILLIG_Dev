trigger defaultContractOptionName on Contract_Option__c (before insert) {

	set<id> idset = new set<id>();
	set<id> aidset = new set<id>();
	for(Contract_Option__c cids:trigger.new){
    	idset.add(cids.Customer_Contract__c);
    	aidset.add(cids.Member_Agency__c);
  	}

  	map<id,Customer_Contract__c> contractnameMap = new map<id,Customer_Contract__c>([select id, Name from Customer_Contract__c where id in :idset]);
  	map<id,Account> accountMap = new map<id, Account>([select id, Internal_Name__c from Account where id in :aidset]);

	for (Contract_Option__c co:trigger.new) {
		co.Name = contractnameMap.get(co.Customer_Contract__c).name.abbreviate(47) + ' - ' 
							+ accountMap.get(co.Member_Agency__c).Internal_Name__c.abbreviate(30);
	}
}