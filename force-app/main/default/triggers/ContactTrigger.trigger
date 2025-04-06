trigger ContactTrigger on Contact (after insert, after update) {
	
    switch on Trigger.operationType {
        when AFTER_INSERT {
            ContactTriggerHandler.afterInsert(Trigger.new);
        }
        when AFTER_UPDATE {
            ContactTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
        /*
        when AFTER_DELETE {
            ContactTriggerHandler.afterDelete();
        }
        when AFTER_UNDELETE {
            ContactTriggerHandler.afterUndelete();
        }*/
    }
}