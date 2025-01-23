@isTest (seeAllData=false)
public class listContractsTest {
    
    public static account cAccount;
    public static Customer_Contract__c tContract;
    
    public static ID objId;

    public static testmethod void init(){
        cAccount = new account (Name='Test Main Contract Account');
        insert cAccount;
        tContract = new Customer_Contract__c (Name='Test Contract', Lead_Agency__c = cAccount.Id, Bid_Status__c = 'Bid', Bid_Stage__c = 'Award GILLIG', Bid_Submission_Type__c = 'Email');
        insert tContract;
        system.debug(tContract);
        objId = cAccount.id;
    }

    public static testmethod void testlistContracts () {
        init();
        test.startTest();
        
        listContracts CL = new listContracts();
        CL.objId = objId;
        CL.getlistContracts();
        
        system.debug(CL);
        
        system.assertEquals(tContract.Lead_Agency__c, CL.objId);
        
        test.stopTest();
        
    }
}