@isTest
private class createProductionOrderTest
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
	static void itShouldcreateProductionOrder()
	{
		// Given a sales order

		List<Sales_Order__c> sorders = new List<Sales_Order__c>([select Id, Name, Release_Order__c from Sales_Order__c]);

		// When the release date is set
		for (Sales_Order__c thisSO:sorders) {
			thisSO.Release_Order__c = true;
		}
		update sorders;
		TestData.createProductionOrder();

		// Then a production order should be created

		List<Production_Order__c> pOrders = new List<Production_Order__c>([select Id, Name, Sales_Order__c, Start_Date__c, Quantity__c from Production_Order__c]);
		system.assertNotEquals(0, pOrders.size());

		List<Bus__c> busses = new List<Bus__c>([select Id, Name, Sales_Order__c, Production_Order__c, Production_Order_Sequence__c, Start_Date__c, Sequence__c from Bus__c order by Name]);
		system.assertNotEquals(0, busses.size());

		Integer prodOrderSeq=1;
		Id prodOrder;


		for (Bus__c thisbus:busses) {
			if (thisbus.Production_Order__c!=prodOrder) {
				prodOrderSeq=1;
				prodOrder=thisbus.Production_Order__c;
			} else {
				prodOrderSeq++;
			}

			// Production order sequence should be set

			system.assertEquals(prodOrderSeq, thisbus.Production_Order_Sequence__c);
			for (Production_Order__c thisProdO:pOrders) {
				if (thisbus.Sales_Order__c == thisProdO.Sales_Order__c) {
					// Each of the busses for the Sales Order should have a matching Production Order
					system.assertEquals(thisbus.Production_Order__c, thisProdO.Id);
					system.assertNotEquals(Null, thisProdO.Start_Date__c);
					break;
				}
			}
		}

		Integer busQty=0;
		date sDate = Null;
		for (Production_Order__c thisProdO:pOrders) {
			for (Bus__c thisbus:busses) {
				if (thisbus.Production_Order__c==thisProdO.Id) {
					busQty++;
					if (thisbus.Sequence__c==1) {
						sDate=thisbus.Start_Date__c;
					}
				}
			}
//			system.assertEquals(sDate,thisProdO.Start_Date__c);
			system.assertEquals(busQty,thisProdO.Quantity__c);
			sDate=Null;
			busQty=0;
		}
	}
}