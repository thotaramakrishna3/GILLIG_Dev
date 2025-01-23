/***********************************************************************************************************************************
     Developer :Suyati
     Name      : TestDataFactory
     Usage     : Creation of test data
     Date      : October 2019   
************************************************************************************************************************************/   
global class TestDataFactory {
    /***********************************************************************************************************************************
     Method Name  : createAccount
     Parameters   : None
     Return Type  : Account    
     Method call  : createAccount()
     Description  : Creation of Account
   ************************************************************************************************************************************/  
    global static Account createAccount()
    {
        Account testAccount= new Account();
        testAccount.name='test Account';
        insert testAccount;
        return testAccount;
    }
       /***********************************************************************************************************************************
     Method Name  : createTripReport
     Parameters   : Id
     Return Type  : Trip_Report__c    
     Method call  : createTripReport(AccountId)
     Description  : Creation of trip report 
   ************************************************************************************************************************************/  
    global static Trip_Report__c createTripReport(Id AccountId)
    {
        Trip_Report__c tripReport= new Trip_Report__c();
        tripReport.Account_Visited__c=AccountId;
        tripReport.Date_of_Visit__c=System.today();
        tripReport.Ridership__c='Karen stated that ridership was up by 3% in 2019 ';
        tripReport.Artic_Bus_Plans__c='No 60 ft. bus interest';
        tripReport.Electric_Bus_Plans__c='No electric bus interest was expressed';
        tripReport.Fleet_Replacement_Plans__c='Karen stated she will have an ITB for 2- 29 ft. diesel buses out this Fall 2019. She stated they want equipped much like the 35 ft. buses. We discussed adding right front skid pad and rear skid pads to the technical specifications.';
        tripReport.Fleet_Performance__c='Performance was good';
        tripReport.Fuel_Cell_Bus_Plans__c='No fuel cell bus plan interest';
        insert tripReport;
        return tripReport;
    }
}