public class UserExtension_Service {

	private String userExtId;
	private String userObjId;
	private String userObjName;
	private String userObjEmployeeId;
	private String userObjTeam;

	public static Map<String, Id> allTeamMapByRc;
	public static Map<Id, Team_Structure__c> allTeamStructureMap;
	public static Map<String, Id> allUserExtMapByUser;
	public static List<SObject> updateGlobalList;

	public UserExtension_Service(User_Extension__c userExt) {
		this.userObjId = userExt.User__c;
        this.userObjName = userExt.Name;
        this.userObjEmployeeId = userExt.External_ID__c;
        this.userObjTeam = userExt.Team_Structure__c;
        this.userExtId = userExt.Id;
	}

	public UserExtension_Service(User userObj) {
		this.userObjId = userObj.Id;
        this.userObjName = userObj.Name;
        this.userObjEmployeeId = userObj.Employee_ID__c;
	}

	public static Map<Id, User> getAllUserMapByUserExt() {
		Map<Id, User_Extension__c> userExtensionMap = new Map<Id, User_Extension__c>([SELECT Id, User__c FROM User_Extension__c]);
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id,IsActive,Profile.Name,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.IsActive,Manager.Manager.IsActive,Manager.Manager.Manager.IsActive FROM User]);
		Map<Id, User> resultMap = new Map<Id, User>();
		for(User_Extension__c eachUserExt : userExtensionMap.values()) {
			if(eachUserExt.User__c != null && userMap.containsKey(eachUserExt.User__c))
            	resultMap.put(eachUserExt.Id, userMap.get(eachUserExt.User__c));
        }
        return resultMap;
	}


	public static Map<String, Id> getUserExtensionMap(Set<String> empIds) {
		List<User_Extension__c> userExtList = new List<User_Extension__c>();
		userExtList = [SELECT Id, External_ID__c FROM User_Extension__c WHERE External_Id__c IN :empIds];
        Map<String, Id> userExtMapByEmpId = new Map<String, Id>();
		
		for(User_Extension__c eachUserExt : userExtList) {
            userExtMapByEmpId.put(eachUserExt.External_ID__c, eachUserExt.Id);
        }

        return userExtMapByEmpId;
	}

	public static Map<String, Id> getUserExtensionMapByUser() {
		List<User_Extension__c> userExtList = new List<User_Extension__c>();
		userExtList = [SELECT Id, User__c FROM User_Extension__c];
        Map<String, Id>  userExtMapByEmpId = new Map<String, Id> ();
		
		for(User_Extension__c eachUserExt : userExtList) {
            userExtMapByEmpId.put(eachUserExt.User__c, eachUserExt.Id);
        }

        return userExtMapByEmpId;
	}

	public static Map<String, Id> getAllTeamStructureMapByRC() {
		List<Team_Structure__c> teamStructureList = new List<Team_Structure__c>();
        teamStructureList = [SELECT Id, External_ID__c FROM Team_Structure__c];
		Map<String, Id> teamMapByRc = new Map<String, Id>();

        for(Team_Structure__c eachTeam : teamStructureList) {
            teamMapByRc.put(eachTeam.External_ID__c, eachTeam.Id);
        }
        return teamMapByRc;
	}

	public static Map<String, Id> getTeamStructureMap(Set<String> rcCodes) {
		List<Team_Structure__c> teamStructureList = new List<Team_Structure__c>();
        teamStructureList = [SELECT Id, External_ID__c FROM Team_Structure__c WHERE External_Id__c IN :rcCodes];
		Map<String, Id> teamMapByRc = new Map<String, Id>();

        for(Team_Structure__c eachTeam : teamStructureList) {
            teamMapByRc.put(eachTeam.External_ID__c, eachTeam.Id);
        }
        return teamMapByRc;
	}

	@future
	public static void insertUserExtension(String userExtStringList) {
		List<User_Extension__c> userExtList = (List<User_Extension__c>) JSON.deserialize(userExtStringList, List<User_Extension__c>.class);
		insert userExtList;
	}

	@future
	public static void updateUserExtension(String userExtStringList) {
		List<User_Extension__c> userExtList = (List<User_Extension__c>) JSON.deserialize(userExtStringList, List<User_Extension__c>.class);
		update userExtList;
	}

	//public static void reassignRelatedObject(Map<Id, Bulk_Assignment__c> assignMapByCurrentUser) {
	//	Map<Id, User_Extension__c> userExtMap = new Map<Id, User_Extension__c>(
	//	[SELECT Id, Team_Structure__c, Team_Structure__r.AH_Name__c, Team_Structure__r.NH_Name__c, User__c,
	//		(Select Id, Permanent_Owner_Extension__c, Permanent_Owner_Extension__r.User__c 
	//		FROM AccountsPermanentOwnerExtension__r WHERE Permanent_Owner_Extension__r.User__c IN :assignMapByCurrentUser.keySet())
	//	FROM User_Extension__c]);

	//	Map<String, User_Extension__c> userExtMapByUserId = new Map<String, User_Extension__c>();
	//	for(User_Extension__c eachUserExt : userExtMap.values()) {
 //           userExtMapByUserId.put(eachUserExt.User__c, eachUserExt);
 //       }

 //       List<Account> accountUpdateList = new List<Account>();
 //       Bulk_Assignment__c eachAssignment;
	//	for(User_Extension__c eachUserExt : userExtMap.values()) {			
	//		// Account
	//		for(Account eachAccount : eachUserExt.AccountsPermanentOwnerExtension__r) {
	//			eachAssignment = assignMapByCurrentUser.get(eachAccount.Permanent_Owner_Extension__r.User__c);
	//			if(eachAccount.Permanent_Owner_Extension__c != null && 
	//			assignMapByCurrentUser.containsKey(eachAccount.Permanent_Owner_Extension__r.User__c) &&
	//			userExtMapByUserId.containsKey(eachAssignment.AssignmentOwner__c)) {
	//				eachAccount.Permanent_Owner_Extension__c = userExtMapByUserId.get(eachAssignment.AssignmentOwner__c).Id;
	//				// Inactive extension dont find new team set
	//				//eachAccount.Permanent_Team_Name__c = userExtMapByUserId.get(eachAssignment.AssignmentOwner__c).Team_Structure__c;
	//				//eachAccount.Permanent_AH_Name__c = userExtMapByUserId.get(eachAssignment.AssignmentOwner__c).Team_Structure__r.AH_Name__c;
	//				//eachAccount.Permanent_NH_Name__c = userExtMapByUserId.get(eachAssignment.AssignmentOwner__c).Team_Structure__r.NH_Name__c;
	//				accountUpdateList.add(eachAccount);
	//			}
	//		}
	//	}

	//	if(accountUpdateList.size() > 0) 
	//		update accountUpdateList;
	//}

	public static void teamChange(Map<Id, User_Extension__c> userExtMap) {
		List<Opportunity> updateOppList = new List<SObject>();
		List<Call_Report__c> updateCallRepList = new List<Call_Report__c>();
		// Call Report
		List<Call_Report__c> callReportUpdateList = new List<Call_Report__c>();
        callReportUpdateList = [SELECT Id,Current_Owner_Extension__c,Status__c FROM Call_Report__c WHERE Current_Owner_Extension__c IN :userExtMap.keySet()];

        if(UserExtension_Service.allTeamStructureMap == null) {
        	UserExtension_Service.allTeamStructureMap = new Map<Id, Team_Structure__c>([SELECT Id, RC_Code__c, External_Id__c, AH_Name__c, NH_Name__c FROM Team_Structure__c]);
        } 

        if(callReportUpdateList!=null && callReportUpdateList.size() > 0){
            for(Call_Report__c eachCallReport : callReportUpdateList){
                if(userExtMap.containsKey(eachCallReport.Current_Owner_Extension__c) && eachCallReport.Status__c == GlobalConstants.PLAN) {
                    eachCallReport.Current_Team_Name__c = userExtMap.get(eachCallReport.Current_Owner_Extension__c).Team_Structure__c;
                    eachCallReport.Current_AH_Name__c = UserExtension_Service.allTeamStructureMap.get(eachCallReport.Current_Team_Name__c).AH_Name__c;
                    eachCallReport.Current_NH_Name__c = UserExtension_Service.allTeamStructureMap.get(eachCallReport.Current_Team_Name__c).NH_Name__c;
                    updateCallRepList.add(eachCallReport);
                }
            }
        }
        // Opportunity
        List<Opportunity> opportunityUpdateList = new List<Opportunity>();
        opportunityUpdateList = [SELECT Id,Current_Owner_Extension__c,StageName,IsClosed FROM Opportunity WHERE Current_Owner_Extension__c IN :userExtMap.keySet()];    

        if(UserExtension_Service.allTeamStructureMap == null) {
        	UserExtension_Service.allTeamStructureMap = new Map<Id, Team_Structure__c>([SELECT Id, RC_Code__c, External_Id__c, AH_Name__c, NH_Name__c FROM Team_Structure__c]);
        } 

        if(opportunityUpdateList!=null && opportunityUpdateList.size() > 0){
            for(Opportunity eachOpportunity : opportunityUpdateList){
                if(userExtMap.containsKey(eachOpportunity.Current_Owner_Extension__c) && !eachOpportunity.IsClosed && (eachOpportunity.StageName != GlobalConstants.PARTIAL_LOAN_SETUP && eachOpportunity.StageName!=GlobalConstants.ALL_LOAN_SETUP && eachOpportunity.StageName != GlobalConstants.AUTO_CLOSED && eachOpportunity.StageName != GlobalConstants.CLOSE_LOST)){
                    eachOpportunity.Current_Team_Name__c = userExtMap.get(eachOpportunity.Current_Owner_Extension__c).Team_Structure__c;
                    eachOpportunity.Current_AH_Name__c = UserExtension_Service.allTeamStructureMap.get(eachOpportunity.Current_Team_Name__c).AH_Name__c;
                    eachOpportunity.Current_NH_Name__c = UserExtension_Service.allTeamStructureMap.get(eachOpportunity.Current_Team_Name__c).NH_Name__c;
                    updateOppList.add(eachOpportunity);
                }
            }
        }
        TriggerHandler.bypass('OpportunityTriggerHandler');
        TriggerHandler.bypass('CallReportTriggerHandler');
        if(updateCallRepList.size() > 0) update updateCallRepList;
        if(updateOppList.size() > 0) update updateOppList;
        TriggerHandler.clearAllBypasses();
	}
}