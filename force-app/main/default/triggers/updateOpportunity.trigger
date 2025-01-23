trigger updateOpportunity on Opportunity (before update) {

	set<id> idset = new set<id>();
    for(Opportunity c:trigger.new){
        idset.add(c.Id);
    }

	List<Opportunity_Line__c> oppLines = new List<Opportunity_Line__c>([select id, Opportunity_Line__c, Contract_Option__c
														from Opportunity_Line__c where Opportunity_Line__c in :idset]);
	List<Opportunity_Line__c> updLines = new List<Opportunity_Line__c>();

	// to-do update when ref contract changes?
	for (Opportunity tOpp:trigger.new) {
		Opportunity oldOpp = Trigger.oldMap.get(tOpp.Id);
		if (tOpp.Options_Used__c != oldOpp.Options_Used__c) {
			for (Opportunity_Line__c tOppline:oppLines) {
				if (tOppline.Opportunity_Line__c == tOpp.id) {
					tOppline.Contract_Option__c = tOpp.Options_Used__c;
					updLines.add(tOppline);
				}
			}
		}
	}
	if (updLines.size()>0) {
		update updLines;
	}
}