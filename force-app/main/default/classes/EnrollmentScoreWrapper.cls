public with sharing class EnrollmentScoreWrapper {
    public class RequestWrapper {
        public List<ScoreRequest> scores;
    }
    public class ScoreRequest {
 
        public String contactEmail; 
        public Integer score; 
        public String recommendedAction; 
        public String sourceSystem; 
        public Datetime scoredAt; 
    }
    public class ResponseWrapper {
 
        public List<ScoreResponse> results = new List<ScoreResponse>();
 
    }
    public class ScoreResponse { 
        public String contactEmail; 
        public Boolean success; 
        public String message; 
        public Id enrollmentScoreId;
 
    } 
}