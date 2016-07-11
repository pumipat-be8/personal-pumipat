public without sharing class TeamStructure_Service {
    public static Map<String, User> userMapByRCCode;
    public static Map<String, Team_Structure__c> teamMapByRCCode;

    public static Map<String, User> getUserMapByRCCode() {
        Set<String> profileSet = new Set<String>{GlobalConstants.SME_NH, GlobalConstants.SME_AH, GlobalConstants.SME_TM};
        List<User> allUser = [SELECT Id, RC_Code__c, IsActive, ManagerId, Manager.ManagerId, Manager.IsActive, Manager.Manager.IsActive, Manager.Manager.Manager.IsActive FROM User WHERE Profile.Name IN :profileSet ORDER BY Isactive DESC, LastModifiedDate DESC];
        Map<String, User> userMapByRC = new Map<String, User>();
        for(User eachUser : allUser) {
            if(!userMapByRC.containsKey(eachUser.RC_Code__c) && eachUser.RC_Code__c != null)
                userMapByRC.put(eachUser.RC_Code__c, eachUser);
        }

        return userMapByRC;
    }

	public static void reassignOwner(Map<Id, Bulk_Assignment__c> assignMapByCurrentUser, Map<Id, User> newUserMap) {
        List<Team_Structure__c> updateTeamList = new List<Team_Structure__c>();
        updateTeamList = [SELECT Id, OwnerId, RC_Code__c FROM Team_Structure__c WHERE OwnerId IN:assignMapByCurrentUser.keyset()];
        User eachNewUser;
        for(Team_Structure__c eachTeam : updateTeamList) {
            if(newUserMap.containsKey(eachTeam.OwnerId)) {
                eachNewUser = newUserMap.get(eachTeam.OwnerId);
            }
            if(eachNewUser != null && assignMapByCurrentUser.containsKey(eachTeam.OwnerId) && (eachNewUser.Isactive == false || eachNewUser.RC_Code__c != eachTeam.RC_Code__c)) {
                eachTeam.OwnerId = assignMapByCurrentUser.get(eachTeam.OwnerId).AssignmentOwner__c;
            }
        }
        if(updateTeamList.size() > 0)
            update updateTeamList;
    }

    @future
    public static void updateTeamStructure(String teamStringList) {
        List<Team_Structure__c> teamList = (List<Team_Structure__c>) JSON.deserialize(teamStringList, List<Team_Structure__c>.class);
        update teamList;
    }
}