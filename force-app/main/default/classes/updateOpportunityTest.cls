@isTest (seeallData=false)
public class updateOpportunityTest {

    static Opportunity tOpportunity;
    static Customer_Contract__c cContract;
    static Contract_Option__c cOptions;
    static Opportunity_Line__c tOppLine;
    static Opportunity_Line__c uOppLine;

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
        account coAccount = new account(Name='Test Options Account', Owner = rRep, Project_Sales_Manager__c = pRep.Id,
                             Internal_Name__c='Test Options Acct, St');
        insert coAccount;
       
        recordtype rType = [select id from recordtype where Name = 'GILLIG' and SOBJECTTYPE = 'Customer_Contract__c' limit 1];

        cContract = new Customer_Contract__c (name = 'Test Contract', ownerid = rRep.Id, RecordTypeID = rType.ID,
                                                                  Lead_Agency__c = tAccount.Id, Project_Sales_Manager__c = pRep.Id,
                                                                  Bid_Status__c = 'Bid', Bid_Stage__c = 'Award GILLIG', Bid_Submission_Type__c = 'Email');
        insert cContract;
        cOptions = new Contract_Option__c(Member_Agency__c=coAccount.id, Customer_Contract__c=cContract.id);
        insert cOptions;

        tOpportunity = new opportunity (AccountID=coAccount.ID,Name='Test CO Opp',StageName='Forecast', 
                                                    CloseDate=system.today(), ownerid = rRep.Id, 
                                                    Type = 'Existing Business', Order_Probability__c = '1. High Probability',
                                                    Options_Used__c=cOptions.id);
        insert tOpportunity;

        tOppLine = new Opportunity_Line__c (Opportunity_Line__c = tOpportunity.Id, 
                                            Serial_Number__c  = '123456', 
                                            Quantity__c = 2, 
                                            Date_Booked__c = system.today(), 
                                            Mode__c = 'Diesel',
                                            PO_Amount__c = 150, 
                                            PO_Date__c = system.today(), 
                                            PO_Reference__c = 'Test PO',
                                            Quoted_Price__c = 100, 
                                            Reference_Contract__c = cContract.Id,
                                            Contract_Option__c = cOptions.id,
                                            Style__c = 'LF',
                                            Length__c = '40',
                                            Start_Date__c = system.today());
        insert tOppLine;

    }

    static testmethod void changeCO () {
    	init();

    	test.startTest();

    	system.debug('Opportunity');
    	system.debug(tOpportunity);

    	Opportunity chgOpp = [select id, Options_Used__c from Opportunity where id=:tOpportunity.id];
    	chgOpp.Options_Used__c = null;
    	update chgOpp;

    	Opportunity_Line__c OppLineChng = [select id, Contract_Option__c from Opportunity_Line__c where id=:tOppLine.id];

    	system.assertEquals(null, OppLineChng.Contract_Option__c);

    	test.stopTest();
    }

}