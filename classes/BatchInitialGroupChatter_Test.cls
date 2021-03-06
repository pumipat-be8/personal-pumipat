@isTest
private class BatchInitialGroupChatter_Test {
	
	@testSetup static void setupUser(){
		TriggerHandler.bypass('TeamStructureTriggerHandler');
		TriggerHandler.bypass('UserTriggerHandler');
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        Chatter_Group_Manager__c customSetting = new Chatter_Group_Manager__c(Name = Mockup_Test.userFirstNameRM + ' ' + Mockup_Test.userLastNameRM);
        insert customSetting;
    }

	@isTest static void testCreate1Nh1Ah1Tm1RmTeamAnd4UsersThenInitial1NhGroupAnd2AllNhGroup() {
		Test.startTest();
			Database.executeBatch(new BatchInitialGroupChatter());
		Test.stopTest();
		CollaborationGroup nhGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :Mockup_Test.nhRoleDeveloperName];
	    CollaborationGroup allNhSeGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :GlobalConstants.SEGMENT_SE];
	    CollaborationGroup allNhMeGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :GlobalConstants.SEGMENT_ME];
		List<CollaborationGroup> allGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup];

		System.assertEquals(3,allGroup.size());
		System.assertEquals(5,nhGroup.MemberCount);
		System.assertEquals(3,allNhSeGroup.MemberCount);
		System.assertEquals(2,allNhMeGroup.MemberCount);
	}
	
	@isTest static void testCreate2Nh1Ah1Tm1RmTeamAnd4UsersThenInitial2NhGroupAnd2AllNhGroup() {
		TriggerHandler.bypass('TeamStructureTriggerHandler');
		TriggerHandler.bypass('UserTriggerHandler');
		String NH_RC_CODE = '1234';
		String userFirstNameNH = '2nhUser';
		String userLastNameNH = 'nh team';
		String userEmpIdNH = '4321';
		Profile nhProfile = [SELECT Id, Name FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
		UserRole nhRole = [SELECT Id FROM UserRole WHERE Name = :Mockup_Test.NH_RC_CODE LIMIT 1];

		Team_Structure__c tsNh = new Team_Structure__c(
            External_ID__c = NH_RC_CODE,
            RC_Code__c = NH_RC_CODE,
            AH_RC_Code__c = null,
            NH_RC_Code__c = null,
            Name = '2nhTeam',
            Segment__c = GlobalConstants.SEGMENT_ME,
            Type__c = 'Network'
        );
        insert tsNh;

		User nhUser = Mockup_Test.newUser(
                userFirstNameNH,
                userLastNameNH,
                true,
                userFirstNameNH+'@mail.com',
                userFirstNameNH+'@mail.com',
                userFirstNameNH.substring(0, 4),
                nhProfile.Id,
                nhRole.Id,
                null,
                userEmpIdNH
        );
        nhUser.RC_Code__c = NH_RC_CODE;
        nhUser.NH_RC_Code__c = NH_RC_CODE;
        nhUser.Job_Code__c = 'ME1A';
        nhUser.Status__c = 'A';
        nhUser.Segment__c = 'ME';
        insert nhUser;

        Test.startTest();
			Database.executeBatch(new BatchInitialGroupChatter());
		Test.stopTest();

		CollaborationGroup nhFirstGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :Mockup_Test.nhRoleDeveloperName];
		CollaborationGroup nhSecondGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = '2nhTeam'];
	    CollaborationGroup allNhSeGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :GlobalConstants.SEGMENT_SE];
	    CollaborationGroup allNhMeGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :GlobalConstants.SEGMENT_ME];
		List<CollaborationGroup> allGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup];

		System.assertEquals(4,allGroup.size());
		System.assertEquals(5,nhFirstGroup.MemberCount);
		System.assertEquals(3,nhSecondGroup.MemberCount);
		System.assertEquals(3,allNhSeGroup.MemberCount);
		System.assertEquals(3,allNhMeGroup.MemberCount);
	}
	
}