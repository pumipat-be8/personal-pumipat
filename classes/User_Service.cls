public class User_Service {
    public static Map<Id, User> allUserMap;
    public static Map<Id, User> allOldUserMap;
    public static Map<String, User_Extension__c> userExtensionMapByUserId;
    public static Map<String, Team_Structure__c> teamMapByRC;

    public static Map<String, User_Extension__c> getUserExtensionMapByUser() {
        List<User_Extension__c> userExtList = new List<User_Extension__c>();
        userExtList = [SELECT Id, User__c, OwnerId FROM User_Extension__c];
        Map<String, User_Extension__c>  userExtMapByUser = new Map<String, User_Extension__c> ();
        
        for(User_Extension__c eachUserExt : userExtList) {
            userExtMapByUser.put(eachUserExt.User__c, eachUserExt);
        }
        return userExtMapByUser;
    }

    public static Map<String, Team_Structure__c> getAllTeamStructureMapByRC() {
        List<Team_Structure__c> teamStructureList = new List<Team_Structure__c>();
        teamStructureList = [SELECT Id, External_ID__c, OwnerId, Segment__c, Name, Type__c,NH_RC_Code__c FROM Team_Structure__c];
        Map<String, Team_Structure__c> allTeamMapByRc = new Map<String, Team_Structure__c>();

        for(Team_Structure__c eachTeam : teamStructureList) {
            allTeamMapByRc.put(eachTeam.External_ID__c, eachTeam);
        }
        return allTeamMapByRc;
    }

    //public static void inactiveServiceRM(Map<Id, Bulk_Assignment__c> assignMapByCurrentUser) {
    //    List<Account> accountUpdateList = new List<Account>();
    //    accountUpdateList = [SELECT Id, Service_RM__c FROM Account WHERE Service_RM__c IN:assignMapByCurrentUser.keyset()];
    //    for(Account eachAccount : accountUpdateList) {
    //        if(assignMapByCurrentUser.containsKey(eachAccount.Service_RM__c)) {
    //            eachAccount.Service_RM__c = null;
    //        }
    //    }
    //    if(accountUpdateList.size() > 0)
    //        update accountUpdateList;
    //}
}