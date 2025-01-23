/***********************************************************************************************************************************
Developer :Suyati
Name      : NewCaseController
Usage     : Apex Controller to upload and display associated documents
Associated Component:NewCaseComponent
Date      : October 2019   
************************************************************************************************************************************/ 
public class NewCaseController {
/***********************************************************************************************************************************
Method Name  : getTripAccountVisited
Parameters   : Id<recordId> 
Return Type  : wrapper    
Method call  : getTripAccountVisited(recordId)
Description  : To query visited accounts from trip report
************************************************************************************************************************************/   
    @auraEnabled
    public static caseWrapper getTripAccountVisited(Id recordId){
        caseWrapper wrapper= new caseWrapper();
        try{
            wrapper.accountId=[SELECT Account_Visited__c FROM Trip_Report__c where Id =:recordId].Account_Visited__c;
            wrapper.recordTypeId=Schema.SObjectType.case.getRecordTypeInfosByName().get('Sales Support').getRecordTypeId();
        }
        catch(Exception e)
        {
            System.debug('Error message:'+e.getMessage());
        }
        return wrapper;
    }
/***********************************************************************************************************************************
Class Name   : caseWrapper
Description  : To store value of Account Id  and Record TypeId
Used In       :  Fetch Account of Trip Report
************************************************************************************************************************************/    
    public class caseWrapper{
        @auraEnabled public Id accountId{get;set;}
        @auraEnabled public Id recordTypeId{get;set;}
    }
    
/***********************************************************************************************************************************
Method Name  : uploadComment
Parameters   : Id<recordId> 
Return Type  : void    
Method call  : uploadComment(comment,contentDocumentId)
Description  : To update content version
************************************************************************************************************************************/  
    @AuraEnabled
    public static void uploadComment( String comment, String contentDocumentId) { 
        try{
            ContentVersion contentVersionId=[SELECT Id,comments__c FROM ContentVersion where  ContentDocumentId=:contentDocumentId];
            contentVersionId.comments__c=comment;
            update contentVersionId;
        }
        catch(Exception e)
        {
            System.debug('Error message:'+e.getMessage());
        }
    }
}