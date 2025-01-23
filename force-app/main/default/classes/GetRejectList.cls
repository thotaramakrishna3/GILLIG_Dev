public with sharing class GetRejectList {
    //Fetch records from Reject Object
     @AuraEnabled(cacheable=false)
   public static List<getDataWrapper> getRejectData(String ecardId, String dept) {
     List<User> usr = [select Id, Name,IsActive,EmployeeNumber from User where IsActive = true];
        List<Reject__c> rej = new List<Reject__c>();
            if(dept == 'ALL DEPARTMENTS'){
           rej = [SELECT Id,Ecard_Id__c,Name, Buildstation__c, Department__c, Reject_Description__c, Rejected_by__r.Name, 
                Reason_Code__c, Quantity_Rejected__c, Bus_Part_Number__c,CreatedDate,Rejected_By_Employee_Id__c FROM Reject__c WHERE Ecard_Id__c = :ecardId];
    }
        else{
        rej = [SELECT Id,Ecard_Id__c,Name, Buildstation__c, Department__c, Reject_Description__c, Rejected_by__r.Name, 
                Reason_Code__c, Quantity_Rejected__c, Bus_Part_Number__c,CreatedDate,Rejected_By_Employee_Id__c FROM Reject__c WHERE Ecard_Id__c = :ecardId AND Department__c =: dept];
    }
         
        List<getDataWrapper> gts = new List<getDataWrapper>();
        Map<String,String> emp = new Map<String,String>();
        for(User us : usr){
            emp.put(us.EmployeeNumber , us.Name);
        }
        for(Reject__c re : rej){
             getDataWrapper gt = new getDataWrapper();
            gt.Id = re.Id;
            gt.Ecard_Id = re.Ecard_Id__c;
            gt.Name = re.Name;
            gt.Buildstation = re.Buildstation__c;
            gt.Department = re.Department__c;
            gt.Reject_Description= re.Reject_Description__c;
            gt.Reason_Code = re.Reason_Code__c;
            gt.Quantity_Rejected = re.Quantity_Rejected__c;
            gt.Bus_Part_Number = re.Bus_Part_Number__c;
            gt.CreatedDate = re.CreatedDate;
            gt.UserName = emp.get(re.Rejected_By_Employee_Id__c);
             gt.Rejected_By_Employee_Id = re.Rejected_By_Employee_Id__c;
            gts.add(gt);
        }
        return gts;
    }
    
        
          //For rework records
   @AuraEnabled(cacheable=false)
   public static List<getDataWrapper> getReworkDataEcard(String ecardId, String dept) {
     List<User> usr = [select Id, Name,IsActive,EmployeeNumber from User where IsActive = true];
        List<Rework__c> rej = new List<Rework__c>();
            if(dept == 'ALL DEPARTMENTS'){
           		rej = [SELECT Id, Reworked_by__c,Name, Ecard_Id__c,CreatedDate,Department__c, Buildstation__c, Bus_Part_Number__c, 
                       Bus_Part_Id__c, Reworked_to_part_number__c, UUID__c, Rework_description__c, Reason_Code__c, 
                       Reworked_by_employee_id__c, Quantity_Reworked__c FROM Rework__c WHERE Ecard_Id__c = :ecardId];
            }
      		else{
       				rej = [SELECT Id, Reworked_by__c,Name, Ecard_Id__c,CreatedDate,Department__c, Buildstation__c, Bus_Part_Number__c, 
                           Bus_Part_Id__c, Reworked_to_part_number__c, UUID__c, Rework_description__c, Reason_Code__c,Quantity_Reworked__c, 
                           Reworked_by_employee_id__c  FROM Rework__c WHERE Ecard_Id__c = :ecardId AND Department__c =: dept];
   }
         
        List<getDataWrapper> gts = new List<getDataWrapper>();
        Map<String,String> emp = new Map<String,String>();
        for(User us : usr){
            emp.put(us.EmployeeNumber , us.Name);
        }
        for(Rework__c re : rej){
             getDataWrapper gt = new getDataWrapper();
            gt.Id = re.Id;
            gt.Ecard_Id = re.Ecard_Id__c;
            gt.Name = re.Name;
            gt.Buildstation = re.Buildstation__c;
            gt.Department = re.Department__c;
            gt.Reject_Description= re.Rework_description__c;
            gt.Reason_Code = re.Reason_Code__c;
            gt.Quantity_Rejected = re.Quantity_Reworked__c;
            gt.Bus_Part_Number = re.Bus_Part_Number__c;
            gt.CreatedDate = re.CreatedDate;
            gt.UserName = emp.get(re.Reworked_by_employee_id__c);
             gt.Rejected_By_Employee_Id = re.Reworked_by_employee_id__c;
            gt.Rework_Bus_Part_No = re.Reworked_to_part_number__c;
            system.debug(gt.Rework_Bus_Part_No);
            gts.add(gt);
        }
       system.debug(gts);
        return gts;
    }
     @AuraEnabled(cacheable=false)
    public static Integer getRejectCount(String ecardId) {
        return [SELECT COUNT() FROM Reject__c WHERE Ecard_Id__c = :ecardId];
    }
     @AuraEnabled(cacheable=true)
    public static List<getDataWrapper> getData() {
                List<User> usr = [select Id, Name,IsActive,EmployeeNumber from User where IsActive = true];
        List<Reject__c> rej = [SELECT Id,Ecard_Id__c,Name, Buildstation__c, Department__c, Reject_Description__c,BuschasisNumber__c, 
                                Reason_Code__c, Quantity_Rejected__c, Bus_Part_Number__c,Rejected_By_Employee_Id__c ,CreatedDate FROM Reject__c];
        
        List<getDataWrapper> gts = new List<getDataWrapper>();
        Map<String,String> emp = new Map<String,String>();
        for(User us : usr){
            emp.put(us.EmployeeNumber , us.Name);
        }
        for(Reject__c re : rej){
            getDataWrapper gt = new getDataWrapper();
            gt.Id = re.Id;
            gt.Ecard_Id = re.Ecard_Id__c;
            gt.Name = re.Name;
            gt.Buildstation = re.Buildstation__c;
            gt.Department = re.Department__c;
            gt.Reject_Description= re.Reject_Description__c;
            gt.BuschasisNumber = re.BuschasisNumber__c;
            gt.Reason_Code = re.Reason_Code__c;
            gt.Quantity_Rejected = re.Quantity_Rejected__c;
            gt.Bus_Part_Number = re.Bus_Part_Number__c;
            gt.CreatedDate = re.CreatedDate;
            gt.UserName = emp.get(re.Rejected_By_Employee_Id__c);
            gt.Rejected_By_Employee_Id = re.Rejected_By_Employee_Id__c;
            gts.add(gt);
        }
        return gts;
    }
    public class getDataWrapper{
        @AuraEnabled
        public String Id{get;set;}
                @AuraEnabled
        public String Ecard_Id{get;set;}
                @AuraEnabled
        public String Name{get;set;}
                @AuraEnabled
        public String Buildstation{get;set;}
                @AuraEnabled
        public String Department{get;set;}
                @AuraEnabled
        public String Reject_Description{get;set;}
                @AuraEnabled
        public String BuschasisNumber{get;set;}
                @AuraEnabled
        public String Reason_Code{get;set;}
                 @AuraEnabled
        public Decimal Quantity_Rejected{get;set;}
                 @AuraEnabled
        public String Bus_Part_Number{get;set;}
                 @AuraEnabled
        public Datetime CreatedDate{get;set;}
          @AuraEnabled
    public String Rework_Bus_Part_No{set;get;}
        
                 @AuraEnabled
        public String UserName{get;set;}
                @AuraEnabled
        public String Remark{get;set;}
                 @AuraEnabled
        public String Rejected_By_Employee_Id{get;set;}
      
    }
    @AuraEnabled(cacheable=false)
    public static Integer getReworkCount(String ecardId) {
        return [SELECT COUNT() FROM Rework__c WHERE Ecard_Id__c = :ecardId];
    }
@AuraEnabled
    public static List<getDataWrapper> getUpdateRecord(Id ids){
          List<User> usr = [select Id, Name,IsActive,EmployeeNumber from User where IsActive = true];
        List<Reject__c> rej = [SELECT Id,Ecard_Id__c,Name, Buildstation__c, Department__c, Reject_Description__c,BuschasisNumber__c, 
                                Reason_Code__c, Quantity_Rejected__c, Bus_Part_Number__c,Remarks__c,Rejected_By_Employee_Id__c ,CreatedDate FROM Reject__c where Id =: ids];
        
        List<getDataWrapper> gts = new List<getDataWrapper>();
        Map<String,String> emp = new Map<String,String>();
        for(User us : usr){
            emp.put(us.EmployeeNumber , us.Name);
        }
        for(Reject__c re : rej){
            getDataWrapper gt = new getDataWrapper();
            gt.Id = re.Id;
            gt.Ecard_Id = re.Ecard_Id__c;
            gt.Name = re.Name;
            gt.Buildstation = re.Buildstation__c;
            gt.Department = re.Department__c;
            gt.Reject_Description= re.Reject_Description__c;
            gt.BuschasisNumber = re.BuschasisNumber__c;
            gt.Reason_Code = re.Reason_Code__c;
            gt.Quantity_Rejected = re.Quantity_Rejected__c;
            gt.Bus_Part_Number = re.Bus_Part_Number__c;
            gt.CreatedDate = re.CreatedDate;
            gt.UserName = emp.get(re.Rejected_By_Employee_Id__c);
            gt.Remark = re.Remarks__c;
            gt.Rejected_By_Employee_Id = re.Rejected_By_Employee_Id__c;
            gts.add(gt);
        }
        return gts;
    }
   
@AuraEnabled
    public static string updateReject(Id recid,String remarks,Decimal quantity,String empId){
        try{
        Reject__c reje = new Reject__c();
        reje.Id = recid;
        reje.Remarks__c = remarks;
        reje.Quantity_Rejected__c = quantity;
        reje.LastModifiedByEmployeeId__c = empId;
        update reje;
        return 'Success';
        }catch(Exception e){
            return 'Failed';
        }
    }   
 @AuraEnabled(cacheable=true)
    public static List<getDataWrapper> getReworkData() {
                List<User> usr = [select Id, Name,IsActive,EmployeeNumber from User where IsActive = true];
        List<Rework__c> rej = [SELECT Id, Name, CreatedDate, Ecard_Id__c, Department__c, Department_Id__c, Buildstation__c, Buildstation_Id__c,
                               Reworked_by__c, Bus_Part_Number__c, Reworked_to_part_number__c, Rework_description__c, Reason_Code__c, Reworked_by_employee_id__c, Quantity_Reworked__c FROM Rework__c];
        
        List<getDataWrapper> gts = new List<getDataWrapper>();
        Map<String,String> emp = new Map<String,String>();
        for(User us : usr){
            emp.put(us.EmployeeNumber , us.Name);
        }
        for(Rework__c re : rej){
            getDataWrapper gt = new getDataWrapper();
            gt.Id = re.Id;
            gt.Ecard_Id = re.Ecard_Id__c;
            gt.Name = re.Name;
            gt.Buildstation = re.Buildstation__c;
            gt.Department = re.Department__c;
            gt.Reject_Description= re.Rework_description__c;
            gt.Reason_Code = re.Reason_Code__c;
            gt.Quantity_Rejected = re.Quantity_Reworked__c;
            gt.Bus_Part_Number = re.Bus_Part_Number__c;
            gt.CreatedDate = re.CreatedDate;
            gt.UserName = emp.get(re.Reworked_by_employee_id__c);
            gt.Rejected_By_Employee_Id = re.Reworked_by_employee_id__c;
            gt.Rework_Bus_Part_No = re.Reworked_to_part_number__c;
            gts.add(gt);
        }
        return gts;
    }
    @AuraEnabled
    public static List<getDataWrapper> getUpdateReworkRecord(Id ids){
          List<User> usr = [select Id, Name,IsActive,EmployeeNumber from User where IsActive = true];
        List<Rework__c> rej = [SELECT Id, Name, CreatedDate, Ecard_Id__c, Department__c, Department_Id__c, Buildstation__c, Buildstation_Id__c,
                               Reworked_by__c, Bus_Part_Number__c,Remarks__c, Reworked_to_part_number__c, Rework_description__c, Reason_Code__c, Reworked_by_employee_id__c, Quantity_Reworked__c FROM Rework__c where Id=:ids];
        
        List<getDataWrapper> gts = new List<getDataWrapper>();
        Map<String,String> emp = new Map<String,String>();
        for(User us : usr){
            emp.put(us.EmployeeNumber , us.Name);
        }
        for(Rework__c re : rej){
            getDataWrapper gt = new getDataWrapper();
            gt.Id = re.Id;
            gt.Ecard_Id = re.Ecard_Id__c;
            gt.Name = re.Name;
            gt.Buildstation = re.Buildstation__c;
            gt.Department = re.Department__c;
            gt.Reject_Description= re.Rework_description__c;
            gt.Reason_Code = re.Reason_Code__c;
            gt.Quantity_Rejected = re.Quantity_Reworked__c;
            gt.Bus_Part_Number = re.Bus_Part_Number__c;
            gt.CreatedDate = re.CreatedDate;
            gt.UserName = emp.get(re.Reworked_by_employee_id__c);
            gt.Rejected_By_Employee_Id = re.Reworked_by_employee_id__c;
            gt.Rework_Bus_Part_No = re.Reworked_to_part_number__c;
            gt.Remark = re.Remarks__c;
            gts.add(gt);
        }
        return gts;
    }
    @AuraEnabled
    public static string updateRework(String remark,Id recid,Decimal quantity,String empId,String reworkpart){
        try{
        Rework__c rewrk = new Rework__c();
        rewrk.Id = recid;
        rewrk.Quantity_Reworked__c = quantity;
        rewrk.Reworked_to_part_number__c = reworkpart; 
        rewrk.Remarks__c = remark;    
        rewrk.LastModifiedByEmployeeId__c = empId;
        update rewrk;
        return 'Success';
        }catch(Exception e){
            return 'Failed';
        }
    }   


}