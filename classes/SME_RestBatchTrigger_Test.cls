/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   A test class for SME_RestBatchTrigger

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015  Charnun.t           First Create
------------------------------------------------------------*/
@isTest
private class SME_RestBatchTrigger_Test
{
    static testMethod void testRestBatchTriggerHRIS()
    {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String returnString = '{\"jsonResponse\":{\"Batch_Name\" : \"HRIS\"}}';
        Blob blobBody = Blob.valueOf(returnString);
   
        req.requestURI = '/services/apexrest/BatchTrigger';  
        req.httpMethod = 'POST';
        req.requestBody = blobBody;
        System.debug('req:'+req);
        RestResponseModel.batchTrigger_model batchTriggerType = new RestResponseModel.batchTrigger_model();
        batchTriggerType.batch_Name = 'HRIS';
        SME_RestBatchTrigger.doBatchTrigger(batchTriggerType);

        Test.stopTest();
        System.debug('res:'+res);
    }

    static testMethod void testRestBatchTriggerConvertProspect()
    {
        Test.startTest();
        String PROSPECT = 'SME-Prospect';
        String prospectRecordTypeId = String.valueOf(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(PROSPECT).GetRecordTypeId());

        Account accProspect = new Account();
        accProspect.Name = 'testBatch';
        accProspect.CIS__c = '123456';
        accProspect.RecordTypeId = prospectRecordTypeId;
        insert accProspect;

        Account accProspect2 = new Account();
        accProspect2.Name = 'testBatch2';
        accProspect2.CIS__c = 'String';
        accProspect2.RecordTypeId = prospectRecordTypeId;
        accProspect2.Birthdate_Registration_Date__c = System.today() - 600;
        accProspect2.Identification_No_Prospect__c = '2312312425553';

        insert accProspect2;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String returnString = '{\"jsonResponse\":{\"Batch_Name\" : \"convertProspect\"}}';
        Blob blobBody = Blob.valueOf(returnString);
   
        req.requestURI = '/services/apexrest/BatchTrigger';  
        req.httpMethod = 'POST';
        req.requestBody = blobBody;
        System.debug('req:'+req);
        RestResponseModel.batchTrigger_model batchTriggerType = new RestResponseModel.batchTrigger_model();
        batchTriggerType.batch_Name = 'convertProspect';
        SME_RestBatchTrigger.doBatchTrigger(batchTriggerType);

        Test.stopTest();
        System.debug('res:'+res);
    }
}