/***********************************************************************************************************************************
     Developer :Suyati
     Name      : OpportunityLineRelatedList
     Usage     : Apex Controller to display and update OpportunityLines
     Associated Component:OpportunityLineRelatedListComponent
     Date      : October 2019   
************************************************************************************************************************************/   

public class OpportunityLineRelatedList {   
    /***********************************************************************************************************************************
     Method Name  : getOpportunityLines
     Parameters   : String 
     Return Type  : List<Opportunity_Line__c>    
     Method call  : getOpportunityLines(recordId)
     Description  : Queries Forecasted opportunity lines
   ************************************************************************************************************************************/   
    @auraEnabled
    public static List<Opportunity_Line__c> getOpportunityLines(String recordId)
    {
        Id RecordTypeId = Schema.SObjectType.Opportunity_Line__c.getRecordTypeInfosByName().get('Forecasted').getRecordTypeId();
         List<Opportunity_Line__c> opportunityLineList=new  List<Opportunity_Line__c>();
        try{
        String AccountId=[SELECT Account_Visited__c  FROM Trip_Report__c where Id=:recordId].Account_Visited__c;
        String AccountIdTruncated=AccountId.substring(0, 15);
            opportunityLineList=[SELECT Id,Name, Mode__c,Length__c,Style__c,Quantity__c,Account__c,RecordtypeId,Recordtype.name FROM Opportunity_Line__c where RecordtypeId=:RecordTypeId  and Account__c=:AccountIdTruncated and Opportunity_Line__r.IsClosed = False and Opportunity_Line__r.IsWon=False]; 
            
        }
        catch(Exception e){
               System.debug('The following exception has occurred: ' + e.getMessage());
        }
        return opportunityLineList;
    }

}