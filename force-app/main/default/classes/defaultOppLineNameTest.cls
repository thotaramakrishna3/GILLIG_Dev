@isTest (seeAlldata=false)
public class defaultOppLineNameTest {

    static Opportunity tOpportunity;
    static Customer_Contract__c cContract;
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
        account tAccount = new account(Name='Test Account', Owner = rRep, Project_Sales_Manager__c = pRep.Id, Internal_Name__c = 'test, st'
                             );
        insert tAccount;
        
        tOpportunity = new opportunity (AccountID=tAccount.ID,Name='Test Opp',StageName='Forecast', 
                                                    Type = 'Existing Business',Order_Probability__c = '1. High Probability', 
                                                    CloseDate=system.today(), ownerid = rRep.Id);
        insert tOpportunity;
       
        recordtype rType = [select id from recordtype where Name = 'GILLIG' and SOBJECTTYPE = 'Customer_Contract__c' limit 1];

        cContract = new Customer_Contract__c (name = 'Test Contract', ownerid = rRep.Id, RecordTypeID = rType.ID,
                                                                  Lead_Agency__c = tAccount.Id, Project_Sales_Manager__c = pRep.Id,
                                                                  Bid_Status__c = 'Bid', Bid_Stage__c = 'Award GILLIG', Bid_Submission_Type__c = 'Email');
        insert cContract;      
    }
    
    static testmethod void checkLineName () {
        init();
        
        test.startTest();
        
        // Opportunity line with no name
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
                                            Style__c = 'LF',
                                            Length__c = '40',
                                            Start_Date__c = system.today());
        insert tOppLine;  
        
        Opportunity_Line__c cOppLine = [select ID, Opportunity_Line__c, Name from Opportunity_Line__c where id = :tOppLine.Id];
        opportunity theOpp = [select id, Name, Total_Lines__c from opportunity where id = :cOppLine.Opportunity_Line__c];
      	decimal lastLine = theOpp.Total_Lines__c;
        string tName = theOpp.Name.abbreviate(71) + ' - ' + lastLine.format();
        
        system.assertEquals(tName, cOppLine.Name);
        test.stopTest();
    }
}