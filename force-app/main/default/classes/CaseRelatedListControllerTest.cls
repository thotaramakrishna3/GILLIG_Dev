/***********************************************************************************************************************************
     Developer :Suyati
     Name      : CaseRelatedListControllerTest
     Usage     : Apex Controller to test CaseRelatedListController class
     Associated Controller:CaseRelatedListController
     Date      : October 2019   
************************************************************************************************************************************/
@isTest
public class CaseRelatedListControllerTest {
    @testsetup
    static void setup()
    {
        Account testAccount= TestDataFactory.createAccount();
        Trip_Report__c tripReport= TestDataFactory.createTripReport(testAccount.id);
        case sampleCase=new case(Status='Gather Preliminary Information', Subject='Test case',Trip_Report__c=tripReport.Id);
        insert sampleCase;
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Test Document';
        contentVersion.PathOnClient = 'TestDocument.pdf';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.IsMajorVersion = true;
        Insert contentVersion;
        List<ContentDocument> docList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink documentLink = New ContentDocumentLink();
        documentLink.LinkedEntityId = sampleCase.Id;
        documentLink.ContentDocumentId = docList[0].Id;
        documentLink.shareType = 'V';
        Insert documentLink;
    }
    /***********************************************************************************************************************************
     Method Name  : getCaseDetailsTest

     Method Tested  : getCaseDetails()
   ************************************************************************************************************************************/
    static testMethod void getCaseDetailsTest()
    {
        Account testAccount=[select id from account];
        Trip_Report__c tripReport=[select id ,Account_Visited__c from Trip_Report__c where Account_Visited__c=: testAccount.Id];
        case sampleCase=[select id from case where Trip_Report__c=: tripReport.id];
        try{
            test.startTest();
            List<Case> getCase=CaseRelatedListController.getCaseDetails(tripReport.Id);
            test.stopTest();
            System.assertEquals(sampleCase.id, getCase[0].id);
        }
        catch(exception e)
        {
            system.debug('Message'+e.getMessage());
        }
    }
     /***********************************************************************************************************************************
     Method Name  : getfileAndCommentTest

     Method Tested  : getfileAndComment()
   ************************************************************************************************************************************/   
    static testMethod void getfileAndCommentTest()
    {
        Account testAccount=[select id from account];
        Trip_Report__c tripReport=[select id ,Account_Visited__c from Trip_Report__c where Account_Visited__c=: testAccount.Id];
        case sampleCase=[select id from case where Trip_Report__c=: tripReport.id];
        try{
            test.startTest();
            List<ContentVersion> contentVersion=CaseRelatedListController.getfileAndComment(sampleCase.Id);
            test.stopTest();
            ContentDocumentLink contentdocumentLink =[Select Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId=:sampleCase.Id];
            system.assertEquals(contentVersion[0].ContentDocumentId , contentdocumentLink.ContentDocumentId);
        }
        catch(Exception e )
        {
            system.debug('Message'+e.getMessage());
        }
    }
    /***********************************************************************************************************************************
     Method Name  : getfileAndCommentNegativeTest

     Method Tested  : getfileAndComment()
   ************************************************************************************************************************************/     
    static testMethod void getfileAndCommentNegativeTest()
    {
        Account testAccount=[select id from account];
        Trip_Report__c tripReport=[select id ,Account_Visited__c from Trip_Report__c where Account_Visited__c=: testAccount.Id];
        case sampleCase=[select id from case where Trip_Report__c=: tripReport.id];
        try{
            test.startTest();
            List<ContentVersion> contentVersion2=CaseRelatedListController.getfileAndComment(null);
            test.stopTest();
            system.assertNotEquals(null, contentVersion2);
        }
        catch(Exception e )
        {
            system.debug('Message'+e.getMessage());
        }
    }
    /***********************************************************************************************************************************
     Method Name  : uploadCommentTest

     Method Tested  : uploadComment()
   ************************************************************************************************************************************/ 
    static testMethod void uploadCommentTest()
    {
        Account testAccount=[select id from account];
        Trip_Report__c trip_report=[select id ,Account_Visited__c from Trip_Report__c where Account_Visited__c=: testAccount.Id];
        Id sampleCase=[select id from case where Trip_Report__c=: trip_report.id].id;
        contentdocumentLink documentLink=[select id, ContentDocumentId,LinkedEntityId from contentdocumentLink where LinkedEntityId=:sampleCase ];
        try{
            test.startTest();
            List<ContentVersion> contentVersionList= CaseRelatedListController.uploadComment('Test comments', documentLink.ContentDocumentId, sampleCase);
            test.stopTest();
            contentVersion cv=[select id ,ContentDocumentId ,comments__c from contentversion where id=:contentVersionList[0].id ];
            system.assertEquals('Test comments',cv.comments__c);
        }
        catch(Exception e )
        {
            system.debug('Message'+e.getMessage());
        }
    }
    /***********************************************************************************************************************************
     Method Name  : uploadCommentNegativeTest

     Method Tested  : uploadComment()
   ************************************************************************************************************************************/ 
    static testMethod void uploadCommentNegativeTest()
    {
        Account testAccount=[select id from account];
        Trip_Report__c trip_report=[select id ,Account_Visited__c from Trip_Report__c where Account_Visited__c=: testAccount.Id];
        Id sampleCase=[select id from case where Trip_Report__c=: trip_report.id].id;
        contentdocumentLink documentLink=[select id, ContentDocumentId,LinkedEntityId from contentdocumentLink where LinkedEntityId=:sampleCase ];
        try{
            test.startTest();
            List<ContentVersion> contentVersion2= CaseRelatedListController.uploadComment('Test comments', null, sampleCase);
             test.stopTest();
            system.assertNotEquals(null, contentVersion2);
        }
        catch(Exception e )
        {
            system.debug('Message'+e.getMessage());
        }
    }
}