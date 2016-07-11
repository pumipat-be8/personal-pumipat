@isTest
private class ValueChain_Controller_Test {
	public static String accountNameAH = 'accountNameAH';

	@testSetup static void setUpTest(){
		Mockup_Test mt = new Mockup_Test().setUpTest();

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
	}

	static testMethod void testStandard() {
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){

			Account testAcc = [SELECT Id FROM Account WHERE Name = :ValueChain_Controller_Test.accountNameAH LIMIT 1];
			testAcc.OwnerId = UserInfo.getUserId();
			update testAcc;
        	
			Test.startTest();
				Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign1', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.SME_EVENT, GlobalConstants.LEAD_FOR_SALES);
	            insert camp;

				Target_List__c target = new Target_List__c();
				target.Lead_Campaign__c = camp.Id;
				target.CIS_ID_Prospect_Name__c = testAcc.Id;
				insert target;

				ApexPages.StandardController stdController = new ApexPages.StandardController(target);

        		ApexPages.currentPage().getParameters().put('id',target.Id);
        		ValueChain_Controller ctrl = new ValueChain_Controller(stdController);
        		ctrl.savingtarget();

			Test.stopTest();
		}
	}

    static testMethod void testArray() {
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){

			Account testAcc = [SELECT Id FROM Account WHERE Name = :ValueChain_Controller_Test.accountNameAH LIMIT 1];
			testAcc.OwnerId = UserInfo.getUserId();
			update testAcc;
        	
			Test.startTest();
				Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(), 'Campaign1', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.SME_EVENT, GlobalConstants.LEAD_FOR_SALES);
	            insert camp;

				Target_List__c target = new Target_List__c();
				target.Lead_Campaign__c = camp.Id;
				target.CIS_ID_Prospect_Name__c = testAcc.Id;
				insert target;

        		ApexPages.currentPage().getParameters().put('valuelist',target.Id);

        		ValueChain_Controller ctrl = new ValueChain_Controller();
        		        		
        		ctrl.savingtarget();
			Test.stopTest();

			Target_List__c finalTarget = [SELECT Id, Status__c FROM Target_List__c WHERE Id = :target.Id];
			System.assertEquals('Registered', finalTarget.Status__c);
		}
	}
}