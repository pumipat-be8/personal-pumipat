public with sharing class CampaignMemberTriggerHandler extends TriggerHandler {
	public override void beforeInsert() {
		Set<Id> contactIds = new Set<Id>();
		Set<Id> campaignIds = new Set<Id>();
		for (CampaignMember campMember : (List<CampaignMember>) Trigger.new) {
			if(campMember.CampaignId!=null){
				contactIds.add(campMember.ContactId);
				campaignIds.add(campMember.CampaignId);
			}
		}

		// Map Campaign Member Contact Id by Customer Name 
		Map<Id, Id> mapMemberContactByAccId = new Map<Id, Id>();
		List<Id> accountIds = new List<Id>();
		Map<Id, Contact> mapContacts = new Map<Id, Contact>([SELECT Id, Customer_Name__c, AccountId, Phone_Number__c FROM Contact WHERE Id IN :contactIds]);
		for (Contact eachContact : mapContacts.values()) {
			accountIds.add(eachContact.AccountId);
			mapMemberContactByAccId.put(eachContact.Id, eachContact.AccountId);
		}

		Set<String> etsAccountAndCampaignString = new Set<String>();
		for (Event_Target_List__c ets : [SELECT Id,CIS_ID_Prospect_Name__c,Event_Name__c FROM Event_Target_List__c WHERE CIS_ID_Prospect_Name__c IN :accountIds AND Event_Name__c IN :campaignIds]) {
			if(ets.CIS_ID_Prospect_Name__c!=null && ets.Event_Name__c!=null) {
				etsAccountAndCampaignString.add(ets.CIS_ID_Prospect_Name__c+' '+ets.Event_Name__c);
			}
		}

		for (CampaignMember campMember : (List<CampaignMember>) Trigger.new) {
			if (!(campMember.ContactId!=null && campMember.CampaignId!=null && etsAccountAndCampaignString.contains(mapMemberContactByAccId.get(campMember.ContactId)+' '+campMember.CampaignId))) {
				campMember.addError(GlobalConstants.CANNOT_INSERT_CAMMEM);
			}
			if(campMember.ContactId != null && mapContacts.containsKey(campMember.ContactId)){
				campMember.Contact_Phone_Number__c = mapContacts.get(campMember.ContactId).Phone_Number__c;
			}
		}

	}
}