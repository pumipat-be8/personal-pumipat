@isTest
private class OpportunityLead_Test {
	public static String accountNameAH = 'accountNameAH';

	@testSetup static void setupUser(){
		Mockup_Test mt = new Mockup_Test().setUpTest();

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
	}

	static testMethod void testAddOppLead(){
		String ahRcCode = '99996';
		String ahName = 'Name4';
		String ahEmpId = '2342411';

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){

			Account testAcc = [SELECT Id FROM Account WHERE Name = :OpportunityLead_Test.accountNameAH LIMIT 1];

			Opportunity opp = Mockup_Test.newOpportunity(testAcc.Id, 'Tester1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
			insert opp;		

			Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(), 'TestCampaign', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.SME_EVENT, GlobalConstants.LEAD_FOR_SALES);
            insert camp;

            Campaign camp2 = Mockup_Test.newCampaign(UserInfo.getUserId(), 'TestCampaign2', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.SME_EVENT, GlobalConstants.LEAD_FOR_SALES);
            insert camp2;

			Target_List__c target = new Target_List__c();
			target.Lead_Campaign__c = camp.Id;
			target.CIS_ID_Prospect_Name__c = testAcc.Id;
			insert target;

			Target_List__c target2 = new Target_List__c();
			target2.Lead_Campaign__c = camp2.Id;
			target2.CIS_ID_Prospect_Name__c = testAcc.Id;
			insert target2;

			//Call_Report__c callReport = new Call_Report__c();
			//callReport.CIS_ID__c = testAcc.Id;
			//insert callReport;

			//Call_Report_Lead__c callReportLead = new Call_Report_Lead__c();
			//callReportLead.Call_Plan_Call_Report__c = callReport.Id;
			//callReportLead.Target_List__c = target.Id;
			//insert callReportLead;

			Opportunity_Lead__c oppLead = new Opportunity_Lead__c();
			oppLead.Opportunity__c = opp.Id;
			oppLead.Target_List__c = target.Id;

			Opportunity_Lead__c oppLead2 = new Opportunity_Lead__c();
			oppLead2.Opportunity__c = opp.Id;
			oppLead2.Target_List__c = target2.Id;

			Test.startTest();
				try {
					insert oppLead2;
					System.assertNotEquals(null, [SELECT Id FROM Opportunity_Lead__c WHERE Id = :oppLead2.Id LIMIT 1]);
				} catch (Exception e) {
					Boolean expectedExceptionThrown =  e.getMessage().contains('Opportunity Lead need to be the same name') ? true : false;
					//System.assertEquals(expectedExceptionThrown, true);
				}				
				insert oppLead;
				System.assertNotEquals(null, [SELECT Id FROM Opportunity_Lead__c WHERE Id = :oppLead.Id LIMIT 1]);
			Test.stopTest();
			
		}

	}

	static testMethod void testOppLead(){
		String ahRcCode = '99996';
		String ahName = 'Name4';
		String ahEmpId = '2342411';

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){

			Account testAcc = [SELECT Id FROM Account WHERE Name = :OpportunityLead_Test.accountNameAH LIMIT 1];

			Opportunity opp = Mockup_Test.newOpportunity(testAcc.Id, 'Tester1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
			insert opp;		

			Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(), 'TestCampaign', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.SME_EVENT, GlobalConstants.LEAD_FOR_SALES);
            insert camp;

            Campaign camp2 = Mockup_Test.newCampaign(UserInfo.getUserId(), 'TestCampaign2', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.SME_EVENT, GlobalConstants.LEAD_FOR_SALES);
            insert camp2;

			Target_List__c target = new Target_List__c();
			target.Lead_Campaign__c = camp.Id;
			target.CIS_ID_Prospect_Name__c = testAcc.Id;
			insert target;

			Target_List__c target2 = new Target_List__c();
			target2.Lead_Campaign__c = camp2.Id;
			target2.CIS_ID_Prospect_Name__c = testAcc.Id;
			insert target2;

			Call_Report__c callReport = new Call_Report__c();
			callReport.CIS_ID__c = testAcc.Id;
			insert callReport;

			Call_Report_Lead__c callReportLead = new Call_Report_Lead__c();
			callReportLead.Call_Plan_Call_Report__c = callReport.Id;
			callReportLead.Target_List__c = target.Id;
			insert callReportLead;

			Opportunity_Lead__c oppLead = new Opportunity_Lead__c();
			oppLead.Opportunity__c = opp.Id;
			oppLead.Target_List__c = target.Id;

			Opportunity_Lead__c oppLead2 = new Opportunity_Lead__c();
			oppLead2.Opportunity__c = opp.Id;
			oppLead2.Target_List__c = target2.Id;

			Test.startTest();
				try {
					insert oppLead2;
				} catch (Exception e) {
					Boolean expectedExceptionThrown =  e.getMessage().contains('Opportunity Lead need to be the same name') ? true : false;
					System.assertEquals(expectedExceptionThrown, true);
				}
				
				insert oppLead;
				System.assertNotEquals(null, [SELECT Id FROM Opportunity_Lead__c]);
			Test.stopTest();
			
		}

	}
	
}