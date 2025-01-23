@isTest
private class BusTest
{
    @testSetup static void init () {
        TestData.init();
        TestData.createAcct();
        TestData.createOpp();
        TestData.createContract();
        TestData.createOppLine(5, 5);
    }
    
    //2b
    @isTest
    static void itShouldDeleteReservedBusses() {
        
        test.startTest();
        
        // Given a reserved opportunity line
        // Opportunity line with a start date but no serial number
        
        List<Opportunity_Line__c> tOppLine = [select Id, Quantity__c, Start_Date__c from Opportunity_Line__c];
        Integer oppLineTotal=0;
        for (Opportunity_Line__c t:tOppLine) {
            t.Start_Date__c = system.today().addYears(2);
            oppLineTotal=oppLineTotal+(Integer)t.Quantity__c;
        }
        update tOppLine;
        
        List<Opportunity_Line__c> topp = [select Id, Name, Fleet__c, Start_Date__c from Opportunity_Line__c];
        
        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c
                                     from Bus__c Order By Name];
        
        system.assertEquals(oppLineTotal,resultingBus.size());
        
        // When the start date is removed
        
        topp[0].Start_Date__c = null;
        update topp;
        
        // Then the busses should be deleted
        List<Bus__c> deletedBus;
        try {
            deletedBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c
                          from Bus__c where Opportunity_Line__c =:tOpp[0].Id];
        } catch (Exception e) {
            system.assertNotEquals(null,e);
        }
        
        system.assertEquals(0,deletedBus.size());
        test.stopTest();
        
    }
    
    // 2c
    @isTest
    static void itShouldAddReservedBusses() {
        
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        Schema.RecordTypeInfo busTBSRecordType = busMap.get('To Be Scheduled');
        
        test.startTest();
        
        //Give an Opportunity Line that is not yet booked a start date but no serial number
        List<Opportunity_Line__c> tOppLine = [select Id, Quantity__c, Start_Date__c from Opportunity_Line__c];
        Integer oppLineTotal=0;
        for (Opportunity_Line__c t:tOppLine) {
            t.Start_Date__c = system.today().addYears(2);
            oppLineTotal=oppLineTotal+(Integer)t.Quantity__c;
        }
        update tOppLine;
        
        List<Opportunity_Line__c> topp = [select Id, Name, Fleet__c, Quantity__c, Start_Date__c, Opportunity_Line__c from Opportunity_Line__c];
        map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([select Id, CloseDate from Opportunity]);
        map<Id, Fleet__c> resultingFleetMap = new Map<Id, Fleet__c>([select Id, Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c, Quantity__c
                                                                     from Fleet__c]);
        for (Opportunity_Line__c t:topp) {
            system.assertEquals(t.Quantity__c, resultingFleetMap.get(t.Fleet__c).Quantity__c);
        }
        
        List<Bus__c> tbsBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                               from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        String busName;
        Integer i=1;
        Id opplID;
        Date closeDt;
        for (Bus__c rBus:tbsBus) {
            if (rbus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        closeDt = oppMap.get(tOppl.Opportunity_Line__c).CloseDate;
                        busName = closeDt.month() + string.valueof(closeDt.year()).right(2) + ' - ';
                        i=1;
                        rBus.Start_Date__c = system.today().addDays(i);
                        break;
                    }
                }
            }
            system.assertEquals(busName+String.valueOf(i), rBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), rBus.RecordTypeID);
            system.assertEquals(i-1, rbus.Reservation_ID__c);
            i++;
        }
        update tbsBus;
        
        // When the quantity is increased
        
        List<Opportunity_Line__c> updOppLine = [select Id, Opportunity_Line__c, Name, Quantity__c, Fleet__c from Opportunity_Line__c];
        Decimal oQTY = updOppLine[0].Quantity__c;
        updOppLine[0].Quantity__c = 204;
        update updOppLine;
        
        // Then there should be new busses
        
        Fleet__c updatedFleet = [select Id, Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c, Quantity__c
                                 from Fleet__c where Id=:tOpp[0].Fleet__c];
        system.assertEquals(204, updatedFleet.Quantity__c);
        
        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                     from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        i=1;
        opplID=Null;
        
        for (Bus__c rBus:resultingBus) {
            if (rbus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        closeDt = oppMap.get(tOppl.Opportunity_Line__c).CloseDate;
                        busName = closeDt.month() + string.valueof(closeDt.year()).right(2) + ' - ';
                        i=1;
                        break;
                    }
                }
            }
            
            system.assertEquals(busName+String.valueOf(i), rBus.Name);
            system.assertEquals(i-1, rbus.Reservation_ID__c);
            system.assertEquals(i, rbus.Sequence__c);
            i++;
        }
        test.stopTest();
    }
    
    // 2aa
    @isTest
    static void itShouldChangeForecastedtoScheduled()
    {
        
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        Schema.RecordTypeInfo busTBSRecordType = busMap.get('To Be Scheduled');
        
        test.startTest();
        
        // Given
        // Opportunity line with no start date and no serial number 
        
        List<Opportunity_Line__c> topp = [select Id, Name, Serial_Number__c, Quantity__c, Fleet__c from Opportunity_Line__c];
        map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([select Id, CloseDate from Opportunity]);
        
        // When the serial number is set
        
        List<Opportunity_Line__c> setSerial = [select Id, RecordTypeID, Name, Serial_Number__c, Date_Booked__c, Start_Date__c from Opportunity_Line__c];
        setSerial[0].Serial_Number__c = '123456';
        
        update setSerial;
        
        // Then the busses should be To Be Scheduled
        
        List<Bus__c> tobescheduledBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                         from Bus__c where Opportunity_Line__c =:setSerial[0].Id order By Name];
        
        String scheduledbusName;
        Integer scheduledserialNum= Integer.valueOf(setSerial[0].Serial_Number__c);
        Integer scheduled=0;
        for (Bus__c sBus:tobescheduledBus) {
            scheduledbusName = String.valueOf(scheduledserialNum + scheduled);
            system.assertEquals(scheduledbusName, sBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), sBus.RecordTypeID);
            system.assertEquals(scheduled, sBus.Reservation_ID__c);
            scheduled++;
        }
        system.assertEquals(topp[0].Quantity__c, tobescheduledBus.size());
        test.stopTest();
        
    }
    
    // 2a
    @isTest
    static void itShouldChangeReservedtoScheduled()
    {
        
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        Schema.RecordTypeInfo busTBSRecordType = busMap.get('To Be Scheduled');
        Schema.RecordTypeInfo busScheduledRecordType = busMap.get('Scheduled');
        test.startTest();
        
        // Given
        // Opportunity line with a start date but no serial number 
        
        List<Opportunity_Line__c> tOppLine = [select Id, Quantity__c, Start_Date__c from Opportunity_Line__c];
        Integer oppLineTotal=0;
        for (Opportunity_Line__c t:tOppLine) {
            t.Start_Date__c = system.today().addYears(2);
            oppLineTotal=oppLineTotal+(Integer)t.Quantity__c;
        }
        update tOppLine;
        
        List<Opportunity_Line__c> topp = [select Id, Name, Serial_Number__c, Fleet__c, Start_Date__c, Opportunity_Line__c from Opportunity_Line__c];
        map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([select Id, CloseDate from Opportunity]);
        
        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c
                                     from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        Fleet__c resultingFleet = [select Id, Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c 
                                   from Fleet__c where Id=:tOpp[0].Fleet__c];
        String busName;
        Integer i=1;
        Id opplID;
        Date closeDt;
        for (Bus__c rBus:resultingBus) {
            if (rBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        closeDt = oppMap.get(tOppl.Opportunity_Line__c).CloseDate;
                        busName = closeDt.month() + string.valueof(closeDt.year()).right(2) + ' - ';
                        i=1;
                        break;
                    }
                }
            }
            system.assertEquals(busName+ String.valueOf(i), rBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), rBus.RecordTypeID);
            rBus.Start_Date__c = system.today().addDays(i);
            i++;
        }
        update resultingBus;
        // When the serial number is set
        
        List<Opportunity_Line__c> setSerial = [select Id, RecordTypeID, Name, Serial_Number__c, Date_Booked__c, Start_Date__c from Opportunity_Line__c where Id=:tOppLine[0].Id];
        setSerial[0].Serial_Number__c = '123456';
        
        update setSerial;
        
        // Then the busses on should be scheduled
        
        List<Bus__c> scheduledBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                     from Bus__c where Opportunity_Line__c =:setSerial[0].Id order By Reservation_ID__c];
        
        String scheduledbusName;
        Integer scheduledserialNum= Integer.valueOf(setSerial[0].Serial_Number__c);
        Integer scheduled=0;
        for (Bus__c sBus:scheduledBus) {
            scheduledbusName = String.valueOf(scheduledserialNum + scheduled);
            system.assertEquals(scheduledbusName, sBus.Name);
            system.assertEquals(busScheduledRecordType.getRecordTypeId(), sBus.RecordTypeID);
            system.assertEquals(scheduled, sbus.Reservation_ID__c);
            scheduled++;
        }       
        
        test.stopTest();
        
    }
    
    // 2d
    @isTest
    static void itShouldChangeToBeScheduledtoScheduled()
    {
        
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        Schema.RecordTypeInfo busTBSRecordType = busMap.get('To Be Scheduled');
        Schema.RecordTypeInfo busScheduledRecordType = busMap.get('Scheduled');
        
        test.startTest();
        
        // Given
        // Opportunity line with a serial number but no start date 
        
        List<Opportunity_Line__c> tOppLine = [select Id, Quantity__c, Serial_Number__c from Opportunity_Line__c];
        Integer oppLineTotal=0;
        Integer i=0;
        for (Opportunity_Line__c t:tOppLine) {
            t.Serial_Number__c = String.valueOf(i*t.Quantity__c);
            oppLineTotal=oppLineTotal+(Integer)t.Quantity__c;
            i++;
        }
        update tOppLine;
        
        List<Opportunity_Line__c> topp = [select Id, Serial_Number__c, Fleet__c, Quantity__c from Opportunity_Line__c];
        
        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c, is_Future_Holding__c
                                     from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        Map<Id, Fleet__c> resultingFleet = new Map<Id, Fleet__c>([select Id, Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c, Active_Quantity_GILLIG__c
                                                                  from Fleet__c]);
        
        for (Opportunity_Line__c t:topp) {
            system.assertEquals(t.Quantity__c, resultingFleet.get(t.Fleet__c).Active_Quantity_GILLIG__c);
        }
        
        Integer serialNum;
        i=0;
        Id opplID;
        for (Bus__c rBus:resultingBus) {
            if (rBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:topp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        serialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        i=0;
                        break;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(serialNum + i), rBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), rBus.RecordTypeID);
            system.assertEquals(i, rbus.Reservation_ID__c);
            i++;
        }
        
        for (Bus__c setStart:resultingBus) {
            setStart.Start_Date__c = system.today().addYears(2);
        }
        update resultingBus;
        
        // Then the busses on should be scheduled
        
        List<Bus__c> scheduledBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                     from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        Integer scheduledserialNum;
        Integer scheduled=0;
        opplID=Null;
        for (Bus__c sBus:scheduledBus) {
            if (sBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (sBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        scheduledserialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        scheduled=0;
                        break;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(scheduledserialNum + scheduled), sBus.Name);
            system.assertEquals(busScheduledRecordType.getRecordTypeId(), sBus.RecordTypeID);
            system.assertEquals(scheduled, sBus.Reservation_ID__c);
            scheduled++;
        }
        
        test.stopTest();
        
    }
    
    // 2e
    @isTest
    static void itShouldDeleteToBeScheduledBusses()
    {
        
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        Schema.RecordTypeInfo busTBSRecordType = busMap.get('To Be Scheduled');
        Schema.RecordTypeInfo busScheduledRecordType = busMap.get('Scheduled');
        
        test.startTest();
        
        // Given
        // Opportunity line with a serial number but no start date 
        
        List<Opportunity_Line__c> tOppLine = [select Id, Quantity__c, Serial_Number__c from Opportunity_Line__c];
        Integer oppLineTotal=0;
        Integer i=0;
        for (Opportunity_Line__c t:tOppLine) {
            t.Serial_Number__c = String.valueOf(i*t.Quantity__c);
            oppLineTotal=oppLineTotal+(Integer)t.Quantity__c;
            i++;
        }
        update tOppLine;
        
        List<Opportunity_Line__c> topp = [select Id, Serial_Number__c, Fleet__c from Opportunity_Line__c];
        
        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                     from Bus__c  Order By Opportunity_Line__c, Reservation_ID__c];
        
        Map<Id,Fleet__c> resultingFleet = new Map<Id, Fleet__c>([select Id, Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c 
                                                                 from Fleet__c]);
        
        Integer serialNum;
        i=0;
        Id opplID;
        for (Bus__c rBus:resultingBus) {
            if (rBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        serialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        i=0;
                        break;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(serialNum + i), rBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), rBus.RecordTypeID);
            system.assertEquals(i, rBus.Reservation_ID__c);
            i++;
        }
        
        // When the serial number is removed
        for (Opportunity_Line__c t:tOppLine) {
            t.Serial_Number__c = null;
        }
        update tOppLine;
        
        // Then the busses should be deleted
        List<Bus__c> deletedBus = new List<Bus__c>();
        try {
            deletedBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c
                          from Bus__c];
        } catch (Exception e) {
            system.assertNotEquals(null,e);
        }
        
        system.assertEquals(0,deletedBus.size());
        
        test.stopTest();
    }
    
    // 2g
    @isTest
    static void itShouldChangetoReserved()
    {
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        Schema.RecordTypeInfo busTBSRecordType = busMap.get('To Be Scheduled');
        Schema.RecordTypeInfo busReservedRecordType = busMap.get('Reserved');
        
        test.startTest();
        //Given an Opportunity Line that is not yet booked, and has a Serial Number and a start date
        
        List<Opportunity_Line__c> tOppLine = [select Id, Quantity__c, Start_Date__c, Serial_Number__c from Opportunity_Line__c];
        Integer oppLineTotal=0;
        Integer i = 1;
        for (Opportunity_Line__c t:tOppLine) {
            t.Serial_Number__c = String.valueOf(i*t.Quantity__c);
            t.Start_Date__c = system.today().addYears(2);
            oppLineTotal=oppLineTotal+(Integer)t.Quantity__c;
            i++;
        }
        update tOppLine;
        
        List<Opportunity_Line__c> topp = [select Id, Serial_Number__c, Fleet__c, Start_Date__c from Opportunity_Line__c];
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([select Id, CloseDate from Opportunity]);
        
        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                     from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        Map<Id,Fleet__c> resultingFleet = new Map<Id, Fleet__c>([select Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c 
                                                                 from Fleet__c]);
        String busName;
        Integer serialNum;
        i=0;
        Id opplID;
        for (Bus__c rBus:resultingBus) {
            if (rBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        serialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        i=0;
                        break;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(serialNum + i), rBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), rBus.RecordTypeID);
            system.assertEquals(i, rBus.Reservation_ID__c);
            rbus.Start_Date__c = system.today().addDays(i);
            i++;
        }
        update resultingBus;
        
        // When the Serial number is removed
        
        for (Opportunity_Line__c t:tOppLine) {
            t.Serial_Number__c = null;
        }
        update tOppLine;
        
        // Then it should be reserved and the bus names should change
        
        List<Opportunity_Line__c> changetoReservedoppl = [select Id, Name, Fleet__c, Start_Date__c, Opportunity_Line__c from Opportunity_Line__c];
        
        List<Bus__c> changetoReservedBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                            from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        String changetoReservedName;
        Integer changetoReserved=1;
        opplID=Null;
        Date closeDt;
        for (Bus__c rBus:changetoReservedBus) {
            if (rBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:changetoReservedoppl) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        closeDt = oppMap.get(tOppl.Opportunity_Line__c).CloseDate;
                        changetoReservedName = closeDt.month() + string.valueof(closeDt.year()).right(2) + ' - ' ;
                        changetoReserved=1;
                        break;
                    }
                }
            }
            
            system.assertEquals(changetoReservedName + String.valueOf(changetoReserved), rBus.Name);
            system.assertEquals(busReservedRecordType.getRecordTypeId(), rBus.RecordTypeID);
            system.assertEquals(changetoReserved-1, rbus.Reservation_ID__c);
            changetoReserved++;
        }
        
        test.stopTest();
    }
    
    // 2h
    @isTest
    static void itShouldChangetoToBeScheduled()
    {
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        Schema.RecordTypeInfo busTBSRecordType = busMap.get('To Be Scheduled');
        Schema.RecordTypeInfo busScheduledRecordType = busMap.get('Scheduled');
        
        test.startTest();
        //Given an Opportunity Line that is not yet booked, and has a Serial Number and a start date
        
        List<Opportunity_Line__c> tOppLine = [select Id, Quantity__c, Start_Date__c, Serial_Number__c from Opportunity_Line__c];
        Integer oppLineTotal=0;
        Integer i = 1;
        for (Opportunity_Line__c t:tOppLine) {
            t.Serial_Number__c = String.valueOf(i*t.Quantity__c);
            t.Start_Date__c = system.today().addYears(2);
            oppLineTotal=oppLineTotal+(Integer)t.Quantity__c;
            i++;
        }
        update tOppLine;
        
        List<Opportunity_Line__c> topp = [select Id, Serial_Number__c, Fleet__c from Opportunity_Line__c];
        
        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                     from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        Map<Id, Fleet__c> resultingFleet = new Map<Id, Fleet__c>([select Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c 
                                                                  from Fleet__c]);
        
        Integer serialNum;
        i=0;
        Id opplID;
        for (Bus__c rBus:resultingBus) {
            if (rBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        serialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        i=0;
                        break;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(serialNum + i), rBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), rBus.RecordTypeID);
            system.assertEquals(i, rBus.Reservation_ID__c);
            rBus.Start_Date__c = system.today().addDays(i);
            i++;
        }
        update resultingBus;
        
        List<Bus__c> schedBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                 from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        for (Bus__c sBus:schedBus) {
            if (sBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (sBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        serialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        i=0;
                        break;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(serialNum + i), sBus.Name);
            system.assertEquals(busScheduledRecordType.getRecordTypeId(), sBus.RecordTypeID);
            system.assertEquals(i, sBus.Reservation_ID__c);
            i++;
        }
        
        // When the Start Date is removed
        
        List<Opportunity_Line__c> tbsoppl = [select Id, Serial_Number__c, Start_Date__c, Date_Booked__c,Fleet__c from Opportunity_Line__c];
        
        for (Opportunity_Line__c t:tbsoppl) {
            t.Start_Date__c = null;
        }
        update tbsoppl;
        
        // Then it should be To Be Scheduled
        List<Opportunity_Line__c> changetoToBeScheduledoppl = [select Id, Serial_Number__c, Fleet__c from Opportunity_Line__c];
        
        List<Bus__c> toBeScheduledBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                         from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        Integer toBeScheduledserialNum;
        Integer tbs=0;
        opplID=Null;
        for (Bus__c tbsBus:toBeScheduledBus) {
            if (tbsBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:changetoToBeScheduledoppl) {
                    if (tbsBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        toBeScheduledserialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        tbs=0;
                        break;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(toBeScheduledserialNum + tbs), tbsBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), tbsBus.RecordTypeID);
            system.assertEquals(tbs, tbsBus.Reservation_ID__c);
            
            tbs++;
        }
        
        test.stopTest();
    }
    
    // 2f
    @isTest
    static void itShouldChangeToBeScheduledSerialNumbers()
    {
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        Schema.RecordTypeInfo busTBSRecordType = busMap.get('To Be Scheduled');
        Schema.RecordTypeInfo busScheduledRecordType = busMap.get('Scheduled');
        
        test.startTest();
        
        // Given
        // Opportunity line with a serial number but no start date 
        
        List<Opportunity_Line__c> tOppLine = [select Id, Quantity__c, Serial_Number__c from Opportunity_Line__c];
        Integer oppLineTotal=0;
        Integer i=0;
        for (Opportunity_Line__c t:tOppLine) {
            t.Serial_Number__c = String.valueOf(i*t.Quantity__c);
            oppLineTotal=oppLineTotal+(Integer)t.Quantity__c;
            i++;
        }
        update tOppLine;
        
        List<Opportunity_Line__c> topp = [select Id, Serial_Number__c, Fleet__c from Opportunity_Line__c];
        
        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                     from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        Map<Id, Fleet__c> resultingFleet = new Map<Id, Fleet__c>([select Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c 
                                                                  from Fleet__c]);
        
        Integer serialNum;
        i=0;
        Id opplID;
        for (Bus__c rBus:resultingBus) {
            if (rBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        serialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        i=0;
                        break;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(serialNum + i), rBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), rBus.RecordTypeID);
            system.assertEquals(i, rBus.Reservation_ID__c);
            i++;
        }
        
        // When the serial number is changed
        
        tOppLine[0].Serial_Number__c = '123856';
        update tOppLine;
        
        // Then the busses should have a different serial number
        
        List<Opportunity_Line__c> changetoSerialoppl = [select Id, Serial_Number__c, Fleet__c from Opportunity_Line__c];
        
        List<Bus__c> changetoSerialBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                          from Bus__c Order By Id];
        
        Integer changetoSerialNum;
        Integer changetoSerial=0;
        opplID=Null;
        for (Bus__c ctsBus:changetoSerialBus) {
            if (ctsBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:changetoSerialoppl) {
                    if (ctsBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        changetoSerialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        changetoSerial=0;
                        break;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(changetoSerialNum + changetoSerial), ctsBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), ctsBus.RecordTypeID);
            system.assertEquals(changetoSerial, ctsBus.Reservation_ID__c);
            changetoSerial++;
        }
        
        test.stopTest();
    }
    
    // 2i
    @isTest
    static void itShouldDeleteScheduledBusses()
    {
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        Schema.RecordTypeInfo busTBSRecordType = busMap.get('To Be Scheduled');
        
        test.startTest();
        //Given an Opportunity Line that is not yet booked, and has a Serial Number and a start date
        
        List<Opportunity_Line__c> tOppLine = [select Id, Quantity__c, Start_Date__c, Serial_Number__c from Opportunity_Line__c];
        Integer oppLineTotal=0;
        Integer i = 1;
        for (Opportunity_Line__c t:tOppLine) {
            t.Serial_Number__c = String.valueOf(i*t.Quantity__c);
            t.Start_Date__c = system.today().addYears(2);
            oppLineTotal=oppLineTotal+(Integer)t.Quantity__c;
            i++;
        }
        update tOppLine;
        
        List<Opportunity_Line__c> topp = [select Id, Serial_Number__c, Start_Date__c, Fleet__c, Quantity__c from Opportunity_Line__c];
        
        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                     from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        Map<Id,Fleet__c> resultingFleet = new Map<Id, Fleet__c>([select Id, Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c , Active_Quantity_GILLIG__c
                                                                 from Fleet__c]);
        
        for (Opportunity_Line__c t:topp) {
            system.assertEquals(t.Quantity__c, resultingFleet.get(t.Fleet__c).Active_Quantity_GILLIG__c);
        }
        
        Integer serialNum;
        i=0;
        Id opplID;
        for (Bus__c rBus:resultingBus) {
            if (rBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        serialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        i=0;
                        break;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(serialNum + i), rBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), rBus.RecordTypeID);
            system.assertEquals(i, rBus.Reservation_ID__c);
            rBus.Start_Date__c = system.today().addDays(i);
            i++;
        }
        update resultingBus;
        
        // When the start date is removed
        topp[0].Serial_Number__c = null;
        topp[0].Start_Date__c = null;
        update tOpp;
        
        // Then the busses should be deleted
        List<Bus__c> deletedBus = new List<Bus__c>();
        try {
            deletedBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c
                          from Bus__c where Opportunity_Line__c =:topp[0].Id];
        } catch (Exception e) {
            system.assertNotEquals(null,e);
        }
        
        system.assertEquals(0,deletedBus.size());
        
        test.stopTest();
        
    }
    
    // 2j
    @isTest
    static void itShouldChangeScheduledSerialNumbers()
    {
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        Schema.RecordTypeInfo busTBSRecordType = busMap.get('To Be Scheduled');
        Schema.RecordTypeInfo busScheduledRecordType = busMap.get('Scheduled');
        
        test.startTest();
        //Given an Opportunity Line that is not yet booked, and has a Serial Number and a start date
        
        List<Opportunity_Line__c> tOppLine = [select Id, Quantity__c, Start_Date__c, Serial_Number__c from Opportunity_Line__c];
        Integer oppLineTotal=0;
        Integer i = 1;
        for (Opportunity_Line__c t:tOppLine) {
            t.Serial_Number__c = String.valueOf(i*t.Quantity__c);
            t.Start_Date__c = system.today().addYears(2);
            oppLineTotal=oppLineTotal+(Integer)t.Quantity__c;
            i++;
        }
        update tOppLine;
        
        List<Opportunity_Line__c> topp = [select Id, Serial_Number__c, Fleet__c from Opportunity_Line__c];
        
        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                     from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        Map<Id,Fleet__c> resultingFleet = new Map<Id, Fleet__c>([select Id, Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c 
                                                                 from Fleet__c]);
        Integer serialNum;
        i=0;
        Id opplID;
        for (Bus__c rBus:resultingBus) {
            if (rBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        serialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        i=0;
                        break;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(serialNum + i), rBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), rBus.RecordTypeID);
            system.assertEquals(i, rBus.Reservation_ID__c);
            i++;
            rBus.Start_Date__c = system.today().addDays(i);
        }
        update resultingBus;
        
        // When the serial number is changed
        
        tOppLine[0].Serial_Number__c = '123856';
        update tOppLine;
        
        // Then the busses should have a different serial number
        
        List<Opportunity_Line__c> changetoSerialoppl = [select Id, Serial_Number__c, Fleet__c from Opportunity_Line__c];
        
        List<Bus__c> changetoSerialBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                          from Bus__c Order By Id];
        Integer changetoSerialNum;
        Integer changetoSerial=0;
        opplID=Null;
        for (Bus__c ctsBus:changetoSerialBus) {
            if (ctsBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:changetoSerialoppl) {
                    if (ctsBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        changetoSerialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        changetoSerial = 0;
                        break;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(changetoSerialNum + changetoSerial), ctsBus.Name);
            system.assertEquals(busScheduledRecordType.getRecordTypeId(), ctsBus.RecordTypeID);
            system.assertEquals(changetoSerial, ctsBus.Reservation_ID__c);
            changetoSerial++;
        }
        
        test.stopTest();
    }
    
    //2k
    @isTest
    static void itShouldReduceScheduledBusses()
    {
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        Schema.RecordTypeInfo busTBSRecordType = busMap.get('To Be Scheduled');
        Schema.RecordTypeInfo busScheduledRecordType = busMap.get('Scheduled');
        
        test.startTest();
        //Given an Opportunity Line that is not yet booked, and has a Serial Number and a start date
        
        List<Opportunity_Line__c> tOppLine = [select Id, Quantity__c, Start_Date__c, Serial_Number__c from Opportunity_Line__c];
        Integer oppLineTotal=0;
        Integer i = 1;
        for (Opportunity_Line__c t:tOppLine) {
            t.Serial_Number__c = String.valueOf(i*t.Quantity__c);
            t.Start_Date__c = system.today().addYears(2);
            oppLineTotal=oppLineTotal+(Integer)t.Quantity__c;
            i++;
        }
        update tOppLine;
        
        List<Opportunity_Line__c> topp = [select Id, Serial_Number__c, Fleet__c, Quantity__c from Opportunity_Line__c];
        
        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                     from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        Map<Id, Fleet__c> resultingFleet = new Map<Id, Fleet__c>([select Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c 
                                                                  from Fleet__c]);
        
        Integer serialNum;
        i=0;
        Id opplID;
        for (Bus__c rBus:resultingBus) {
            if (rBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        serialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        i=0;
                        break;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(serialNum + i), rBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), rBus.RecordTypeID);
            system.assertEquals(i, rBus.Reservation_ID__c);
            rBus.Start_Date__c = system.today().addDays(i);
            i++;
        }
        update resultingBus;
        
        // When the quantity is decreased
        
        for (Opportunity_Line__c o:topp) {
            o.Quantity__c = 2;
        }
        update topp;
        
        // Then there should be less busses
        
        List<Fleet__c> updatedFleet = [select Id, Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c, Active_Quantity_GILLIG__c
                                       from Fleet__c];
        for (Opportunity_Line__c o:topp) {
            for (Fleet__c f:updatedFleet) {
                if (f.id==o.Fleet__c) {
                    system.assertEquals(o.Quantity__c, f.Active_Quantity_GILLIG__c);
                }
            }
        }
        
        
        List<Bus__c> reducedBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                   from Bus__c Order By Opportunity_Line__c,Reservation_ID__c];
        Integer reducedserialNum;
        Integer reduced=0;
        opplID=Null;
        for (Bus__c rBus:reducedBus) {
            if (rBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        reducedserialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        reduced=0;
                        break;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(reducedserialNum + reduced), rBus.Name);
            system.assertEquals(busScheduledRecordType.getRecordTypeId(), rBus.RecordTypeID);
            system.assertEquals(reduced, rBus.Reservation_ID__c);
            reduced++;
        }
        test.stopTest();
    }
    
    // 2l
    @isTest
    static void itShouldAddScheduledBusses() {
        
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        Schema.RecordTypeInfo busTBSRecordType = busMap.get('To Be Scheduled');
        Schema.RecordTypeInfo busScheduledRecordType = busMap.get('Scheduled');
        
        test.startTest();
        
        //Give an Opportunity Line that is not yet booked, and has a Start Date and a Serial Number
        List<Opportunity_Line__c> tOppLine = [select Id, Quantity__c, Start_Date__c, Serial_Number__c from Opportunity_Line__c];
        Integer oppLineTotal=0;
        Integer i = 1;
        for (Opportunity_Line__c t:tOppLine) {
            t.Serial_Number__c = String.valueOf(i*t.Quantity__c);
            t.Start_Date__c = system.today().addYears(2);
            oppLineTotal=oppLineTotal+(Integer)t.Quantity__c;
            i++;
        }
        update tOppLine;
        
        List<Opportunity_Line__c> topp = [select Id, Serial_Number__c, Fleet__c, Quantity__c from Opportunity_Line__c];
        
        Map<Id, Fleet__c> resultingFleet = new Map<Id, Fleet__c>([select Id, Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c, Quantity__c
                                                                  from Fleet__c]);
        
        for (Opportunity_Line__c t:topp) {
            system.assertEquals(t.Quantity__c, resultingFleet.get(t.Fleet__c).Quantity__c);
        }
        
        List<Bus__c> tbsBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                               from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        Integer serialNum;
        i=0;
        Id opplID;
        for (Bus__c rBus:tbsBus) {
            if (rBus.Opportunity_Line__c !=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        serialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        i=0;
                        break;
                    }
                }
            }
            
            rbus.Start_Date__c = system.today().addDays(i);
            system.assertEquals(String.valueOf(serialNum + i), rBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), rBus.RecordTypeID);
            system.assertEquals(i, rBus.Reservation_ID__c);
            i++;
        }
        update tbsBus;
        
        // When the quantity is increased
        
        List<Opportunity_Line__c> updOppLine = [select Id, Opportunity_Line__c, Name, Quantity__c, Fleet__c, Date_Booked__c, Serial_Number__c, Start_Date__c from Opportunity_Line__c where id=:tOpp[0].Id];
        Decimal oQty = updOppLine[0].Quantity__c;
        updOppLine[0].Quantity__c = 204;
        update updOppLine;
        
        // Then there should be new busses
        
        Fleet__c chngFleet = [select Id, Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c, Quantity__c
                              from Fleet__c where Id=:tOpp[0].Fleet__c];
        
        system.assertEquals(204, chngFleet.Quantity__c);
        
        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                     from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        serialNum=0;
        i=0;
        opplID=Null;
        for (Bus__c rBus:resultingBus) {
            if (rBus.Opportunity_Line__c !=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        serialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        i=0;
                        break;
                    }
                }
            }
            
            if (i<oQty) {
                system.assertEquals(busScheduledRecordType.getRecordTypeId(), rBus.RecordTypeID);
            } else {
                system.assertEquals(busTBSRecordType.getRecordTypeId(), rBus.RecordTypeID);
            }
            system.assertEquals(String.valueOf(serialNum + i), rBus.Name);
            system.assertEquals(i, rBus.Reservation_ID__c);
            i++;
        }
        test.stopTest();
    }
    
    // 2m
    @isTest
    static void itShouldChangeToFirm()
    {
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        Schema.RecordTypeInfo busTBSRecordType = busMap.get('To Be Scheduled');
        Schema.RecordTypeInfo busScheduledRecordType = busMap.get('Scheduled');
        Schema.RecordTypeInfo busFirmRecordType = busMap.get('Firm');
        
        test.startTest();
        
        //Give an Opportunity Line that is not yet booked, and has a Start Date and a Serial Number
        List<Opportunity_Line__c> tOppLine = [select Id, Quantity__c, Start_Date__c, Serial_Number__c, Opportunity_Line__c, Mode__c, PO_Amount__c, PO_Date__c, PO_Reference__c, Quoted_Price__c, Style__c, Length__c, Contract_Option__c, Book_with_Sales_Order__c from Opportunity_Line__c];
        Integer oppLineTotal=0;
        Integer i = 1;
        for (Opportunity_Line__c t:tOppLine) {
            t.Serial_Number__c = String.valueOf(i*t.Quantity__c);
            t.Start_Date__c = system.today().addYears(2);
            oppLineTotal=oppLineTotal+(Integer)t.Quantity__c;
            i++;
        }
        update tOppLine;
        
        List<Opportunity_Line__c> topp = [select Id, Serial_Number__c, Fleet__c from Opportunity_Line__c];
        
        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                     from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        Map<Id, Fleet__c> resultingFleet = new Map<Id, Fleet__c>([select Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c 
                                                                  from Fleet__c]);
        String busName;
        Integer serialNum;
        i=0;
        Id opplID;
        for (Bus__c rBus:resultingBus) {
            if (rBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        serialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        i=0;
                        break;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(serialNum + i), rBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), rBus.RecordTypeID);
            system.assertEquals(i, rBus.Reservation_ID__c);
            rBus.Start_Date__c = system.today().addDays(i);
            i++;
        }
        update resultingBus;
        
        //when a Booked Date is set and it has a start date
        for (Opportunity_Line__c t:tOppLine) {
            t.Date_Booked__c = system.today();
        }
        
        update tOppLine;
        createSO.insertSO(tOppLine);
        
        List<Bus__c> bookedBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                  from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        List<Opportunity_Sales_Order__c> bookedOSO = [select Name, Opportunity_Line__c, Sales_Order__c, Quantity__c from Opportunity_Sales_Order__c];
        map<Id, Opportunity_Line__c> opplMap = new Map<Id, Opportunity_Line__c>(tOppLine);
        map<Id, Id> opplSOMap = new Map<Id, Id>();
        for (Opportunity_Sales_Order__c thisOSO:bookedOSO) {
            system.assertEquals(opplMap.get(thisOSO.Opportunity_Line__c).Quantity__c, thisOSO.Quantity__c);
            opplSOMap.put(thisOSO.Opportunity_Line__c, thisOSO.Sales_Order__c);
        }
        
        //Then the busses should have serial numbers and be Firm
        
        Integer bookedserialNum;
        Integer booked=0;
        opplID=Null;
        for (Bus__c bBus:bookedBus) {
            if (bBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:topp) {
                    if (bBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        bookedserialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        booked=0;
                        break;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(bookedserialNum + booked), bBus.Name);
            system.assertEquals(busFirmRecordType.getRecordTypeId(), bBus.RecordTypeID);
            system.assertEquals(opplSOMap.get(bBus.Opportunity_Line__c), bBus.Sales_Order__c);
            system.assertEquals(booked, bBus.Reservation_ID__c);
            booked++;
        }
        test.stopTest();
    }
    
    // 2o
    @isTest
    static void itShouldChangeFirmSerialNumbers() {
        
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        Schema.RecordTypeInfo busTBSRecordType = busMap.get('To Be Scheduled');
        Schema.RecordTypeInfo busFirmRecordType = busMap.get('Firm');
        
        test.startTest();
        
        List<Opportunity_Line__c> tOppLine = [select Id, Quantity__c, Start_Date__c, Serial_Number__c, Opportunity_Line__c, Mode__c, PO_Amount__c, PO_Date__c, PO_Reference__c, Quoted_Price__c, Style__c, Length__c, Contract_Option__c, Book_with_Sales_Order__c from Opportunity_Line__c];
        Integer oppLineTotal=0;
        Integer i = 1;
        for (Opportunity_Line__c t:tOppLine) {
            t.Serial_Number__c = String.valueOf(i*t.Quantity__c);
            t.Start_Date__c = system.today().addYears(2);
            oppLineTotal=oppLineTotal+(Integer)t.Quantity__c;
            i++;
        }
        update tOppLine;
        for (Opportunity_Line__c t:tOppLine) {
            t.Date_Booked__c = system.today();
        }
        update tOppLine;
        createSO.insertSO(tOppLine);
        
        List<Sales_Order__c> resultingSO = [select Id, Name, Quantity__c from Sales_Order__c];
        
        system.assertNotEquals(0,resultingSO.size());
        
        List<Opportunity_Line__c> topp = [select Id, Serial_Number__c, Start_Date__c, Fleet__c, Quantity__c from Opportunity_Line__c];
        
        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                     from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        Map<Id, Fleet__c> resultingFleet = new Map<Id, Fleet__c>([select Id, Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c, Active_Quantity_GILLIG__c
                                                                  from Fleet__c]);
        
        for (Opportunity_Line__c t:topp) {
            system.assertEquals(t.Quantity__c, resultingFleet.get(t.Fleet__c).Active_Quantity_GILLIG__c);
        }
        
        List<Opportunity_Sales_Order__c> bookedOSO = [select Id, Name, Opportunity_Line__c, Sales_Order__c, Quantity__c from Opportunity_Sales_Order__c];
        system.assertNotEquals(0,bookedOSO.size());
        
        Integer serialNum;
        i=0;
        Id opplID;
        Id bookedID;
        date opplStart;
        for (Bus__c rBus:resultingBus) {
            if (rBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        serialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        opplStart = tOppl.Start_Date__c;
                        i=0;
                        break;
                    }
                }
                for (Opportunity_Sales_Order__c tOSO:bookedOSO) {
                    if (rBus.Opportunity_Line__c==tOSO.Opportunity_Line__c) {
                        bookedID=toso.Sales_Order__c;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(serialNum + i), rBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), rBus.RecordTypeID);
            system.assertEquals(bookedID, rBus.Sales_Order__c);
            system.assertEquals(i, rBus.Reservation_ID__c);
            rBus.Start_Date__c = opplStart.addDays(i);
            i++;
        }
        update resultingBus;
        
        // When the Sales Order Name is changed
        
        Sales_Order__c changeSO = [select Id, Name, Quantity__c from Sales_Order__c where Id=:bookedOSO[0].Sales_Order__c];
        changeSO.Name = '123856';
        update changeSO;
        
        // Then the busses should have a different serial number
        
        List<Bus__c> changetoSerialBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                          from Bus__c where Sales_Order__c=:changeSO.Id];
        
        Integer changetoSerialNum=Integer.valueOf(changeSO.Name);
        Integer changetoSerial=0;
        for (Bus__c ctsBus:changetoSerialBus) {
            system.assertEquals(String.valueOf(changetoSerialNum+changetoSerial) , ctsBus.Name);
            system.assertEquals(busFirmRecordType.getRecordTypeId(), ctsBus.RecordTypeID);
            system.assertEquals(changetoSerial, ctsBus.Reservation_ID__c);
            changetoSerial++;
        }
        test.stopTest();
    }
    
    //2q
    @isTest
    static void itShouldChangeQtyFromOpportunitySalesOrder()
    {
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        Schema.RecordTypeInfo busTBSRecordType = busMap.get('To Be Scheduled');
        Schema.RecordTypeInfo busFirmRecordType = busMap.get('Firm');
        
        test.startTest();
        
        List<Opportunity_Line__c> tOpps = [select Id, Quantity__c, Start_Date__c, Serial_Number__c, Opportunity_Line__c, Mode__c, PO_Amount__c, PO_Date__c, PO_Reference__c, Quoted_Price__c, Style__c, Length__c, Contract_Option__c, Book_with_Sales_Order__c
                                           from Opportunity_Line__c];
        Integer oppLineTotal=0;
        Integer     i = 1;
        for (Opportunity_Line__c t:tOpps) {
            t.Serial_Number__c = String.valueOf(i*t.Quantity__c);
            t.Start_Date__c = system.today().addYears(2);
            t.Date_Booked__c = system.today();
            oppLineTotal=oppLineTotal+(Integer)t.Quantity__c;
            i++;
        }
        update tOpps;
        
        createSO.insertSO(tOpps);
        
        List<Opportunity_Line__c> topp = [select Id, Serial_Number__c, Fleet__c from Opportunity_Line__c];
        
        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                     from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        Map<Id, Fleet__c> resultingFleet = new map<Id, Fleet__c>([select Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c 
                                                                  from Fleet__c]);
        
        Integer serialNum;
        i=0;
        Id opplID;
        for (Bus__c rBus:resultingBus) {
            if (rBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        serialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        i=0;
                        break;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(serialNum + i), rBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), rBus.RecordTypeID);
            system.assertEquals(i, rBus.Reservation_ID__c);
            i++;
        }
        
        // Given an Opportunity Sales Order
        
        List<Opportunity_Sales_Order__c> oppSO = [select Id, Name, Sales_Order__c, Opportunity_Line__c, Quantity__c from Opportunity_Sales_Order__c];
        
        // When the Quanity is increased
        
        oppSO[0].Quantity__c = 204;
        update oppSO;
        
        // Then the busses should increase
        
        List<Bus__c> osoBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                               from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        Map<Id, Fleet__c> osoFleet = new Map<Id, Fleet__c>([select Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c, Active_Quantity_GILLIG__c
                                                            from Fleet__c]);
        Map<Id, Sales_Order__c> resultingSO = new Map<Id, Sales_Order__c>([select Name, Quantity__c from Sales_Order__c]);
        
        for (Opportunity_Sales_Order__c toso:oppSO) {
            system.assertEquals(toso.Quantity__c, resultingSO.get(toso.Sales_Order__c).Quantity__c);
        }
        
        Integer ososerialNum;
        Integer oso=0;
        opplID=Null;
        for (Bus__c oBus:osoBus) {
            if (oBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (oBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        ososerialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        oso=0;
                        break;
                    }
                }
            }            
            system.assertEquals(String.valueOf(ososerialNum+oso) , oBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), oBus.RecordTypeID);
            system.assertEquals(oso, oBus.Reservation_ID__c);
            oso++;
        }
        test.stopTest();
    }
    
    //2r
    @isTest
    static void itShouldReduceQtyFromOpportunitySalesOrder()
    {
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        Schema.RecordTypeInfo busTBSRecordType = busMap.get('To Be Scheduled');
        Schema.RecordTypeInfo busFirmRecordType = busMap.get('Firm');
        
        test.startTest();
        
        List<Opportunity_Line__c> tOpps = [select Id, Quantity__c, Start_Date__c, Serial_Number__c, Opportunity_Line__c, Mode__c, PO_Amount__c, PO_Date__c, PO_Reference__c, Quoted_Price__c, Style__c, Length__c, Contract_Option__c, Book_with_Sales_Order__c
                                           from Opportunity_Line__c];
        Integer oppLineTotal=0;
        Integer     i = 1;
        for (Opportunity_Line__c t:tOpps) {
            t.Serial_Number__c = String.valueOf(i*t.Quantity__c);
            t.Start_Date__c = system.today().addYears(2);
            t.Date_Booked__c = system.today();
            oppLineTotal=oppLineTotal+(Integer)t.Quantity__c;
            i++;
        }
        update tOpps;
        
        createSO.insertSO(tOpps);
        
        List<Opportunity_Line__c> topp = [select Id, Serial_Number__c, Fleet__c from Opportunity_Line__c];
        
        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                     from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        Map<Id, Fleet__c> resultingFleet = new Map<Id, Fleet__c>([select Id, Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c 
                                                                  from Fleet__c]);
        Integer serialNum;
        i=0;
        Id opplID;
        for (Bus__c rBus:resultingBus) {
            if (rBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=toppl.Id;
                        serialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        i=0;
                        break;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(serialNum + i), rBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), rBus.RecordTypeID);
            system.assertEquals(i, rBus.Reservation_ID__c);
            i++;
        }
        
        // Given an Opportunity Sales Order
        
        List<Opportunity_Sales_Order__c> oppSO = [select Id, Name, Sales_Order__c, Opportunity_Line__c, Quantity__c from Opportunity_Sales_Order__c];
        Map<Id, Sales_Order__c> soMap = new Map<Id, Sales_Order__c>([select Name from Sales_Order__c]);
        
        // When the Quanity is decreased
        
        Map<Id, Integer> oppOSOMap = new Map<Id, Integer>();
        for (Opportunity_Sales_Order__c t:oppSO) {
            t.Quantity__c = 2;
            oppOSOMap.put(t.Sales_Order__c, (Integer)t.Quantity__c);
        }
        update oppSO;
        
        // Then the busses should decrease
        
        List<Bus__c> osoBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                               from Bus__c Order By Sales_Order__c, Reservation_ID__c];
        
        List<Fleet__c> osoFleet = [select Id, Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c, Active_Quantity_GILLIG__c
                                   from Fleet__c];
        
        Integer ososerialNum=0;
        Integer oso=0;
        Id busSO;
        for (Bus__c oBus:osoBus) {
            if (oBus.Sales_Order__c!=busSO) {
                ososerialNum = Integer.valueOf(soMap.get(oBus.Sales_Order__c).Name);
                oso=0;
                busSO = oBus.Sales_Order__c;
            }
            system.assertEquals(String.valueOf(ososerialNum+oso) , oBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), oBus.RecordTypeID);
            system.assertEquals(oso, oBus.Reservation_ID__c);
            oso++;
        }
        test.stopTest();
    }
    
    @isTest
    static void itShouldChangeOpplStartDate()
    {
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        Schema.RecordTypeInfo busTBSRecordType = busMap.get('To Be Scheduled');
        
        test.startTest();
        //Given an Opportunity Line that is not yet booked, and has a Serial Number and a start date
        
        List<Opportunity_Line__c> tOppLine = [select Id, Quantity__c, Start_Date__c, Serial_Number__c from Opportunity_Line__c];
        Integer oppLineTotal=0;
        Integer i = 1;
        for (Opportunity_Line__c t:tOppLine) {
            t.Serial_Number__c = String.valueOf(i*t.Quantity__c);
            t.Start_Date__c = system.today().addYears(2);
            oppLineTotal=oppLineTotal+(Integer)t.Quantity__c;
            i++;
        }
        update tOppLine;
        
        List<Opportunity_Line__c> topp = [select Id, Serial_Number__c, Fleet__c, Quantity__c from Opportunity_Line__c];
        
        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                     from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        Map<Id, Fleet__c> resultingFleet = new Map<Id, Fleet__c>([select Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c, Active_Quantity_GILLIG__c 
                                                                  from Fleet__c]);
        Integer busCnt = 0;
        for (Opportunity_Line__c t:topp) {
            system.assertEquals(t.Quantity__c, resultingFleet.get(t.Fleet__c).Active_Quantity_GILLIG__c);
            busCnt = busCnt + (integer)t.Quantity__c;
        }
        system.assertEquals(busCnt, resultingBus.size());
        
        Integer serialNum;
        i=0;
        Id opplID;
        for (Bus__c rBus:resultingBus) {
            if (rBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        serialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        i=0;
                        break;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(serialNum + i), rBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), rBus.RecordTypeID);
            system.assertEquals(i, rBus.Reservation_ID__c);
            i++;
        }
        
        // When the start date of the first bus is changed
        Date plus2 = system.today().addDays(2);
        for (Bus__c bus0:resultingBus) {
            for (Opportunity_Line__c uOpp:tOpp) {
                if (bus0.Name==uOpp.Serial_Number__c) {
                    bus0.Start_Date__c=plus2;
                }
            }
        }
        update resultingBus;
        
        // Then the Opportunity Line should have a new start date
        List<Opportunity_Line__c> uOppl = [select Id, Start_Date__c from Opportunity_Line__c];
        for (Opportunity_Line__c thisOppl:uOppl) {
            system.assertEquals(plus2, thisOppl.Start_Date__c);
        }
        
        test.stopTest();
        
    }
    
    @isTest
    static void itShouldNotChangeOpplStartDate()
    {
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        Schema.RecordTypeInfo busTBSRecordType = busMap.get('To Be Scheduled');
        Schema.RecordTypeInfo busFirmRecordType = busMap.get('Firm');
        
        test.startTest();
        
        List<Opportunity_Line__c> tOpps = [select Id, Quantity__c, Start_Date__c, Serial_Number__c, Opportunity_Line__c, Mode__c, PO_Amount__c, PO_Date__c, PO_Reference__c, Quoted_Price__c, Style__c, Length__c, Contract_Option__c, Book_with_Sales_Order__c
                                           from Opportunity_Line__c];
        Integer oppLineTotal=0;
        Integer     i = 1;
        for (Opportunity_Line__c t:tOpps) {
            t.Serial_Number__c = String.valueOf(i*t.Quantity__c);
            t.Start_Date__c = system.today().addYears(2);
            t.Date_Booked__c = system.today();
            oppLineTotal=oppLineTotal+(Integer)t.Quantity__c;
            i++;
        }
        update tOpps;
        
        //Given an Opportunity Line that isbooked, and has a Serial Number and a start date
        
        createSO.insertSO(tOpps);
        
        List<Opportunity_Line__c> topp = [select Id, Serial_Number__c, Fleet__c from Opportunity_Line__c];
        
        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                     from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        Map<Id,Fleet__c> resultingFleet = new Map<Id, Fleet__c>([select Id, Name, OwnerId, RecordTypeID, Account__c, Length_GILLIG__c, Mode__c, Retired__c, Start_Date__c, Style_GILLIG__c 
                                                                 from Fleet__c]);
        
        List<Sales_Order__c> resultingSO = [select Id, Name, Start_Date__c from Sales_Order__c];
        for (Sales_Order__c s:resultingSO) {
            system.assertEquals(system.today().addYears(2), s.Start_Date__c);
        }
        
        Integer serialNum;
        i=0;
        Id opplID;
        for (Bus__c rBus:resultingBus) {
            if (rBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        serialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        i=0;
                        break;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(serialNum + i), rBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), rBus.RecordTypeID);
            system.assertEquals(i, rBus.Reservation_ID__c);
            i++;
        }
        
        // When the start date of the first bus is changed
        Date plus2 = system.today().addDays(2);
        for (Bus__c bus0:resultingBus) {
            for (Opportunity_Line__c uOpp:topp) {
                if (bus0.Name==uOpp.Serial_Number__c) {
                    bus0.Start_Date__c=plus2;
                }
            }
        }
        update resultingBus;
        
        // Then the Opportunity Line should NOT have a new start date
        List<Opportunity_Line__c> uOppl = [select Id, Start_Date__c from Opportunity_Line__c];
        for (Opportunity_Line__c thisOppl:uOppl) {
            system.assertNotEquals(system.today().addDays(2), thisOppl.Start_Date__c);
        }
        
        // Then the Sales Order should have a new start date
        
        List<Sales_Order__c> uSO = [select Id, Name, Start_Date__c from Sales_Order__c];
        for (Sales_Order__c s:uSO) {
            system.assertEquals(system.today().addDays(2), s.Start_Date__c);
        }
        
        test.stopTest();
        
    }
    
    @isTest
    static void itShouldChangeSOStartDate()
    {
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        Schema.RecordTypeInfo busTBSRecordType = busMap.get('To Be Scheduled');
        Schema.RecordTypeInfo busFirmRecordType = busMap.get('Firm');
        
        test.startTest();
        
        List<Opportunity_Line__c> tOpps = [select Id, Quantity__c, Start_Date__c, Serial_Number__c, Opportunity_Line__c, Mode__c, PO_Amount__c, PO_Date__c, PO_Reference__c, Quoted_Price__c, Style__c, Length__c, Contract_Option__c, Book_with_Sales_Order__c
                                           from Opportunity_Line__c];
        Integer oppLineTotal=0;
        Integer     i = 1;
        for (Opportunity_Line__c t:tOpps) {
            t.Serial_Number__c = String.valueOf(i*t.Quantity__c);
            t.Start_Date__c = system.today().addYears(2);
            t.Date_Booked__c = system.today();
            oppLineTotal=oppLineTotal+(Integer)t.Quantity__c;
            i++;
        }
        update tOpps;
        
        //Given an Opportunity Line that isbooked, and has a Serial Number and a start date
        
        createSO.insertSO(tOpps);
        
        List<Opportunity_Line__c> topp = [select Id, Serial_Number__c, Fleet__c from Opportunity_Line__c];
        
        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c
                                     from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        Integer serialNum;
        i=0;
        Id opplID;
        for (Bus__c rBus:resultingBus) {
            if (rBus.Opportunity_Line__c!=opplID) {
                for (Opportunity_Line__c tOppl:tOpp) {
                    if (rBus.Opportunity_Line__c == tOppl.Id) {
                        opplID=tOppl.Id;
                        serialNum = Integer.valueOf(tOppl.Serial_Number__c);
                        i=0;
                        break;
                    }
                }
            }
            
            system.assertEquals(String.valueOf(serialNum + i), rBus.Name);
            system.assertEquals(busTBSRecordType.getRecordTypeId(), rBus.RecordTypeID);
            system.assertEquals(i, rBus.Reservation_ID__c);
            i++;
        }
        
        // When the start date of the first bus is changed
        Date plus2 = system.today().addDays(2);
        for (Bus__c bus0:resultingBus) {
            for (Opportunity_Line__c uOpp:tOpp) {
                if (bus0.Name==uOpp.Serial_Number__c) {
                    bus0.Start_Date__c=plus2;
                }
            }
        }
        update resultingBus;
        
        // Then the Sales Order should have a new start date
        List<Sales_Order__c> uSO = [select Id, Name, Start_Date__c from Sales_Order__c];
        system.assertNotEquals(0, uSO.size());
        
        for (Sales_Order__c thisSO:uSO) {
            system.assertEquals(plus2, thisSO.Start_Date__c);
        }
        test.stopTest();
    }
    
    @isTest
    static void itShouldChangeProdOrderStartDate()
    {
        Schema.DescribeSObjectResult busSchema = Schema.SObjectType.Bus__c;
        Map<String,Schema.RecordTypeInfo> busMap = busSchema.getRecordTypeInfosByName();
        
        Schema.RecordTypeInfo busTBSRecordType = busMap.get('To Be Scheduled');
        Schema.RecordTypeInfo busFirmRecordType = busMap.get('Firm');
        
        test.startTest();
        
        List<Opportunity_Line__c> tOpps = [select Id, Quantity__c, Start_Date__c, Serial_Number__c, Opportunity_Line__c, Mode__c, PO_Amount__c, PO_Date__c, PO_Reference__c, Quoted_Price__c, Style__c, Length__c, Contract_Option__c, Book_with_Sales_Order__c
                                           from Opportunity_Line__c];
        Integer oppLineTotal=0;
        Integer i = 1;
        for (Opportunity_Line__c t:tOpps) {
            t.Serial_Number__c = String.valueOf(i*t.Quantity__c);
            t.Start_Date__c = system.today().addYears(2);
            t.Date_Booked__c = system.today();
            oppLineTotal=oppLineTotal+(Integer)t.Quantity__c;
            i++;
        }
        update tOpps;
        
        createSO.insertSO(tOpps);
        
        List<Sales_Order__c> sorders = new List<Sales_Order__c>([select Id, Name, Release_Order__c from Sales_Order__c]);
        
        for (Sales_Order__c thisSO:sorders) {
            thisSO.Release_Order__c = true;
        }
        update sorders;
        TestData.createProductionOrder();
        
        List<Opportunity_Line__c> topp = [select Id, Serial_Number__c, Fleet__c from Opportunity_Line__c];
        
        List<Bus__c> resultingBus = [select Id, RecordtypeId, Name, Current_Owner__c, Opportunity_Line__c, Retired__c, Sales_Order__c, Sequence__c, Serial_Number__c, Slot_Index__c, Slot_Index_In_Day__c, Slots__c, Start_Date__c, Week_Start_Date__c, Reservation_ID__c, Production_Order__c
                                     from Bus__c Order By Opportunity_Line__c, Reservation_ID__c];
        
        // When the start date of the first bus is changed
        Date plus2 = system.today().addDays(2);
        for (Bus__c bus0:resultingBus) {
            for (Opportunity_Line__c uOpp:tOpp) {
                if (bus0.Name==uOpp.Serial_Number__c) {
                    bus0.Start_Date__c=plus2;
                }
            }
        }
        update resultingBus;
        
        // Then the Production Order should have a new start date
        List<Production_Order__c> uProdOrder = [select Id, Start_Date__c, Sales_Order__c from Production_Order__c];
        system.assertNotEquals(0, uProdOrder.size());
        
        for (Production_Order__c thisProdOrder:uProdOrder) {
            //            system.assertEquals(plus2, thisProdOrder.Start_Date__c);
        }
        test.stopTest();
    }
     
}