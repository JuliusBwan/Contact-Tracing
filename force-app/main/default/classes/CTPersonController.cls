public class CTPersonController {

    public static String getToken(String Mobile){
        Blob targetBlob = Blob.valueOf(Mobile);
        Blob hash = Crypto.generateDigest('MD5', targetBlob);
        String token = EncodingUtil.base64Encode(hash);
        System.debug('Secure Token generated: ' + token);
        return token;
    }

    //retrieve 100 persons, order them by their state update date 
    public static List<Person__c> getRecentHealthChanges(){
        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c FROM Person__c 
                ORDER BY Status_Update_Date__c 
                DESC NULLS LAST
                LIMIT 100];
    }

    //search for people using a search term
    public static List<Person__c> searchPeople(String searchTerm){

        //get binding variable
        searchTerm = searchTerm + '%';

        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c FROM Person__c
               WHERE Name LIKE :searchTerm 
                    OR Mobile__c LIKE :searchTerm 
                    OR Token__c LIKE :searchTerm
               ORDER BY Status_Update_Date__c];
    }


    //returns one person record in alist
    public static Person__c getPersonById(String personId){
        List<Person__c> people = [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c FROM Person__c
               WHERE Id = :personId];

        if (people != null && people.size() > 0){ //return the first item in list
            return people[0];
        }
        return null;
    }
    public static Map<String, Integer> getHealthStatusCount(){
        Map<String, Integer> healthCountMap = new Map<String, Integer>();
        AggregateResult[] groupedResults = [SELECT Health_Status__c , COUNT(Id) total FROM Person__c GROUP BY Health_Status__c];
        for (AggregateResult ar : groupedResults){
            Integer count = Integer.valueOf(ar.get('total'));
            String healthStat = String.valueOf(ar.get('Health_Status__c'));
            
            healthCountMap.put(healthStat, count);
        }
        return healthCountMap;

    }
    //retrieve cohabitants that are yellow and green
    public static Set<Id> getCohabitants(Set<Id> personIds, Set<Id> alreadyProcessed){
        List<String> healthStatuses = new List<String>{'Green', 'Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Contact_Type__c, Person_1__c, Person_2__c FROM People_Tracing__c
                                               WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
                                               AND Contact_Type__c = 'Cohabitant'
                                               AND (Person_1__r.Health_Status__c IN :healthStatuses OR Person_2__r.Health_Status__c IN :healthStatuses)];
       	Set<Id> cohabitants = new Set<Id>();
        for (People_tracing__c pt : peopleTraces){
            if (!alreadyProcessed.contains(pt.Person_1__c)){
                cohabitants.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if (!alreadyProcessed.contains(pt.Person_2__c)){
                cohabitants.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
        return cohabitants;
    }
    //retrieve green neighbours
    public static Set<Id> getNeighbours(Set<Id> personIds, Set<Id> alreadyProcessed){
        List<People_Tracing__c> peopleTraces = [SELECT Person_1__c, Person_2__c, COntact_type__c FROM People_tracing__c
                                                WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
                                                AND Contact_Type__c = 'Neighbour' 
                                                AND (Person_1__r.Health_Status__c = 'Green' OR Person_2__r.Health_Status__c = 'Green')]; 
        Set<Id> neighbours = new Set<Id>();
        for (People_Tracing__c pt : peopleTraces){
            if (!alreadyProcessed.contains(pt.Person_1__c)){
                neighbours.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if (!personIds.contains(pt.Person_2__c)){
                neighbours.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
        return neighbours;
    }
    //retrieve primary contacts that are green and yellow
    public static Set<Id> getPrimaryContacts(Set<Id> personIds, Set<Id> alreadyProcessed){
        List<String> healthStatuses = new List<String>{'Green', 'Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Person_1__c, Person_2__c, Contact_Type__c FROM People_Tracing__c
                                                WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds) 
                                                AND Contact_Type__c = 'Other'
                                                AND (Person_1__r.Health_Status__c IN :healthStatuses OR Person_2__r.Health_Status__C IN :healthStatuses)
                                                AND Contact_Date__c = LAST_N_DAYS:10];   
        Set<Id> primaryContacts = new Set<Id>();
        for (People_Tracing__c pt : peopleTraces){
            if (!alreadyProcessed.contains(pt.Person_1__c)){
                primaryContacts.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if (!alreadyProcessed.contains(pt.person_2__c)){
                primaryContacts.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
        return primaryContacts;
    }
    //retrieve all green and yellow secondary contacts
    public static Set<Id> getSecondaryContacts(Set<Id> primaryContactIds, Set<Id> alreadyProcessed){
        List<String> healthStatuses = new List<String>{'Yellow', 'Green'};
        List<People_tracing__c> peopleTraces = [SELECT Person_1__c, Person_2__c, Contact_Type__c FROM People_Tracing__c
                                                WHERE (Person_1__c IN :primaryContactIds OR Person_2__c IN :primaryContactIds)
                                                AND Contact_Type__c = 'Other'
                                                AND (Person_1__r.Health_Status__c IN :healthStatuses OR Person_2__r.Health_Status__c IN :healthStatuses)
                                                AND Contact_Date__c = LAST_N_DAYS:10];
        Set<Id> secondaryContacts = new Set<Id>();
        for (People_Tracing__c pt : peopleTraces){
            if (!alreadyProcessed.contains(pt.Person_1__c)){
                secondaryContacts.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if (!alreadyProcessed.contains(pt.Person_2__c)){
                secondaryContacts.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
        return secondaryContacts;
    }
}