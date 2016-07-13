global class SME_BatchInitialGroupChatter implements Database.Batchable<sObject>, Database.Stateful {
	
	String queryListNhTeamStructure;
	Map<String,Team_Structure__c> mapTeamStructureMapByNhRcCode = new Map<String,Team_Structure__c>();
	Map<String,List<User>> mapListUserMapByNhRcCode = new Map<String,List<User>>();
	Map<String,CollaborationGroup> collaborationGroupMapByRcCode = new Map<String,CollaborationGroup>();
	
	global SME_BatchInitialGroupChatter() {
		this.queryListNhTeamStructure = 'SELECT Id,Name,Rc_Code__c,Segment__c FROM Team_Structure__c WHERE Type__c = \'Network\'';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		//if(SME_GroupChatterService.mapCollaborationGroupMapByName == null){
		//	SME_GroupChatterService.mapCollaborationGroupMapByName = SME_GroupChatterService.getAllCollaborationGroupMapByName();
		//}
		List<String> listProfileNameForGroup = new List<String>{GlobalConstants.SME_NH,GlobalConstants.SME_AH,GlobalConstants.SME_TM,GlobalConstants.SME_RM};
		List<String> listAdmin = new List<String>{System.Label.Chatter_Group_Owner};
		for(Chatter_Group_Manager__c groupManager : Chatter_Group_Manager__c.getall().values()){
			listAdmin.add(groupManager.Name);
		}

		List<User> listUser = [SELECT Id,Name,Segment__c,NH_RC_Code__c,Profile.Name,RC_Code__c FROM User WHERE Profile.Name IN :listProfileNameForGroup AND Name NOT IN :listAdmin AND isActive = true ORDER BY NH_RC_Code__c,Segment__c];
		for(User eachUser : listUser){
			List<User> listUserGroupByNhRcCode;
			String nhRcCode = eachUser.Profile.Name == GlobalConstants.SME_NH ? eachUser.RC_Code__c : eachUser.NH_RC_Code__c;
			if(nhRcCode != null){
				if(!mapListUserMapByNhRcCode.containsKey(nhRcCode)){
					listUserGroupByNhRcCode = new List<User>();
				}else{
					listUserGroupByNhRcCode = mapListUserMapByNhRcCode.get(nhRcCode);
				}
				listUserGroupByNhRcCode.add(eachUser);
			
				mapListUserMapByNhRcCode.put(nhRcCode, listUserGroupByNhRcCode);
			}
		}

		return Database.getQueryLocator(queryListNhTeamStructure);
	}

   	global void execute(Database.BatchableContext BC, List<Team_Structure__c> listNhTeamStructure) {
		List<CollaborationGroup> listCreateCollaborationGroup = createNhGroupAndAllNhGroup(listNhTeamStructure);
		insert listCreateCollaborationGroup;
		List<CollaborationGroupMember> listCreateCollaborationGroupMember = createGroupMemberAndAdmin(listNhTeamStructure);
		insert listCreateCollaborationGroupMember;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
	private List<CollaborationGroupMember> createGroupMemberAndAdmin(List<Team_Structure__c> listNhTeamStructure){
		List<CollaborationGroupMember> listNewCollaborationGroupMember = new List<CollaborationGroupMember>();
		Map<String, CollaborationGroup> mapAllGroupMapByName = SME_GroupChatterService.getAllCollaborationGroupMapByName();

		for(Team_Structure__c eachTeam : listNhTeamStructure){
			String groupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(eachTeam.Name, eachTeam.Segment__c);
			CollaborationGroup eachGroupNh = mapAllGroupMapByName.get(groupName);
			listNewCollaborationGroupMember.addAll(SME_GroupChatterService.getListManager(eachGroupNh));

			List<User> listUserGroupMapNhRcCode = mapListUserMapByNhRcCode.get(eachTeam.Rc_Code__c);
			for(User eachUser : listUserGroupMapNhRcCode){
				CollaborationGroupMember newMember = SME_GroupChatterService.createMemberGroup(eachUser, eachGroupNh);
				listNewCollaborationGroupMember.add(newMember);
				if(eachUser.Profile.Name == GlobalConstants.SME_NH){
					CollaborationGroupMember newNhMember = createNhMemberToAllNhGroupBySegment(eachUser,mapAllGroupMapByName);
					listNewCollaborationGroupMember.add(newNhMember);
				}
			}
		}
		CollaborationGroup allNhSeGroup = mapAllGroupMapByName.get(GlobalConstants.SEGMENT_SE);
		CollaborationGroup allNhMeGroup = mapAllGroupMapByName.get(GlobalConstants.SEGMENT_ME);
		listNewCollaborationGroupMember.addAll(SME_GroupChatterService.getListManager(allNhSeGroup));
		listNewCollaborationGroupMember.addAll(SME_GroupChatterService.getListManager(allNhMeGroup));
		return listNewCollaborationGroupMember;
	}

	private CollaborationGroupMember createNhMemberToAllNhGroupBySegment(User nhUser,Map<String, CollaborationGroup> mapAllGroupMapByName){
		CollaborationGroupMember newNhMember;
		if(nhUser.Segment__c == GlobalConstants.SEGMENT_ME){
			newNhMember = SME_GroupChatterService.createMemberGroup(nhUser, mapAllGroupMapByName.get(GlobalConstants.SEGMENT_ME));
		}else if(nhUser.Segment__c == GlobalConstants.SEGMENT_SE){
			newNhMember = SME_GroupChatterService.createMemberGroup(nhUser, mapAllGroupMapByName.get(GlobalConstants.SEGMENT_SE));
		}
		return newNhMember;
	}

	private List<CollaborationGroup> createNhGroupAndAllNhGroup(List<Team_Structure__c> listNhTeamStructure){
		List<CollaborationGroup> listCreateCollaborationGroup = new List<CollaborationGroup>();
		List<CollaborationGroupMember> listCreateCollaborationGroupMember = new List<CollaborationGroupMember>();
		Map<String, CollaborationGroup> allCollaborationGroupMapByName = SME_GroupChatterService.getAllCollaborationGroupMapByName();

		for(Team_Structure__c eachTeam : listNhTeamStructure){
			String groupName = SME_GroupChatterService.createGroupNameFromTeamNameAndSegment(eachTeam.Name, eachTeam.Segment__c);
			if(groupName.length() <= 40){
				if(!allCollaborationGroupMapByName.containsKey(groupName)){
					CollaborationGroup newGroup = SME_GroupChatterService.createGroupChatter(groupName);
					listCreateCollaborationGroup.add(newGroup);
				}
			}
		}
		CollaborationGroup newMeGroup = SME_GroupChatterService.createGroupChatter(GlobalConstants.SEGMENT_ME);
		CollaborationGroup newSeGroup = SME_GroupChatterService.createGroupChatter(GlobalConstants.SEGMENT_SE);
		listCreateCollaborationGroup.add(newMeGroup);
		listCreateCollaborationGroup.add(newSeGroup);
		return listCreateCollaborationGroup;
	}
}