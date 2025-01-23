@istest (seealldata=false)
public class defaultContactOwnerTest {

    static account tAccount;
    static user rRep;
    static user pRep;
    
    static void init () {

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        system.runAs(thisUser) {
            Profile p = [SELECT Id FROM Profile WHERE Name='Regional Sales Manager'];
            rRep = new user(LastName = 'National Sales Rep', Username = 'NationalSales.User@example.com', Email = 'NationalSales.User@example.com', 
                        Alias = 'rRep', CommunityNickname = 'rRep', 
                        TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                       	EmailEncodingKey = 'ISO-8859-1', ProfileId = p.ID,
                       	LanguageLocaleKey = 'en_US');
            insert rRep;
        
            Profile pm = [SELECT Id FROM Profile WHERE Name='Project Sales Manager'];
            pRep = new user(LastName = 'Project Sales Rep', Username = 'ProjectSales.User@example.com', Email = 'ProjectSales.User@example.com', 
                        Alias = 'pRep', CommunityNickname = 'pRep', 
                        TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                       	EmailEncodingKey = 'ISO-8859-1', ProfileId = pm.ID,
                       	LanguageLocaleKey = 'en_US');
            insert pRep;
        }
        
       	tAccount = new account(Name='Test Account', 
                               Ownerid = rRep.Id, 
                               Project_Sales_Manager__c = pRep.Id);
        insert tAccount;
        system.debug('Account');
        system.debug(tAccount);
    }
    
    static testmethod void testDefaultOwner () {
        init();
        
        test.startTest();
        list<Contact> tconts = new List<Contact>();
        for (Integer i = 0; i < 101; i++) {
            tconts.add(new contact (AccountID=tAccount.ID,FirstName='Test - '+i.format(),
                                    LastName='Contact'+i.format(), ownerid=pRep.id));
        }
        insert tconts;
        system.debug('new Contact');
        system.debug(tconts);
        
        contact checkContact = [select id, ownerid, Name from contact where id=:tconts[0].id];
        system.debug('check Contact');
        system.debug(checkContact);
        
        system.assertEquals(rRep.Id, checkContact.OwnerId);
        
        test.stopTest();
    }
}