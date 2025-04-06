public class CTPersonTriggerHandler {
    //Triggerhandler method to handle before insert events
    public static void beforeInsert(List<Person__c> newRecords){
        //before inserting new records, do the following
        for (Person__c prsn : newRecords){ 
            //Heath Status shoulbe be 'Green' 
            prsn.Health_Status__c = 'Green';
            //Generate token
            prsn.Token__c = CTPersonController.getToken(prsn.Mobile__c);         
        }
    }
    
    //Triggerhandler method to handle before update events
    public static void beforeUpdate(List<Person__c> newRecords, Map<Id, Person__c> oldRecordsMap){
        
        for (Person__c prsn : newRecords){
            //if the health status changes, change the status update date
            if (prsn.Health_Status__c != oldRecordsMap.get(prsn.Id).Health_Status__c){
                prsn.Status_Update_Date__c = Date.today();
            }
        } 
    }

    //TriggerHandler method for after update events
    public static void afterUpdate(List<Person__c> newRecords, Map<Id, Person__c> oldRecordsMap){
        Set<Id> statusChange = new Set<id>(); //set to store ids of records whose health status changes
        Set<Id> redStatus = new Set<Id>(); //set to store ids of records whose health status changes to 'Red'

        Set<Id> yellowStatus = new Set<id>(); //set to store ids of records whose health status changes to 'yellow' 
        //'Neighbours' and 'Secondary contacts' also stored here when they get into contact with 'Red' status person

        Set<Id> orangeStatus = new Set<Id>(); //set to store ids of records whose health status changes to 'orange'
        //'Cohabitants' and 'primary contacts' also stored here when they get into contact with 'Red' status person

        Set<Id> alreadyProcessed = new Set<Id>(); //store any duplicates
        alreadyProcessed.addAll(redStatus); 

        List<Person__C> personToUpdate = new List<Person__c>();


        //find out when health stus of  a record changes
        for (Person__c prsn : newRecords){
            //if health status changes 
            if (prsn.Health_Status__C != oldRecordsMap.get(prsn.Id).Health_Status__C){ 
                statusChange.add(prsn.Id); //add all record Ids whose health status changes
            }
            //if health status changes from red to yellow or green or orange
            if (prsn.Health_Status__C == 'Red' && oldRecordsMap.get(prsn.Id).Health_Status__c != 'Red'){  
                redStatus.add(prsn.Id); //add all record Ids whose health status changes to 'Red'
            }
        }
        
        orangeStatus.addAll(CTPersonController.getCohabitants(redStatus, alreadyProcessed)); 
        //populate orangeStatus with cohabitants to people with 'Red' status

        Set<Id> primaryContacts = CTPersonController.getPrimaryContacts(redStatus, alreadyProcessed); //get primary contacts returned into a set to be used
        orangeStatus.addAll(primaryContacts);                                         //as an argument in a method to return secondary contcts
        //populate orangeStatus with 'primary contacts' to people with 'Red' status


        yellowStatus.addAll(CTPersonController.getNeighbours(redStatus, alreadyProcessed)); 
        //populate yellowStatus with neighbours of people with 'Red' status


        yellowStatus.addAll(CTPersonController.getSecondaryContacts(primaryContacts, alreadyProcessed));
        //populate yellowStatus set with 'secondaryContacts' to people with 'Red' status

        for (Id prsnId : orangeStatus){
            personToUpdate.add(new Person__c(Id = prsnId, Health_Status__c = 'Orange'));
        }
        for (Id prsnId : yellowStatus){
            personToUpdate.add(new Person__c(Id = prsnId, Health_Status__c = 'Yellow'));
        }
        if (personToUpdate != null && personToUpdate.size() > 0){
            update personToUpdate;
        }

        //query location Ids whose status needs to be updated because of they had red status persons visiting
        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByPersonIds(statusChange);
        if (locationTraces != null && locationTraces.size() > 0){

            Set<Id> locationIds = new Set<Id>();
            for (Location_Tracing__c traces : locationTraces){
                locationIds.add(traces.Location__c);
            }

            CTLocationController.updateRedScore(locationIds);
        }
    }
}