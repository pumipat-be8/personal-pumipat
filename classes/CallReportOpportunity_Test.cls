/**
* @author komsan.wi@beryl8.com
* @30/09/2015 created new
*/
@isTest
private class CallReportOpportunity_Test {
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';
	@testSetup static void setupAccount(){
		Mockup_Test mt = new Mockup_Test().setUpTest();

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        /*System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }*/
	}
	static testMethod void defaultLeadToOpportunity(){
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
			Account testAcc = [SELECT Id FROM Account WHERE Name = :CallReportOpportunity_Test.accountNameTM LIMIT 1];
			Opportunity opp1 = Mockup_Test.newOpportunity(testAcc.Id, 'Tester1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
			insert opp1;		

			Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(), 'TestCampaign', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.SME_EVENT, GlobalConstants.LEAD_FOR_SALES);
            insert camp;

			Target_List__c target = new Target_List__c();
			target.Lead_Campaign__c = camp.Id;
			target.CIS_ID_Prospect_Name__c = testAcc.Id;
			insert target;

			Call_Report__c callReport = new Call_Report__c();
			callReport.Plan_Amount__c = 50000;
			callReport.CIS_ID__c = testAcc.Id;
			insert callReport;

			Call_Report_Lead__c callReportLead = new Call_Report_Lead__c();
			callReportLead.Call_Plan_Call_Report__c = callReport.Id;
			callReportLead.Target_List__c = target.Id;
			insert callReportLead;

			Call_Report_Opportunity__c callReportOpp = new Call_Report_Opportunity__c();
			callReportOpp.Call_Plan_Call_Report__c = callReport.Id;
			callReportOpp.Opportunity_Name__c = opp1.Id;

			Test.startTest();
				insert callReportOpp;
			Test.stopTest();

			Opportunity_Lead__c oppLead = [SELECT Target_List__c FROM Opportunity_Lead__c WHERE Opportunity__c = :callReportOpp.Opportunity_Name__c LIMIT 1];
			System.assertEquals(target.Id, oppLead.Target_List__c);
		}
	}
}