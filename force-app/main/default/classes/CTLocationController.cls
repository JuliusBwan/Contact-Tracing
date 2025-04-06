public class CTLocationController {
    public static List<Location__c> getRecentStatusChanges(){//return list of locations and order them by their status update date
        return [SELECT Id, Name, Status__c, Address__c, Red_Score__c, Pincode__c, Status_Update_Date__c 
               FROM Location__c
               ORDER BY Status_Update_Date__c
               DESC NULLS LAST
               LIMIT 100];
    } 
    
    //return list of locations by using a search word
    public static List<Location__c> searchLocations(String searchTerm){
        //create binding variable
        searchTerm = searchTerm + '%';

        List<Location__c> locations = [SELECT Id, Name, Status__c, Address__c, Red_Score__c, Pincode__c, Status_Update_Date__c 
               FROM Location__c
               WHERE Name LIKE :searchTerm 
                    OR Pincode__c LIKE :searchTerm 
                    OR Address__c LIKE :searchTerm
               ORDER BY Status_Update_Date__c
               DESC NULLS LAST];

        if (locations != null && locations.size() > 0){
            return locations;
        }
        return null;
    }
    
    //retrieve location record using its Id
    public static Location__c getLocationById(String locationId){
        List<Location__c> locations = [SELECT Id, Name, Status__c, Address__c, Red_Score__c, Pincode__c, Status_Update_Date__c 
               FROM Location__c
               WHERE Id =:locationId];
        if (locations != null && locations.size() > 0){
            return locations[0];
        }
        return null;
    }

    public static Map<String, Integer> getStatusCount(){
        Map<String, Integer> statCountMap = new Map<String, Integer>();
        AggregateResult[] groupedResult = [SELECT Status__c, COUNT(Id) total FROM Location__c GROUP BY Status__c];
        for (AggregateResult ar : groupedResult){
            String status = String.valueOf(ar.get('Status__c'));
            Integer count = Integer.valueOf(ar.get('total'));
            statCountMap.put(status, count);
        }
        return statCountMap;
    }

    public static void updateRedScore(Set<Id> locationIds){

        List<Location__c> locationToUpdate = new List<Location__c>();

        AggregateResult[] redPeoplePerLocation = [SELECT Location__c, COUNT(Id) total FROM Location_tracing__c 
                        WHERE Person__r.health_Status__c = 'Red'
                        AND Location__c IN :locationIds
                        AND Visit_Date__c = LAST_N_DAYS : 10
                        GROUP BY Location__c];

        for (AggregateResult ar : redPeoplePerLocation){
            String locationId = String.valueOf(ar.get('Location__c'));
            Integer redScore = Integer.valueOf(ar.get('total'));
            String status = getStatus(redScore);

            locationToUpdate.add(new Location__c(Id = locationId, Red_Score__c = redScore, Status__c = status));
        }

        if (locationToUpdate != null && locationToUpdate.size() > 0){
            update locationToUpdate;
        }
    }

    public static String getStatus(Integer redScore){
        if (redScore == 0){
            return 'Green';
        }
        else if (redScore <= 5){
            return 'Yellow';
        }
        else if (redScore <= 10){
            return 'Orange';
        }
        else {
            return 'Red';
        }
    }
}