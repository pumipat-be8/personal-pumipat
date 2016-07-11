@isTest
private class AssociatedCustomerTrigger_Test {
	public static final String accountNameTM = 'accountNameTM';
	public static final String accountNameRM = 'accountNameRM';

	@testSetup static void setupAccount(){
		Mockup_Test mt = new Mockup_Test().setUpTestAdmin().setUpTestWithExtension();

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.PORT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
	}

	@isTest static void testInsertAssociatedCustomerRecordTypeInterestedAndBowwerTypeEqualCoBowwerThenInsertCallReportInterest() {
		Id recordType = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Associated_Customer__c','Interested');
		Account tmAccount = [SELECT Id FROM Account WHERE Name = :accountNameTM];
		Account rmAccount = [SELECT Id FROM Account WHERE Name = :accountNameRM];

		Call_Report__c callReport = new Call_Report__c(
			CIS_ID__c = tmAccount.Id
		);
		insert callReport;

		Associated_Customer__c assoCus = new Associated_Customer__c(
			RecordTypeId = recordType,
			Associated_Customer_Type__c = 'Interested',
			Borrower_Type__c = 'Co Borrower',
			Call_Plan_Call_Report__c = callReport.Id,
			Customer__c = rmAccount.Id
		);

		Test.startTest();
			insert assoCus;
		Test.stopTest();

		Associated_Customer__c assoCusResult = [SELECT Id,Secondary_Call_Plan_Call_Report__c FROM Associated_Customer__c WHERE Id = :assoCus.Id];
		Call_Report__c callReportResult = [SELECT Id,Offer_Interest__c FROM Call_Report__c WHERE CIS_ID__c = :rmAccount.Id];

		System.assertNotEquals(null,callReportResult.Id);
		System.assertEquals('Interest and can apply',callReportResult.Offer_Interest__c);
		
		System.assertEquals(assoCusResult.Secondary_Call_Plan_Call_Report__c,callReportResult.Id);
	}
	
	@isTest static void testInsertAssociatedCustomerRecordTypeNotInterestedAndBowwerTypeEqualCoBowwerThenInsertCallReportNotInterest() {
		Id recordType = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Associated_Customer__c','Not_Interested');
		Account tmAccount = [SELECT Id FROM Account WHERE Name = :accountNameTM];
		Account rmAccount = [SELECT Id FROM Account WHERE Name = :accountNameRM];

		Call_Report__c callReport = new Call_Report__c(
			CIS_ID__c = tmAccount.Id
		);
		insert callReport;

		Associated_Customer__c assoCus = new Associated_Customer__c(
			RecordTypeId = recordType,
			Associated_Customer_Type__c = 'Not Interest',
			Borrower_Type__c = 'Co Borrower',
			Call_Plan_Call_Report__c = callReport.Id,
			Customer__c = rmAccount.Id
		);

		Test.startTest();
			insert assoCus;
		Test.stopTest();

		Associated_Customer__c assoCusResult = [SELECT Id,Secondary_Call_Plan_Call_Report__c FROM Associated_Customer__c WHERE Id = :assoCus.Id];
		Call_Report__c callReportResult = [SELECT Id,Offer_Interest__c FROM Call_Report__c WHERE CIS_ID__c = :rmAccount.Id];

		System.assertNotEquals(null,callReportResult.Id);
		System.assertEquals('Not interest',callReportResult.Offer_Interest__c);
		
		System.assertEquals(assoCusResult.Secondary_Call_Plan_Call_Report__c,callReportResult.Id);
	}
	
}