public with sharing class Sales_Order {

	private final Sales_Order__c originSO;
    transient public String toSaleOrder {get; set;}
    transient public Integer toSalesOrderQty {get; set;} 

    // MODEL ID GENERATE 
    public static Map<String, Object> engineTypeMap { get; set; }
    public static Map<String, Object> busLengthMap { get; set; }
    
    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public Sales_Order(ApexPages.StandardController stdController) {
        originSO = (Sales_Order__c)stdController.getRecord();
    }

    public PageReference mergeTo() {
        Sales_Order__c toSo = [Select Id, Name, RecordTypeId, Start_Date__c from Sales_Order__c where Name=:toSaleOrder];
        if (toSo.Id!=Null) {

            Schema.DescribeSObjectResult soSchema = Schema.SObjectType.Sales_Order__c;
            Map<String,Schema.RecordTypeInfo> soMap = soSchema.getRecordTypeInfosByName();
            Schema.RecordTypeInfo soMergedRecordType = soMap.get('Merged');

            List<Opportunity_Sales_Order__c> fromOSO = [select Id, Name, Opportunity_Line__c, Sales_Order__c, Quantity__c from Opportunity_Sales_Order__c where Sales_Order__c =:originSO.Id];
            List<Opportunity_Sales_Order__c> toOSO = new List<Opportunity_Sales_Order__c>();
            Opportunity_Sales_Order__c tempOSO;
            for (Opportunity_Sales_Order__c thisOSO:fromOSO) {
                tempOSO = thisOSO.clone(false, true, false, false);
                tempOSO.Sales_Order__c=toSo.id;
                toOSO.add(tempOSO);
            }
            insert toOSO;

            List<Bus__c> reparentBus = [select Id, Name, Sales_Order__c, Start_Date__c, Opportunity_Line__c from Bus__c where Sales_Order__c=:originSO.Id];
            for (Bus__c b:reparentBus) {
                b.Sales_Order__c = toSo.Id;
            }
            update reparentBus;

            Sales_Order__c fromSO = [select Id, RecordTypeId, Name, Start_Date__c from Sales_Order__c where Id=:originSO.Id];
            fromSO.RecordTypeId = soMergedRecordType.getRecordTypeId();
            update fromSO;

        }
        PageReference soPage = new ApexPages.StandardController(toSO).view();
        soPage.setRedirect(true);
        return soPage;
    }

    public PageReference splitTo() {

        Sales_Order__c so = [select Id, Name, Account__c, Axle_Ratio__c, BOM_Processing_Hours__c, Brakes__c,
                Buy_Design_Check__c, Chassis_Manufacturer__c, Clear_Coat__c, Contract_Option__c,
                Contract_Type__c, Control_Number__c, Current_Price__c, Current_Tax__c, Dash_Layou__c,
                Date_Booked__c, Document_Retention_Information__c, Engine__c, Engineering_Order_Release_Date__c,
                Final_BOM_Release_Date__c, Forecasted_Margin__c, Front_Axle__c, HVAC_System__c, Invoice_Information__c,
                ITS_System__c, ITS_System_Type__c, Length__c, Letter_Code__c, Letter_Due__c, Letter_Response__c,
                Letter_Sent__c, Mode__c, Opportunity__c, Order_Loaded__c, Order_Processing_Notes__c, Order_Processor__c,
                Paint_Layout__c, Paint_Passes__c, Passenger_Seating_Manufacturer__c, PO_Amount__c, PO_Confirmation_Delivery__c,
                PO_Date__c, PO_Reference__c, Preproduction_Meeting__c, Quoted_Price__c, Rear_Axle__c, Rear_Door__c,
                Rear_Suspension__c, Reference_Contract__c, Release_Order__c, Review_Date__c, Sales_Order_Release__c,
                Seat_Layout__c, Spare_Tooling_Budget__c, Start_Date__c, Style__c, Transmission__c, Wheelchair_Ramp__c,
                Width__c, Ownerid, RecordTypeId
                from Sales_Order__c where Id = :originSO.Id];

        Sales_Order__c toSO = so.clone(false, true, false, false);
        toSO.name = toSaleOrder;

        insert toSO;

        List<Opportunity_Sales_Order__c> fromOSOList = [select Id, Name, Opportunity_Line__c, Sales_Order__c, Quantity__c from Opportunity_Sales_Order__c where Sales_Order__c =:originSO.Id];
        if(fromOSOList.size()>0){
        Opportunity_Sales_Order__c fromOSO = fromOSOList[0];
        for (Opportunity_Sales_Order__c checkOSO:fromOSOList) {
            if (checkOSO.Quantity__c >= toSalesOrderQty) {
                fromOSO = checkOSO;
                break;
            }
        }

        Opportunity_Sales_Order__c toOSO = fromOSO.clone(false, true, false, false);
        toOSO.Sales_Order__c = toSO.Id;
        toOSO.Quantity__c = toSalesOrderQty;
        insert toOSO;

        map<Opportunity_Sales_Order__c, Opportunity_Sales_Order__c> osoMap = new map<Opportunity_Sales_Order__c, Opportunity_Sales_Order__c>();
        osoMap.put(fromOSO, toOSO);
        bus.move(osoMap);

        fromOSO.Quantity__c = fromOSO.Quantity__c - toOSO.Quantity__c;
        update fromOSO;

        PageReference soPage = new ApexPages.StandardController(toSO).view();
        soPage.setRedirect(true);
        return soPage;
            }else{
            PageReference soPage = new PageReference('/home/home.jsp');
        soPage.setRedirect(true);
        return soPage;
        }
    }

	public void splitTO (Sales_Order__c fromSalesOrder, String toSaleOrder, Integer toQuantity) {

		Sales_Order__c toSO = fromSalesOrder.clone(false, false, false, false);
		toSO.name = toSaleOrder;
		insert toSO;

		Opportunity_Sales_Order__c fromOSO = [select Id, Name, Opportunity_Line__c, Sales_Order__c, Quantity__c from Opportunity_Sales_Order__c where id =:fromSalesOrder.Id];
		Opportunity_Sales_Order__c toOSO = fromOSO.clone(false, false, false, false);
		toOSO.Sales_Order__c = toSO.Id;
		toOSO.Quantity__c = toQuantity;
		insert toOSO;

		fromOSO.Quantity__c = fromOSO.Quantity__c - toOSO.Quantity__c;
		update fromOSO;

		return;
	}
    
    // MODEL ID GENERATE AND UPDATE
	public static void updateModelField(List<Sales_Order__c> newOrders) {
        String modelValue = '';
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'VinDigitCodeMapping'];
        String modelIdMapStr = sr.Body.toString();
        Map<String, Object> modelidmapping = (Map<String, Object>) JSON.deserializeUntyped(modelidmapstr);
        busLengthMap = (Map<String, Object>) modelidmapping.get('Bus_lengh');
        engineTypeMap = (Map<String, Object>) modelidmapping.get('Engine_type');
        for (Sales_Order__c order : newOrders) {
            Boolean fieldsChanged = false;
            if (order.Id != null) {
                fieldsChanged = true;
            } else if (Trigger.oldMap != null && Trigger.oldMap.containsKey(order.Id)) {
                Sales_Order__c oldOrder = (Sales_Order__c) Trigger.oldMap.get(order.Id);
                if (order.Engine__c != oldOrder.Engine__c || order.Length__c != oldOrder.Length__c || order.Width__c != oldOrder.Width__c || 
                    order.Rear_Suspension__c != oldOrder.Rear_Suspension__c || order.Letter_Code__c != oldOrder.Letter_Code__c) {
                    fieldsChanged = true;
                }
            } 

            if (fieldsChanged = true) {
                modelValue = String.valueOf(order.Letter_Code__c);

                if(order.Mode__C == 'Electric'){
                    modelValue += '28';
                }   
                else if (order.Mode__C != 'Electric' && order.Engine__c != null && engineTypeMap.containsKey(order.Engine__c)) {
                    modelValue += String.valueOf(engineTypeMap.get(order.Engine__c));
                } 
                else{
                    modelValue += 'TBD';
                }

                if (order.Length__c != null && busLengthMap.containsKey(order.Length__c)) {
                    modelValue += String.valueOf(busLengthMap.get(order.Length__c));
                } else if (order.Length__c == null) {
                    modelValue += 'TBD';
                }

                modelValue += String.valueOf(order.Width__c);
                if(order.Rear_Suspension__c != null){
                    modelValue += String.valueOf(order.Rear_Suspension__c);
                }else if(order.Rear_Suspension__c == null){
                    modelValue += '';
                }

                order.Model_Id__c = modelValue;
            }
        }
    } 
  }