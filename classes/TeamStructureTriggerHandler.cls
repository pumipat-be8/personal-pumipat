public class TeamStructureTriggerHandler extends TriggerHandler{

	public override void allAfter() {
        //for test class
        if(TestUtils.isRunningTest()){
            User_Service.allUserMap = null;
            GroupChatterService.mapCollaborationGroupMapByName = null;
        }

        if(User_Service.allUserMap == null){
            User_Service.allUserMap = new Map<Id, User>([SELECT Id, Name, Status__c, FirstName, LastName, Profile.Name, Employee_ID__c, RC_Code__c, IsActive, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId,Manager.RC_Code__c, Manager.Manager.RC_Code__c, Manager.Manager.Manager.RC_Code__c, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive,Segment__c FROM User]);
        }

        if(GroupChatterService.mapCollaborationGroupMapByName == null){
            GroupChatterService.mapCollaborationGroupMapByName = GroupChatterService.getAllCollaborationGroupMapByName();
        }

        if(GroupChatterService.mapAllGroupMembersByGroupIdAndMemberId == null){
            GroupChatterService.mapAllGroupMembersByGroupIdAndMemberId = GroupChatterService.getAllGroupMembersByGroupIdAndMemberId();
        }
    }

	public override void afterUpdate() {
		updateGroupChatter();
	}

	public override void afterInsert() {
		createGroupChatter();
	}

	private Boolean isNetworkChangeTeamName(Team_Structure__c newTeam , Team_Structure__c oldTeam){
		if(newTeam.Type__c == 'Network' && oldTeam.Name != newTeam.Name){
			return true;
		}
		return false;
	}

	private Boolean isChangeTypeToNetwork(Team_Structure__c newTeam , Team_Structure__c oldTeam){
		if(newTeam.Type__c == 'Network' && newTeam.Type__c != oldTeam.Type__c){
			return true;
		}
		return false;
	}

	private void updateGroupChatter(){
		String groupName;
		CollaborationGroup collaborationGroup;
		List<CollaborationGroupMember> listInsertCollaborationGroupManager = new List<CollaborationGroupMember>();
		List<CollaborationGroup> listInsertCollaborationGroup = new List<CollaborationGroup>();
		List<CollaborationGroup> listUpdateCollaborationGroup = new List<CollaborationGroup>();
		for(Team_Structure__c eachTeam : (List<Team_Structure__c>)Trigger.new){

			Team_Structure__c oldTeam = (Team_Structure__c) Trigger.oldMap.get(eachTeam.Id);

			if(isNetworkChangeTeamName(eachTeam,oldTeam)){
				collaborationGroup = GroupChatterService.getUpdatedGroupName(eachTeam,oldTeam);
				if(collaborationGroup != null){
					listUpdateCollaborationGroup.add(collaborationGroup);
				}
			}else if(isChangeTypeToNetwork(eachTeam,oldTeam)){
				groupName = GroupChatterService.createGroupNameFromTeamNameAndSegment(eachTeam.Name,eachTeam.Segment__c);
				collaborationGroup = GroupChatterService.createGroupChatter(groupName);
				if(collaborationGroup != null){
					listInsertCollaborationGroup.add(collaborationGroup);
				}
			}
		}

		if(!listUpdateCollaborationGroup.isEmpty()){
			update listUpdateCollaborationGroup;
		}
		if(!listInsertCollaborationGroup.isEmpty()){
			insert listInsertCollaborationGroup;
			for(CollaborationGroup eachGroup : listInsertCollaborationGroup){
				listInsertCollaborationGroupManager.addAll(GroupChatterService.getListManager(eachGroup));
			}
		}

		if(!listInsertCollaborationGroupManager.isEmpty()){
			insert listInsertCollaborationGroupManager;
		}
	}

	private void createGroupChatter(){
		String groupName;
		CollaborationGroup collaborationGroup;
		List<CollaborationGroupMember> listInsertCollaborationGroupManager = new List<CollaborationGroupMember>();
		List<CollaborationGroup> listCollaborationGroup = new List<CollaborationGroup>();
		for(Team_Structure__c eachTeam : (List<Team_Structure__c>)Trigger.new){
			if(eachTeam.Type__c == 'Network'){
				groupName = GroupChatterService.createGroupNameFromTeamNameAndSegment(eachTeam.Name,eachTeam.Segment__c);
				collaborationGroup = GroupChatterService.createGroupChatter(groupName);
				listCollaborationGroup.add(collaborationGroup);
			}
		}

		if(!listCollaborationGroup.isEmpty()){
			insert listCollaborationGroup;
		}
		for(CollaborationGroup eachGroup : listCollaborationGroup){
			listInsertCollaborationGroupManager.addAll(GroupChatterService.getListManager(eachGroup));
		}
		if(!listInsertCollaborationGroupManager.isEmpty()){
			insert listInsertCollaborationGroupManager;
		}
	}
}