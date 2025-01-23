public with sharing class Production_Order {

    private final Production_Order__c originProdOrder;
    transient public String toProdOrder {get; set;}
    private List<Bus__c> busList;
    public String fieldValue {get; set;}
    public String selectedbus {get; set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public Production_Order(ApexPages.StandardController stdController) {
        originProdOrder = (Production_Order__c)stdController.getRecord();
        busList = [select Id, Name, Production_Order__c, Start_Date__c from Bus__c where Production_Order__c=:originProdOrder.Id Order by Name];
    }

    public List<SelectOption> prodBusses{
        get{
            List<SelectOption> theseBusses = new List<SelectOption>();
            for(Bus__c busOnProdOrder : busList)
            {
                theseBusses.add(new SelectOption(busOnProdOrder.Name,busOnProdOrder.Name)) ;
            }
            return theseBusses ;
        }
        set;
    }

    public void splitatthisbus(){
        fieldValue = selectedbus;
    }

    public PageReference splitTo() {

//        if () {
//           ApexPages.Message(ApexPages.Severity.ERROR, <exception message here>);
//        }


        Production_Order__c prodOrder = [select Name, Quantity__c,
                                            Sales_Order__c, Order_Processing_Notes__c
                                            from Production_Order__c where Id=:originProdOrder.Id];

        Production_Order__c toProductionOrder = prodOrder.clone(false, true, false, false);
        toProductionOrder.Order_Processing_Notes__c = UserInfo.getName()+' split from Production Order '+toProductionOrder.name;
        toProductionOrder.name = 'B'+selectedbus.leftPad(6,'0');
        insert toProductionOrder;

        Boolean splithere=false;
        Integer fromProdOrderCount=0;
        Integer toProdOrderCount=0;
        Date toProductionOrderStart;
        for (Bus__c thisBus:busList) {
            if (thisBus.Name==selectedbus) {
                splithere=true;
                toProductionOrderStart=thisBus.Start_Date__c;
            } else if (!splithere) {
                fromProdOrderCount++;
            }
            if (splithere) {
                thisBus.Production_Order__c=toProductionOrder.id;
                thisBus.Production_Order_Sequence__c = toProdOrderCount+1;
                toProdOrderCount++;
            }
        }
        update busList;

        prodOrder.Quantity__c=fromProdOrderCount;
        update prodOrder;
        toProductionOrder.Quantity__c=toProdOrderCount;
        toProductionOrder.Start_Date__c=toProductionOrderStart;
        update toProductionOrder;

        PageReference prodOrderPage = new ApexPages.StandardController(toProductionOrder).view();
        prodOrderPage.setRedirect(true);

        return prodOrderPage;
    }
}