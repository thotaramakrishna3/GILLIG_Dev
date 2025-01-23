public with sharing class createProductionOrder {

	@InvocableMethod(label='Create Production Order' description='Create a Production Order when Sales Order is released')
	public static void insertProductionOrder (List<Sales_Order__c> salesOrders) {

		set<id> soset = new set<id>();
		for (Sales_Order__c soID:salesOrders) {
			soset.add(soID.Id);
		}
		List<Bus__c> busses = [select Id, Sales_Order__c, Production_Order__c, Production_Order_Sequence__c, Start_Date__c from Bus__c where Sales_Order__c in:soset Order By Name];

		List<Production_Order__c> newProdOrder = new List<Production_Order__c>();
		Integer bCount = 0;
		for (Sales_Order__c thisSO:salesOrders) {
			for (Bus__c cBus:busses) {
				if (cBus.Sales_Order__c==thisSO.Id) {
					bCount++;
				}
			}
			newProdOrder.add(new Production_Order__c(Sales_Order__c=thisSO.Id,
														name='B'+thisSO.name.leftPad(6,'0'),
														Start_Date__c=thisSO.Start_Date__c,
														Quantity__c=bCount));
			bCount=0;
		}
		insert newProdOrder;

		Integer prodOrderSeq=1;
		Id lastSO;
		for (Bus__c thisBus:busses) {
			for (Production_Order__c thisProdO:newProdOrder) {
				if (thisBus.Sales_Order__c==thisProdO.Sales_Order__c) {
					thisBus.Production_Order__c=thisProdO.Id;
					break;
				} 
			}
			if (thisBus.Sales_Order__c!=lastSO) {
				prodOrderSeq=1;
				lastSO=thisBus.Sales_Order__c;
			}
			thisBus.Production_Order_Sequence__c=prodOrderSeq;
			prodOrderSeq++;
		}
		update busses;

		return ;
	}
}