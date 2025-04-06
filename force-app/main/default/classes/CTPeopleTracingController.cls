public class CTPeopleTracingController {
    //return people tracing records using a personid
    public static List<People_Tracing__c> getTraces(String personId){
        List<People_Tracing__c> peopleTraces = [SELECT Id, Contact_Date__c, Person_1__c, Person_1__r.Health_Status__c, Person_1__r.Token__c,
                                                    Person_2__c, Person_2__r.Health_Status__c, Person_2__r.Token__c  
                                                    FROM People_Tracing__c
                                                    WHERE Person_1__c = :personId
                                                    OR Person_2__c = :personId
                                                    ORDER BY Contact_Date__c DESC];

        //iterate through the list and return the only record
        if (peopleTraces != null & peopleTraces.size() > 0){
            return peopleTraces;
        }
        else {
            return null;
        }
    }

    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> peopleTraces){
        
        //extract from peopleTraces list into a set
        Set<Id> pplIds = new Set<Id>();
        for (People_Tracing__c trace : peopleTraces){
            pplIds.add(trace.Person_1__c);
            pplIds.add(trace.Person_2__c);
        }

        //list of duplicate records
        List<People_Tracing__c> duplicates = new List<People_Tracing__c>();

        //create map 
        Map<Id, Set<Id>> mapOfExistingRecords = new Map<Id, Set<Id>>();

        //list of existing people tracing records in our database with same Ids as our parameter list
        List<People_Tracing__c> existinRecords = [SELECT Id, Name, Person_1__c, Person_2__c 
                FROM People_Tracing__c
                WHERE Person_1__c IN :pplIds
                OR Person_2__c IN :pplIds];

        //compare what's in our set to what's in our database list
        if (existinRecords != null & existinRecords.size() > 0){
            for (People_Tracing__c trace : existinRecords){
                if(!mapOfExistingRecords.containsKey(trace.Person_1__c)){
                    mapOfExistingRecords.put(trace.Person_1__c, new Set<Id>());
                }
                mapOfExistingRecords.get(trace.Person_1__c).add(trace.Person_2__c);

                //build map for person 2
                if(!mapOfExistingRecords.containsKey(trace.Person_2__c)){
                    mapOfExistingRecords.put(trace.Person_2__c, new Set<Id>());
                }
                mapOfExistingRecords.get(trace.Person_2__c).add(trace.Person_1__c);
            }
            //loop over existing records to find duplicates
            for (People_Tracing__c trace : peopleTraces){
                if(mapOfExistingRecords.containsKey(trace.Person_1__c) && mapOfExistingRecords.get(trace.Person_1__c).contains(trace.Person_2__c)
                ||
                mapOfExistingRecords.containsKey(trace.Person_2__c) && mapOfExistingRecords.get(trace.Person_2__c).contains(trace.Person_1__c)){
                    duplicates.add(trace);
                }
            }
        }
        
        return duplicates;
    }
}