public without sharing class GroupChatterService {
	public static Map<String, CollaborationGroup> mapCollaborationGroupMapByName;
	public static Map<String, Map<String, CollaborationGroupMember>> mapAllGroupMembersByGroupIdAndMemberId;
	public static User groupOwner;
	public static List<User> listUserManager = new List<User>();

	public static Map<String, CollaborationGroup> getAllCollaborationGroupMapByName(){
		Map<String, CollaborationGroup>  groupMapByName = new Map<String, CollaborationGroup> ();
		List<CollaborationGroup> listCollaborationGroup = [SELECT Id,Name FROM CollaborationGroup];
		for(CollaborationGroup colGroup : listCollaborationGroup){
			groupMapByName.put(colGroup.Name, colGroup);
		}
		return groupMapByName;
	}

	public static Map<String, Map<String, CollaborationGroupMember>> getAllGroupMembersByGroupIdAndMemberId(){
		Map<String, Map<String, CollaborationGroupMember>> memberMapByGroupIdAndMemberId = new Map<String, Map<String, CollaborationGroupMember>>();
		List<CollaborationGroupMember> listMembers = [SELECT Id,CollaborationGroupId,MemberId FROM CollaborationGroupMember];
		for(CollaborationGroupMember member : listMembers){
			memberMapByGroupIdAndMemberId.put(member.CollaborationGroupId, new Map<String, CollaborationGroupMember>{member.MemberId => member});
		}
		return memberMapByGroupIdAndMemberId;
	}

	public static void addUserToList(User user,List<CollaborationGroupMember> insertCollaborationGroupMemberList){
		manageChatter(user,insertCollaborationGroupMemberList,true);
	}

	public static void addDeleteUserToList(User oldUser,List<CollaborationGroupMember> deleteCollaborationGroupMemberList){
		manageChatter(oldUser,deleteCollaborationGroupMemberList,false);
	}

	private static void manageChatter(User user,List<CollaborationGroupMember> collaborationGroupMemberList,Boolean isAddMember){
		String rcCode;
        String groupName;

        User userWithProfile;

        if(isAddMember){
        	userWithProfile = User_Service.allUserMap.get(user.Id);
    	}else{
			userWithProfile = User_Service.allOldUserMap.get(user.Id);
    	}

        Team_Structure__c teamStructure = getNhTeamStructure(userWithProfile);

        if(teamStructure != null && teamStructure.Type__c == 'Network'){
            groupName = createGroupNameFromTeamNameAndSegment(teamStructure.Name,teamStructure.Segment__c);

            CollaborationGroup collaborationGroup = mapCollaborationGroupMapByName.get(groupName);
            CollaborationGroupMember member;
            CollaborationGroupMember nhMember;
            if(isAddMember){
            	if(collaborationGroup == null){
	            	collaborationGroup = createGroupChatter(groupName);
	            	insert collaborationGroup;
	            	mapCollaborationGroupMapByName.put(collaborationGroup.Name, collaborationGroup);
	            	collaborationGroupMemberList.addAll(getListManager(collaborationGroup));
	            }
				member = createMemberGroup(user,collaborationGroup);
				nhMember = createNhUserToAllNhGroup(userWithProfile,collaborationGroupMemberList);
                mapAllGroupMembersByGroupIdAndMemberId.put(collaborationGroup.Id,new Map<String,CollaborationGroupMember>{member.MemberId => member});
        	}else{
        		member = mapAllGroupMembersByGroupIdAndMemberId.get(collaborationGroup.Id).get(user.Id);
        		nhMember = deleteNhUserFromAllNhGroup(userWithProfile);
        	}
            
            if(member != null){
            	collaborationGroupMemberList.add(member);	
            }

            if(nhMember != null){
            	collaborationGroupMemberList.add(nhMember);
            }
        }

	}

	public static String createGroupNameFromTeamNameAndSegment(String teamName,String segment){
		String groupName;
		if(segment == GlobalConstants.SEGMENT_SE || segment == 'Small'){
            groupName = teamName.replace('เครือข่ายลูกค้าผู้ประกอบการ 2','SE');
        }else if(segment == GlobalConstants.SEGMENT_ME || segment == 'Medium'){
            groupName = teamName.replace('เครือข่ายลูกค้าผู้ประกอบการ 1','ME');
        }
        groupName = groupName.replace('(','');
        groupName = groupName.replace(')','');
		return groupName;
	}

	private static Team_Structure__c getNhTeamStructure(User userWithProfile){
		String nhRcCode = getNhRcCodeFromUser(userWithProfile);
		Team_Structure__c ts = User_Service.teamMapByRC.get(nhRcCode);
		return ts;
	}

	private static String getNhRcCodeFromUser(User userWithProfile){
		String nhRcCode = '';
		if(userWithProfile != null){
	        if(userWithProfile.Profile.Name != GlobalConstants.SME_NH){
	            nhRcCode = userWithProfile.NH_RC_Code__c;
	        }else {
	            nhRcCode = userWithProfile.RC_Code__c;
	        }
	    }
	    return nhRcCode;
	}

	public static CollaborationGroup createGroupChatter(String groupName){
		if(groupOwner == null){
			groupOwner = [SELECT Id FROM User WHERE Name = :System.Label.Chatter_Group_Owner LIMIT 1];
		}
		CollaborationGroup collaborationGroup = new CollaborationGroup();

    	collaborationGroup.OwnerId = groupOwner.Id;

    	collaborationGroup.Name = groupName;
    	collaborationGroup.CollaborationType = 'Private';
    	return collaborationGroup;
	}

	public static CollaborationGroup deleteGroupChatter(String groupName){
		CollaborationGroup collaborationGroup = mapCollaborationGroupMapByName.get(groupName);
    	return collaborationGroup;
	}

	public static CollaborationGroupMember createMemberGroup(User user,CollaborationGroup collaborationGroup){
		CollaborationGroupMember collaborationGroupMember = new CollaborationGroupMember();
		collaborationGroupMember.CollaborationGroupId = collaborationGroup.Id;
        collaborationGroupMember.CollaborationRole = 'Standard';
        collaborationGroupMember.MemberId = user.Id;
    	return collaborationGroupMember;
	}

	public static CollaborationGroupMember createAdminGroup(User user,CollaborationGroup collaborationGroup){
		CollaborationGroupMember collaborationGroupMember = new CollaborationGroupMember();
		collaborationGroupMember.CollaborationGroupId = collaborationGroup.Id;
        collaborationGroupMember.CollaborationRole = 'Admin';
        collaborationGroupMember.MemberId = user.Id;
    	return collaborationGroupMember;
	}

	public static Boolean isUserChangeRcCode(User newUser , User oldUser){
		if(newUser.RC_Code__c != oldUser.RC_Code__c){
			return true;
		}
		return false;
	}

	public static CollaborationGroupMember createNhUserToAllNhGroup(User user,List<CollaborationGroupMember> collaborationGroupMemberList){
		CollaborationGroupMember member;
		if (user.Profile.Name == GlobalConstants.SME_NH){
        	CollaborationGroup groupAllNh;
        	if(user.Segment__c == GlobalConstants.SEGMENT_ME){
        		groupAllNh = mapCollaborationGroupMapByName.get(GlobalConstants.SEGMENT_ME);
        	}else{
        		groupAllNh = mapCollaborationGroupMapByName.get(GlobalConstants.SEGMENT_SE);
        	}
        	if(groupAllNh == null){
            	groupAllNh = createGroupChatter(user.Segment__c);
            	insert groupAllNh;
            	mapCollaborationGroupMapByName.put(groupAllNh.Name, groupAllNh);
            	collaborationGroupMemberList.addAll(getListManager(groupAllNh));
            }

            member = createMemberGroup(user,groupAllNh);
            mapAllGroupMembersByGroupIdAndMemberId.put(groupAllNh.Id,new Map<String,CollaborationGroupMember>{member.MemberId => member});
        }

        return member;
	}

	public static List<CollaborationGroupMember> getListManager(CollaborationGroup collaborationGroup){
		List<CollaborationGroupMember> returnList = new List<CollaborationGroupMember>();
		if(listUserManager.isEmpty()){
			Set<String> listManagerName = new Set<String>();
			for(Chatter_Group_Manager__c groupManager : Chatter_Group_Manager__c.getall().values()){
				listManagerName.add(groupManager.Name);
			}
			listUserManager = [SELECT Id,Name, Profile.Name FROM User WHERE Name in :listManagerName AND IsActive = true AND Name != :System.Label.Chatter_Group_Owner];
		}
		System.debug('listUserManager = '+listUserManager);
		for(User eachUser : listUserManager){
			CollaborationGroupMember cbgMember = createAdminGroup(eachUser,collaborationGroup);
			returnList.add(cbgMember);
		}
		System.debug('getListManager = '+returnList);
		return returnList;
	}

	public static CollaborationGroupMember deleteNhUserFromAllNhGroup(User user){
		CollaborationGroupMember member;
		if (User.Profile.Name == GlobalConstants.SME_NH){
        	CollaborationGroup groupAllNh;

        	if(User.Segment__c == GlobalConstants.SEGMENT_ME){
        		groupAllNh = mapCollaborationGroupMapByName.get(GlobalConstants.SEGMENT_ME);
        	}else{
        		groupAllNh = mapCollaborationGroupMapByName.get(GlobalConstants.SEGMENT_SE);
        	}

        	if(groupAllNh != null){
        		member = mapAllGroupMembersByGroupIdAndMemberId.get(groupAllNh.Id).get(user.Id);
        	}
        }

        return member;
	}

	public static CollaborationGroup getUpdatedGroupName(Team_Structure__c newTeam,Team_Structure__c oldTeam){
		String oldName = createGroupNameFromTeamNameAndSegment(oldTeam.Name,oldTeam.Segment__c);
		String newName = createGroupNameFromTeamNameAndSegment(newTeam.Name,newTeam.Segment__c);
		CollaborationGroup cbg = mapCollaborationGroupMapByName.get(oldName);
		cbg.Name = newName;
		return cbg;
	}
}