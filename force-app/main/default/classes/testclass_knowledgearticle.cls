@isTest
private class testclass_knowledgearticle {
    
    static testMethod void testGetAccount() {
        // Create knowledge article record
        Knowledge__kav ka = new Knowledge__kav();
        ka.Title = 'Gillig Test Knowledge Article';
        ka.Issue_Description1__c = 'GILLIG Test KA';
        ka.UrlName = 'https-login-salesforce-com-staging-in';
        insert ka;
        
        PageReference pageRef = Page.Knowledge_Article;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', ka.Id);
           
        KnowledgeArticleController controller = new KnowledgeArticleController();
        Knowledge__kav result = controller.getAccount();
        
        System.assertEquals(ka.Id, result.Id);
        System.assertEquals(ka.Title, result.Title);
    }
}