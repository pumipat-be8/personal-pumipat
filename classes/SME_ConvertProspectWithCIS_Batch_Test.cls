@isTest
private class SME_ConvertProspectWithCIS_Batch_Test {
	
	@testSetup static void setupTestClass(){
		Mockup_Test mt = new Mockup_Test().setUpTestOnlyAdmin();
	}	

	@isTest static void testBatch(){
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

			Database.executeBatch(new SME_ConvertProspectWithCIS_Batch());
		Test.stopTest();
	}
	
}