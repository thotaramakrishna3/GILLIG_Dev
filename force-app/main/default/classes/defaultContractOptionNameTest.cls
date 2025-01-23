@isTest (seealldata=false)
public class defaultContractOptionNameTest {
    
    static Customer_Contract__c cContract;
    static List<Contract_Option__c> memberContract;
    static set<string> cNames;

    static void init () {

        User rRep;
        User pRep;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        system.runAs(thisUser) {

            Profile p = [SELECT Id FROM Profile WHERE Name='Regional Sales Manager'];
            rRep = new user(LastName = 'National Sales Rep', Username = 'NationalSales.User@example.com', Email = 'NationalSales.User@example.com', 
                        Alias = 'rRep', CommunityNickname = 'rRep', 
                        TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                       	EmailEncodingKey = 'ISO-8859-1', ProfileId = p.ID,
                       	LanguageLocaleKey = 'en_US');
            insert rRep;
            Profile pm = [SELECT Id FROM Profile WHERE Name='Project Sales Manager'];
            pRep = new user(LastName = 'Project Sales Rep', Username = 'ProjectSales.User@example.com', Email = 'ProjectSales.User@example.com', 
                        Alias = 'pRep', CommunityNickname = 'pRep', 
                        TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                       	EmailEncodingKey = 'ISO-8859-1', ProfileId = pm.ID,
                       	LanguageLocaleKey = 'en_US');
            insert pRep;
        }       
        account tAccount = new account(Name='Test Account', Owner = rRep, Project_Sales_Manager__c = pRep.Id,
                             Internal_Name__c='Test Acct, St');
        insert tAccount;

        cNames = new set<string>();
        List<Account> mAccount = new List<Account>();
        for (integer a=0; a < 101; a++) {
        	mAccount.add(new account(Name='Test Member Account - '+a.format(), Owner = rRep, Project_Sales_Manager__c = pRep.Id,
                             Internal_Name__c='Mem Acct, St'+a.format()));
        	cNames.add('Test Contract - Mem Acct, St'+a.format());
        }
        insert mAccount;
       
        recordtype rType = [select id from recordtype where Name = 'GILLIG' and SOBJECTTYPE = 'Customer_Contract__c' limit 1];

        cContract = new Customer_Contract__c (name = 'Test Contract', ownerid = rRep.Id, RecordTypeID = rType.ID,
                                                                  Lead_Agency__c = tAccount.Id, Project_Sales_Manager__c = pRep.Id,
                                                                  Bid_Status__c = 'Bid', Bid_Stage__c = 'Award GILLIG', Bid_Submission_Type__c = 'Email');
        insert cContract;

		memberContract = new List<Contract_Option__c>();
        for (Integer i = 0; i < 101; i++) {
				memberContract.add(new Contract_Option__c(Member_Agency__c=mAccount[i].id, Customer_Contract__c=cContract.id,
        										Quantity__c = 1));
        }
        insert memberContract;
    }

    static testmethod void checkName () {
    	init();
    	List<Contract_Option__c> chkName = new List<Contract_Option__c>([select id, Name from Contract_Option__c where Customer_Contract__c = :cContract.ID]);

    	Test.startTest();

    	for (Contract_Option__c dName:chkName) {
    		system.assert(cNames.contains(dName.Name));
    	}

    	Test.stopTest();
    }
}