/***********************************************************************************************************************************
     Developer :Suyati
     Name      : CaseRelatedListController
     Usage     : Apex Controller to upload comments and retrive case details
     Associated Component:CaseRelatedListComponent
     Date      : October 2019   
************************************************************************************************************************************/ 
public class CaseRelatedListController {
     /***********************************************************************************************************************************
     Method Name  : getCaseDetails
     Parameters   : String<recordId> 
     Return Type  : List    
     Method call  : getCaseDetails(recordId)
     Description  : To query case fields
   ************************************************************************************************************************************/
    @auraEnabled
    Public static List<Case> getCaseDetails(string recordId)       
    {
        List<Case> caseList=new List<Case>();
        try{
            caseList=[SELECT Id, CaseNumber, Status, Subject,AccountId FROM Case where Trip_Report__c=:recordId order by createddate desc];
        }
         catch(exception e)
         {
        system.debug('Message'+e.getMessage());
        }
        return caseList;
    }
    /***********************************************************************************************************************************
     Method Name  : getfileAndComment
     Parameters   : String<caseRecordId> 
     Return Type  : List    
     Method call  : getfileAndComment(recordId)
     Description  : To query ContentDocumentLink fields
      ************************************************************************************************************************************/
     @auraEnabled
    public static   List<contentversion> getfileAndComment(String caseRecordId)
    {
        List<id> contentdocumentIds= new list<Id>();
        try{
        List<ContentDocumentLink> contentdocumentLinkList= [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId=:caseRecordId];
        for(ContentDocumentLink link:contentdocumentLinkList)
        {
            contentdocumentIds.add(link.ContentDocumentId);
        }
        }
        catch(exception e)
        {
        system.debug('Message'+e.getMessage());
        }
        List<contentversion> contentversionList=[SELECT Id, ContentDocumentId, Title,Comments__c FROM ContentVersion where ContentDocumentId IN :contentdocumentIds];
        return contentversionList;
    }
    /***********************************************************************************************************************************
     Method Name  : getfileAndComment
     Parameters   : String<caseRecordId> 
     Return Type  : List    
     Method call  : getfileAndComment(recordId)
     Description  : To query ContentDocumentLink fields
      ************************************************************************************************************************************/
    @AuraEnabled
    public static  List<contentversion> uploadComment( String comment, String contentDocumentId,String caseRecordId) { 
        try{
            ContentVersion contentVersionId=[SELECT Id,comments__c FROM ContentVersion where  ContentDocumentId=:contentDocumentId];
            contentVersionId.comments__c=comment;
            update contentVersionId;
        }
        catch(Exception e)
        {
              system.debug('Message'+e.getMessage());
        }
        List<contentversion> contentversionList=getfileAndComment(caseRecordId);
        return contentversionList;
    }
}