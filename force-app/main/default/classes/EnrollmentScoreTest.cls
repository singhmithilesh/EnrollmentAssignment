@IsTest
private class EnrollmentScoreTest {
 
    @testSetup
    static void setupData(){
 
        List<Contact> contacts = new List<Contact>();
 
        for(Integer i=1;i<=6;i++){
 
            contacts.add(new Contact(
                LastName='Student '+i,
                Email='student'+i+'@test.com'
            ));
 
        }
 
        insert contacts;
 
    }
 
    @IsTest
    static void testRestPositive(){
 
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
 
        req.requestUri='/services/apexrest/enrollment-scores/';
        req.httpMethod='POST';
 
        req.requestBody=Blob.valueOf(
        '{'+
            '"scores":['+
            '{'+
            '"contactEmail":"student1@test.com",'+
            '"score":90,'+
            '"recommendedAction":"Schedule Call",'+
            '"sourceSystem":"EDMO Bot v2",'+
            '"scoredAt":"2026-03-10T10:30:00Z"'+
            '}'+
            ']'+
        '}');
 
        RestContext.request=req;
        RestContext.response=res;
 
        Test.startTest();
        EnrollmentScoreRest.receiveEnrollmentScores();
        Test.stopTest();
 
        System.assertEquals(200,RestContext.response.statusCode);
 
        List<Enrollment_Score__c> scores=[
            SELECT Id,Score__c
            FROM Enrollment_Score__c
        ];
 
        System.assertEquals(1,scores.size());
        System.assertEquals(90,scores[0].Score__c);
 
    }
 
    @IsTest
    static void testRestContactNotFound(){
 
        RestRequest req=new RestRequest();
        RestResponse res=new RestResponse();
 
        req.requestUri='/services/apexrest/enrollment-scores/';
        req.httpMethod='POST';
 
        req.requestBody=Blob.valueOf(
        '{'+
            '"scores":['+
            '{'+
            '"contactEmail":"notfound@test.com",'+
            '"score":55,'+
            '"recommendedAction":"Send Info Pack",'+
            '"sourceSystem":"EDMO Bot v2",'+
            '"scoredAt":"2026-03-10T10:30:00Z"'+
            '}'+
            ']'+
        '}');
 
        RestContext.request=req;
        RestContext.response=res;
 
        Test.startTest();
        EnrollmentScoreRest.receiveEnrollmentScores();
        Test.stopTest();
 
        System.assertEquals(200,RestContext.response.statusCode);
 
        System.assertEquals(
            0,
            [SELECT COUNT() FROM Enrollment_Score__c]
        );
 
    }
 
    @IsTest
    static void testBulkAPI(){
 
        String body='{"scores":[';
 
        for(Integer i=1;i<=6;i++){
 
            body+='{';
            body+='"contactEmail":"student'+i+'@test.com",';
            body+='"score":'+(40+i)+',';
            body+='"recommendedAction":"Assign Counselor",';
            body+='"sourceSystem":"EDMO Bot v2",';
            body+='"scoredAt":"2026-03-10T10:30:00Z"';
            body+='}';
 
            if(i<6){
                body+=',';
            }
 
        }
 
        body+=']}';
 
        RestRequest req=new RestRequest();
        RestResponse res=new RestResponse();
 
        req.requestUri='/services/apexrest/enrollment-scores/';
        req.httpMethod='POST';
        req.requestBody=Blob.valueOf(body);
 
        RestContext.request=req;
        RestContext.response=res;
 
        Test.startTest();
        EnrollmentScoreRest.receiveEnrollmentScores();
        Test.stopTest();
 
        System.assertEquals(
            6,
            [SELECT COUNT() FROM Enrollment_Score__c]
        );
 
    }
 
    @IsTest
    static void testTriggerPriority(){
 
        Contact c=[
            SELECT Id
            FROM Contact
            WHERE Email='student1@test.com'
            LIMIT 1
        ];
 
        insert new Enrollment_Score__c(
            Contact__c=c.Id,
            Score__c=92,
            Recommended_Action__c='Schedule Call',
            Source_System__c='EDMO Bot v2',
            Scored_At__c=System.now()
        );
 
        Contact updated=[
            SELECT Enrollment_Priority__c
            FROM Contact
            WHERE Id=:c.Id
        ];
 
        System.assertEquals(
            'Hot',
            updated.Enrollment_Priority__c
        );
 
    }
 
    @IsTest
    static void testLatestScoreWins(){
 
        Contact c=[
            SELECT Id
            FROM Contact
            WHERE Email='student2@test.com'
            LIMIT 1
        ];
 
        insert new List<Enrollment_Score__c>{
 
            new Enrollment_Score__c(
                Contact__c=c.Id,
                Score__c=30,
                Recommended_Action__c='Send Info Pack',
                Source_System__c='EDMO',
                Scored_At__c=System.now().addMinutes(-10)
            ),
 
            new Enrollment_Score__c(
                Contact__c=c.Id,
                Score__c=95,
                Recommended_Action__c='Schedule Call',
                Source_System__c='EDMO',
                Scored_At__c=System.now()
            )
 
        };
 
        Contact updated=[
            SELECT Enrollment_Priority__c
            FROM Contact
            WHERE Id=:c.Id
        ];
 
        System.assertEquals(
            'Hot',
            updated.Enrollment_Priority__c
        );
 
    }
 
}