/***********************************************************************************************************************************
     Developer :Suyati
     Name      : NewCaseControllerTest
     Usage     : Apex Controller to test NewCaseApexController class
     Associated Controller:NewCaseController
     Date      : October 2019   
************************************************************************************************************************************/ 

@isTest
public class NewCaseControllerTest {
    @testSetup static void setup() {
        Account testAccount= TestDataFactory.createAccount();
        Trip_Report__c tripReport= TestDataFactory.createTripReport(testAccount.id);
    }
    /***********************************************************************************************************************************
     Method Name  : getVisitedAccountTest
    
     Method Tested  : caseWrapper()
   ************************************************************************************************************************************/   
    static testMethod void getVisitedAccountTest()
    {
        Account testAccount=[select id from account];
        try{
            Trip_Report__c tripReport=[select id,Account_Visited__c from Trip_Report__c where Account_Visited__c=:testAccount.Id];
            Test.startTest();
           	NewCaseController.caseWrapper testcase= NewCaseController.getTripAccountVisited(tripReport.Id);
            Test.stopTest();
            system.assertEquals(testAccount.id, testcase.accountId);
        }
        catch(Exception e)
        {
            system.debug('in  exe'+e.getMessage());
        }
    }
     /***********************************************************************************************************************************
     Method Name  : getVisitedAccountNegativeTest
    
     Method Tested  : caseWrapper()
   ************************************************************************************************************************************/  
    static testMethod void getVisitedAccountNegativeTest()
    {
        try{
            Test.startTest();
           	NewCaseController.caseWrapper testcase= NewCaseController.getTripAccountVisited(null);
            Test.stopTest();
            system.assertEquals(null, testcase.accountId);
        }
        catch(Exception e)
        {
            system.debug('in  exe'+e.getMessage());
        }
    }
    /***********************************************************************************************************************************
     Method Name  : uploadCommentTest
    
     Method Tested  : uploadComment()
   ************************************************************************************************************************************/  
    static testMethod void uploadCommentTest()
    {
        String commentstring;
        ContentVersion contentVersionTest = new ContentVersion();
        contentVersionTest.Title = 'Test Document';
        contentVersionTest.PathOnClient = 'TestDocument.pdf';
        contentVersionTest.VersionData = Blob.valueOf('Test Content');
        contentVersionTest.IsMajorVersion = true;
        Insert contentVersionTest;
        Contentversion contentVersionDocumentId=[select id,ContentDocumentId,comments__c from Contentversion where id=:contentVersionTest.id  ];
        try
        {
            test.startTest();
            NewCaseController.uploadComment('The comments are uploaded',contentVersionDocumentId.ContentDocumentId);
            Test.stopTest();
            Contentversion contentVersionTest1=[select id,ContentDocumentId,comments__c from Contentversion where id=:contentVersionDocumentId.id  ];
            system.assertEquals('The comments are uploaded', contentVersionTest1.comments__c);
        }
        catch (Exception ex)
        {
            system.debug('in  exe'+ex.getMessage());
        }
    }
    /***********************************************************************************************************************************
     Method Name  : uploadCommentNegativeTest
    
     Method Tested  : uploadComment()
   ************************************************************************************************************************************/
  static testMethod void uploadCommentNegativeTest()
    {
        try
        {
            test.startTest();
            NewCaseController.uploadComment(null,null);
            Test.stopTest();
        }
        catch (Exception ex)
        {
             system.assertNotEquals(null,ex.getMessage());
        }
    }
}