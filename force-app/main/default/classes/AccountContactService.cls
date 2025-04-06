public class AccountContactService {
    //updates the active contacts field on account
    public static void updateActiveContacts(Set<Id> idSet){//takes a set of ids
        //queries total contacts that are active per AccountId 
        List<AggregateResult> results = [SELECT AccountId, COUNT(Id) total FROM Contact 
                                        	WHERE Active__c = TRUE 
                                        	AND AccountId IN :idSet
                                        	GROUP BY AccountId];
        
        List<Account> accToUpdate = new List<Account>();
        //loop through the queried contact results
        for (AggregateResult ar : results){
            String accId = String.valueOf(ar.get('AccountId'));
            Integer totalContacts = Integer.valueOf(ar.get('total'));
            
            //update the contacts' related account (active contacts field)
            accToUpdate.add(new Account(Id = accId, Active_Contacts__c = totalContacts));
        }
        update accToUpdate;
    }
}