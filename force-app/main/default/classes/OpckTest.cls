@istest
public class OpckTest{
    @isTest
    public static void OpCkMasterDataControllertstPositive() {
        SingleRequestMock logindata = new SingleRequestMock(200,'SUCCESS','{"data":{"token":{"access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MDEyODc4MjQsIm5iZiI6MTYwMTI4NzgyNCwianRpIjoiZWQ3ZWEyOTYtNDEyMS00MTAyLTg5ZTYtYWFkZGQ4ZGYxNTg5IiwiZXhwIjoxNjAxMjg5NjI0LCJpZGVudGl0eSI6eyJhcHB1c2VyX2lkIjo4NzcsImFwcHJvbGVfaWQiOjEsImRlcGFydG1lbnRfY29kZSI6bnVsbCwiaXNfYWN0aXZlIjp0cnVlLCJkZXBhcnRtZW50X2lkIjpudWxsfSwiZnJlc2giOmZhbHNlLCJ0eXBlIjoiYWNjZXNzIn0.hXgIOxq2hFvFx_rrsBpql0VoWr1iqVMu1-cktHasGqY","expiry_token":1601289624,"refresh_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MDEyODc4MjQsIm5iZiI6MTYwMTI4NzgyNCwianRpIjoiYjk4YjM1ZTItOTAxOC00MjUxLWIzMWQtNTYyZmFiYjQzMTBkIiwiZXhwIjoxNjAzODc5ODI0LCJpZGVudGl0eSI6eyJhcHB1c2VyX2lkIjo4NzcsImFwcHJvbGVfaWQiOjEsImRlcGFydG1lbnRfY29kZSI6bnVsbCwiaXNfYWN0aXZlIjp0cnVlLCJkZXBhcnRtZW50X2lkIjpudWxsfSwidHlwZSI6InJlZnJlc2gifQ.pVmOXf3GQtSUA5VEj0kRQcFS8B5V7_PTkvUxrIiqccU"},"user":{"approle_id":1,"appuser_id":877,"department_code":null,"department_id":null,"is_active":true}}}',null);
        SingleRequestMock getBusDetails = new SingleRequestMock(200,'SUCCESS','{"url":"https://ecard-qa.s3.amazonaws.com/EcardRepository/InspectionRecords/ecard_B197631.pdf?AWSAccessKeyId=AKIAYVCUL7AQHMO4LPLN&Signature=eIbe4n8sIxpQQlz4BcgPmGcjv%2BE%3D&Expires=1658933919"}',null);
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put(System.Label.EcardAppendpoint+'api/sflogin',logindata);
        endpoint2TestResp.put(System.Label.EcardAppendpoint+'api/ecardbychassisno/',getBusDetails);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        OpCkMasterDataController.getBusDetails('B197631');
    }
    
    @isTest
    public static void OpCkMasterDataControllertstNegative() {
        SingleRequestMock logindata = new SingleRequestMock(200,'SUCCESS','{"data":{"token":{"access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MDEyODc4MjQsIm5iZiI6MTYwMTI4NzgyNCwianRpIjoiZWQ3ZWEyOTYtNDEyMS00MTAyLTg5ZTYtYWFkZGQ4ZGYxNTg5IiwiZXhwIjoxNjAxMjg5NjI0LCJpZGVudGl0eSI6eyJhcHB1c2VyX2lkIjo4NzcsImFwcHJvbGVfaWQiOjEsImRlcGFydG1lbnRfY29kZSI6bnVsbCwiaXNfYWN0aXZlIjp0cnVlLCJkZXBhcnRtZW50X2lkIjpudWxsfSwiZnJlc2giOmZhbHNlLCJ0eXBlIjoiYWNjZXNzIn0.hXgIOxq2hFvFx_rrsBpql0VoWr1iqVMu1-cktHasGqY","expiry_token":1601289624,"refresh_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MDEyODc4MjQsIm5iZiI6MTYwMTI4NzgyNCwianRpIjoiYjk4YjM1ZTItOTAxOC00MjUxLWIzMWQtNTYyZmFiYjQzMTBkIiwiZXhwIjoxNjAzODc5ODI0LCJpZGVudGl0eSI6eyJhcHB1c2VyX2lkIjo4NzcsImFwcHJvbGVfaWQiOjEsImRlcGFydG1lbnRfY29kZSI6bnVsbCwiaXNfYWN0aXZlIjp0cnVlLCJkZXBhcnRtZW50X2lkIjpudWxsfSwidHlwZSI6InJlZnJlc2gifQ.pVmOXf3GQtSUA5VEj0kRQcFS8B5V7_PTkvUxrIiqccU"},"user":{"approle_id":1,"appuser_id":877,"department_code":null,"department_id":null,"is_active":true}}}',null);
        SingleRequestMock getBusDetails = new SingleRequestMock(404,'ERROR','NOT FOUND',null);
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put(System.Label.EcardAppendpoint+'api/sflogin',logindata);
        endpoint2TestResp.put(System.Label.EcardAppendpoint+'api/ecardbychassisno/',getBusDetails);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        OpCkMasterDataController.getBusDetails('B197601');
    }

   
}