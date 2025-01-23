public class getReworkList {
 @AuraEnabled(cacheable=true)
    public static Integer getReworkCount(String ecardId) {
        return [SELECT COUNT() FROM Rework__c WHERE Ecard_Id__c = :ecardId];
    }
}