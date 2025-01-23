@isTest
public class TestData

{
	public static Opportunity tOpportunity;
    public static Opportunity t29Opportunity;
    public static Customer_Contract__c cContract;
    public static Account tAccount;
    public static User rRep;
    public static User pRep;
    public static User sDir;
    public static User sAdmin;
    public static User cAdmin;
    public static List<Opportunity_Line__c> tOppLine;
    public static List<Opportunity_Line__c> t29OppLine;

   	public static void init () {

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
            Profile sd = [SELECT Id FROM Profile WHERE Name='Sales Director'];
            sDir = new user(FirstName = 'Sales', LastName = 'Director', Username = 'Sales.Director@example.com', Email = 'Sales.Director@example.com', 
                        Alias = 'sDir', CommunityNickname = 'sDir', 
                        TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                       	EmailEncodingKey = 'ISO-8859-1', ProfileId = sd.ID,
                       	LanguageLocaleKey = 'en_US');
            insert sDir;       
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'Test_Class_Fleet_Access'];
            insert new PermissionSetAssignment(AssigneeId = sDir.id, PermissionSetId = ps1.Id);         
            Profile sa = [SELECT Id FROM Profile WHERE Name='Sales Admin'];
            sAdmin = new user(FirstName = 'Sales', LastName = 'Admin', Username = 'Sales.Admin@example.com', Email = 'Sales.Admin@example.com', 
                        Alias = 'sAdm', CommunityNickname = 'sAdm', 
                        TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                       	EmailEncodingKey = 'ISO-8859-1', ProfileId = sa.ID,
                       	LanguageLocaleKey = 'en_US');
            insert sAdmin;
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Test_Class_Fleet_Access'];
            insert new PermissionSetAssignment(AssigneeId = sAdmin.id, PermissionSetId = ps.Id);      
            Profile ca = [SELECT Id FROM Profile WHERE Name='Sales Contract Admin'];
            cAdmin = new user(FirstName = 'Contract', LastName = 'Admin', Username = 'Contract.Admin@example.com', Email = 'Contract.Admin@example.com', 
                        Alias = 'cAdm', CommunityNickname = 'cAdm', 
                        TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                        EmailEncodingKey = 'ISO-8859-1', ProfileId = ca.ID,
                        LanguageLocaleKey = 'en_US');
            insert cAdmin;
        }
    }

    public static void createAcct() {
        system.runAs(rRep) {
            tAccount = new account(Name='Test Account', Internal_Name__c = 'test, st',
                             Project_Sales_Manager__c = pRep.Id);
            insert tAccount;            
        }
    }

    public static void createOpp() {
        system.runAs(rRep) {
            tOpportunity = new opportunity (AccountID=tAccount.ID,Name='Test Opp',StageName='Forecast', 
                                                    Type = 'Existing Business', Order_Probability__c = '1. High Probability',
                                                    CloseDate=system.today().addDays(45));
            insert tOpportunity;
            t29Opportunity = new opportunity (AccountID=tAccount.ID,Name='Test Opp29',StageName='Forecast', 
                                                    Type = 'Existing Business', Order_Probability__c = '1. High Probability',
                                                    CloseDate=system.today().addDays(45));
            insert t29Opportunity;

        }
    }

    public static void createContract() {
        manualShareRead(tAccount.Id, cAdmin.Id);
        system.runAs(cAdmin) {
            Schema.DescribeSObjectResult contractSchema = Schema.SObjectType.Customer_Contract__c;
            Map<String,Schema.RecordTypeInfo> contractMap = contractSchema.getRecordTypeInfosByName();

            Schema.RecordTypeInfo contractRecordType = contractMap.get('GILLIG');
            cContract = new Customer_Contract__c (name = 'Test Contract', RecordTypeID = contractRecordType.getRecordTypeId(),
                                                                  Lead_Agency__c = tAccount.Id, Project_Sales_Manager__c = pRep.Id,
                                                                  Bid_Status__c = 'Bid', Bid_Stage__c = 'Award GILLIG', Bid_Submission_Type__c = 'Email');
            insert cContract;
        }
    }

    public static void createOppLine(Integer n, Integer qty) {
        tOppLine = new List<Opportunity_Line__c>();
        t29OppLine = new List<Opportunity_Line__c>();

        system.runAs(rRep) {
            for (Integer i = 0; i < n; i++) {
                tOppLine.add(new Opportunity_Line__c (Name=TestData.tOpportunity.Name+' - '+String.valueOf(i+1),
                                            Opportunity_Line__c = TestData.tOpportunity.Id,
                                            Quantity__c = qty,
                                            Mode__c = 'Diesel',
                                            Reference_Contract__c = TestData.cContract.Id,
                                            Style__c = 'LF',
                                            Length__c = '40'));
                t29OppLine.add(new Opportunity_Line__c (Name=TestData.t29Opportunity.Name+' - '+String.valueOf(i+1),
                                            Opportunity_Line__c = TestData.t29Opportunity.Id,
                                            Quantity__c = qty,
                                            Mode__c = 'Diesel',
                                            Reference_Contract__c = TestData.cContract.Id,
                                            Style__c = 'LF',
                                            Length__c = '29'));

            }
            insert tOppLine;
            insert t29OppLine;
        }

        system.runAs(sAdmin) {

            for (Opportunity_Line__c t:tOppLine) {
                t.PO_Amount__c = 150;
                t.PO_Date__c = system.today();
                t.PO_Reference__c = 'Test PO';
                t.Quoted_Price__c = 100;
            }
            update tOppLine;
            for (Opportunity_Line__c t29:t29OppLine) {
                t29.PO_Amount__c = 150;
                t29.PO_Date__c = system.today();
                t29.PO_Reference__c = 'Test PO';
                t29.Quoted_Price__c = 100;
            }
            update t29OppLine;

        }
    }

    public static void createSO() {

        List<Opportunity_Line__c> tOpps = [select Id, Quantity__c, Start_Date__c, Serial_Number__c, Opportunity_Line__c, Mode__c, PO_Amount__c, PO_Date__c, PO_Reference__c, Quoted_Price__c, Style__c, Length__c, Contract_Option__c, Book_with_Sales_Order__c
                        from Opportunity_Line__c];
        Integer oppLineTotal=0;
        Integer     i = 1;
        system.runAs(sAdmin) {
            for (Opportunity_Line__c t:tOpps) {
                t.Serial_Number__c = String.valueOf(i*t.Quantity__c);
                t.Start_Date__c = system.today().addYears(2);
                oppLineTotal=oppLineTotal+(Integer)t.Quantity__c;
                i++;
            }
            update tOpps;
        }

        system.runAs(sDir) {
            for (Opportunity_Line__c ol:tOpps) {
                ol.Date_Booked__c = system.today();
            }
            update tOpps;
            createSO.insertSO(tOpps);
        }
    }

    public static void createProductionOrder() {
        List<Sales_Order__c> salesOrders = [select Id, Name, Start_Date__c from Sales_Order__c];

        createProductionOrder.insertProductionOrder(salesOrders);
    }
    public static void manualShareRead(Id recordId, Id userOrGroupId){
        AccountShare accShr  = new AccountShare();
        accShr.AccountId = recordId;
        accShr.UserOrGroupId = userOrGroupId;
        accShr.AccountAccessLevel = 'Read';
        accShr.OpportunityAccessLevel = 'Read';
        accShr.RowCause = Schema.AccountShare.RowCause.Manual;
        try{             
            insert accShr;             
        }catch(DMLException DMLe){ 
            system.debug('Caught DML Exception: '+DMle.getMessage()); 
        }
    }  
}