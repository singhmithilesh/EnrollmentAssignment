public with sharing class EnrollmentScoreService {
 
    public static EnrollmentScoreWrapper.ResponseWrapper processScores(
        EnrollmentScoreWrapper.RequestWrapper requestWrapper
    ) {
 
        EnrollmentScoreWrapper.ResponseWrapper response =
            new EnrollmentScoreWrapper.ResponseWrapper();
 
        if (requestWrapper == null ||
            requestWrapper.scores == null ||
            requestWrapper.scores.isEmpty()) {
 
            return response;
        }
 
        Set<String> emailSet = new Set<String>();
 
        for (EnrollmentScoreWrapper.ScoreRequest req : requestWrapper.scores) {
            if (String.isNotBlank(req.contactEmail)) {
                emailSet.add(req.contactEmail.trim().toLowerCase());
            }
        }
 
        Map<String, Contact> contactMap = new Map<String, Contact>();
 
        if (!emailSet.isEmpty()) {
            for (Contact con : [
                SELECT Id, Email
                FROM Contact
                WHERE Email IN :emailSet
            ]) {
                contactMap.put(con.Email.toLowerCase(), con);
            }
        }
 
        List<Enrollment_Score__c> scoreRecords = new List<Enrollment_Score__c>();
 
        List<EnrollmentScoreWrapper.ScoreResponse> successResponses =
            new List<EnrollmentScoreWrapper.ScoreResponse>();
 
        for (EnrollmentScoreWrapper.ScoreRequest req : requestWrapper.scores) {
 
            EnrollmentScoreWrapper.ScoreResponse res =
                new EnrollmentScoreWrapper.ScoreResponse();
 
            res.contactEmail = req.contactEmail;
            if (String.isBlank(req.contactEmail)) {
                res.success = false;
                res.message = 'Contact email is required.';
                response.results.add(res);
                continue;
            }
 
            Contact con = contactMap.get(req.contactEmail.trim().toLowerCase());
 
            if (con == null) {
                res.success = false;
                res.message = 'Contact not found.';
                response.results.add(res);
                continue;
            }
 
            Enrollment_Score__c score = new Enrollment_Score__c();
 
            score.Contact__c = con.Id;
            score.Score__c = req.score;
            score.Recommended_Action__c = req.recommendedAction;
            score.Source_System__c = req.sourceSystem;
            score.Scored_At__c = req.scoredAt;
 
            scoreRecords.add(score);
            successResponses.add(res);
            response.results.add(res);
        }
        if (!scoreRecords.isEmpty()) {
 
            Database.SaveResult[] saveResults =
                Database.insert(scoreRecords, false);
 
            for (Integer i = 0; i < saveResults.size(); i++) {
 
                Database.SaveResult sr = saveResults[i];
 
                EnrollmentScoreWrapper.ScoreResponse res =
                    successResponses[i];
 
                if (sr.isSuccess()) {
 
                    res.success = true;
                    res.message = 'Enrollment Score created successfully.';
                    res.enrollmentScoreId = sr.getId();
 
                } else {
 
                    res.success = false;
 
                    String errorMsg = '';
 
                    for (Database.Error err : sr.getErrors()) {
                        errorMsg += err.getMessage() + ' ';
                    }
 
                    res.message = errorMsg.trim();
                }
            }
        }
 
        return response;
    }
}