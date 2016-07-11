public without sharing class UserExtensionTriggerHandler extends TriggerHandler{
	public override void beforeUpdate() {
		User_Extension__c oldUserExt;
		Map<Id, User_Extension__c> userExtMap = new Map<Id, User_Extension__c>();

		for(User_Extension__c eachUserExt : (List<User_Extension__c>)Trigger.new) {
			oldUserExt = (User_Extension__c) Trigger.oldMap.get(eachUserExt.Id);
			if(eachUserExt.Team_Structure__c != null && eachUserExt.Team_Structure__c != oldUserExt.Team_Structure__c) {
				userExtMap.put(eachUserExt.Id,eachUserExt);
			}
		}

		if(!userExtMap.isEmpty()) {			
			UserExtension_Service.teamChange(userExtMap);
		}
	}

	 public override void afterUpdateFinally() {
        //if(UserExtension_Service.updateGlobalList!=null){
        //    update UserExtension_Service.updateGlobalList;
        //    UserExtension_Service.updateGlobalList = null;
        //}
    }
}