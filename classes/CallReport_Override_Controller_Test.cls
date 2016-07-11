@isTest
private class CallReport_Override_Controller_Test {
	
	public static String accountNameTM = 'tmCreatedAccountName';
	@testSetup static void setupAccount(){
        Mockup_Test mt = new Mockup_Test().setUpTest();
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
	        mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
	    }
	}    

	static testMethod void testRedirectToCallReport(){
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :CallReport_Override_Controller_Test.accountNameTM LIMIT 1];

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            Contact con = new Contact();
			con.LastName = 'lastname';
			con.Contact_Firstname__c = 'Firstname';
			con.Birthdate__c = '11/11/2550';
			con.AccountId = targetAccount.Id;
			con.Phone_Number__c = '023450789';
			insert con;

            Call_Report__c callreportObj = new Call_Report__c(
				Collect_Documents__c = true,
				CIS_ID__c = targetAccount.Id,
				Status__c = GlobalConstants.PLAN,
				Plan_Date__c = System.Today(),
				Contact__c = con.Id,
				RecordtypeId = [SELECT Id FROM RecordType WHERE SObjectType ='Call_Report__c' AND DeveloperName=:GlobalConstants.CALL_REPORT_NO_PLAN_DEVNAME][0].Id
			);

			insert callreportObj;
       		
       		CallReport_OverrideEdit_Controller controller = new CallReport_OverrideEdit_Controller(new ApexPages.StandardController(callreportObj));
        	controller.redirectToNewPage();
        	//String currentURL = ApexPages.currentPage().getUrl();
        }
    }

    static testMethod void testRedirectToCallPlan(){
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :CallReport_Override_Controller_Test.accountNameTM LIMIT 1];

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
			Call_Report__c callPlanObj;
			callPlanObj = new Call_Report__c(
				RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType ='Call_Report__c' AND DeveloperName=:GlobalConstants.NEW_CALL_PLAN_DEVNAME][0].Id,
				CIS_ID__c = targetAccount.Id,
				Status__c = GlobalConstants.PLAN,
				Plan_Date__c = System.Today(),
				Plan_Amount__c = 50000,
				Customer_Important_Note__c = 'expected'
			);
			insert callPlanObj;

			Test.startTest();
            	ApexPages.currentPage().getParameters().put('newid', callPlanObj.Id);
            	ApexPages.currentPage().getParameters().put('accountId', targetAccount.Id);
            	CallReport_OverrideEdit_Controller controller = new CallReport_OverrideEdit_Controller(new ApexPages.StandardController(callPlanObj));
            	controller.redirect();

            	//String currentURL = ApexPages.currentPage().getUrl();
            Test.stopTest();
        }
    }

    static testMethod void testRedirectToCallPlanListView(){
    	CallReport_OverrideEdit_Controller controller = new CallReport_OverrideEdit_Controller();
    	Test.startTest();
    	controller.redirectToListView();
    	Test.stopTest();
    }

    static testMethod void testCallPlanListViewRedirect(){
    	CallReport_OverrideListView_Controller controller = new CallReport_OverrideListView_Controller();
    	Test.startTest();
    	controller.redirectToListView();
    	Test.stopTest();
    }
	
}