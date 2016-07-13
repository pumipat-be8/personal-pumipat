/**
* @author komsan.wi@beryl8.com
* @16/07/2015 createddate
*/
public class UserTriggerHandler extends TriggerHandler{
    private String PROFILE_RM_ID;

    public override void allBefore(){
        //for test class
        if(TestUtils.isRunningTest()){
            User_Service.allOldUserMap = null;
        }
        
        if(User_Service.allOldUserMap == null){
            User_Service.allOldUserMap = new Map<Id, User>([SELECT Id, Name, Status__c, FirstName, LastName, Profile.Name, Employee_ID__c, RC_Code__c, IsActive, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId,Manager.RC_Code__c, Manager.Manager.RC_Code__c, Manager.Manager.Manager.RC_Code__c, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive,Segment__c,NH_RC_Code__c FROM User]);
        }
    }

    public override void beforeInsert() {
        for(User eachUser : (List<User>)Trigger.new){
            // Charnun.T
            // Setup default value for each employee user
            eachUser.LanguageLocaleKey = 'th';
            eachUser.LocaleSidKey = 'th_TH';
            eachUser.EmailEncodingKey = 'UTF-8';
            eachUser.TimeZoneSidKey = 'Asia/Bangkok';
        }
    }

    public override void beforeUpdate() {
        Set<Id> oldUserIds = new Set<Id>();
        User oldUser;
        for(User eachUser : (List<User>)Trigger.new){
            oldUser = (User) Trigger.oldMap.get(eachUser.Id);
            if((eachUser.IsActive == false && (eachUser.IsActive != oldUser.IsActive)) || (eachUser.Status__c == 'I' && eachUser.Status__c != oldUser.Status__c) || eachUser.Job_Code__c != oldUser.Job_Code__c || eachUser.RC_Code__c != oldUser.RC_Code__c) {
                oldUserIds.add(eachUser.Id);
            }
        }
        if(SME_CalculateOwnershipAssignment_Service.oldUserMap == null)
            SME_CalculateOwnershipAssignment_Service.oldUserMap = new Map<Id, User>([SELECT Id, 
                ManagerId,
                Manager.ManagerId,
                Manager.Manager.ManagerId, 
                Manager.IsActive,
                Manager.Manager.IsActive,
                Manager.Manager.Manager.IsActive, 
                Manager.RC_Code__c,
                Manager.Manager.RC_Code__c,
                Manager.Manager.Manager.RC_Code__c, 
                Manager.Job_Code__c,
                Manager.Manager.Job_Code__c,
                Manager.Manager.Manager.Job_Code__c, 
                Name, IsActive, Acting_Flag__c, Employee_ID__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Job_Code__c, UserRole.DeveloperName, Profile.Name, Email, Username, FirstName, LastName, Segment__c, Status__c, Effective_Date__c, Team_Name__c  FROM User]);
    }

    public override void allAfter() {
        if(User_Service.teamMapByRC == null)
            User_Service.teamMapByRC = User_Service.getAllTeamStructureMapByRC();
        
        if(User_Service.userExtensionMapByUserId == null)
            User_Service.userExtensionMapByUserId = User_Service.getUserExtensionMapByUser();
        
        //for test class
        if(TestUtils.isRunningTest()){
            User_Service.allUserMap = null;
        }

        if(User_Service.allUserMap == null){
            User_Service.allUserMap = new Map<Id, User>([SELECT Id, Name, Status__c, FirstName, LastName, Profile.Name, Employee_ID__c, RC_Code__c, IsActive, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId,Manager.RC_Code__c, Manager.Manager.RC_Code__c, Manager.Manager.Manager.RC_Code__c, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive,Segment__c,NH_RC_Code__c FROM User]);
        }

        if(TestUtils.isRunningTest()){
            SME_GroupChatterService.mapCollaborationGroupMapByName = null;
        }
        if(SME_GroupChatterService.mapCollaborationGroupMapByName == null){
            SME_GroupChatterService.mapCollaborationGroupMapByName = SME_GroupChatterService.getAllCollaborationGroupMapByName();
        }

        if(SME_GroupChatterService.mapAllGroupMembersByGroupIdAndMemberId == null){
            SME_GroupChatterService.mapAllGroupMembersByGroupIdAndMemberId = SME_GroupChatterService.getAllGroupMembersByGroupIdAndMemberId();
        }
    }

    public override void afterUpdate() {
        /*
        Map<Id,User> usersInactiveNew = new Map<Id,User>([SELECT Id, IsActive FROM User WHERE IsActive = false AND Id IN: Trigger.newMap.keySet()]);
        Set<Id> userIdToUpdateOpportunity = usersInactiveNew.keySet();
        List<Opportunity> opportunityToUpdate = new List<Opportunity>([SELECT Current_AH__c, Current_NH__c, OwnerId FROM Opportunity WHERE OwnerId IN: userIdToUpdateOpportunity]);
        System.debug('userIdToUpdateOpportunity : ' + userIdToUpdateOpportunity);
        System.debug('opportunityToUpdate : ' + opportunityToUpdate);
        for(Opportunity eachOpportunity : opportunityToUpdate){
            System.debug('OwnerId in UserTriggerHandler : ' + eachOpportunity.OwnerId);
            eachOpportunity.Current_AH__c = null;
            eachOpportunity.Current_NH__c = null;
        }
        update opportunityToUpdate;
        */

        List<Team_Structure__c> updateTeamList = new List<Team_Structure__c>();
        Map<Id, User_Extension__c> userExtMap = new Map<Id, User_Extension__c>();
        Map<String, User> userMapByNewRoleRC = new Map<String, User>();
        Map<String, User_MaskModel> userMaskMapByEmpId = new Map<String, User_MaskModel>();
        List<CollaborationGroupMember> listInsertMemberToGroup = new List<CollaborationGroupMember>();
        List<CollaborationGroupMember> listDeleteMemberFromGroup = new List<CollaborationGroupMember>();
        Set<Id> hrisDiffIds = new Set<Id>();
        Set<Id> hrisInActiveIds = new Set<Id>();
        User_MaskModel userMask;
        User oldUser;
        Team_Structure__c eachTeam;
        User_Extension__c userExt;
        User targetUser;
        for(User eachUser : (List<User>)Trigger.new){
            oldUser = (User) Trigger.oldMap.get(eachUser.Id);
            
            if(User_Service.userExtensionMapByUserId.containsKey(eachUser.Id)) {
                userExt = User_Service.userExtensionMapByUserId.get(eachUser.Id);
                if(eachUser.RC_Code__c != oldUser.RC_Code__c || eachUser.FirstName != oldUser.FirstName || eachUser.LastName != oldUser.LastName) {
                    userExt.Team_Structure__c = User_Service.teamMapByRc.containsKey(eachUser.RC_Code__c) ? User_Service.teamMapByRc.get(eachUser.RC_Code__c).Id : null;
                    userExt.Name = (eachUser.FirstName != null) ? (eachUser.FirstName + ' ' + eachUser.LastName) : eachUser.LastName;
                    userExtMap.put(userExt.Id, userExt);
                }
                if(eachUser.IsActive && (eachUser.IsActive != oldUser.IsActive) && userExt.OwnerId != eachUser.Id) {
                    userExt.OwnerId = eachUser.Id;
                    userExtMap.put(userExt.Id, userExt);
                }
            }
            if(eachUser.IsActive && ((eachUser.IsActive != oldUser.IsActive) || eachUser.RC_Code__c != oldUser.RC_Code__c)) {
                targetUser = User_Service.allUserMap.get(eachUser.Id);
                if(targetUser.Profile.Name != GlobalConstants.SME_RM && eachUser.RC_Code__c != null && User_Service.teamMapByRC.containsKey(eachUser.RC_Code__c)) {
                    eachTeam = User_Service.teamMapByRC.get(eachUser.RC_Code__c);
                    eachTeam.OwnerId = eachUser.Id;
                    updateTeamList.add(eachTeam);
                }
            }

            if((eachUser.Status__c == 'I' && (eachUser.Status__c != oldUser.Status__c)) || (eachUser.IsActive == false && (eachUser.IsActive != oldUser.IsActive))){
                userMask = new User_MaskModel(SME_CalculateOwnershipAssignment_Service.oldUserMap.get(eachUser.Id));
                userMask.setNewUser(eachUser);
                if(eachUser.Employee_ID__c != null)
                    userMaskMapByEmpId.put(eachUser.Employee_ID__c,userMask);
                hrisInActiveIds.add(eachUser.Id);
            } else if(eachUser.Job_Code__c != oldUser.Job_Code__c || eachUser.RC_Code__c != oldUser.RC_Code__c) {
                userMask = new User_MaskModel(SME_CalculateOwnershipAssignment_Service.oldUserMap.get(eachUser.Id));
                userMask.setNewUser(eachUser);

                userMapByNewRoleRC.put(eachUser.Job_Code__c + '-' + eachUser.RC_Code__c, eachUser);
                if(eachUser.Employee_ID__c != null)
                    userMaskMapByEmpId.put(eachUser.Employee_ID__c,userMask);
                hrisDiffIds.add(eachUser.Id);
            }

            if(!eachUser.IsActive){
                SME_GroupChatterService.addDeleteUserToList(eachUser, listDeleteMemberFromGroup);
            }else if(SME_GroupChatterService.isUserChangeNhRcCode(User_Service.allUserMap.get(eachUser.Id),User_Service.allOldUserMap.get(oldUser.Id))){
                SME_GroupChatterService.addDeleteUserToList(oldUser, listDeleteMemberFromGroup);
                SME_GroupChatterService.addUserToList(eachUser, listInsertMemberToGroup);
            }

        }
        if(!userExtMap.isEmpty())
            UserExtension_Service.updateUserExtension(JSON.serialize((List<User_Extension__c>) userExtMap.values()));
        if(!updateTeamList.isEmpty())
            TeamStructure_Service.updateTeamStructure(JSON.serialize(updateTeamList));

        if(userMaskMapByEmpId != null && userMaskMapByEmpId.size() > 0) {
            Database.executeBatch(new SME_CalculateOwnershipAssignment_Batch(userMaskMapByEmpId, userMapByNewRoleRC, hrisDiffIds, hrisInActiveIds));
        }

        if(!listDeleteMemberFromGroup.isEmpty()){
            delete listDeleteMemberFromGroup;
        }
        if(!listInsertMemberToGroup.isEmpty()){
            insert listInsertMemberToGroup;
        }
    }

    public override void afterInsert() {
        if(PROFILE_RM_ID == null) {
            try {
                PROFILE_RM_ID = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1].Id;
            } catch(Exception ex) {

            }
        }
        SME_Admin__c smeAdmin = SME_Admin__c.getOrgDefaults();
        List<User_Extension__c> userExtList = new List<User_Extension__c>();
        List<Team_Structure__c> updateTeamList = new List<Team_Structure__c>();
        List<CollaborationGroupMember> listInsertMemberToGroup = new List<CollaborationGroupMember>();
        Team_Structure__c eachTeam;
        User_Extension__c userExt;
        for(User eachUser : (List<User>)Trigger.new){
            if(eachUser.Employee_ID__c != null) {
                userExt = new User_Extension__c();

                if(eachUser.IsActive) {
                    userExt.OwnerId = eachUser.Id;
                    if(PROFILE_RM_ID != null && eachUser.Profile != null && eachUser.ProfileId != PROFILE_RM_ID && eachUser.RC_Code__c != null && User_Service.teamMapByRC.containsKey(eachUser.RC_Code__c)) {
                        eachTeam = User_Service.teamMapByRC.get(eachUser.RC_Code__c);
                        eachTeam.OwnerId = eachUser.Id;
                        updateTeamList.add(eachTeam);
                    }
                    SME_GroupChatterService.addUserToList(eachUser, listInsertMemberToGroup);
                } else {
                    userExt.OwnerId = smeAdmin.User_Record_ID__c;
                }

                userExt.User__c = eachUser.Id;
                userExt.Name = (eachUser.FirstName != null) ? (eachUser.FirstName + ' ' + eachUser.LastName) : eachUser.LastName;
                userExt.External_ID__c = eachUser.Employee_ID__c;

                if(User_Service.teamMapByRc.containsKey(eachUser.RC_Code__c)) 
                    userExt.Team_Structure__c = User_Service.teamMapByRc.get(eachUser.RC_Code__c).Id;
                userExtList.add(userExt);
            }
        }
        if(!userExtList.isEmpty()) {
            UserExtension_Service.insertUserExtension(JSON.serialize(userExtList));
        }
        if(!updateTeamList.isEmpty()) {
            TeamStructure_Service.updateTeamStructure(JSON.serialize(updateTeamList));
        }
        if(!listInsertMemberToGroup.isEmpty()){
            insert listInsertMemberToGroup;
        }
    }
}