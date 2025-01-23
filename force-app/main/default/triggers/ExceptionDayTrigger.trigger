trigger ExceptionDayTrigger on Exception_Day__c (after delete, after insert, after update, before delete, before insert, before update)
{
    TriggerFactory.createAndExecuteHandler(ExceptionDaysTriggerHandler.class);

}