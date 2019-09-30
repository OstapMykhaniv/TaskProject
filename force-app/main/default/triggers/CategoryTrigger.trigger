trigger CategoryTrigger on Category__c (after delete, after insert, after undelete, 
     after update, before delete, before insert, before update) {
   CategoryTriggerHandler.handleTrigger(trigger.old, trigger.new, trigger.oldMap, trigger.newMap, trigger.operationType);
}