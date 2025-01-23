public class listFleet {
  public ID objId {get; set;}

  public Fleet__c[] getFleetList() {
    return [SELECT ID, Name, Start_date__c, Mode__c, Style__c, Length__c, Quantity__c FROM Fleet__c WHERE Account__c = :objId];
  }
}