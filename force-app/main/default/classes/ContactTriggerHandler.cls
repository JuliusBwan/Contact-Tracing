public class ContactTriggerHandler {
    //when new contacts are inserted, 
    public static void afterInsert(List<Contact> newContacts){
        Set<Id> accountIds = new Set<Id>(); 
        //extract AccountIds from each contact
        for (Contact con : newContacts){
            if (String.isNotBlank(con.AccountId)){
               //add each accountId to a set
                accountIds.add(con.AccountId);
            }
        }
        //update the count of active contacts on each account
        AccountContactService.updateActiveContacts(accountIds); 
    }
    
    //when existing contacts are updated,
    public static void afterUpdate(List<Contact> newContacts, Map<Id, Contact> oldContactsMap){
        Set<id> accountIds = new Set<id>();
        
        for (Contact con : newContacts){
            //if the active checkbox value has changed
            if (String.isNotBlank(con.AccountId) && con.Active__c != oldContactsMap.get(con.Id).Active__c){
                //store the account Id to the set
                accountIds.add(con.AccountId);
                //If the AccountId changed, add both the old and new AccountId to the set
            } else if (con.AccountId != oldContactsMap.get(con.Id).AccountId){
                accountIds.add(con.AccountId);
                accountIds.add(oldContactsMap.get(con.Id).AccountId);
            }
        }
        //update the count
        AccountContactService.updateActiveContacts(accountIds);
    }

}