/***********************************************************************************************************************************
Developer :Suyati
Name      : ContactVisitedComponentController
Usage     : Apex Controller to create new tripcontact and update existing ones.
Associated Component:ContactVisitedComponent
Date      : October 2019   
************************************************************************************************************************************/   
public class ContactVisitedComponentController {
    /***********************************************************************************************************************************
    Method Name  : getTripContacts
    Parameters   : Id
    Return Type  : list<VisitedContactWrapper>   
    Method call  : getTripContacts(recordId)
    Description  : Returns a list of contact and their associated tripcontact for a given tripreport
    ************************************************************************************************************************************/   
    @auraEnabled
    public static list<VisitedContactWrapper> getTripContacts(Id recordId){   
        list<VisitedContactWrapper> contactwrapperList=new list<VisitedContactWrapper>();
        String AccountVisitedId=[select id,account_visited__c from Trip_Report__c where  id=:recordId].account_visited__c;
        try{
            list<Contact> ContactList=[SELECT Id,Name,phone,mobilephone,Email,accountId,account.Name,(select id,ContactName__c,Visited__c,Name,TripReport__c from Trip_Visit__r  where TripReport__c =:recordId) from contact  where accountId=:AccountVisitedId and Left_Company__c=False  order by createddate asc ];
            for(Contact contactRecord:ContactList)
            {
                VisitedContactWrapper contactWrapper = new VisitedContactWrapper();
                contactWrapper.contactId=contactRecord.Id;
                contactWrapper.accountId=contactRecord.AccountId;
                contactWrapper.contactName=contactRecord.Name;
                contactWrapper.tripReportId =recordId;
                contactWrapper.email=contactRecord.Email;
                contactWrapper.phone=contactRecord.Phone;
                contactWrapper.mobilePhone=contactRecord.MobilePhone;
                if(contactRecord.Trip_Visit__r.size()>0)
                {
                    TripContact__c tripContact =new TripContact__c();
                    tripContact=contactRecord.Trip_Visit__r[0]; 
                    contactWrapper.tripContactId = tripContact.Id;
                    contactWrapper.isVisited=tripContact.Visited__c;
                }
                else
                    contactWrapper.isVisited=FALSE;
                contactwrapperList.add(contactWrapper);
            }
            
        }
        catch(exception e)
        {
            system.debug('Message'+e.getMessage());
        }
        return contactwrapperList;
    }
    
    /***********************************************************************************************************************************
    Class Name   : VisitedContactWrapper
    Description  : To store value of contact details and their respective tripcontact(visited field)
    Used In       :  getTripContacts  method
    ************************************************************************************************************************************/     
    public class VisitedContactWrapper {
        @auraEnabled
        public Id contactId;
        @auraEnabled
        public Id accountId;
        @auraEnabled
        public string tripContactId;
        @auraEnabled
        public boolean isVisited;
        @auraEnabled
        public string contactName;
        @auraEnabled
        public string tripReportId;
        @auraEnabled
        public string email;
        @auraEnabled
        public string phone;
        @auraEnabled
        public string mobilePhone;
        
    }
    
    /***********************************************************************************************************************************
    Method Name  : getRecordtypeId
    Parameters   : none
    Return Type  : string    
    Method call  : getRecordtypeId()
    Description  : Returns recordtype Id from recordtype name
    ************************************************************************************************************************************/   
    @auraEnabled 
    public static string getRecordtypeId()
    {
        String recordtypeId;
        try{
            recordtypeId=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            
        }
        catch(exception e)
        {
            system.debug('Message'+e.getMessage());
        }
        return recordtypeId;
    }
    
    /***********************************************************************************************************************************
    Method Name  : createTripContact
    Parameters   : string,string
    Return Type  : list<VisitedContactWrapper>   
    Method call  : createTripContact(tripContactListJson,recordId)
    Description  : To create a new tripcontact or update existing tripcontact
    ************************************************************************************************************************************/   
    @auraEnabled
    public static list<VisitedContactWrapper>createTripContact(string tripContactListJson,string recordId  ){
        
        List<VisitedContactWrapper>tripContactList = (List<VisitedContactWrapper>) JSON.deserialize(tripContactListJson,List<VisitedContactWrapper>.class);
        List<TripContact__c>tripContactInsertList= new List<TripContact__c>();
        List<TripContact__c>tripContactUpdateList= new List<TripContact__c>();
        try
        {
            for(VisitedContactWrapper contactWrapper :tripContactList)
            {
                if(contactWrapper.tripContactId==NULL)
                {
                    if(contactWrapper.isVisited)
                    {
                        TripContact__c newTripContact = new TripContact__c(Visited__c=TRUE,TripReport__c=recordId,TripContact__c=contactWrapper.contactId);
                        tripContactInsertList.add(newTripContact);
                        
                    }
                    else
                    {
                        continue;
                    }
                }
                else
                {   TripContact__c newTripContact=new TripContact__c(Id=contactWrapper.tripContactId,Visited__c=contactWrapper.isVisited);
                 tripContactUpdateList.add(newTripContact);
                } 
            } insert tripContactInsertList;
            update tripContactUpdateList; 
        }
        catch(Exception e)
        {
            throw new AuraHandledException(e.getMessage()); 
        }
        return tripContactList;
    }
}