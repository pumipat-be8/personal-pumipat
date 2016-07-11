@isTest
private class Account_ReferOutInformation_Test {
	public static String accountName = 'referOutCreatedAccountName';
	public static String contactName = 'referOutCreatedContactName';
	public static String lastName = 'referOutCreatedLastName';
	public static String accountNameReq = 'accountNameReq';
	@testSetup static void setupUser(){
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountName,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
    }

	@isTest static void testInitNewData() {
		Boolean expectedInitailDisabledFlag = true;
		String expectedInitailProvince = ' - ';
		String expectedInitailTeam = ' - ';
		Customer_Ownership_Request__c cusOwnershipReq = new Customer_Ownership_Request__c();
        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReq));
        System.assertEquals(expectedInitailDisabledFlag,accountReferOutController.disabledFlag);
        System.assertEquals(expectedInitailProvince,accountReferOutController.selectedProvince);
        System.assertEquals(expectedInitailTeam,accountReferOutController.selectedTeam);
	}

	@isTest static void testInitEditData() {
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
        Boolean expectedInitailDisabledFlag = true;
		String expectedInitailProvince = ' - ';
		String expectedInitailTeam = ' - ';
		String expectedId;
		Customer_Ownership_Request__c cusOwnershipReq = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id);
		insert cusOwnershipReq;
        expectedId = cusOwnershipReq.id;
        ApexPages.currentPage().getParameters().put('cisID', cusOwnershipReq.Id);
        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReq));

        System.assertEquals(expectedInitailDisabledFlag,accountReferOutController.disabledFlag);
        System.assertEquals(expectedInitailProvince,accountReferOutController.selectedProvince);
        System.assertEquals(expectedInitailTeam,accountReferOutController.selectedTeam);
        System.assertEquals(expectedId,accountReferOutController.mysObject.CIS_ID__c);
	}
	
	@isTest static void testCheckReasonConditionReasonOtherTeam() {
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
        Boolean expectedDisabledFlag = false;
		Customer_Ownership_Request__c cusOwnershipReq = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = GlobalConstants.REASON_OTHER_TEAM,Refer_Out_Segment__c = 'ME',Refer_Out_Team__c = 'testTeam');
		insert cusOwnershipReq;
        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReq));
		accountReferOutController.checkReasonCondition();
        System.assertEquals(expectedDisabledFlag,accountReferOutController.disabledFlag);
	}

	@isTest static void testCheckReasonConditionReasonNotOtherTeamOrWrongArea() {
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
        Boolean expectedDisabledFlag = true;
		Customer_Ownership_Request__c cusOwnershipReq = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = 'test',Refer_Out_Segment__c = 'ME',Refer_Out_Team__c = 'testTeam');
		insert cusOwnershipReq;
        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReq));
		accountReferOutController.checkReasonCondition();
        System.assertEquals(expectedDisabledFlag,accountReferOutController.disabledFlag);
	}
	
	@isTest static void testCheckSegmentConditionSelectedReferOutSegment() {
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
        Boolean expectedDisabledFlag = false;
		Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = 'testReason',Refer_Out_Segment__c = 'ME',Refer_Out_Team__c = 'testTeam');
        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
        accountReferOutController.checkSegmentCondition();
        System.assertEquals(expectedDisabledFlag,accountReferOutController.disabledFlag);
	}

	@isTest static void testCheckSegmentConditionNotSelectedReferOutSegment() {
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
        Boolean expectedDisabledFlag = true;
		String expectedProvince = ' - ';
		String expectedTeam = ' - ';
		Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = 'testReason',Refer_Out_Segment__c = '-',Refer_Out_Team__c = 'testTeam');
        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
        accountReferOutController.checkSegmentCondition();
        System.assertEquals(expectedDisabledFlag,accountReferOutController.disabledFlag);
        System.assertEquals(expectedProvince,accountReferOutController.selectedProvince);
        System.assertEquals(expectedTeam,accountReferOutController.selectedTeam);
	}
	
	@isTest static void testGetSelectedProvince() {
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
        String expectedSelectedProvince = 'testReferProvince';
		Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = 'testReason',Refer_Out_Segment__c = 'testSegment',Refer_Out_Team__c = 'testTeam', Refer_Out_Province__c = expectedSelectedProvince);
        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
        accountReferOutController.selectedProvince = null; 
        System.assertEquals(expectedSelectedProvince,accountReferOutController.getSelectedProvince());

	}

	@isTest static void testGetSelectedProvinceNone() {
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
        String expectedSelectedProvince = ' - ';
		Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = 'testReason',Refer_Out_Segment__c = 'testSegment',Refer_Out_Team__c = 'testTeam');
        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
        
        System.assertEquals(expectedSelectedProvince,accountReferOutController.getSelectedProvince());

	}

	@isTest static void testGetProvinceListNotFound() {
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
		Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = 'testReason',Refer_Out_Segment__c = 'testSegment',Refer_Out_Team__c = 'testTeam');
        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
        accountReferOutController.getProvinceList();
        System.assertEquals(1,accountReferOutController.provinceList.size());
        System.assertEquals(0,accountReferOutController.teamList.size());
	}

	@isTest static void testGetProvinceList() {
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
		Id ON_GOING_RECORD_TYPE_ID = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Team_Province_Master_Data__c', 'On_Going');
		Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = GlobalConstants.REASON_WRONG_AREA,Refer_Out_Segment__c = 'ME',Refer_Out_Team__c = 'testTeam');
        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
        List<Team_Structure__c> listTeamStructure = [SELECT Id FROM Team_Structure__c];
        List<Team_Province_Master_Data__c> listTeamProvinceMasterData = new  List<Team_Province_Master_Data__c>();
		listTeamProvinceMasterData.add(new Team_Province_Master_Data__c(Province_Name__c = 'province 1',RecordTypeId = ON_GOING_RECORD_TYPE_ID,Segment__c = 'ME',Team_Structure__c = listTeamStructure[0].Id));
		listTeamProvinceMasterData.add(new Team_Province_Master_Data__c(Province_Name__c = 'province 2',RecordTypeId = ON_GOING_RECORD_TYPE_ID,Segment__c = 'ME',Team_Structure__c = listTeamStructure[1].Id));
		insert listTeamProvinceMasterData;

        accountReferOutController.getProvinceList();
        System.assertNotEquals(1,accountReferOutController.provinceList.size());
        System.assertNotEquals(0,accountReferOutController.teamList.size());
	}
	
	@isTest static void testSelectProvinceThenSelectTeamME() {
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
		Id ON_GOING_RECORD_TYPE_ID = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Team_Province_Master_Data__c', 'On_Going');
		Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = GlobalConstants.REASON_WRONG_AREA,Refer_Out_Segment__c = 'ME',Refer_Out_Team__c = 'testTeam');
        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
        List<Team_Structure__c> listTeamStructure = [SELECT Id FROM Team_Structure__c];

		Team_Structure__c ts1 = new Team_Structure__c(
			AH_Name__c = null,
			RC_Code__c = Mockup_Test.NH_RC_CODE,
			Name = System.Label.Filter_ME_Team + ' team 1',
			External_ID__c = '1'
		);
		insert ts1;

		Team_Structure__c ts2 = new Team_Structure__c(
			AH_Name__c = null,
			RC_Code__c = Mockup_Test.NH_RC_CODE,
			Name = System.Label.Filter_ME_Team + ' team 2',
			External_ID__c = '2'
		);
		insert ts2;

        List<Team_Province_Master_Data__c> listTeamProvinceMasterData = new  List<Team_Province_Master_Data__c>();
		listTeamProvinceMasterData.add(new Team_Province_Master_Data__c(Province_Name__c = 'province 1',RecordTypeId = ON_GOING_RECORD_TYPE_ID,Segment__c = 'ME',Team_Structure__c = listTeamStructure[0].Id));
		listTeamProvinceMasterData.add(new Team_Province_Master_Data__c(Province_Name__c = 'province 2',RecordTypeId = ON_GOING_RECORD_TYPE_ID,Segment__c = 'ME',Team_Structure__c = listTeamStructure[1].Id));
		listTeamProvinceMasterData.add(new Team_Province_Master_Data__c(Province_Name__c = 'province 3',RecordTypeId = ON_GOING_RECORD_TYPE_ID,Segment__c = 'ME',Team_Structure__c = ts1.Id));
		listTeamProvinceMasterData.add(new Team_Province_Master_Data__c(Province_Name__c = 'province 4',RecordTypeId = ON_GOING_RECORD_TYPE_ID,Segment__c = 'ME',Team_Structure__c = ts2.Id));
		insert listTeamProvinceMasterData;

        accountReferOutController.selectProvince();
        System.assertEquals(3,accountReferOutController.teamList.size());
	}

	@isTest static void testSelectProvinceThenSelectTeamSE() {
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
		Id ON_GOING_RECORD_TYPE_ID = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Team_Province_Master_Data__c', 'On_Going');
		Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = GlobalConstants.REASON_WRONG_AREA,Refer_Out_Segment__c = 'SE',Refer_Out_Team__c = 'testTeam');
        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
        List<Team_Structure__c> listTeamStructure = [SELECT Id FROM Team_Structure__c];

		Team_Structure__c ts1 = new Team_Structure__c(
			AH_Name__c = null,
			RC_Code__c = Mockup_Test.NH_RC_CODE,
			Name = System.Label.Filter_SE_Team + ' team 1',
			External_ID__c = '1'
		);
		insert ts1;

		Team_Structure__c ts2 = new Team_Structure__c(
			AH_Name__c = null,
			RC_Code__c = Mockup_Test.NH_RC_CODE,
			Name = System.Label.Filter_SE_Team + ' team 2',
			External_ID__c = '2'
		);
		insert ts2;

        List<Team_Province_Master_Data__c> listTeamProvinceMasterData = new  List<Team_Province_Master_Data__c>();
		listTeamProvinceMasterData.add(new Team_Province_Master_Data__c(Province_Name__c = 'province 1',RecordTypeId = ON_GOING_RECORD_TYPE_ID,Segment__c = 'SE',Team_Structure__c = listTeamStructure[0].Id));
		listTeamProvinceMasterData.add(new Team_Province_Master_Data__c(Province_Name__c = 'province 2',RecordTypeId = ON_GOING_RECORD_TYPE_ID,Segment__c = 'SE',Team_Structure__c = listTeamStructure[1].Id));
		listTeamProvinceMasterData.add(new Team_Province_Master_Data__c(Province_Name__c = 'province 3',RecordTypeId = ON_GOING_RECORD_TYPE_ID,Segment__c = 'SE',Team_Structure__c = ts1.Id));
		listTeamProvinceMasterData.add(new Team_Province_Master_Data__c(Province_Name__c = 'province 4',RecordTypeId = ON_GOING_RECORD_TYPE_ID,Segment__c = 'SE',Team_Structure__c = ts2.Id));
		insert listTeamProvinceMasterData;

        accountReferOutController.selectProvince();
        System.assertEquals(3,accountReferOutController.teamList.size());
	}

	@isTest static void testIfBlockTeamThenNotSave() {
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
		Id ON_GOING_RECORD_TYPE_ID = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Team_Province_Master_Data__c', 'On_Going');
		Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = GlobalConstants.REASON_WRONG_AREA,Refer_Out_Segment__c = 'SE',Refer_Out_Team__c = System.Label.Filter_SE_Team + ' team 1');
        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
        
        Team_Structure__c ts1 = new Team_Structure__c(
			AH_Name__c = null,
			RC_Code__c = Mockup_Test.NH_RC_CODE,
			Name = System.Label.Filter_SE_Team + ' team 1',
			External_ID__c = '99999'
		);
		insert ts1;

        PageReference result = accountReferOutController.save();
        System.assertEquals(null,result);
	}

	@isTest static void testSave() {
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
		Id ON_GOING_RECORD_TYPE_ID = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Team_Province_Master_Data__c', 'On_Going');
		Customer_Ownership_Request__c cusOwnershipReqReasonOther = new Customer_Ownership_Request__c(CIS_ID__c = targetAccount.id,Refer_Out_Reason__c = 'test other reason',Refer_Out_Segment__c = 'SE',Refer_Out_Team__c = System.Label.Filter_SE_Team + ' team 1');
        Account_ReferOutInformation_Controller accountReferOutController = new Account_ReferOutInformation_Controller(new ApexPages.StandardController(cusOwnershipReqReasonOther));
       
        Team_Structure__c ts1 = new Team_Structure__c(
			AH_Name__c = null,
			RC_Code__c = Mockup_Test.NH_RC_CODE,
			Name = System.Label.Filter_SE_Team + ' team 1',
			External_ID__c = '1'
		);
		insert ts1;

		Team_Structure__c ts2 = new Team_Structure__c(
			AH_Name__c = null,
			RC_Code__c = Mockup_Test.NH_RC_CODE,
			Name = 'Blocked team',
			External_ID__c = '99999'
		);
		insert ts2;

		Test.startTest();
			System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
        		accountReferOutController.save();
        	}
        Test.stopTest();
        List<Customer_Ownership_Request__c> result = [SELECT Id FROM Customer_Ownership_Request__c];
        System.assertEquals(1,result.size());
	}

}