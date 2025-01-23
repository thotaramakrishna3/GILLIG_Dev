@isTest 
private class createSOTest {

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
                                                    Type = 'Existing Business',Order_Probability__c = '1. High Probability', 
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
                                            Length__c = '40',
                                            Lo_No_Grant__c = 'Test Lo no'));
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
                                            Length__c = '40',
                                            Lo_No_Grant__c = 'Test Lo No'));
        insert tOppLine;
    }

//	If the "Book With" field is null at the time of entry of Date Booked, then a new sales order would be created and that Sales Order would be added to the Junction Object.
	@isTest
	static void itShouldCreateOpportunitySalesOrder() {

		// Given any number of Opportunity Lines
		init();

		test.startTest();

        tOppLine[0].Start_Date__c = system.today();
        tOppLine[1].Start_Date__c = system.today();
        tOppLine[0].Serial_Number__c = '123456';
        tOppLine[1].Serial_Number__c = '123458';
        tOppLine[0].Date_Booked__c = system.today();
        tOppLine[1].Date_Booked__c = system.today();

        //When the Opportunity Lines are booked
        update tOppLine;

        createSO.insertSO(tOppLine);

        set<Id> oppLines = new set<Id>();
        oppLines.add(tOppLine[0].Id);
        oppLines.add(tOppLine[1].Id);

        List<Opportunity_Sales_Order__c> resultingOSO = [select Id, Opportunity_Line__c, Sales_Order__c, Quantity__c from Opportunity_Sales_Order__c where Opportunity_Line__c in :oppLines];
        
        // Then there should be a Oopportunity Sales Order for each Opportunity Line
        system.assertEquals(tOppLine.size(), resultingOSO.size());

        for (Opportunity_Sales_Order__c checkQty:resultingOSO) {
        	for (Opportunity_Line__c olQty:tOppLine) {
        		if (checkQty.Opportunity_Line__c == olQty.Id) {
        // Then the Opportunity Sales Order quantity should match the Opportunity Line Qty
        			system.assertEquals(olQty.Quantity__c,checkQty.Quantity__c);
        		break;
        		}
        	}
        }
		test.stopTest();
	}

//	If the "Book With" field is null at the time of entry of Date Booked, then a new sales order would be created and that Sales Order would be added to the Junction Object.
	@isTest
	static void itShouldCreateSalesOrder() {

		// Given any number of Opportunity Lines
		init();

		test.startTest();

        tOppLine[0].Start_Date__c = system.today();
        tOppLine[1].Start_Date__c = system.today();
        update tOppLine;     

        tOppLine[0].Serial_Number__c = '123456';
        tOppLine[1].Serial_Number__c = '123458';
        update tOppLine;

        tOppLine[0].Date_Booked__c = system.today();
        tOppLine[1].Date_Booked__c = system.today();
        //When the Opportunity Lines are booked
        update tOppLine; 

        createSO.insertSO(tOppLine);

        set<Id> oppLines = new set<Id>();
        oppLines.add(tOppLine[0].Id);
        oppLines.add(tOppLine[1].Id);

        List<Opportunity_Sales_Order__c> resultingOSO = [select Id, Opportunity_Line__c, Sales_Order__c, Quantity__c from Opportunity_Sales_Order__c where Opportunity_Line__c in :oppLines];
        
       	set<Id> salesOrders = new set<Id>();
        for (Opportunity_Sales_Order__c tOSO:resultingOSO) {
        	salesOrders.add(tOSO.Sales_Order__c);
        }
 		set<Id> opps = new set<Id>();
 		opps.add(tOppLine[0].Opportunity_Line__c);
 		opps.add(tOppLine[1].Opportunity_Line__c);
 		List <Opportunity> allOpps = new List<Opportunity>([select ID, Accountid, RecordTypeID, Reference_Contract__c, Name, Total_Lines__c, Options_Used__c from Opportunity where ID in :opps]);
 		map<id,String> oppContractType = new map<id,String>();
		for (recordtype contractRec:[select id, Name, DEVELOPERNAME, SOBJECTTYPE from recordtype where SOBJECTTYPE = 'Opportunity']) {
			oppContractType.put(contractRec.Id, contractRec.Name);
		} 		

        List<Sales_Order__c> resultingSO = [select Ownerid, Name, Opportunity__c, Account__c,
        										Mode__c, Date_Booked__c, PO_Amount__c, PO_Date__c,
        										PO_Reference__c, Quoted_Price__c,
        										Current_Price__c, Current_Tax__c, Spare_Tooling_Budget__c, Reference_Contract__c, Style__c,
        										Start_Date__c,Length__c, Contract_Option__c, Contract_Type__c, Lo_No_Grant__c
        										from Sales_Order__c where Id in :salesOrders];
        
        // Then there should be a Sales Order for each Opportunity Line
        system.assertEquals(tOppLine.size(), resultingSO.size());

        // Then the Sales Order fields should match the Opportunity Lines
        for (Opportunity_Line__c olFields:tOppLine) {
        	for (Opportunity_Sales_Order__c tOSO:resultingOSO) {
        		if (olFields.Id == tOSO.Opportunity_Line__c) {
        			for (Sales_Order__c soFields:resultingSO) {
        				if (soFields.Id == tOSO.Sales_Order__c) {
        					for (Opportunity chkOpp:allOpps) {
        						if (olFields.Opportunity_Line__c == chkOpp.Id) {
        							system.assertEquals(olFields.Serial_Number__c, soFields.Name);
        							system.assertEquals(chkOpp.Id, soFields.Opportunity__c);
        							system.assertEquals(chkOpp.AccountId, soFields.Account__c);
        							system.assertEquals(olFields.Mode__c, soFields.Mode__c);
        							system.assertEquals(olFields.Date_Booked__c, soFields.Date_Booked__c);
        							system.assertEquals(olFields.PO_Amount__c, soFields.PO_Amount__c);
        							system.assertEquals(olFields.PO_Date__c, soFields.PO_Date__c);
        							system.assertEquals(olFields.PO_Reference__c, soFields.PO_Reference__c);
        							system.assertEquals(olFields.Quoted_Price__c, soFields.Quoted_Price__c);
                                    system.assertEquals(olFields.Quoted_Price__c, soFields.Current_Price__c);
        							system.assertEquals(olFields.Spare_Tooling_Budget__c, soFields.Spare_Tooling_Budget__c);
                                    system.assertEquals(olFields.Current_Tax__c, soFields.Current_Tax__c);
        							system.assertEquals(chkOpp.Reference_Contract__c, soFields.Reference_Contract__c);
        							system.assertEquals(olFields.Style__c, soFields.Style__c);
        							system.assertEquals(olFields.Start_Date__c, soFields.Start_Date__c);
        							system.assertEquals(olFields.Length__c, soFields.Length__c);
        							system.assertEquals(olFields.Contract_Option__c, soFields.Contract_Option__c);
        							system.assertEquals(oppContractType.get(chkOpp.RecordTypeID),soFields.Contract_Type__c);
                                    system.assertEquals(olFields.Lo_No_Grant__c, soFields.Lo_No_Grant__c);
        						break;
        						}
        					}
        				break;
        				}
        			}
        		break;
        		}
        	}
        }
        test.stopTest();
	}

	@isTest
	static void itShouldBookWithSalesOrder()
	{
		init();

		test.startTest();
        tOppLine[0].Start_Date__c = system.today();
        tOppLine[1].Start_Date__c = system.today();
        update tOppLine;     

        tOppLine[0].Serial_Number__c = '123456';
        tOppLine[1].Serial_Number__c = '123458';
        update tOppLine;

        tOppLine[0].Date_Booked__c = system.today();
        tOppLine[1].Date_Booked__c = system.today();
        update tOppLine;

        // Given an existing sales order
        createSO.insertSO(tOppLine);
        List<Opportunity_Sales_Order__c> bookedOSO = [select Id, Opportunity_Line__c, Sales_Order__c, Quantity__c from Opportunity_Sales_Order__c where Opportunity_Line__c = :tOppLine[1].Id];

		// If the "Book With" field has a sales order, then no new sales order is generated and the existing Sales Order would be added to the junction object.  
		// We would need to do a check to validate that the necessary fields are the same on the sales order as on the opportunity line somehow when selecting the "Book With".  
		// I am thinking using the filter functionality to ensure length, style and mode are the same on the Opportunity Line and the Sales Order might work, if not some other check.  
		List<Opportunity_Line__c> bwOppLine = new List<Opportunity_Line__c>();

        // When an Opportunity Line Book with Sales order is set
        bwOppLine.add(new Opportunity_Line__c (Opportunity_Line__c = tOpportunity.Id,
                                            Quantity__c = 2,
                                            Mode__c = 'Diesel',
                                            PO_Amount__c = 150, 
                                            PO_Date__c = system.today(), 
                                            PO_Reference__c = 'Test PO',
                                            Quoted_Price__c = 100, 
                                            Reference_Contract__c = cContract.Id,
                                            Style__c = 'LF',
                                            Length__c = '40',
                                            Lo_No_Grant__c = 'Test Lo No'));
      
        insert bwOppLine;

        bwOppLine[0].Start_Date__c = system.today();
        update bwOppLine;

        bwOppLine[0].Serial_Number__c = '123460';
        update bwOppLine;

        bwOppLine[0].Date_Booked__c = system.today();
        bwOppLine[0].Book_with_Sales_Order__c = bookedOSO[0].Sales_Order__c;
        update bwOppLine;
        createSO.insertSO(bwOppLine);

        // Then there should not be a sales order created for that line
        try { 
				Sales_Order__c bwSO = [select Id, Name from Sales_Order__c where Name=:bwOppLine[0].Serial_Number__c];
			} catch (Exception e) {
				system.assertNotEquals(Null, e);		
			}

		// But there should be an Opportunity Sales Order created
		List<Opportunity_Sales_Order__c> resultingOSO = [select Id, Opportunity_Line__c, Sales_Order__c, Quantity__c from Opportunity_Sales_Order__c where Opportunity_Line__c = :bwOppLine[0].Id];
		system.assertEquals(bookedOSO[0].Sales_Order__c,resultingOSO[0].Sales_Order__c);

		// And the Quantity on the Sales Order should be the sum of all Opportunity Lines
		set<Id> oppLines = new set<Id>();
		oppLines.add(tOppLine[1].Id);
		oppLines.add(bwOppLine[0].Id);
		AggregateResult[] soQty = [select sum(Quantity__c)totalSOqty from Opportunity_Sales_Order__c where Opportunity_Line__c in :oppLines];
		Sales_Order__c resultingSO = [select Id, Name, Quantity__c from Sales_Order__c where Id=:bwOppLine[0].Book_with_Sales_Order__c];
		system.assertEquals(soQty[0].get('totalSOqty'),resultingSO.Quantity__c);

		test.stopTest();
	}
    @isTest
    static void itShouldMergeSalesOrder()
    {

        init();
        tOppLine[0].Start_Date__c = system.today();
        tOppLine[1].Start_Date__c = system.today();
        update tOppLine;       

        tOppLine[0].Serial_Number__c = '123456';
        tOppLine[1].Serial_Number__c = '123458';
        update tOppLine;

        tOppLine[0].Date_Booked__c = system.today();
        tOppLine[1].Date_Booked__c = system.today();

        update tOppLine; 
        // Given 2 Sales Orders
        createSO.insertSO(tOppLine);

        test.startTest();
        set<Id> oppLines = new set<Id>();
        oppLines.add(tOppLine[0].Id);
        oppLines.add(tOppLine[1].Id);

        List<Opportunity_Sales_Order__c> resultingOSO = [select Id, Opportunity_Line__c, Sales_Order__c, Quantity__c from Opportunity_Sales_Order__c where Opportunity_Line__c in :oppLines];
        
        set<Id> salesOrders = new set<Id>();
        for (Opportunity_Sales_Order__c tOSO:resultingOSO) {
            salesOrders.add(tOSO.Sales_Order__c);
        }
        set<Id> opps = new set<Id>();
        opps.add(tOppLine[0].Opportunity_Line__c);
        opps.add(tOppLine[1].Opportunity_Line__c);
        List <Opportunity> allOpps = new List<Opportunity>([select ID, Accountid, RecordTypeID, Reference_Contract__c, Name, Total_Lines__c, Options_Used__c from Opportunity where ID in :opps]);
        map<id,String> oppContractType = new map<id,String>();
        for (recordtype contractRec:[select id, Name, DEVELOPERNAME, SOBJECTTYPE from recordtype where SOBJECTTYPE = 'Opportunity']) {
            oppContractType.put(contractRec.Id, contractRec.Name);
        }

        List<Sales_Order__c> resultingSO = [select Ownerid, Name, Opportunity__c, Account__c,
                                                Mode__c, Date_Booked__c, PO_Amount__c, PO_Date__c,
                                                PO_Reference__c, Quoted_Price__c,
                                                Current_Price__c, Current_Tax__c, Spare_Tooling_Budget__c, Reference_Contract__c, Style__c,
                                                Start_Date__c,Length__c, Contract_Option__c, Contract_Type__c, Lo_No_Grant__c
                                                from Sales_Order__c where Id in :salesOrders];

        Id mergetoSO;
        Id mergefromSO;
        for (Opportunity_Sales_Order__c mergetoOSO:resultingOSO) {
            if (mergetoOSO.Opportunity_Line__c == tOppLine[0].Id) {
                mergetoSO = mergetoOSO.Sales_Order__c;
            }
        }
        // When the Opportunity Sales Order changes from one Sales Order to another
        for (Opportunity_Sales_Order__c mergewithOSO:resultingOSO) {
            if (mergewithOSO.Opportunity_Line__c == tOppLine[1].Id) {
                mergefromSO = mergewithOSO.Sales_Order__c;
                mergewithOSO.Sales_Order__c = mergetoSO;
            }            
        }
        update resultingOSO;

        // Then the orginating Sales Order no longer has a quantity
        Sales_Order__c updatefromSO = [select Id, name, Quantity__c from Sales_Order__c where id=:mergefromSO];
        system.assertEquals(0,updatefromSO.Quantity__c);

        // And the target Sales Order has the quantity of the combined Sales Orders
        Sales_Order__c updatetoSO = [select Id, name, Quantity__c from Sales_Order__c where id=:mergetoSO];
        system.assertEquals(4, updatetoSO.Quantity__c);
        test.stopTest();
    }

    @isTest
    static void itShouldSplitSalesOrder()
    {
        init();
        tOppLine[0].Start_Date__c = system.today();
        update tOppLine;       

        tOppLine[0].Serial_Number__c = '123456';
        update tOppLine;

        tOppLine[0].Date_Booked__c = system.today();
        update tOppLine; 

        // Given a Sales Orders
        createSO.insertSO(tOppLine);

        Opportunity_Sales_Order__c resultingOSO = [select Id, Opportunity_Line__c, Sales_Order__c, Quantity__c from Opportunity_Sales_Order__c where Opportunity_Line__c =:tOppLine[0].Id];

        set<Id> opps = new set<Id>();
        opps.add(tOppLine[0].Opportunity_Line__c);
        opps.add(tOppLine[1].Opportunity_Line__c);
        List <Opportunity> allOpps = new List<Opportunity>([select ID, Accountid, RecordTypeID, Reference_Contract__c, Name, Total_Lines__c, Options_Used__c from Opportunity where ID in :opps]);
        map<id,String> oppContractType = new map<id,String>();
        for (recordtype contractRec:[select id, Name, DEVELOPERNAME, SOBJECTTYPE from recordtype where SOBJECTTYPE = 'Opportunity']) {
            oppContractType.put(contractRec.Id, contractRec.Name);
        }

        Sales_Order__c resultingSO = [select Id, Ownerid, Name, Opportunity__c, Account__c,
                                                Mode__c, Date_Booked__c, PO_Amount__c, PO_Date__c,
                                                PO_Reference__c, Quoted_Price__c,
                                                Current_Price__c, Current_Tax__c, Spare_Tooling_Budget__c, Reference_Contract__c, Style__c,
                                                Start_Date__c,Length__c, Contract_Option__c, Contract_Type__c, Lo_No_Grant__c
                                                from Sales_Order__c where Id =:resultingOSO.Sales_Order__c];


        test.startTest();

        // When a Sales Order is cloned
        Sales_Order__c splitSO = resultingSO.clone(false, true, true, false);
        splitSO.name = '123458';
        insert splitSO;
        // And the quantity is changed
        resultingOSO.Quantity__c = 1;
        update resultingOSO;
        // And the Opposturnity Sales Order xref is created
        Opportunity_Sales_Order__c splitOSO = new Opportunity_Sales_Order__c(Opportunity_Line__c=tOppLine[0].Id,
                        Sales_Order__c = splitSO.Id,
                        Quantity__c=1);
        insert splitOSO;

        // Then the orginal Sales Order should have the reduced quantity
        Sales_Order__c oirginalSO = [select Id, Name, Quantity__c from Sales_Order__c where Id =:resultingSO.Id];
        system.assertEquals(1, oirginalSO.Quantity__c);
        
        // And the new Sales Order should have the increased quantity with the correct name
        Sales_Order__c clonedSO = [select Id, Name, Quantity__c from Sales_Order__c where Id =:splitSO.Id];
        system.assertEquals(1, clonedSO.Quantity__c);
        system.assertEquals('123458', clonedSO.Name);

        test.stopTest();
    }

    @isTest
    static void itShouldNotCreateSalesOrder() {

        // Given any number of Opportunity Lines
        init();

        test.startTest();

        tOppLine[0].Start_Date__c = system.today();
        tOppLine[1].Start_Date__c = system.today();
        update tOppLine;      

        tOppLine[0].Serial_Number__c = '123456';
        tOppLine[1].Serial_Number__c = '123458';
        update tOppLine;

        tOppLine[0].Date_Booked__c = null;
        tOppLine[1].Date_Booked__c = null;

        //When the Opportunity Lines are booked with no Booked Date
        update tOppLine; 

        createSO.insertSO(tOppLine);

        set<Id> oppLines = new set<Id>();
        oppLines.add(tOppLine[0].Id);
        oppLines.add(tOppLine[1].Id);

        List<Opportunity_Sales_Order__c> resultingOSO;
        try {
            resultingOSO = [select Id, Opportunity_Line__c, Sales_Order__c, Quantity__c from Opportunity_Sales_Order__c where Opportunity_Line__c in :oppLines];
        } catch (Exception e) {
            system.assertNotEquals(null,e);
        }

        system.assertEquals(0, resultingOSO.size());

        test.stopTest();
    }

}