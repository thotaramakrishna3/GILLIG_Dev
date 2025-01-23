@isTest (seeAlldata=false)
public class defaultFleetTest {

    @testSetup static void init () {
        TestData.init();
        TestData.createAcct();
        TestData.createOpp();
        TestData.createContract();
        TestData.createOppLine(5, 5);
        TestData.createSO();
    }
    
    static testmethod void checkFleetName () {

        test.startTest();

        List<Fleet__c> resultingFleet = [select id, Name, Date_Booked__c, Year_Booked__c, Start_Date__c, Mode__c, Length_GILLIG__c from Fleet__c];

        for (Fleet__c tFleet:resultingFleet) {

            string fName = 'GILLIG - ' + String.valueOf(tFleet.Start_Date__c.year()) + ' ' + tFleet.Length_GILLIG__c 
                                + ' ' + tFleet.Mode__c;

            system.assertEquals(fName, tFleet.Name);
        }
        test.stopTest();
    }
}