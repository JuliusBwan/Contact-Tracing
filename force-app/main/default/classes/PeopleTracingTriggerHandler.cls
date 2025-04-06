public with sharing class PeopleTracingTriggerHandler {
    
    public static void beforeInsert(List<People_Tracing__c> newRecords){

        List<People_Tracing__c> peopleDuplicates = CTPeopleTracingController.checkDuplicates(newRecords); 

        for (People_Tracing__c prsn : peopleDuplicates){          
            prsn.addError('This record already exists.');           
        }        
    }
}