@isTest (seeAllData=false)
public class listJointProcurementsTest {
    
    public static account tAccount;
    public static account cAccount;
    public static Customer_Contract__c tContract;
    public static Contract_Option__c tCoption;
    
    public static ID objId;
    public static ID tAcct;
    
    public static testmethod void init() {
        //to-do run test as Sales manager role
        cAccount = new account (Name='Test Main Contract Account', ASW_ID__c = 't1', Gillig_ID__c  = 1, Internal_Name__c ='iT1');
        insert cAccount;
        tAccount = new account (Name='Test Account', ASW_ID__c = 't2', Gillig_ID__c  = 2, Internal_Name__c ='iT2');
        insert tAccount;
        tAcct = tAccount.id;
    }
    
    // When all data is valid
    public static TestMethod void testJointProcurements () {
        init();
        
        // set up before test
        tContract = new Customer_Contract__c (Name='Test Contract', Lead_Agency__c = cAccount.Id, Expiration__c = system.today(),Bid_Status__c = 'Bid', Bid_Stage__c = 'Award GILLIG', Bid_Submission_Type__c = 'Email');
        insert tContract;
        tCoption = new Contract_Option__c (Member_Agency__c = tAccount.Id, Customer_Contract__c = tContract.Id, Quantity__c = 1);
        insert tCoption;
        objId = tAccount.Id;
        Test.startTest();
        
        listJointProcurements tJP = new listJointProcurements();
        tjp.objId = objid;
        tjp.getlistJointProcurements();
        system.debug(tJP);
        
        system.assertEquals(objId, tJP.objid);
        
        Test.stopTest();
        
    }
    
/*    public static TestMethod void testExpiredJointP () {
        init();
        
        //set up before test with expired contract
        tContract = new Customer_Contract__c (Name='Test Contract', Lead_Agency__c = cAccount.Id, Expiration__c = system.today()-1);
        insert tContract;
        tCoption = new Contract_Option__c (Member_Agency__c = tAccount.Id, Customer_Contract__c = tContract.Id, Quantity__c = 1);
        insert tCoption;
        objId = tAccount.Id;
        Test.startTest();
        
        listJointProcurements tJP = new listJointProcurements();
        tjp.objId = objid;
        tjp.getlistJointProcurements();
        system.debug('In expired contract test');
        system.debug(tJP);
        
        system.assertEquals(Null, tJP.objId);
        
        Test.stopTest();        
    }
*/    
}