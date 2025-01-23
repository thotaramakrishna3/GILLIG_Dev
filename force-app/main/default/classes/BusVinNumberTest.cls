@isTest
private class BusVinNumberTest {
    
    @testSetup static void init () {
        test.startTest();
        TestData.init();
        TestData.createAcct();
        TestData.createOpp();
        TestData.createContract();
        TestData.createOppLine(10, 10);
        TestData.createSO();
        test.stopTest();
    }

    @isTest
    static void itShouldNotGenerateVinforBusses() {
        
        test.startTest();        
        List<Sales_order__c> so = [select id,name from Sales_Order__c];     
        List<Bus__c> b = [select Id, Name, Sales_Order__c,Bus_Length__c, Engine__c,Sales_Order__r.Letter_Code__c,VIN__c,Brakes__c, Green_Sheet_Date__c from Bus__c];
        system.assertEquals(null, b[0].VIN__c);        
        test.stopTest();
        
    }
    
    @isTest
    static void itShouldUpdateVinNumofBusses1() {
        
        test.startTest();            
        List<Sales_order__c> so = [select id,name,Length__c,Engine__c,Brakes__c from Sales_Order__c order by id asc];
        List<Bus__c> b = [select Id, Name, Sales_Order__c,Bus_Length__c, Engine__c,Sales_Order__r.Letter_Code__c,VIN__c,Brakes__c, Green_Sheet_Date__c from Bus__c order by id asc];
        b[0].sales_order__c = so[0].Id;
        Date greenSheetDate = Date.newInstance(2022,07,21);
        b[0].Green_Sheet_Date__c = greenSheetDate.addYears(2);
        update b;
        
        so[0].Name = '197273';   
        so[0].Length__c = '29';
        so[0].Engine__c = 'Cummins L9N 8.9 Liter';
        so[0].Brakes__c = 'Disc';
        update so;
        
        List<Bus__c> ubus = [select Id, Name, Sales_Order__c,Bus_Length__c, Engine__c,Sales_Order__r.Letter_Code__c,VIN__c,Brakes__c, Green_Sheet_Date__c from Bus__c where sales_order__c =:so[0].Id ];
        system.assertEquals('15GGD3118R3197273', ubus[0].VIN__c);   
        
        ubus[0].Name = '96020';
        update ubus;
        
        List<Bus__c> upbus = [select Id, Name, Sales_Order__c,Bus_Length__c, Engine__c,Sales_Order__r.Letter_Code__c,VIN__c,Brakes__c, Green_Sheet_Date__c from Bus__c where sales_order__c =:so[0].Id ];
        system.assertEquals('15GGD3110R3096020', upbus[0].VIN__c); 
        
        test.stopTest();
        
    }
    
    @isTest
    static void itShouldUpdateVinNumofBusToNull1() {
        
        test.startTest();           
        List<Sales_order__c> so = [select id,name,Length__c,Engine__c,Brakes__c from Sales_Order__c order by id asc];
        List<Bus__c> b = [select Id, Name, Sales_Order__c,Bus_Length__c, Engine__c,Sales_Order__r.Letter_Code__c,VIN__c,Brakes__c, Green_Sheet_Date__c from Bus__c order by id asc];
        b[0].sales_order__c = so[0].Id;
        Date greenSheetDate = Date.newInstance(2022,07,21);
        b[0].Green_Sheet_Date__c = greenSheetDate.addYears(2);
        update b;
        
        so[0].Name = '197273';   
        so[0].Length__c = '29';
        so[0].Engine__c = 'Cummins L9N 8.9 Liter';
        so[0].Brakes__c = 'Disc';
        update so;
        
        List<Bus__c> ubus = [select Id, Name, Sales_Order__c,Bus_Length__c, Engine__c,Sales_Order__r.Letter_Code__c,VIN__c,Brakes__c, Green_Sheet_Date__c from Bus__c where sales_order__c =:so[0].Id ];
        system.assertEquals('15GGD3118R3197273', ubus[0].VIN__c);   
        
        ubus[0].Green_Sheet_Date__c = null;
        update ubus;
        
        List<Bus__c> upbus = [select Id, Name, Sales_Order__c,Bus_Length__c, Engine__c,Sales_Order__r.Letter_Code__c,VIN__c,Brakes__c, Green_Sheet_Date__c from Bus__c where sales_order__c =:so[0].Id ];
        system.assertEquals(null, upbus[0].VIN__c); 
        
        test.stopTest();
        
    }
    
    @isTest
    static void itShouldUpdateVinNumofBusses2() {
        
        test.startTest();            
        List<Sales_order__c> so = [select id,name,Length__c,Engine__c,Brakes__c from Sales_Order__c order by id asc];
        List<Bus__c> b = [select Id, Name, Sales_Order__c,Bus_Length__c, Engine__c,Sales_Order__r.Letter_Code__c,VIN__c,Brakes__c, Green_Sheet_Date__c from Bus__c order by id asc];
        b[0].sales_order__c = so[0].Id;
        Date greenSheetDate = Date.newInstance(2022,07,21);
        b[0].Green_Sheet_Date__c = greenSheetDate.addYears(2);
        update b;
        
        so[0].Name = '197273';
        so[0].Engine__c = 'Cummins L9N 8.9 Liter';
        so[0].Brakes__c = 'Disc';
        update so;
        
        List<Bus__c> ubus = [select Id, Name, Sales_Order__c,Bus_Length__c, Engine__c,Sales_Order__r.Letter_Code__c,VIN__c,Brakes__c, Green_Sheet_Date__c from Bus__c where sales_order__c =:so[0].Id ];
        system.assertEquals('15GGD3118R3197273', ubus[0].VIN__c);   
        
        Sales_Order__c uSo = [select id,name,Length__c,Engine__c,Brakes__c from Sales_Order__c where id=:so[0].Id];
        uSo.Name = '096854';
        uSo.Engine__c = 'Cummins B6.7 6.7 Liter';
        uSo.Brakes__c = 'Hydraulic';
        update uSo;
        
        List<Bus__c> upbus = [select Id, Name, Sales_Order__c,Bus_Length__c, Engine__c,Sales_Order__r.Letter_Code__c,VIN__c,Brakes__c, Green_Sheet_Date__c from Bus__c where sales_order__c =:so[0].Id ];
        system.assertEquals('15GGD3013R3096854', upbus[0].VIN__c);
        
        test.stopTest();
        
    }
    
    @isTest
    static void itShouldUpdateVinNumofBusToNull2() {
        
        test.startTest();           
        List<Sales_order__c> so = [select id,name,Length__c,Engine__c,Brakes__c from Sales_Order__c order by id asc];
        List<Bus__c> b = [select Id, Name, Sales_Order__c,Bus_Length__c, Engine__c,Sales_Order__r.Letter_Code__c,VIN__c,Brakes__c, Green_Sheet_Date__c from Bus__c order by id asc];
        b[0].sales_order__c = so[0].Id;
        Date greenSheetDate = Date.newInstance(2022,07,21);
        b[0].Green_Sheet_Date__c = greenSheetDate.addYears(2);
        update b;
        
        so[0].Name = '197273';   
        so[0].Length__c = '29';
        so[0].Engine__c = 'Cummins L9N 8.9 Liter';
        so[0].Brakes__c = 'Disc';
        update so;
        
        List<Bus__c> ubus = [select Id, Name, Sales_Order__c,Bus_Length__c, Engine__c,Sales_Order__r.Letter_Code__c,VIN__c,Brakes__c, Green_Sheet_Date__c from Bus__c where sales_order__c =:so[0].Id ];
        system.assertEquals('15GGD3118R3197273', ubus[0].VIN__c);   
        
        Sales_Order__c uSo = [select id,name,Length__c,Engine__c,Brakes__c from Sales_Order__c where id=:so[0].Id];
        uSo.Engine__c = null;
        update uSo;
        
        List<Bus__c> upbus = [select Id, Name, Sales_Order__c,Bus_Length__c, Engine__c,Sales_Order__r.Letter_Code__c,VIN__c,Brakes__c, Green_Sheet_Date__c from Bus__c where sales_order__c =:uSo.Id ];
        system.assertEquals(null, upbus[0].VIN__c); 
        
        test.stopTest();
        
    } 
}