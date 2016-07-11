@isTest
private class SetupAll_Controller_Test {
	public static String accountNameTM = 'tmCreatedAccountName';
	@testSetup static void setupAccount(){
        Mockup_Test mt = new Mockup_Test().setUpTest();
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
	        mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
	    }
	}    

	static testMethod void assertTarget(){
		Integer expectedSetupAmount = 100;
		Date expectedDate = System.today()-2;
		String expectedStatus = 'Setup';

		User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :SetupAll_Controller_Test.accountNameTM LIMIT 1];
		Opportunity targetOp = new Opportunity();
		Opportunity_Product__c targetOpProduct = new Opportunity_Product__c();
		System.runAs(userTM){

			targetOp.AccountId = targetAccount.Id;
            targetOp.Name = 'TestOp';
			targetOp.StageName = 'Waiting for Credit Setup';
			targetOp.CloseDate = System.Today() + 1;
			targetOp.Submission_Channel__c   = GlobalConstants.CMAS;
            targetOp.Credit_Model__c = 'DLA';
            targetOp.Submit_Issue__c = 'New Credit';
            targetOp.Amount      = 10;
            targetOp.CloseDate   = System.today() + 1;
            targetOp.Tentative_Application_Submit_Date__c = System.today() + 7;

            insert targetOp;

            targetOpProduct.Opportunity__c = targetOp.Id;
            insert targetOpProduct;

            ApexPages.currentPage().getParameters().put('opid',targetOp.Id);

            SetupAll_Controller sc = new SetupAll_Controller();
            sc = new SetupAll_Controller(new ApexPages.StandardController(targetOpProduct));

            sc.setupall.Setup_Date__c = expectedDate;
			sc.setupall.Setup_Amount__c = expectedSetupAmount;
			sc.setupall.Status__c = expectedStatus;

            Test.startTest();
            	sc.savingSetupall();
            Test.stopTest();

            Opportunity_Product__c resultOpProduct = [SELECT Id,Setup_Date__c,Setup_Amount__c,Status__c FROM Opportunity_Product__c WHERE Opportunity__c = :targetOp.Id LIMIT 1];

            System.assertEquals(expectedDate,resultOpProduct.Setup_Date__c);
			System.assertEquals(expectedSetupAmount,resultOpProduct.Setup_Amount__c);
			System.assertEquals(expectedStatus,resultOpProduct.Status__c);
        }
	}
}