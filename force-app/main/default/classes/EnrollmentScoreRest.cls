@RestResource(urlMapping='/enrollment-scores/*')
global with sharing class EnrollmentScoreRest {
 
    @HttpPost
    global static void receiveEnrollmentScores() {
 
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; 
        res.addHeader('Content-Type', 'application/json');
 
        try {
 
            if(req.requestBody == null) { 
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(
                    '{"message":"Request body cannot be empty."}'
                );
                return;
            }
            EnrollmentScoreWrapper.RequestWrapper requestWrapper =
                (EnrollmentScoreWrapper.RequestWrapper)
                JSON.deserialize(
                    req.requestBody.toString(),
                    EnrollmentScoreWrapper.RequestWrapper.class
                );
 
            if(requestWrapper == null ||
               requestWrapper.scores == null ||
               requestWrapper.scores.isEmpty()) {
 
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(
                    '{"message":"No enrollment scores were provided."}'
                );
                return;
            }
            EnrollmentScoreWrapper.ResponseWrapper responseWrapper =
                EnrollmentScoreService.processScores(requestWrapper);
 
            res.statusCode = 200;
            res.responseBody =
                Blob.valueOf(JSON.serializePretty(responseWrapper));
 
        }
        catch(JSONException ex) {
 
            res.statusCode = 400; 
            Map<String,Object> errorResponse =
                new Map<String,Object>(); 
            errorResponse.put('success', false);
            errorResponse.put('message', 'Invalid JSON payload.');
            errorResponse.put('error', ex.getMessage()); 
            res.responseBody =
                Blob.valueOf(JSON.serializePretty(errorResponse));
 
        }
        catch(Exception ex) {
 
            res.statusCode = 500; 
            Map<String,Object> errorResponse =
                new Map<String,Object>(); 
            errorResponse.put('success', false);
            errorResponse.put('message', 'Unexpected server error.');
            errorResponse.put('error', ex.getMessage()); 
            res.responseBody =
                Blob.valueOf(JSON.serializePretty(errorResponse));
 
        } 
    } 
}