@istest (seealldata=false)
public class defaultOppOwnerTest {

    static account tAccount;
    static user rRep;
    static user pRep;
    
    static void init () {

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
        
       	tAccount = new account(Name='Test Account', 
                               Ownerid = rRep.Id, 
                               Project_Sales_Manager__c = pRep.Id);
        insert tAccount;

    }

    static void initNoOwner () {
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        system.runAs(thisUser) {
            Profile p = [SELECT Id FROM Profile WHERE Name='Regional Sales Manager'];
            rRep = new user(LastName = 'National Sales Rep', Username = 'NationalSales.User@example.com', Email = 'NationalSales.User@example.com', 
                        Alias = 'rRep', CommunityNickname = 'rRep', 
                        TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                        EmailEncodingKey = 'ISO-8859-1', ProfileId = p.ID,
                        LanguageLocaleKey = 'en_US');
            insert rRep;
        }        
        tAccount = new account(Name='Test Account', 
                               Ownerid = rRep.Id);
        insert tAccount;

    }

    static testmethod void testDefaultOwner () {
        init();
        
        test.startTest();

        Opportunity tOpportunity = new opportunity (AccountID=tAccount.ID,Name='Test Opp',
                                                    StageName='Forecast', CloseDate=system.today(),
                                                    Type = 'Existing Business',Order_Probability__c = '1. High Probability', 
                                                   	ownerid=pRep.id);
		insert tOpportunity;
        
        Opportunity checkOpp = [select id, Name, ownerid
                                from Opportunity where id=:tOpportunity.Id];
        system.assertEquals(rRep.id, checkOpp.OwnerId);
        
        test.stopTest();
    }

    static testmethod void testNoOwner () {
        initNoOwner();
        
        test.startTest();

        Opportunity tOpportunity = new opportunity (AccountID=tAccount.ID,Name='Test Opp',
                                                    Type = 'Existing Business',Order_Probability__c = '1. High Probability', 
                                                    StageName='Forecast', CloseDate=system.today());
        insert tOpportunity;
        
        Opportunity checkOpp = [select id, Name, ownerid
                                from Opportunity where id=:tOpportunity.Id];

        system.assertEquals(rRep.id, checkOpp.OwnerId);
        
        test.stopTest();
    }
}