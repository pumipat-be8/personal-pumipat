global class SME_TeamStructureInitial_Batch implements Database.Batchable<sObject> {
	
	String query;
	
	global SME_TeamStructureInitial_Batch() {
		query = 'SELECT Id, RC_Code__c, AH_Name__c, AH_Name__r.OwnerId, NH_Name__c, NH_Name__r.OwnerId FROM Team_Structure__c';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Team_Structure__c> scope) {
   		SME_Admin__c smeAdmin = SME_Admin__c.getOrgDefaults();

   		if(TeamStructure_Service.userMapByRCCode == null)
   			TeamStructure_Service.userMapByRCCode = TeamStructure_Service.getUserMapByRCCode();

   		User eachUser;
		for(Team_Structure__c eachTeam : scope) {
			if(TeamStructure_Service.userMapByRCCode.containsKey(eachTeam.RC_Code__c)) {
				eachUser = TeamStructure_Service.userMapByRCCode.get(eachTeam.RC_Code__c);
				if(eachUser.IsActive)
					eachTeam.OwnerId = eachUser.Id;
				else if(eachUser.Manager != null && eachUser.Manager.IsActive)
		            eachTeam.OwnerId = eachUser.ManagerId;
		        else if(eachUser.Manager.Manager != null && eachUser.Manager.Manager.IsActive)
		            eachTeam.OwnerId = eachUser.Manager.ManagerId;
			} else if(eachTeam.AH_Name__c != null)
				eachTeam.OwnerId = eachTeam.AH_Name__r.OwnerId;
			else if(eachTeam.NH_Name__c != null)
				eachTeam.OwnerId = eachTeam.NH_Name__r.OwnerId;
			else
				eachTeam.OwnerId = smeAdmin.User_Record_ID__c;
		}
		update scope;
	}
	
	global void finish(Database.BatchableContext BC) {}
	
}