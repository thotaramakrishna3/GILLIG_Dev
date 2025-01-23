public with sharing class compareOppLinetoSalesOrder {
	public static boolean match(Opportunity_Line__c opportunityLine, Sales_Order__c salesOrder) {
		if (opportunityLine.Length__c == salesOrder.Length__c &&
			opportunityLine.Mode__c == salesOrder.Mode__c &&
			opportunityLine.Style__c == salesOrder.Style__c) {
				return true;
		} else {
			return false;
		}
	}
}