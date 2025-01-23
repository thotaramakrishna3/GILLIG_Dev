@isTest
private class OpCkMasterDataControllerTest {
    static user rRep;
    static user pRep;
    @isTest
    public static void testgetBusDetailsPositive() {
        SingleRequestMock logindata = new SingleRequestMock(200,'SUCCESS','{"data":{"token":{"access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2OTY1ODc0MDAsIm5iZiI6MTY5NjU4NzQwMCwianRpIjoiYzBjZjhlYzItNzZmZC00NGY4LTg5YjgtM2QzNGNhMTcyY2U3IiwiZXhwIjoxNjk2NTg5MjAwLCJpZGVudGl0eSI6eyJlbXBsb3llZV9pZCI6MjM4LCJhcHB1c2VyX2lkIjoyMzgsImlzX2FjdGl2ZSI6dHJ1ZSwiZGVwYXJ0bWVudF9pZCI6MywiYXBwcm9sZV9pZCI6NiwiYXBwcm9sZV9uYW1lIjoiQ3VzdG9tZXIiLCJkZXBhcnRtZW50X2NvZGUiOiIwNEMifSwiZnJlc2giOmZhbHNlLCJ0eXBlIjoiYWNjZXNzIn0.PUQ5JVMHtNkBG1Bdrq6-vHsz1cIhnO2gWKhOIsqe-iw","expiry_token":1696589200,"refresh_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2OTY1ODc0MDAsIm5iZiI6MTY5NjU4NzQwMCwianRpIjoiM2FiNTc1ODAtZmJhYi00YWY0LWIzNDAtN2ExMDE4NzMyMDU3IiwiZXhwIjoxNjk5MTc5NDAwLCJpZGVudGl0eSI6eyJlbXBsb3llZV9pZCI6MjM4LCJhcHB1c2VyX2lkIjoyMzgsImlzX2FjdGl2ZSI6dHJ1ZSwiZGVwYXJ0bWVudF9pZCI6MywiYXBwcm9sZV9pZCI6NiwiYXBwcm9sZV9uYW1lIjoiQ3VzdG9tZXIiLCJkZXBhcnRtZW50X2NvZGUiOiIwNEMifSwidHlwZSI6InJlZnJlc2gifQ.Q0NCT4R9Aa6HtE0cfnPUBk4hZlo6_kl3EguCynx1wc0"},"user":{"approle_id":6,"appuser_id":238,"department_code":null,"department_id":null,"is_active":true}}}',null);
        SingleRequestMock getBusDetails = new SingleRequestMock(200,'SUCCESS','{"data":{"ecard":{"ecard_id":4706, "chassis_no":"B199093", "customer_id": 576, "customer_name": "Norman, OK" }}}',null);
        
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put(System.Label.EcardAppendpoint+'api/sflogin',logindata);
        endpoint2TestResp.put(System.Label.EcardAppendpoint+'api/ecardbychassisno/',getBusDetails);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        OpCkMasterDataController.getBusDetails('B199093');
    }
    
    @isTest
    public static void testgetBusDetailsNegative() {
        SingleRequestMock logindata = new SingleRequestMock(200,'SUCCESS','{"data":{"token":{"access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2OTY1ODc0MDAsIm5iZiI6MTY5NjU4NzQwMCwianRpIjoiYzBjZjhlYzItNzZmZC00NGY4LTg5YjgtM2QzNGNhMTcyY2U3IiwiZXhwIjoxNjk2NTg5MjAwLCJpZGVudGl0eSI6eyJlbXBsb3llZV9pZCI6MjM4LCJhcHB1c2VyX2lkIjoyMzgsImlzX2FjdGl2ZSI6dHJ1ZSwiZGVwYXJ0bWVudF9pZCI6MywiYXBwcm9sZV9pZCI6NiwiYXBwcm9sZV9uYW1lIjoiQ3VzdG9tZXIiLCJkZXBhcnRtZW50X2NvZGUiOiIwNEMifSwiZnJlc2giOmZhbHNlLCJ0eXBlIjoiYWNjZXNzIn0.PUQ5JVMHtNkBG1Bdrq6-vHsz1cIhnO2gWKhOIsqe-iw","expiry_token":1696589200,"refresh_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2OTY1ODc0MDAsIm5iZiI6MTY5NjU4NzQwMCwianRpIjoiM2FiNTc1ODAtZmJhYi00YWY0LWIzNDAtN2ExMDE4NzMyMDU3IiwiZXhwIjoxNjk5MTc5NDAwLCJpZGVudGl0eSI6eyJlbXBsb3llZV9pZCI6MjM4LCJhcHB1c2VyX2lkIjoyMzgsImlzX2FjdGl2ZSI6dHJ1ZSwiZGVwYXJ0bWVudF9pZCI6MywiYXBwcm9sZV9pZCI6NiwiYXBwcm9sZV9uYW1lIjoiQ3VzdG9tZXIiLCJkZXBhcnRtZW50X2NvZGUiOiIwNEMifSwidHlwZSI6InJlZnJlc2gifQ.Q0NCT4R9Aa6HtE0cfnPUBk4hZlo6_kl3EguCynx1wc0"},"user":{"approle_id":6,"appuser_id":238,"department_code":null,"department_id":null,"is_active":true}}}',null);
        SingleRequestMock getBusDetails = new SingleRequestMock(200,'SUCCESS','{"data":{"ecard":{"ecard_id":4706, "chassis_no":"B199093", "customer_id": 576, "customer_name": "Norman, OK" }}}',null);
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put(System.Label.EcardAppendpoint+'api/sflogin',logindata);
        endpoint2TestResp.put(System.Label.EcardAppendpoint+'api/ecardbychassisno/',getBusDetails);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        OpCkMasterDataController.getBusDetails('B199093');
    }
    
    @isTest
    static void testGetOperationCheckList() {
        List<Account> testAccount = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
            Account tAccount = new Account(Name = 'Test Account' + i, Internal_Name__c = 'TestInternalName');
            testAccount.add(tAccount);
        }
        insert testAccount;
        List<Operation_Check_Master_Data__c> testOpcklist = new List<Operation_Check_Master_Data__c>();
        for (Integer i = 0; i < 5; i++) {
            testOpcklist.add(new Operation_Check_Master_Data__c(
                Department_ID__c = 'test department' + i,
                Build_Station_ID__c = 'Test Builstation ' + i,
                isActive__c = True,
                Operation_Description__c = 'Test Description ' + i,
                Operation_Sequence_Number__c = Decimal.valueOf(i),
                Active_Date__c = Date.newInstance(2026, 05, 30),
                Inactive_Date__c = Date.newInstance(2026, 06, 29)
            ));
        }
        insert testOpcklist;
        Test.startTest();
        List<Operation_Check_Master_Data__c> result = OpCkMasterDataController.getOperationCheckList();
        Test.stopTest();
        System.assertEquals(5, result.size(), 'Incorrect number of records returned');
    }
    
    @isTest
    static void testGetAllAccounts() {
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            testAccounts.add(new Account(
                Name = 'Test Account ' + i,
                Internal_Name__c = 'Test Internal Name ' + i,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId()
            ));
        }
        insert testAccounts;
        Test.startTest();
        List<Account> result = OpCkMasterDataController.getAllAccounts();
        Test.stopTest();
        System.assertEquals(5, result.size(), 'Incorrect number of records returned');
        for (Integer i = 0; i < result.size(); i++) {
            Account account = result[i];
            System.assertEquals('Test Account ' + i, account.Name);
            System.assertEquals('Test Internal Name ' + i, account.Internal_Name__c);
        }
    }
    
    @isTest
    static void testGetAllBuslists() {
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        system.runAs(thisUser) {
            Profile p = [SELECT Id FROM Profile WHERE Name='Regional Sales Manager'limit 1];
            rRep = new user(LastName = 'National Sales Rep', Username = 'NationalSales.User@example.com', Email = 'NationalSales.User@example.com', 
                            Alias = 'rRep', CommunityNickname = 'rRep', 
                            TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = p.ID,
                            LanguageLocaleKey = 'en_US');
            insert rRep;
            Profile pm = [SELECT Id FROM Profile WHERE Name='Project Sales Manager'limit 1];
            pRep = new user(LastName = 'Project Sales Rep', Username = 'ProjectSales.User@example.com', Email = 'ProjectSales.User@example.com', 
                            Alias = 'pRep', CommunityNickname = 'pRep', 
                            TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = pm.ID,
                            LanguageLocaleKey = 'en_US');
            insert pRep;
        }
        
        List<Account> testAccount = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
            Account tAccount = new Account(Name = 'Test Account' + i, Internal_Name__c = 'TestInternalName'+ i, OwnerId = pRep.Id, Project_Sales_Manager__c=pRep.Id);
            testAccount.add(tAccount);
        }
        insert testAccount;
        List<Fleet__c> fleets = new List<Fleet__c>();
        Account a = [Select id,Project_Sales_Manager__c from Account where Id in:testAccount limit 1];
        for (Integer j = 0; j < 3; j++) {
            Fleet__c fleet = new Fleet__c(Name = 'Test Fleet ' + j, Account__c = testAccount[0].Id, OwnerId = a.Project_Sales_Manager__c);
            fleets.add(fleet);
        }
        insert fleets;
        List<Bus__c> testBuses = new List<Bus__c>();
        for (Integer k = 0; k < 5; k++) {
            testBuses.add(new Bus__c(
                Name = 'Test Bus ' + k,
                Fleet__c = fleets[0].id,
                Status__c = 'Staging'
            ));
        }
        insert testBuses;
        Test.startTest();
        List<Bus__c> result = OpCkMasterDataController.getAllBuslists();
        Test.stopTest();
        System.assertEquals(5, result.size()); 
    }
    
    @isTest
    static void testGetBuslistbyAccount() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser) {
            Profile p = [SELECT Id FROM Profile WHERE Name='Regional Sales Manager'limit 1];
            rRep = new user(LastName = 'National Sales Rep', Username = 'NationalSales.User@example.com', Email = 'NationalSales.User@example.com', 
                            Alias = 'rRep', CommunityNickname = 'rRep', 
                            TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = p.ID,
                            LanguageLocaleKey = 'en_US');
            insert rRep;
            Profile pm = [SELECT Id FROM Profile WHERE Name='Project Sales Manager'limit 1];
            pRep = new user(LastName = 'Project Sales Rep', Username = 'ProjectSales.User@example.com', Email = 'ProjectSales.User@example.com', 
                            Alias = 'pRep', CommunityNickname = 'pRep', 
                            TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = pm.ID,
                            LanguageLocaleKey = 'en_US');
            insert pRep;
        }
        List<Account> testAccount = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
            Account tAccount = new Account(Name = 'Test Account' + i, Internal_Name__c = 'TestInternalName', OwnerId = pRep.Id, Project_Sales_Manager__c=pRep.Id);
            testAccount.add(tAccount);
        }
        insert testAccount;
        List<Fleet__c> fleets = new List<Fleet__c>();
        Account a = [Select id,Project_Sales_Manager__c from Account where Id in:testAccount limit 1];
        for (Integer j = 0; j < 3; j++) {
            Fleet__c fleet = new Fleet__c(Name = 'Test Fleet ' + j, Account__c = testAccount[0].Id, OwnerId = a.Project_Sales_Manager__c);
            fleets.add(fleet);
        }
        insert fleets;
        List<Bus__c> testBuses = new List<Bus__c>();
        for (Integer k = 0; k < 5; k++) {
            testBuses.add(new Bus__c(
                Name = 'Test Bus ' + k,
                Fleet__c = fleets[0].id,
                Status__c = 'Staging'
            ));
        }
        insert testBuses;
        Test.startTest();
        List<Bus__c> result = OpCkMasterDataController.getBuslistbyAccount('TestInternalName');
        Test.stopTest();
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(5, result.size(), 'Expected 3 Bus records');
    }
    
    @isTest
    static void testGetPageRecordId() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser) {
            Profile p = [SELECT Id FROM Profile WHERE Name='Regional Sales Manager'limit 1];
            rRep = new user(LastName = 'National Sales Rep', Username = 'NationalSales.User@example.com', Email = 'NationalSales.User@example.com', 
                            Alias = 'rRep', CommunityNickname = 'rRep', 
                            TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = p.ID,
                            LanguageLocaleKey = 'en_US');
            insert rRep;
            Profile pm = [SELECT Id FROM Profile WHERE Name='Project Sales Manager'limit 1];
            pRep = new user(LastName = 'Project Sales Rep', Username = 'ProjectSales.User@example.com', Email = 'ProjectSales.User@example.com', 
                            Alias = 'pRep', CommunityNickname = 'pRep', 
                            TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = pm.ID,
                            LanguageLocaleKey = 'en_US');
            insert pRep;
        }
        List<Account> testAccount = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
            Account tAccount = new Account(Name = 'Test Account' + i, Internal_Name__c = 'TestInternalName', OwnerId = pRep.Id, Project_Sales_Manager__c=pRep.Id);
            testAccount.add(tAccount);
        }
        insert testAccount;
        List<Fleet__c> fleets = new List<Fleet__c>();
        Account a = [Select id,Project_Sales_Manager__c from Account where Id in:testAccount limit 1];
        for (Integer j = 0; j < 3; j++) {
            Fleet__c fleet = new Fleet__c(Name = 'Test Fleet ' + j, Account__c = testAccount[0].Id, OwnerId = a.Project_Sales_Manager__c);
            fleets.add(fleet);
        }
        insert fleets;
        List<Bus__c> testBuses = new List<Bus__c>();
        for (Integer k = 0; k < 5; k++) {
            testBuses.add(new Bus__c(
                Name = 'Test Bus ' + k,
                Fleet__c = fleets[0].id,
                Status__c = 'Staging'
            ));
        }
        insert testBuses;
        Test.startTest();
        Bus__c result = OpCkMasterDataController.gePageRecordId(testBuses[0].id);
        Test.stopTest();
        System.assertEquals(testBuses[0].Name, result.Name);
    }
    
    @isTest
    public static void testGetRecordTypes() {
        List<RecordType> results = OpCkMasterDataController.getRecordTypes();
        System.assertEquals(true, results.size() > 0, 'Sorry no Record Types.');
    }
}