public with sharing class EnrollmentScoreController {
    public class EnrollmentScoreDTO {
 
        @AuraEnabled
        public Integer score;
 
        @AuraEnabled
        public String recommendedAction;
 
        @AuraEnabled
        public String sourceSystem;
 
        @AuraEnabled
        public Datetime scoredAt;
 
        @AuraEnabled
        public String priority;
 
        @AuraEnabled
        public Boolean hasScore;
 
    }
 
    @AuraEnabled(cacheable=true)
    public static EnrollmentScoreDTO getLatestEnrollmentScore(Id contactId){
 
        EnrollmentScoreDTO dto = new EnrollmentScoreDTO(); 
        dto.hasScore = false; 
        if(contactId == null){
            return dto;
        }
 
        List<Enrollment_Score__c> scores = [
            SELECT Id,
                   Score__c,
                   Recommended_Action__c,
                   Source_System__c,
                   Scored_At__c
            FROM Enrollment_Score__c
            WHERE Contact__c = :contactId
            ORDER BY Scored_At__c DESC LIMIT 1 
        ];
 
        if(scores.isEmpty()){
            return dto;
        }
 
        SObjectAccessDecision decision =
            Security.stripInaccessible(
                AccessType.READABLE,
                scores
            );
 
        Enrollment_Score__c latest =
            (Enrollment_Score__c)decision.getRecords()[0];
 
        dto.score = Integer.valueOf(latest.Score__c);
        dto.recommendedAction = latest.Recommended_Action__c;
        dto.sourceSystem = latest.Source_System__c;
        dto.scoredAt = latest.Scored_At__c;
        dto.hasScore = true;
 
        if(dto.score >= 75){ 
            dto.priority = 'Hot'; 
        }
        else if(dto.score >= 40){ 
            dto.priority = 'Warm'; 
        }
        else{ 
            dto.priority = 'Cold'; 
        } 
        return dto; 
    }
 
}