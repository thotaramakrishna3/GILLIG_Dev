public with sharing class Bus {
    
    public static Bus__c create(Opportunity_Line__c oppl, Integer reservationNum, Id owner, Date closeDate) {
        
        Bus__c newBus = new Bus__c(Name=bus.changeName(oppl, reservationNum, closeDate),
                                   Current_Owner__c=owner,
                                   Fleet__c=oppl.Fleet__c,
                                   Opportunity_Line__c=oppl.ID,
                                   Retired__c = false,
                                   RecordTypeID = defaultRecordType(),
                                   Reservation_ID__c = reservationNum,
                                   Sequence__c = reservationNum+1,
                                   Slots__c = 1
                                  );
        return newBus;
    }
    
    public static Bus__c create(Sales_Order__c salesOrder, Id fleet, Id oppl, Integer reservationNum, Id owner) {
        
        Bus__c newBus = new Bus__c(Name=String.valueof(integer.valueof(salesOrder.Name)+reservationNum),
                                   Current_Owner__c=owner,
                                   Fleet__c=fleet,
                                   Opportunity_Line__c=oppl,
                                   Sales_Order__c = salesOrder.Id,
                                   Retired__c = false,
                                   RecordTypeID = defaultRecordType(),
                                   Reservation_ID__c = reservationNum,
                                   Sequence__c = reservationNum+1,
                                   Slots__c = 1
                                  );
        return newBus;
    }
    
    public static Id defaultRecordType() {
        
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        Schema.RecordTypeInfo busRecordType;
        busRecordType = busMap.get('To Be Scheduled');
        
        return busRecordType.getRecordTypeId();
    }
    
    public static Id determineRecordType(Bus__c thisBus, Opportunity_line__c oppl) {
        
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        Schema.RecordTypeInfo busRecordType;
        
        set<Id> busRecT = new set<ID>();
        busRecordType = busMap.get('Firm');
        busRecT.add(busRecordType.getRecordTypeId());
        busRecordType = busMap.get('Scheduled');
        busRecT.add(busRecordType.getRecordTypeId());
        busRecordType = busMap.get('Reserved');
        busRecT.add(busRecordType.getRecordTypeId());
        busRecordType = busMap.get('To Be Scheduled');
        busRecT.add(busRecordType.getRecordTypeId());
        busRecordType = busMap.get('Forecasted');
        busRecT.add(busRecordType.getRecordTypeId());
        
        Id determinedRecType;
        if (busRecT.contains(thisBus.RecordTypeId)) {
            if (thisBus.Sales_Order__c != null) {
                busRecordType = busMap.get('Firm');
            } else if (oppl.Serial_Number__c != null && thisBus.Start_Date__c != Null) {
                busRecordType = busMap.get('Scheduled');
            } else if (oppl.Serial_Number__c == null && thisBus.Start_Date__c != null) {
                busRecordType = busMap.get('Reserved');
            } else {
                busRecordType = busMap.get('To Be Scheduled');
            }
            determinedRecType = busRecordType.getRecordTypeId();
        } else {
            determinedRecType = thisBus.RecordTypeId;
        }
        
        return determinedRecType;
    }
    
    public static Id determineRecordType(Opportunity_Line__c oppl) {
        
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        Schema.RecordTypeInfo busRecordType;
        if (oppl.Date_Booked__c != null) {
            busRecordType = busMap.get('Firm');
        } else if (oppl.Serial_Number__c != null && oppl.Start_Date__c == Null) {
            busRecordType = busMap.get('To Be Scheduled');
        } else if (oppl.Serial_Number__c != null) {
            busRecordType = busMap.get('Scheduled');
        } else if (oppl.Start_Date__c != null) {
            busRecordType = busMap.get('Reserved');
        } else {
            busRecordType = busMap.get('Forecasted');
        }
        
        return busRecordType.getRecordTypeId();
    }
    
    public static Id determineRecordType(Sales_Order__c salesOrder) {
        
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        Schema.RecordTypeInfo busRecordType;
        
        busRecordType = busMap.get('Firm');
        
        return busRecordType.getRecordTypeId();
    }
    
    public static void remove(List<Opportunity_Line__c> delfromOppl) {
        set<Id> opplSet = new set<Id>();
        for (Opportunity_Line__c toppl:delfromOppl) {
            opplSet.add(toppl.Id);
        }
        
        List<Bus__c> delBusses = new List<Bus__c>([select Id, Name from Bus__c where Opportunity_Line__c in:opplSet]);
        if (delBusses.size()>0) {
            delete delBusses;
        }
    }
    
    public static void add(List<Opportunity_Line__c> addfromOppl) {
        
        List<Bus__c> busList = new List<Bus__c>();
        
        set<Id> opplSet = new set<Id>();
        set<Id> oppSet = new set<Id>();
        for (Opportunity_Line__c toppl:addfromOppl) {
            opplSet.add(toppl.Id);
            oppSet.add(toppl.Opportunity_Line__c);
        }
        
        AggregateResult[] busCount = [select Opportunity_Line__c, count(Name)buscnt, max(Start_Date__c)busStart from bus__c where Opportunity_Line__c in:opplSet group by opportunity_line__c];
        map<Id, Integer> opplbus = new map<Id, Integer>();
        map<Id,Date> busDate = new map<Id, Date>();
        for (AggregateResult b:busCount) {
            opplbus.put((Id)b.get('opportunity_line__c'),(integer)b.get('buscnt'));
            busDate.put((Id)b.get('opportunity_line__c'),(Date)b.get('busStart'));
        }
        List<Opportunity> oppList = [select Id, AccountId, CloseDate from Opportunity where Id in:oppSet]; 
        map<Id, Opportunity> acctMap = new map<Id, Opportunity>(oppList);
        
        integer maxBus;
        integer addCount;
        Id ownerofbus;
        Date closeDt;
        
        for (Opportunity_Line__c tbus:addfromOppl) {
            maxBus=opplbus.get(tbus.Id);
            addCount = (integer)tbus.Quantity__c - maxBus;
            for (Integer i = maxBus; i < tbus.Quantity__c; i++) {
                ownerofbus = acctMap.get(tbus.Opportunity_Line__c).AccountId;
                closeDt = acctMap.get(tbus.Opportunity_Line__c).CloseDate;
                busList.add(create(tbus,i,ownerofbus,closeDt));
            }
        }
        if (busList.size()>0) {
            insert busList;
        }
    }
    
    public static void add(List<Opportunity_Sales_Order__c> oppSO) {
        
        List<Bus__c> busList = new List<Bus__c>();
        
        Set<Id> opplSet = new Set<Id>();
        Set<Id> soSet = new Set<Id>();
        for (Opportunity_Sales_Order__c tOSO:oppSO) {
            opplSet.add(tOSO.Opportunity_Line__c);
            soSet.add(tOSO.Sales_Order__c);
        }
        
        List<Sales_Order__c> soList = [select Id, Account__c, Name, Current_Price__c, Start_Date__c, Quantity__c from Sales_Order__c where id in:soSet];
        List<opportunity_line__c> oppList = [select Id, Name, Fleet__c from Opportunity_line__c where Id in:opplSet];
        map<Id, Id> busFleet = new map<Id,Id>();
        for (opportunity_line__c toppl:oppList) {
            busFleet.put(toppl.id, toppl.Fleet__c);
        }
        AggregateResult[] busCount = [select Sales_Order__c, count(Name)buscnt, max(Start_Date__c)busStart, max(Fleet__c)fleet from bus__c where Sales_Order__c in :soSet group by Sales_Order__c];
        map<Id, Integer> soBus = new map<Id, Integer>();
        map<Id,Date> busDate = new map<Id, Date>();
        
        for (AggregateResult b:busCount) {
            soBus.put((Id)b.get('Sales_Order__c'),(integer)b.get('buscnt'));
            busDate.put((Id)b.get('Sales_Order__c'),(Date)b.get('busStart'));
            busFleet.put((Id)b.get('Sales_Order__c'),(Id)b.get('fleet'));
        }
        
        integer maxBus;
        integer addCount;
        
        for (Opportunity_Sales_Order__c thisOSO:oppSO) {
            maxBus=soBus.get(thisOSO.Sales_Order__c);
            addCount = (integer)thisOSO.Quantity__c - maxBus;
            for (Sales_Order__c cSO:soList) {
                if (cSO.Id==thisOSO.Sales_Order__c) {
                    for (Integer i = maxBus; i < thisOSO.Quantity__c; i++) {
                        busList.add(create(cSO, busFleet.get(thisOSO.Opportunity_Line__c), thisOSO.Opportunity_Line__c, i, cSO.Account__c));
                    }					
                    break;
                }
            }
        }
        
        if (busList.size()>0) {
            insert busList;
        }
    }
    
    public static String changeName(Opportunity_Line__c oppl, Integer reservationNum, Date closeDate) {
        
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        Schema.RecordTypeInfo busRecordType;
        busRecordType = busMap.get('Reserved');
        String tName;
        
        if (determineRecordType(oppl) == busRecordType.getRecordTypeId() || oppl.Serial_Number__c == Null) {
            tName = closeDate.month() + string.valueof(closeDate.year()).right(2) + ' - ' + String.valueOf(reservationNum+1);
        } else {
            tName = String.valueof(integer.valueof(oppl.Serial_Number__c)+reservationNum);
        }
        
        return tName;
    }
    
    public static List<Bus__c> changeName(List<Opportunity_Line__c> oppl) {
        
        set<Id> opplSet = new set<Id>();
        for (Opportunity_Line__c toppl:oppl) {
            opplSet.add(toppl.Id);
        }
        
        List<Bus__c> renameBusses = new List<Bus__c>([select Id, Name, Opportunity_Line__c, Reservation_ID__c from Bus__c where Opportunity_Line__c in:opplSet order by Opportunity_Line__c, Reservation_ID__c]);
        
        for (Bus__c rbus:renameBusses) {
            for (opportunity_line__c thisoppl:oppl) {
                if (thisoppl.Id == rbus.Opportunity_Line__c) {
                    rbus.name = changeName(thisoppl, (Integer)rbus.Reservation_ID__c, Null);
                    break;
                }
            }
        }		
        
        return renameBusses;
    }
    
    public static List<Bus__c> changeName(Sales_Order__c salesOrder, List<Bus__c> busses) {
        
        Integer i=0;
        for (Bus__c rbus:busses) {
            rbus.name = String.valueof(integer.valueof(salesOrder.Name)+i);
            i++;
        }	
        return busses;
    }
    
    public static List<Bus__c> changeName(List<Sales_Order__c> salesOrder, List<Bus__c> busses) {
        
        List<Bus__c> tempBus = new List<Bus__c>();
        List<Bus__c> renameBusses = new List<Bus__c>();
        for (Sales_Order__c tSO:salesOrder) {
            for (Bus__c theseBusses:busses) {
                if (theseBusses.Sales_Order__c==tSO.Id) {
                    tempBus.add(theseBusses);
                }
            }
            renameBusses.addAll(bus.changeName(tSO, tempBus));
            tempBus.clear();
        }
        return renameBusses;
    }
    public static void reduceQty(List<Opportunity_Line__c> reducefromOppl) {
        
        List<Bus__c> busList = new List<Bus__c>();
        
        set<Id> opplSet = new set<Id>();
        
        for (Opportunity_Line__c toppl:reducefromOppl) {
            opplSet.add(toppl.Id);
        }
        
        List<Bus__c> currentBusses = [select Id, Name, Opportunity_Line__c, Reservation_ID__c from Bus__c where Opportunity_Line__c in:opplSet Order By Opportunity_Line__c,Reservation_ID__c];
        
        integer removeCount;
        for (Opportunity_Line__c thisoppl:reducefromOppl) {
            removeCount = (integer)thisoppl.Quantity__c;
            Integer bCount=1;
            for (Bus__c tbus:currentBusses) {
                if (tbus.Opportunity_Line__c==thisoppl.Id) {
                    if (bCount>removeCount) {
                        busList.add(tbus);
                    }
                    bCount++;
                }
            }
        }
        if (busList.size()>0) {
            delete busList;
        }
    }
    
    public static void reduceQty(List<Opportunity_Sales_Order__c> oppSO) {
        
        List<Bus__c> busList = new List<Bus__c>();
        
        Set<Id> opplSet = new Set<Id>();
        for (Opportunity_Sales_Order__c tOSO:oppSO) {
            opplSet.add(tOSO.Opportunity_Line__c);
        }
        
        List<Bus__c> currentBusses = [select Id, Name, Opportunity_Line__c, Sales_Order__c from Bus__c where Opportunity_Line__c in :opplSet order by opportunity_line__c, Reservation_ID__c];
        
        Integer removeCount;
        Integer bCount;
        for (Opportunity_Sales_Order__c thisOSO:oppSO) {
            removeCount=(integer)thisOSO.Quantity__c;
            bCount=1;
            for (Bus__c tbus:currentBusses) {
                if (thisOSO.opportunity_line__c==tbus.opportunity_line__c && 
                    thisOSO.Sales_Order__c==tbus.Sales_Order__c) {
                        if (bCount>removeCount) {
                            busList.add(tbus);
                        }
                        bCount++;				
                    }
            }
        }
        
        if (busList.size()>0) {
            delete busList;
        }
    }
    
    public static void move(map<Opportunity_Sales_Order__c, Opportunity_Sales_Order__c> osoMap) {
        
        Set<Opportunity_Sales_Order__c> fromOSOSet = new Set<Opportunity_Sales_Order__c>();
        fromOSOSet = osoMap.keySet();
        set<Id> soSet = new set<Id>();
        
        for (Opportunity_Sales_Order__c thisOSO:fromOSOSet) {
            soset.add(thisOSO.Sales_Order__c);
        }
        
        List<bus__c> busList = [select Id, Sales_Order__c from Bus__c where Sales_Order__c in:soSet order by Sales_Order__c, Name];
        
        Id SOId = busList[0].Sales_Order__c;
        Integer i=0;
        Integer j=0;
        Integer toQTY=0;
        Integer fromQTY=0;
        Opportunity_Sales_Order__c osoKey;
        map<id, integer> soBusCount = new map<Id, integer>();
        for (bus__c b:busList) {
            if (b.Sales_Order__c!=SOId) {
                soBusCount.put(SOId, i);
                i = 0;
                SOId=b.Sales_Order__c;
            }
            i++;
        }
        soBusCount.put(SOId, i);
        SOId=null;
        i=0;
        for (bus__c thisBus:busList) {
            if (SOId!=thisBus.Sales_Order__c) {
                SOId = thisBus.Sales_Order__c;
                i = 0;
                j = 0;
                for (Opportunity_Sales_Order__c fromOSO:fromOSOSet) {
                    if (fromOSO.Sales_Order__c==SOId) {
                        fromQTY=soBusCount.get(SOId);
                        toQTY=(integer)osoMap.get(fromOSO).Quantity__c;
                        osoKey=fromOSO;
                        
                        break;
                    }
                }
            }
            if (i>=fromQTY-toQTY) {
                thisBus.Sales_Order__c = osoMap.get(osoKey).Sales_Order__c;
                thisBus.Reservation_ID__c=j;
                thisBus.Sequence__c=j+1;
                j++;
            }
            i++;
        }
        
        if (busList.size()>0) {
            update busList;
        }
    }
    
    
    public static List<Bus__c> recalculateVin(List<Bus__c> busses){ 
        for(Bus__c bus : busses){
            Boolean isvalid = checkVINcondition(bus);
            if(isvalid){
                bus.VIN__c = getBusVINNumber(bus);
            }
            else{
                bus.VIN__c = null;
            }
        }
        return busses;
    }
    
    public static String recalculateVin(Bus__c bus){
        Boolean isvalid = checkVINcondition(bus);
        String vinNo = null;
        if(isvalid){
            vinNo = getBusVINNumber(bus);
        }        
        return vinNo;
    }
    
    public static Boolean checkVINcondition(Bus__c bus){
        Boolean isnotnullvalue = true;
        if(bus.Bus_Length__c == null){
            isnotnullvalue = false;
        }
        if(bus.Engine__c == null){
            isnotnullvalue = false;
        }
        if(bus.Brakes__c == null){
            isnotnullvalue = false;
        }
        if(bus.Name == null){
            isnotnullvalue = false;
        }
        if(bus.Green_Sheet_Date__c == null && bus.Scheduled_Green_Sheet_Date__c == null && bus.Start_Date__c == null){
                isnotnullvalue = false;
            }
        return isnotnullvalue;       
        
    }
    
    public static Map<String, Object> busLengthMap {get; set;}
    public static Map<String, Object> engineTypeMap {get; set;}
    public static Map<String, Object> transLetterMap {get; set;}
    public static Map<String, Object> digitWeightageMap {get; set;}
    public static Map<String, Object> modelYearMap {get; set;}
    public static Map<String, Object> letterCodeMap {get; set;}
    public static Map<String, Object> brakeTypeMap {get; set;}
    public static Map<String, Object> modeTypeMap {get; set;}
    
    public static void initVinCodemap(){
        StaticResource sr = [Select id, Body from StaticResource where name = 'VinDigitCodeMapping'];
        String vinmappstr = sr.Body.toString();
        Map<String, Object> vinmapping = (Map<String, Object>)JSON.deserializeUntyped(vinmappstr);
        busLengthMap = (Map<String, Object>)vinmapping.get('Bus_lengh');
        engineTypeMap = (Map<String, Object>)vinmapping.get('Engine_type');
        transLetterMap= (Map<String, Object>)vinmapping.get('Trans_letter');
        digitWeightageMap= (Map<String, Object>)vinmapping.get('digit_weightage');
        modelYearMap= (Map<String, Object>)vinmapping.get('model_year');
        letterCodeMap= (Map<String, Object>)vinmapping.get('Letter_code');
        brakeTypeMap=(Map<String, Object>)vinmapping.get('Break_type');
        modeTypeMap=(Map<String, Object>)vinmapping.get('Model');
    }
    
    public static string getBusVINNumber(Bus__c bus){  
        try{
            String tempVin = '';
            tempVin+=getdefaultManufacturer(bus);
            tempVin+=getdefaultBusModeCode(bus);
            tempVin+=getVinByBusLength(bus);
            tempVin+=getVinCodebyEnginetype(bus);
            tempVin+=getdefaultBrakeCode(bus);
            tempVin+='0';
            tempVin+=getVinCodebyModelYear(bus);
            tempVin+='3';
            tempVin+=bus.Name.leftPad(6, '0');
            return tempVin.subString(0,8)+getVinCheckdigit(tempVin)+tempVin.subString(9,17); 
        }
        catch(Exception e){
            return null;
        }                
    }
    
    public static string getdefaultManufacturer(Bus__c bus){
        return (String)letterCodeMap.get('G');//Complete Buses
    }
    
    public static string getdefaultBrakeCode(Bus__c bus){
        return (String)brakeTypeMap.get('Air');
    }
    
    public static string getdefaultBusModeCode(Bus__c bus){
        return (String)modeTypeMap.get('Low Floor Bus');
    }    
    
    public static string getVinByBusLength(Bus__c bus){
        return (String)busLengthMap.get(bus.Bus_Length__c);
    }
    
    public static string getVinCodebyEnginetype(Bus__c bus){
        return (String)engineTypeMap.get(bus.Engine__c);
    }
    
    public static string getVinCodebyModelYear(Bus__c bus){
        Date completedDate;
        if(bus.Green_Sheet_Date__c != null){
			 completedDate = Date.valueOf(bus.Green_Sheet_Date__c);
		}
		else if(bus.Scheduled_Green_Sheet_Date__c != null){
		     completedDate = Date.valueOf(bus.Scheduled_Green_Sheet_Date__c);
		}
		else if(bus.Start_Date__c != null){
			 completedDate = Date.valueOf(bus.Start_Date__c);
		}
        Integer modelYear = completedDate.year();
        integer yrCode = math.mod((modelYear-1980),30);
        return (String)modelYearMap.get(String.valueOf(yrCode));
    }
    
    public static string getVinCheckdigit(String tempVin){
        Map<String, Object> transliterMap= transLetterMap;
        Map<String, Object> digitWeightageMap = digitWeightageMap;
        Integer count = 0;
        String digitvalue = '';
        Integer vintotal = 0;
        while(count < tempVin.Length()){
            digitvalue = tempVin.substring(count,count+1);
            if(digitvalue.isNumeric()){
                vintotal = vintotal + (Integer.valueOf(digitvalue)*Integer.valueOf(digitWeightageMap.get(String.valueOf(count+1))));
            }
            else{
                vintotal = vintotal + (Integer.valueOf(transliterMap.get(digitvalue))*Integer.valueOf(digitWeightageMap.get(String.valueOf(count+1))));
            }
            count++;
        }
        if(vintotal!=0){
            Integer reminder = math.mod(vintotal,11);
            if(reminder == 10){
                return 'X';
            }
            else{
                return String.valueOf(reminder);
            }
        }
        return null;
        
    }
    
}