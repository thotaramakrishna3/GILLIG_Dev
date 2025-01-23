@isTest
private class Sales_OrderTest
{
    @testSetup static void init () {
        TestData.init();
        TestData.createAcct();
        TestData.createOpp();
        TestData.createContract();
        TestData.createOppLine(5, 5); //(10,10)
        TestData.createSO();
    }
    
    @isTest
    static void itShouldMergeOrder()
    {
        test.startTest();
        Schema.DescribeSObjectResult soSchema = Schema.SObjectType.Sales_Order__c;
        Map<String,Schema.RecordTypeInfo> soMap = soSchema.getRecordTypeInfosByName();
        Schema.RecordTypeInfo soMergedRecordType = soMap.get('Merged');
        
        // Given 2 Sales Orders
        List<Sales_Order__c> soList = [select id, name from Sales_Order__c];
        
        Sales_Order__c fromSalesOrder = [select id, name from Sales_Order__c where Id =:soList[0].Id];
        Sales_Order__c toSalesOrder = [select id, name from Sales_Order__c where Id =:soList[1].Id];
        List<Bus__c> fromSObusses = [select Id, Name, Sales_Order__c from Bus__c where Sales_Order__c=:fromSalesOrder.Id];
        List<Bus__c> toSObusses = [select Id, Name, Sales_Order__c from Bus__c where Sales_Order__c=:toSalesOrder.Id];
        integer totalBusses = fromSObusses.size()+toSObusses.size();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(fromSalesOrder);
        Sales_Order testSOMerge = new Sales_Order(sc);
        testSOMerge.toSaleOrder = toSalesOrder.name;
        
        // When the merge button is envoked
        
        testSOMerge.mergeTo();
        
        // Then the original Sales Order should be of record type merged
        
        Sales_Order__c originalSo = [select Id, Name, RecordTypeId from Sales_Order__c where Id=:fromSalesOrder.Id];
        system.assertEquals(soMergedRecordType.getRecordTypeId(), originalSo.RecordTypeId);
        
        // and there should be no busses on the original order
        
        List<Bus__c> noBusses = [select Id, Name from Bus__c where Sales_Order__c=:originalSo.Id];
        system.assertEquals(0, noBusses.size());
        
        // and the merged Sales Order has the combined quanity
        List<Bus__c> combinedBusses = [select Id, Name from Bus__c where Sales_Order__c=:toSalesOrder.Id];
        system.assertEquals(totalBusses, combinedBusses.size());
        test.stopTest(); 
    }
    
    @isTest
    static void itShouldSplitOrder()
    {
        // Given a sales order
        test.startTest();    
        List<Sales_Order__c> soList = [select id, name from Sales_Order__c LIMIT 1];
        if(soList.size()>0){
        ApexPages.StandardController sc = new ApexPages.StandardController(soList[0]);
        
        Sales_Order scext = new Sales_Order(sc);
        scext.toSaleOrder = '121212';
        scext.toSalesOrderQty = 2;
        
        
        // When the Split button is invoked
        
        scext.splitTo();
        
        // Then the second sales order should exist and the original should reduce qty
        
        Sales_Order__c splitToSalesOrder = [select Id, Name from Sales_Order__c where Name=:scext.toSaleOrder];
        system.assertEquals(scext.toSaleOrder, splitToSalesOrder.Name);
        
       // Opportunity_Sales_Order__c toSplitOSO = [select Id, Name, Opportunity_Line__c, Sales_Order__c, Quantity__c from Opportunity_Sales_Order__c where Sales_Order__c =:splitToSalesOrder.Id];
       // system.assertEquals(scext.toSalesOrderQty, toSplitOSO.Quantity__c);
            }else{
            System.assert(false, 'No Sales Orders to run the test');
        }
        test.stopTest(); 
        
    }
    
    // Model ID test class
    @isTest
    static void testUpdateModelFieldWithFieldsChanged() {
        test.startTest();          
        List<Sales_order__c> so = new List<Sales_order__c>();        
        for(Sales_order__c s: [select id,name,Length__c,Engine__c,Width__c, Rear_Suspension__c,Letter_Code__c, 
                               Mode__C from Sales_Order__c LIMIT 1]){
                                   s.Engine__c = 'Cummins L9 8.9 Liter'; 
                                   s.Length__c = '40';
                                   s.Width__c = '102';
                                   s.Rear_Suspension__c = 'H4';
                                   s.Letter_Code__c = 'G';
                                   s.Mode__C = 'Diesel';
                                   so.add(s);
                               }         
        update so;
        
        Sales_Order__c updatedSo = [SELECT Id, Model_Id__c FROM Sales_Order__c WHERE Id IN :so LIMIT 1];
        System.debug('updatedSo' +updatedSo.Model_Id__c);
        System.assertEquals('G27D102H4', updatedSo.Model_Id__c);
        test.stopTest();  
    }
    
    @isTest
    static void testUpdateModelFieldWithElectricMode() {
        test.startTest();          
        List<Sales_order__c> so = new List<Sales_order__c>(); 
        for(Sales_order__c s: [select id,Length__c,Engine__c,Width__c, Rear_Suspension__c,Letter_Code__c, 
                               Mode__C from Sales_Order__c LIMIT 1]){
                                   s.Engine__c = 'Electric'; 
                                   s.Length__c = '35';
                                   s.Width__c = '102';
                                   s.Rear_Suspension__c = 'H2';
                                   s.Letter_Code__c = 'G';
                                   s.Mode__C = 'Electric';
                                   so.add(s);
                               }
        update so;
        
        Sales_Order__c updatedSo = [SELECT Id, Model_Id__c FROM Sales_Order__c WHERE Id IN :so LIMIT 1];
        System.debug('updatedSo' +updatedSo.Model_Id__c);
        System.assertEquals('G28B102H2', updatedSo.Model_Id__c);
        test.stopTest();  
    }
    
}