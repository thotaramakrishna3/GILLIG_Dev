public class listContracts {
	public ID objId {get; set;}
    
    public Customer_Contract__c[] getlistContracts () {
        return [select ID, RecordType.Name, Name, Initial_Quantity__c, Optional_Quantities__c, Term_Years__c, Expiration__c 
                from Customer_Contract__c where Lead_Agency__c = :objId and Expiration__c >= :system.today()];
    }
}