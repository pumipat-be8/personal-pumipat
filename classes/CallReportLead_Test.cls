@isTest
private class CallReportLead_Test {
	public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';

	@testSetup static void setupAccount(){
		Mockup_Test mt = new Mockup_Test().setUpTest();

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
	}

	@isTest static void testAddTargetList() {
		Boolean expectedTargetListFlag = true;

		Account targetAccount = [SELECT Id FROM Account WHERE Name = :CallReportLead_Test.accountNameRM LIMIT 1];

		Campaign cm = new Campaign();
		cm.Lead_Campaign_Event_Code__c = 'TestCampaign';
		cm.Type__c = GlobalConstants.LEAD_TO_DO;
		cm.Name = 'TestCampaign';
		cm.IsActive = true;
		cm.Status = 'Active';
		cm.StartDate = System.Today() - 1;
		cm.EndDate = System.Today() + 1;
		cm.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName('SME- Lead / Campaign');
		insert cm;

		Target_List__c tl = new Target_List__c();
		tl.CIS_ID_Prospect_Name__c = targetAccount.Id;
		tl.Lead_Campaign__c = cm.Id;
		tl.Status__c = GlobalConstants.STATUS_NEW;
		insert tl;

		Call_Report__c callreportObj;
		callreportObj = new Call_Report__c(
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.NEW_CALL_PLAN_DEVNAME),
			CIS_ID__c = targetAccount.Id,
			Status__c = GlobalConstants.PLAN,
			Plan_Date__c = System.Today()
		);

		Test.startTest();
			insert callreportObj;
		Test.stopTest();

		Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
		resultLead = [SELECT Id, Call_Plan_Call_Report__c, Target_List__c, Target_List__r.In_Call_Plan__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callreportObj.Id LIMIT 1];
		
		System.assert(resultLead != null);
		System.assertEquals(callreportObj.Id, resultLead.Call_Plan_Call_Report__c);
		System.assertEquals(tl.Id, resultLead.Target_List__c);
		System.assertEquals(expectedTargetListFlag, resultLead.Target_List__r.In_Call_Plan__c);
	}

	@isTest static void testDeleteTargetList() {
		Boolean expectedTargetListFlag = false;

		Account targetAccount = [SELECT Id FROM Account WHERE Name = :CallReportLead_Test.accountNameRM LIMIT 1];

		Campaign cm = new Campaign();
		cm.Lead_Campaign_Event_Code__c = 'TestCampaign';
		cm.Type__c = GlobalConstants.LEAD_TO_DO;
		cm.Name = 'TestCampaign';
		cm.IsActive = true;
		cm.Status = 'Active';
		cm.StartDate = System.Today() - 1;
		cm.EndDate = System.Today() + 1;
		cm.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName('SME- Lead / Campaign');
		insert cm;

		Target_List__c tl = new Target_List__c();
		tl.CIS_ID_Prospect_Name__c = targetAccount.Id;
		tl.Lead_Campaign__c = cm.Id;
		tl.Status__c = GlobalConstants.STATUS_NEW;
		insert tl;

		Call_Report__c callreportObj;
		callreportObj = new Call_Report__c(
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.NEW_CALL_PLAN_DEVNAME),
			CIS_ID__c = targetAccount.Id,
			Status__c = GlobalConstants.PLAN,
			Plan_Date__c = System.Today()
		);

		Test.startTest();
			insert callreportObj;

			Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
			resultLead = [SELECT Id, Call_Plan_Call_Report__c, Target_List__c, Target_List__r.In_Call_Plan__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callreportObj.Id LIMIT 1];
			
			System.assert(resultLead != null);
			System.assertEquals(callreportObj.Id, resultLead.Call_Plan_Call_Report__c);
			System.assertEquals(tl.Id, resultLead.Target_List__c);
			System.assertEquals(true, resultLead.Target_List__r.In_Call_Plan__c);
		
			delete resultLead;
		Test.stopTest();

		Target_List__c finalTarget = [SELECT Id, In_Call_Plan__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :targetAccount.Id];

		System.assertEquals(expectedTargetListFlag, finalTarget.In_Call_Plan__c);
	}

	@isTest static void testDeleteTargetList2() {
		Boolean expectedTargetListFlag = true;

		Account targetAccount = [SELECT Id FROM Account WHERE Name = :CallReportLead_Test.accountNameRM LIMIT 1];

		Campaign cm = new Campaign();
		cm.Lead_Campaign_Event_Code__c = 'TestCampaign';
		cm.Type__c = GlobalConstants.LEAD_FOR_SALES;
		cm.Sub_Type__c = 'Strong Formula';
		cm.Name = 'TestCampaign';
		cm.IsActive = true;
		cm.Status = 'Active';
		cm.StartDate = System.Today() - 1;
		cm.EndDate = System.Today() + 1;
		cm.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName('SME- Lead / Campaign');
		insert cm;

		Target_List__c tl = new Target_List__c();
		tl.CIS_ID_Prospect_Name__c = targetAccount.Id;
		tl.Lead_Campaign__c = cm.Id;
		tl.Status__c = GlobalConstants.STATUS_NEW;
		insert tl;

		Call_Report__c callreportObj = new Call_Report__c(
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.NEW_CALL_PLAN_DEVNAME),
			CIS_ID__c = targetAccount.Id,
			Status__c = GlobalConstants.PLAN,
			Plan_Date__c = System.Today()
		);

		Call_Report__c callreportObj2 = new Call_Report__c(
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.NEW_CALL_PLAN_DEVNAME),
			CIS_ID__c = targetAccount.Id,
			Status__c = GlobalConstants.PLAN,
			Plan_Date__c = System.Today()
		);
		insert callreportObj;
		insert callreportObj2;

		Call_Report_Lead__c resultLead = [SELECT Id, Call_Plan_Call_Report__c, Target_List__c, Target_List__r.In_Call_Plan__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callreportObj.Id LIMIT 1];
		Call_Report_Lead__c resultLead2 = [SELECT Id, Call_Plan_Call_Report__c, Target_List__c, Target_List__r.In_Call_Plan__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callreportObj2.Id LIMIT 1];

		System.assertEquals(callreportObj.Id, resultLead.Call_Plan_Call_Report__c);
		System.assertEquals(tl.Id, resultLead.Target_List__c);
		System.assertEquals(true, resultLead.Target_List__r.In_Call_Plan__c);
	
		System.assertEquals(callreportObj2.Id, resultLead2.Call_Plan_Call_Report__c);
		System.assertEquals(tl.Id, resultLead2.Target_List__c);
		System.assertEquals(true, resultLead2.Target_List__r.In_Call_Plan__c);


		Test.startTest();
			delete resultLead;
		Test.stopTest();

		Target_List__c finalTarget = [SELECT Id, In_Call_Plan__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :targetAccount.Id];

		System.assertEquals(expectedTargetListFlag, finalTarget.In_Call_Plan__c);
	}
	
	@isTest static void testUpdateTargetList() {
		Boolean expectedTargetListFlag = false;
		Boolean expectedTargetListFlag2 = true;

		Account targetAccount = [SELECT Id FROM Account WHERE Name = :CallReportLead_Test.accountNameRM LIMIT 1];

		Campaign cm = new Campaign();
		cm.Lead_Campaign_Event_Code__c = 'TestCampaign';
		cm.Type__c = GlobalConstants.LEAD_TO_DO;
		cm.Name = 'TestCampaign';
		cm.IsActive = true;
		cm.Status = 'Active';
		cm.StartDate = System.Today() - 1;
		cm.EndDate = System.Today() + 1;
		cm.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName('SME- Lead / Campaign');
		insert cm;

		Target_List__c tl = new Target_List__c();
		tl.CIS_ID_Prospect_Name__c = targetAccount.Id;
		tl.Lead_Campaign__c = cm.Id;
		tl.Status__c = GlobalConstants.STATUS_NEW;
		insert tl;

		Target_List__c tl2 = new Target_List__c();
		tl2.CIS_ID_Prospect_Name__c = targetAccount.Id;
		tl2.Lead_Campaign__c = cm.Id;
		tl2.Status__c = GlobalConstants.STATUS_NEW;
		insert tl2;

		Call_Report__c callreportObj;
		callreportObj = new Call_Report__c(
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.NEW_CALL_PLAN_DEVNAME),
			CIS_ID__c = targetAccount.Id,
			Status__c = GlobalConstants.PLAN,
			Plan_Date__c = System.Today()
		);

		insert callreportObj;

		Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
		resultLead = [SELECT Id, Call_Plan_Call_Report__c, Target_List__c, Target_List__r.In_Call_Plan__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callreportObj.Id LIMIT 1];
		
		System.assertEquals(callreportObj.Id, resultLead.Call_Plan_Call_Report__c);
		System.assertEquals(tl.Id, resultLead.Target_List__c);
		System.assertEquals(true, resultLead.Target_List__r.In_Call_Plan__c);

		Test.startTest();
			resultLead.Target_List__c = tl2.Id;
			update resultLead;
		Test.stopTest();

		Target_List__c finalTarget = [SELECT Id, In_Call_Plan__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :targetAccount.Id AND Id = :tl.Id];
		Target_List__c finalTarget2 = [SELECT Id, In_Call_Plan__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :targetAccount.Id AND Id = :tl2.Id];

		System.assertEquals(expectedTargetListFlag, finalTarget.In_Call_Plan__c);
		System.assertEquals(expectedTargetListFlag2, finalTarget2.In_Call_Plan__c);
	}

	@isTest static void testUpdateTargetList2() {
		Boolean expectedTargetListFlag = true;
		Boolean expectedTargetListFlag2 = true;

		Account targetAccount = [SELECT Id FROM Account WHERE Name = :CallReportLead_Test.accountNameRM LIMIT 1];

		Campaign cm = new Campaign();
		cm.Lead_Campaign_Event_Code__c = 'TestCampaign';
		cm.Type__c = GlobalConstants.LEAD_FOR_SALES;
		cm.Sub_Type__c = 'Strong Formula';
		cm.Name = 'TestCampaign';
		cm.IsActive = true;
		cm.Status = 'Active';
		cm.StartDate = System.Today() - 1;
		cm.EndDate = System.Today() + 1;
		cm.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName('SME- Lead / Campaign');
		insert cm;

		Target_List__c tl = new Target_List__c();
		tl.CIS_ID_Prospect_Name__c = targetAccount.Id;
		tl.Lead_Campaign__c = cm.Id;
		tl.Status__c = GlobalConstants.STATUS_NEW;
		insert tl;

		Target_List__c tl2 = new Target_List__c();
		tl2.CIS_ID_Prospect_Name__c = targetAccount.Id;
		tl2.Lead_Campaign__c = cm.Id;
		tl2.Status__c = GlobalConstants.STATUS_NEW;
		insert tl2;

		Call_Report__c callreportObj = new Call_Report__c(
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.NEW_CALL_PLAN_DEVNAME),
			CIS_ID__c = targetAccount.Id,
			Status__c = GlobalConstants.PLAN,
			Plan_Date__c = System.Today()
		);

		Call_Report__c callreportObj2 = new Call_Report__c(
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.NEW_CALL_PLAN_DEVNAME),
			CIS_ID__c = targetAccount.Id,
			Status__c = GlobalConstants.PLAN,
			Plan_Date__c = System.Today()
		);
		insert callreportObj;
		insert callreportObj2;

		Call_Report_Lead__c resultLead = [SELECT Id, Call_Plan_Call_Report__c, Target_List__c, Target_List__r.In_Call_Plan__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callreportObj.Id LIMIT 1];
		Call_Report_Lead__c resultLead2 = [SELECT Id, Call_Plan_Call_Report__c, Target_List__c, Target_List__r.In_Call_Plan__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callreportObj2.Id LIMIT 1];

		System.assertEquals(callreportObj.Id, resultLead.Call_Plan_Call_Report__c);
		System.assertEquals(tl.Id, resultLead.Target_List__c);
		System.assertEquals(true, resultLead.Target_List__r.In_Call_Plan__c);
	
		System.assertEquals(callreportObj2.Id, resultLead2.Call_Plan_Call_Report__c);
		System.assertEquals(tl.Id, resultLead2.Target_List__c);
		System.assertEquals(true, resultLead2.Target_List__r.In_Call_Plan__c);

		Test.startTest();
			resultLead.Target_List__c = tl2.Id;
			update resultLead;
		Test.stopTest();

		Target_List__c finalTarget = [SELECT Id, In_Call_Plan__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :targetAccount.Id AND Id = :tl.Id];
		Target_List__c finalTarget2 = [SELECT Id, In_Call_Plan__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :targetAccount.Id AND Id = :tl2.Id];

		System.assertEquals(expectedTargetListFlag, finalTarget.In_Call_Plan__c);
		System.assertEquals(expectedTargetListFlag2, finalTarget2.In_Call_Plan__c);
	}

	@isTest static void testUpdateTargetList3() {
		Boolean expectedTargetListFlag = false;
		Boolean expectedTargetListFlag2 = true;

		Account targetAccount = [SELECT Id FROM Account WHERE Name = :CallReportLead_Test.accountNameRM LIMIT 1];

		Campaign cm = new Campaign();
		cm.Lead_Campaign_Event_Code__c = 'TestCampaign';
		cm.Type__c = GlobalConstants.LEAD_FOR_SALES;
		cm.Name = 'TestCampaign';
		cm.IsActive = true;
		cm.Status = 'Active';
		cm.StartDate = System.Today() - 1;
		cm.EndDate = System.Today() + 1;
		cm.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName('SME- Lead / Campaign');
		insert cm;

		Target_List__c tl = new Target_List__c();
		tl.CIS_ID_Prospect_Name__c = targetAccount.Id;
		tl.Lead_Campaign__c = cm.Id;
		tl.Status__c = GlobalConstants.STATUS_NEW;
		insert tl;

		Target_List__c tl2 = new Target_List__c();
		tl2.CIS_ID_Prospect_Name__c = targetAccount.Id;
		tl2.Lead_Campaign__c = cm.Id;
		tl2.Status__c = GlobalConstants.STATUS_NEW;
		insert tl2;

		Call_Report__c callreportObj;
		callreportObj = new Call_Report__c(
			RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.NEW_CALL_PLAN_DEVNAME),
			CIS_ID__c = targetAccount.Id,
			Status__c = GlobalConstants.PLAN,
			Plan_Date__c = System.Today(),
			Offer_Credit_Product__c = true,
	        Offer_Interest__c = GlobalConstants.INTEREST_AND_CAN_APPLY,
	        Expected_Credit_Amount__c = 50000
		);

		insert callreportObj;

		Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
		resultLead = [SELECT Id, Call_Plan_Call_Report__c, Target_List__c, Target_List__r.In_Call_Plan__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callreportObj.Id LIMIT 1];
		
		System.assertEquals(callreportObj.Id, resultLead.Call_Plan_Call_Report__c);
		System.assertEquals(tl.Id, resultLead.Target_List__c);
		System.assertEquals(true, resultLead.Target_List__r.In_Call_Plan__c);

		Test.startTest();
			resultLead.Target_List__c = tl2.Id;
			update resultLead;
		Test.stopTest();

		Target_List__c finalTarget = [SELECT Id, In_Call_Plan__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :targetAccount.Id AND Id = :tl.Id];
		Target_List__c finalTarget2 = [SELECT Id, In_Call_Plan__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :targetAccount.Id AND Id = :tl2.Id];

		System.assertEquals(expectedTargetListFlag, finalTarget.In_Call_Plan__c);
		System.assertEquals(expectedTargetListFlag2, finalTarget2.In_Call_Plan__c);
	}
}