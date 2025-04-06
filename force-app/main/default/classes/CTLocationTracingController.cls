public class CTLocationTracingController {

    public static List<Location_Tracing__c> getVisitors(String locationId){ //get location tracing records using locationId
        return [SELECT Id, Person__c, Location__c, Visit_Date__c FROM Location_Tracing__c
               WHERE Id =:locationId
               ORDER BY Visit_Date__c
               DESC NULLS LAST];
    }


    public static List<Location_Tracing__c> getLocationsByPersonIds(Set<Id> personIds){//get location records using personIds
        return [SELECT Id, Person__c, Location__c, Visit_Date__c FROM Location_Tracing__c
               WHERE Person__c IN :personIds 
               AND Visit_Date__c = LAST_N_DAYS:10];
    }


    public static List<Location_Tracing__c> getLocationsByLocationIds(Set<Id> locationIds){
        return [SELECT Id, Name, Person__r.Name, Location__r.Name, Visit_Date__c FROM Location_Tracing__c
               WHERE Location__c IN :locationIds 
               AND Person__r.Health_Status__c = 'Green'
               AND Visit_Date__c = LAST_N_DAYS:10];
    }


    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> locationTraces){
        //Step 1 - extract unique location ids and person ids from the parameter list

        //store unique locationids
        Set<Id> locationIds = new Set<Id>();

        //store unique personids
        Set<Id> personIds = new Set<Id>();

        for (Location_Tracing__c trace : locationTraces){
            locationIds.add(trace.Location__c);
            personIds.add(trace.Person__c);
        } 

        //Step 2 - query existing location tracing records
        List<Location_Tracing__c> existingRecords = [SELECT Id, Name, Person__c, Location__c, Visit_Date__c FROM Location_Tracing__c
                                        WHERE Location__c IN :locationIds
                                        AND Person__c IN :personIds ];

        //map of location id with set of person ids
        Map<Id, Set<Id>> mapOfExistingRecords = new Map<Id, Set<Id>>();

        //list to store duplicates
        List<Location_Tracing__c> duplicates = new List<Location_Tracing__c>();

        if (existingRecords != null && existingRecords.size() > 0){
            for (Location_Tracing__c trace : existingRecords){
                if (!mapOfExistingRecords.containsKey(trace.Location__c)){
                    mapOfExistingRecords.put(trace.Location__c, new Set<Id>());
                }

                mapOfExistingRecords.get(trace.Location__c).add(trace.Person__c);
            }

            //loop over new location tracing records
            for (Location_Tracing__c trace : locationTraces){
                //check for location id
                //if found in map, then check for person in set
                if (mapOfExistingRecords.containsKey(trace.Location__c)
                && mapOfExistingRecords.get(trace.Location__c).contains(trace.Person__c)){
                    duplicates.add(trace);
                }
            }
        }
        return duplicates;
        
    }

}