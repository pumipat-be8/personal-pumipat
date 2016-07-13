@isTest
private class TeamStructureTriggerHandler_Test {
	
	public static Map<String,User> mapUserMapByFirstName = new Map<String,User>();

	@testSetup static void setupUser(){
        TestUtils.enable_isRunningTest = true;
        //List<Chatter_Group_Name__c> listCustomSettingGroupName = new List<Chatter_Group_Name__c>();
        //Chatter_Group_Name__c customSettingGroupMeName = new Chatter_Group_Name__c(Name = GlobalConstants.SEGMENT_ME, Replace_from__c = 'เครือข่ายลูกค้าผู้ประกอบการ 1');
        //Chatter_Group_Name__c customSettingGroupSeName = new Chatter_Group_Name__c(Name = GlobalConstants.SEGMENT_SE, Replace_from__c = 'เครือข่ายลูกค้าผู้ประกอบการ 2');
        //listCustomSettingGroupName.add(customSettingGroupMeName);
        //listCustomSettingGroupName.add(customSettingGroupSeName);
        //insert listCustomSettingGroupName;

        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        
        List<User> listUser = [SELECT Id,FirstName FROM User];

        for(User eachUser : listUser){
            mapUserMapByFirstName.put(eachUser.FirstName, eachUser);
        }
    }

	@isTest static void testCreateTeamStructureNhAhTmRmThenCreate1AhGroup1AllAhGroup() {

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
	        Test.startTest();
	            List<CollaborationGroup> allGroup = [SELECT Id FROM CollaborationGroup];
	            String groupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(Mockup_Test.nhTeamName, GlobalConstants.SEGMENT_SE);
	            CollaborationGroup nhGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :groupName];
	            CollaborationGroup allNhGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = :GlobalConstants.SEGMENT_SE];
	        Test.stopTest();

	        System.assertEquals(2, allGroup.size());
	        System.assertEquals(groupName, nhGroup.Name);
	        System.assertEquals(GlobalConstants.SEGMENT_SE, allNhGroup.Name);
	        System.assertEquals(5, nhGroup.MemberCount);
	        System.assertEquals(2, allNhGroup.MemberCount);
        }
	}
	
	@isTest static void testNetworkUpdateTeamNameThenUpdateGroupName() {
		Team_Structure__c nhTeam;
		Team_Structure__c nhTeamAfterChangeName;
		CollaborationGroup nhGroup;
		CollaborationGroup nhGroupAfterChangeName;
		User userAdmin = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0];
		System.runAs(userAdmin){
			String groupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(Mockup_Test.nhTeamName, GlobalConstants.SEGMENT_SE);
            nhGroup = [SELECT Id,Name FROM CollaborationGroup WHERE Name = :groupName];
            System.assertEquals(groupName, nhGroup.Name);
            nhTeam = [SELECT Id,Name FROM Team_Structure__c WHERE RC_Code__c = :Mockup_Test.NH_RC_CODE];
        }
        
        Test.startTest();
	    	nhTeam.Name = 'เครือข่ายลูกค้าผู้ประกอบการ 2 (after change name)';
	        update nhTeam;
	    Test.stopTest();

        nhTeamAfterChangeName = [SELECT Id,Name FROM Team_Structure__c WHERE RC_Code__c = :Mockup_Test.NH_RC_CODE];
    	System.assertEquals('เครือข่ายลูกค้าผู้ประกอบการ 2 (after change name)', nhTeamAfterChangeName.Name);

    	nhGroupAfterChangeName = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = 'SE after change name'];
    	System.assertEquals('SE after change name', nhGroupAfterChangeName.Name);
    	System.assertEquals(5, nhGroupAfterChangeName.MemberCount);
	}
	
	@isTest static void testChangeTypeToNetworkThenCreateNewGroup() {
		String AH_RC_CODE = '1234';
		Team_Structure__c ahTeam;
		Team_Structure__c nhTeam;
		CollaborationGroup nhNewGroup;
		List<CollaborationGroup> allGroup;
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
	        Test.startTest();
	        	nhTeam = [SELECT Id,Name FROM Team_Structure__c WHERE RC_Code__c = :Mockup_Test.NH_RC_CODE];
	            ahTeam = new Team_Structure__c(
	                External_ID__c = AH_RC_CODE,
	                RC_Code__c = AH_RC_CODE,
	                AH_RC_Code__c = null,
	                NH_RC_Code__c = Mockup_Test.NH_RC_CODE,
	                AH_Name__c = null,
	                NH_Name__c = nhTeam.Id,
	                Name = 'เครือข่ายลูกค้าผู้ประกอบการ 1 testToNH',
	                Segment__c = GlobalConstants.SEGMENT_ME,
	                Type__c = 'Area'
	            );
	            insert ahTeam;
	        Test.stopTest();
        }

        ahTeam.Type__c = 'Network';
        update ahTeam;

        allGroup = [SELECT Id FROM CollaborationGroup];
        System.assertEquals(3,allGroup.size());

        nhNewGroup = [SELECT Id,Name,MemberCount FROM CollaborationGroup WHERE Name = 'ME testToNH'];
        System.assertEquals('ME testToNH',nhNewGroup.Name);
        System.assertEquals(1, nhNewGroup.MemberCount);
	}
}