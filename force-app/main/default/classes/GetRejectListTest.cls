@isTest
public class GetRejectListTest {
    @TestSetup 
    private static void createTestRejects() {
        List<Reject__c> testRejects = new List<Reject__c>();
        
        Reject__c reject1 = new Reject__c(
            Ecard_Id__c = '12345',
            Name = 'Reject 1',
            Buildstation__c = 'Station 1',
            Department__c = 'Department 2',
            Reject_Description__c = 'Description',
            Reason_Code__c = 'R_123',
            Quantity_Rejected__c = 5,
            Bus_Part_Number__c = 'P123',
            LastModifiedByEmployeeId__c = 'Emp123',
            Remarks__c = 'Testing purpose'
        );
        testRejects.add(reject1);
        
        Reject__c reject2 = new Reject__c(
            Ecard_Id__c = '12345',
            Name = 'Reject 2',
            Buildstation__c = 'Station 2',
            Department__c = 'Test Department',
            Reject_Description__c = 'Description',
            Reason_Code__c = 'R_367',
            Quantity_Rejected__c = 3.00,
            Bus_Part_Number__c = 'P0012'
        );
        testRejects.add(reject2);
        
        Reject__c reject3 = new Reject__c(
			Ecard_Id__c = '12511',
            Name = 'Reject 3',
            Buildstation__c = 'Station 2',
            Department__c = 'Test Department',
            Reject_Description__c = 'Description',
            Reason_Code__c = 'R_367',
            Quantity_Rejected__c = 3.00,
            Bus_Part_Number__c = 'P0012'
        );
        testRejects.add(reject3);
         List<Rework__c> testReworks = new List<Rework__c>();
        
        Rework__c rework1 = new Rework__c(
            Ecard_Id__c = '12345',
            Name = 'Rework 1',
            Buildstation__c = 'Station 1',
            Department__c = 'Department 1',
            Rework_description__c = 'Description',
            Reason_Code__c = 'R_123',
            Quantity_Reworked__c  = 5.00,
            Bus_Part_Number__c = 'P123',
            Reworked_to_part_number__c = 'P011',
            LastModifiedByEmployeeId__c = 'Emp_123'
        );
        testReworks.add(rework1);
        
         Rework__c rework2 = new Rework__c(
            Ecard_Id__c = '12345',
            Name = 'Rework 2',
            Buildstation__c = 'Station 1',
            Department__c = 'Department 2',
            Rework_description__c = 'Description',
            Reason_Code__c = 'R_123',
            Quantity_Reworked__c  = 5,
            Bus_Part_Number__c = 'P123',
            Reworked_to_part_number__c = 'P011'
        );
        testReworks.add(rework2);
         Rework__c rework3 = new Rework__c(
            Ecard_Id__c = '12345',
            Name = 'Rework 3',
            Buildstation__c = 'Station 1',
            Department__c = 'Department 2',
            Rework_description__c = 'Description',
            Reason_Code__c = 'R_123',
            Quantity_Reworked__c  = 5.00,
            Bus_Part_Number__c = 'P123',
            Reworked_to_part_number__c = 'P011'
        );
        testReworks.add(rework3);
      
        insert testRejects;
        insert testReworks;
         
    }
  
    
    @isTest
    static void testGetRejectData() {
        Test.startTest();
        List<GetRejectList.getDataWrapper> resultAllDepartments = GetRejectList.getRejectData('12345', 'ALL DEPARTMENTS');
        System.assertEquals(2, resultAllDepartments.size());        
        List<GetRejectList.getDataWrapper> resultDepartment = GetRejectList.getRejectData('12345', 'Test Department');        
        System.assertEquals(1, resultDepartment.size());
        Test.stopTest();
        }
      
    @isTest
    static void testGetReworkDataEcard() {
        Test.startTest();
        List<GetRejectList.getDataWrapper> resultAllDepartments = GetRejectList.getReworkDataEcard('12345', 'ALL DEPARTMENTS');
        System.assertEquals(3, resultAllDepartments.size());        
        List<GetRejectList.getDataWrapper> resultDepartment = GetRejectList.getReworkDataEcard('12345', 'Department 1');        
        System.assertEquals(1, resultDepartment.size());
        Test.stopTest();
        }
    @isTest
    static void testGetRejectCount() {
        Test.startTest();
        Integer rejectCount = GetRejectList.getRejectCount('12345');
        Test.stopTest();
        System.assertEquals(2, rejectCount);
    }
     @isTest
    static void testGetReworkCount() {
        Test.startTest();
        Integer reworkCount = GetRejectList.getReworkCount('12345');
        Test.stopTest();
        System.assertEquals(3, reworkCount);
    }
    
   @isTest
    static void testGetUpdateRecord() {
       Reject__c rejectToUpdate = [SELECT Id FROM Reject__c WHERE Name = 'Reject 1' LIMIT 1];

        Test.startTest();
        List<GetRejectList.getDataWrapper> resultUpdateRecords = GetRejectList.getUpdateRecord(rejectToUpdate.Id);
        Test.stopTest();
    //    System.assertEquals(3, resultRejectList.size());
        
    }
     @isTest
    static void testGetUpdateReworkRecord() {
       Rework__c reworkToUpdate = [SELECT Id FROM Rework__c WHERE Name = 'Rework 1' LIMIT 1];

        Test.startTest();
        List<GetRejectList.getDataWrapper> resultUpdateRecords = GetRejectList.getUpdateReworkRecord(reworkToUpdate.Id);
        Test.stopTest();
      System.assertEquals(1, resultUpdateRecords.size());
        
    }
    @isTest
    static void testUpdateReject() {
       Reject__c rejectToUpdate = [SELECT Id,Remarks__c,LastModifiedByEmployeeId__c,Quantity_Rejected__c
                                   FROM Reject__c WHERE Name = 'Reject 1' LIMIT 1];

        Test.startTest();
        String resultUpdateRejects = GetRejectList.updateReject(rejectToUpdate.Id,rejectToUpdate.Remarks__c,
                                                                                     (Integer)rejectToUpdate.Quantity_Rejected__c,rejectToUpdate.LastModifiedByEmployeeId__c);
        Test.stopTest();
    }
     @isTest
    static void testUpdateRework() {
       Rework__c reworkToUpdate = [SELECT Id,Quantity_Reworked__c,LastModifiedByEmployeeId__c 
                                   FROM Rework__c WHERE Name = 'Rework 1' LIMIT 1];

        Test.startTest();
        String resultUpdateRejects = GetRejectList.updateRework(reworkToUpdate.Id,(Integer)reworkToUpdate.Quantity_Reworked__c,reworkToUpdate.LastModifiedByEmployeeId__c,'','' );
        Test.stopTest();
    }
    @isTest
    static void testGetData() {
        Test.startTest();
        List<GetRejectList.getDataWrapper> resultRejectList = GetRejectList.getData();
        Test.stopTest();
        System.assertEquals(3, resultRejectList.size());
        
    }
     @isTest
    static void testGetReworkData() {
        Test.startTest();
        List<GetRejectList.getDataWrapper> resultRejectList = GetRejectList.getReworkData();
        Test.stopTest();
        System.assertEquals(3, resultRejectList.size());
        
    }
}