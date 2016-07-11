global class BatchInitialGroupChatter implements Database.Batchable<sObject>, Database.Stateful {
	
	String queryListNhTeamStructure;
	Map<String,Team_Structure__c> mapTeamStructureMapByNhRcCode = new Map<String,Team_Structure__c>();
	Map<String,List<User>> mapListUserMapByNhRcCode = new Map<String,List<User>>();
	Map<String,CollaborationGroup> collaborationGroupMapByRcCode = new Map<String,CollaborationGroup>();
	
	global BatchInitialGroupChatter() {
		this.queryListNhTeamStructure = 'SELECT Id,Name,Rc_Code__c,Segment__c FROM Team_Structure__c WHERE Type__c = \'Network\'';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		if(GroupChatterService.mapCollaborationGroupMapByName == null){
			GroupChatterService.mapCollaborationGroupMapByName = GroupChatterService.getAllCollaborationGroupMapByName();
		}
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
		//List<CollaborationGroup> listDeleteCollaborationGroup = deleteNhGroupAndAllNhGroup();
		//delete listDeleteCollaborationGroup;
		List<CollaborationGroup> listCreateCollaborationGroup = createNhGroupAndAllNhGroup(listNhTeamStructure);
		insert listCreateCollaborationGroup;
		List<CollaborationGroupMember> listCreateCollaborationGroupMember = createGroupMemberAndAdmin(listNhTeamStructure);
		insert listCreateCollaborationGroupMember;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
	private List<CollaborationGroupMember> createGroupMemberAndAdmin(List<Team_Structure__c> listNhTeamStructure){
		List<CollaborationGroupMember> listNewCollaborationGroupMember = new List<CollaborationGroupMember>();
		Map<String, CollaborationGroup> mapAllGroupMapByName = GroupChatterService.getAllCollaborationGroupMapByName();

		for(Team_Structure__c eachTeam : listNhTeamStructure){
			//System.debug('eachTeam.Rc_Code__c = '+eachTeam.Rc_Code__c);
			//Team_Structure__c nhTeam = mapTeamStructureMapByNhRcCode.get(eachTeam.Rc_Code__c);
			//System.debug('nhTeam = '+nhTeam);
			String groupName = GroupChatterService.createGroupNameFromTeamNameAndSegment(eachTeam.Name, eachTeam.Segment__c);
			CollaborationGroup eachGroupNh = mapAllGroupMapByName.get(groupName);
			listNewCollaborationGroupMember.addAll(GroupChatterService.getListManager(eachGroupNh));

			List<User> listUserGroupMapNhRcCode = mapListUserMapByNhRcCode.get(eachTeam.Rc_Code__c);
			for(User eachUser : listUserGroupMapNhRcCode){
				CollaborationGroupMember newMember = GroupChatterService.createMemberGroup(eachUser, eachGroupNh);
				listNewCollaborationGroupMember.add(newMember);
				if(eachUser.Profile.Name == GlobalConstants.SME_NH){
					CollaborationGroupMember newNhMember = createNhMemberToAllNhGroupBySegment(eachUser,mapAllGroupMapByName);
					listNewCollaborationGroupMember.add(newNhMember);
				}
			}
		}
		CollaborationGroup allNhSeGroup = mapAllGroupMapByName.get(GlobalConstants.SEGMENT_SE);
		CollaborationGroup allNhMeGroup = mapAllGroupMapByName.get(GlobalConstants.SEGMENT_ME);
		listNewCollaborationGroupMember.addAll(GroupChatterService.getListManager(allNhSeGroup));
		listNewCollaborationGroupMember.addAll(GroupChatterService.getListManager(allNhMeGroup));
		return listNewCollaborationGroupMember;
	}

	private CollaborationGroupMember createNhMemberToAllNhGroupBySegment(User nhUser,Map<String, CollaborationGroup> mapAllGroupMapByName){
		CollaborationGroupMember newNhMember;
		if(nhUser.Segment__c == GlobalConstants.SEGMENT_ME){
			newNhMember = GroupChatterService.createMemberGroup(nhUser, mapAllGroupMapByName.get(GlobalConstants.SEGMENT_ME));
		}else if(nhUser.Segment__c == GlobalConstants.SEGMENT_SE){
			newNhMember = GroupChatterService.createMemberGroup(nhUser, mapAllGroupMapByName.get(GlobalConstants.SEGMENT_SE));
		}
		return newNhMember;
	}

	private List<CollaborationGroup> createNhGroupAndAllNhGroup(List<Team_Structure__c> listNhTeamStructure){
		List<CollaborationGroup> listCreateCollaborationGroup = new List<CollaborationGroup>();
		List<CollaborationGroupMember> listCreateCollaborationGroupMember = new List<CollaborationGroupMember>();
		for(Team_Structure__c eachTeam : listNhTeamStructure){
			String groupName = GroupChatterService.createGroupNameFromTeamNameAndSegment(eachTeam.Name, eachTeam.Segment__c);
			if(!GroupChatterService.mapCollaborationGroupMapByName.containsKey(groupName)){
				CollaborationGroup newGroup = GroupChatterService.createGroupChatter(groupName);
				listCreateCollaborationGroup.add(newGroup);
				//mapTeamStructureMapByNhRcCode.put(eachTeam.RC_Code__c, eachTeam);
				//collaborationGroupMapByRcCode.put(eachTeam.RC_Code__c, newGroup);
			}
		}
		CollaborationGroup newMeGroup = GroupChatterService.createGroupChatter(GlobalConstants.SEGMENT_ME);
		CollaborationGroup newSeGroup = GroupChatterService.createGroupChatter(GlobalConstants.SEGMENT_SE);
		listCreateCollaborationGroup.add(newMeGroup);
		listCreateCollaborationGroup.add(newSeGroup);
		//collaborationGroupMapByRcCode.put(GlobalConstants.SEGMENT_ME, newMeGroup);
		//collaborationGroupMapByRcCode.put(GlobalConstants.SEGMENT_SE, newSeGroup);
		return listCreateCollaborationGroup;
	}

	//private List<CollaborationGroup> deleteNhGroupAndAllNhGroup(){
	//	List<CollaborationGroup> listDeleteCollaborationGroup = new List<CollaborationGroup>();
	//	for(String teamName : GroupChatterService.mapCollaborationGroupMapByName.keySet()){
	//		CollaborationGroup deleteGroup = GroupChatterService.deleteGroupChatter(teamName);
	//		if(deleteGroup != null){
	//			listDeleteCollaborationGroup.add(deleteGroup);
	//		}
	//	}
	//	return listDeleteCollaborationGroup;
	//}
}