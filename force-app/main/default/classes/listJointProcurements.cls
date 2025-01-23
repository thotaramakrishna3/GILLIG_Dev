public class listJointProcurements {
	
    public ID objId {get; set;}

	public Contract_Option__c[] getlistJointProcurements () {
		return [SELECT ID, ReferenceContract__c, Member_Agency__c, Customer_Contract__c, 
                Quantity__c, Initial_Qty__c, Optional_Qty__c, Expiration__c, Term__c 
                from Contract_Option__c where Member_Agency__c = :objId 
                    and Expiration__c >= :system.today()];
	}
}