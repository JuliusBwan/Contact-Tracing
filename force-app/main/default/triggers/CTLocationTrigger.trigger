trigger CTLocationTrigger on Location__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            //location status is set to green before inserting the record 
            CTLocationTriggerHandler.beforeInsert(Trigger.new);
            
        }
        when BEFORE_UPDATE {
            //when location status changes, update the status update date
            CTLocationTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
            
        }
        when AFTER_UPDATE {
            //when location status changes to red, update the Person__c who visted in the last 10 days to yellow, except the red and orange ones
            CTLocationTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}