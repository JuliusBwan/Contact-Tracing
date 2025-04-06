public with sharing class CTLocationTriggerHandler {

    public static void beforeInsert(List<Location__c> newRecords) {
        //location status is set to green before inserting the record 
        for (Location__c location : newRecords){
            location.Status__c = 'Green';
        }
    }

    public static void beforeUpdate(List<Location__c> newRecords, Map<Id, Location__c> oldRecordsMap){
        for (Location__c location : newRecords){
            //when location status changes,  
            if (location.Status__c != oldRecordsMap.get(location.Id).Status__c){
                //update the status update date
                location.Status_Update_Date__c = Date.today();
            }
        }
    }

    public static void afterUpdate(List<Location__c> newRecords, Map<Id, Location__c> oldRecordsMap){
        Set<Id> statusChange = new Set<Id>();

        //when location status changes to red, update the Person__c who visted in the last 10 days to yellow, except the red and orange ones
        for (Location__c location : newRecords){
            //when location status changes to red,
            if (location.Status__c == 'Red' && oldRecordsMap.get(location.Id).Status__c != 'Red'){
                statusChange.add(location.Id);
            }
        }
        //get locations by inserting locationIds
        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByLocationIds(statusChange);

        //populate a set of personIds from those locations they visited
        Set<Id> personIds = new Set<Id>();

        for (Location_Tracing__c traces : locationTraces){
            personIds.add(traces.Person__c);
        }

        //create list to update
        List<Person__c> peopleToUpdate = new List<Person__c>();
        for (Id prsnId : personIds){
            peopleToUpdate.add(new Person__c(Id = prsnId, Health_Status__c = 'Yellow'));
        }
        if (peopleToUpdate.size() > 0){
            update peopleToUpdate;
        }
    }
}