public with sharing class EnrollmentScoreTriggerHandler {
 
    public static void afterInsert(List<Enrollment_Score__c> newScores){
 
        if(newScores == null || newScores.isEmpty()){
            return;
        }
        Map<Id, Enrollment_Score__c> latestScoreMap =
            new Map<Id, Enrollment_Score__c>();
        for(Enrollment_Score__c score : newScores){
 
            if(score.Contact__c == null){
                continue;
            }
 
            if(!latestScoreMap.containsKey(score.Contact__c)){
 
                latestScoreMap.put(score.Contact__c, score);
 
            }else{
 
                Enrollment_Score__c existing =
                    latestScoreMap.get(score.Contact__c);
 
                if(existing.Scored_At__c == null){
 
                    latestScoreMap.put(score.Contact__c, score);
 
                }else if(score.Scored_At__c != null &&
                         score.Scored_At__c.getTime() >
                         existing.Scored_At__c.getTime()){
 
                    latestScoreMap.put(score.Contact__c, score);
 
                } 
            } 
        }
 
        if(latestScoreMap.isEmpty()){
            return;
        }
        Map<Id, Contact> contactMap =
            new Map<Id, Contact>(
                [
                    SELECT Id,
                           Enrollment_Priority__c
                    FROM Contact
                    WHERE Id IN :latestScoreMap.keySet()
                ]
            );
 
        List<Contact> contactsToUpdate =
            new List<Contact>();
 
        for(Id contactId : latestScoreMap.keySet()){
 
            Contact con = contactMap.get(contactId);
 
            if(con == null){
                continue;
            }
 
            Integer score = Integer.valueOf(latestScoreMap.get(contactId).Score__c); 
            String priority;
 
            if(score >= 75){ 
                priority = 'Hot'; 
            }else if(score >= 40){ 
                priority = 'Warm'; 
            }else{ 
                priority = 'Cold'; 
            }
            if(con.Enrollment_Priority__c != priority){
 
                con.Enrollment_Priority__c = priority; 
                contactsToUpdate.add(con);
 
            } 
        }
 
        if(!contactsToUpdate.isEmpty()){ 
            update contactsToUpdate; 
        } 
    } 
}