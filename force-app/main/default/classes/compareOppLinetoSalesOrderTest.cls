@isTest
private class compareOppLinetoSalesOrderTest
{
    static Opportunity tOpportunity;
    static List<Opportunity_Line__c> tOppLine;
    static List<Opportunity_Line__c> bwOppLine;
    static Customer_Contract__c cContract;
    static User rRep;
    static User pRep;
    static Opportunity_Sales_Order__c resultingOSO;
    static Sales_Order__c resultingSO;

    @testSetup static void init() {

        TestData.init();
        TestData.createAcct();
        TestData.createOpp();
        TestData.createContract();
        TestData.createOppLine(10, 10);

    }

	@isTest
	static void itShouldNotMatch()
	{
		// Given an existing Sales Order
        List<Opportunity_Line__c> tOpps = [select Id, Quantity__c, Start_Date__c, Serial_Number__c, Opportunity_Line__c, Mode__c, PO_Amount__c, PO_Date__c, PO_Reference__c, Quoted_Price__c, Style__c, Length__c, Contract_Option__c, Book_with_Sales_Order__c, Fleet__c, Date_Booked__c
                        from Opportunity_Line__c];
        tOpps[0].Serial_Number__c = '123456';
        tOpps[0].Length__c = '35';
        tOpps[0].Start_Date__c = system.today().addYears(2);
        tOpps[0].Date_Booked__c = system.today();
        update tOpps;
        createSO.insertSO(tOpps);
        list<Sales_Order__c> resultingSO = [select Id, Name, Length__c, Mode__c, Style__c from Sales_Order__c];

        // Given another Opportunity Line that doesn't match the Sales Order

		test.startTest();

		// When the Opportunity Line is booked with the exisitng Sales Order

		tOpps[1].Book_with_Sales_Order__c = resultingSO[0].Id;
        tOpps[1].Date_Booked__c = system.today();

		// Then there should be an error that indicates the Opportunity Line doesn't match

		system.assertEquals(false, compareOppLinetoSalesOrder.match(tOpps[1], resultingSO[0]));

		test.stopTest();
	}

	@isTest
	static void itShouldMatch() {

		// Given an existing Sales Order
        List<Opportunity_Line__c> tOpps = [select Id, Quantity__c, Start_Date__c, Serial_Number__c, Opportunity_Line__c, Mode__c, PO_Amount__c, PO_Date__c, PO_Reference__c, Quoted_Price__c, Style__c, Length__c, Contract_Option__c, Book_with_Sales_Order__c, Fleet__c, Date_Booked__c
                        from Opportunity_Line__c];
        tOpps[0].Serial_Number__c = '123456';
        tOpps[0].Start_Date__c = system.today().addYears(2);
        tOpps[0].Date_Booked__c = system.today();
        update tOpps;
        createSO.insertSO(tOpps);
        list<Sales_Order__c> resultingSO = [select Id, Name, Length__c, Mode__c, Style__c from Sales_Order__c];

        // Given another Opportunity Line that matches the Sales Order

 		test.startTest();

		// When the Opportunity Line is booked with the exisitng Sales Order

		tOpps[1].Book_with_Sales_Order__c = resultingSO[0].Id;
        tOpps[1].Date_Booked__c = system.today();
        
		// Then there should be an error that indicates the Opportunity Line doesn't match

		system.assertEquals(true, compareOppLinetoSalesOrder.match(tOpps[1], resultingSO[0]));

		test.stopTest();	
	}
}