public class KnowledgeArticleController {
    public Knowledge__kav account;
    public KnowledgeArticleController() {
        account = [SELECT Id, Title,Issue_Description1__c,Symptoms1__c,Tools_Required1__c,Parts_Required__c,Diagnostic_Steps__c,Repair_Steps__c,Labor_Information__c,Warranty_Claims__c,
                   Parts_Return_Disposition__c, Vendor_Article__c,VersionNumber,PublishStatus FROM Knowledge__kav 
                   WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        system.debug('Id=====>' +ApexPages.currentPage().getParameters().get('id'));
    }
    public Knowledge__kav getAccount() {
        return account;
        
    }
}