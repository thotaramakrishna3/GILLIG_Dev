@isTest
private class mergedSalesOrderTest
{

    static Opportunity tOpportunity;
    static List<Opportunity_Line__c> tOppLine;
    static Customer_Contract__c cContract;
    static User rRep;
    static User pRep;

    static void init() {
    
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
        account tAccount = new account(Name='Test Account', Owner = rRep, Project_Sales_Manager__c = pRep.Id, Internal_Name__c = 'test, st'
                             );
        insert tAccount;
        
        account leadAgency = new account(Name='Test Lead Agency', Owner = rRep, Project_Sales_Manager__c = pRep.Id, Internal_Name__c = 'test, st'
                             );
        insert leadAgency;

        tOpportunity = new opportunity (AccountID=tAccount.ID,Name='Test Opp',StageName='Forecast', 
                                                    Type = 'Existing Business', Order_Probability__c = '1. High Probability',
                                                    CloseDate=system.today(), ownerid = rRep.Id);
        insert tOpportunity;
       
        recordtype rType = [select id from recordtype where Name = 'GILLIG' and SOBJECTTYPE = 'Customer_Contract__c' limit 1];

        cContract = new Customer_Contract__c (name = 'Test Contract', ownerid = rRep.Id, RecordTypeID = rType.ID,
                                                                  Lead_Agency__c = leadAgency.Id, Project_Sales_Manager__c = pRep.Id,
                                                                  Bid_Status__c = 'Bid', Bid_Stage__c = 'Award GILLIG', Bid_Submission_Type__c = 'Email');
        insert cContract;

        Contract_Option__c contractOption = new Contract_Option__c(Member_Agency__c = tAccount.Id, Customer_Contract__c = cContract.Id, Quantity__c = 4);
        insert contractOption;

		tOppLine = new List<Opportunity_Line__c>(); 
        tOppLine.add(new Opportunity_Line__c (Opportunity_Line__c = tOpportunity.Id,
                                            Quantity__c = 2,
                                            Mode__c = 'Diesel',
                                            PO_Amount__c = 150, 
                                            PO_Date__c = system.today(), 
                                            PO_Reference__c = 'Test PO',
                                            Quoted_Price__c = 100, 
                                            Reference_Contract__c = cContract.Id,
                                            Contract_Option__c = contractOption.Id,
                                            Style__c = 'LF',
                                            Length__c = '40'));
        insert tOppLine;
    	
    	tOppLine[0].Start_Date__c = system.today();
        update tOppLine;        

        tOppLine[0].Serial_Number__c = '123456';
        update tOppLine;

        tOppLine[0].Date_Booked__c = system.today();
        update tOppLine;
        createSO.insertSO(tOppLine);

    }


	@isTest
	static void itShould()
	{
		// Given an existing Sales Order
		init();

		// When


		// Then

	}
}