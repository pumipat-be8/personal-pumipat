global class CampaignChangeStatus_Batch implements Database.Batchable<sObject>, Database.Stateful {
	
	global Set<Id> setCampaignIds;
	//global Set<Id> allAccountIds;
	String query;
	
	global CampaignChangeStatus_Batch(Set<Id> setCampaignIds) {
		//allAccountIds = new Set<Id>();
		if(this.setCampaignIds == null) {
			this.setCampaignIds = new Set<Id>();
		}
		this.setCampaignIds.addAll(setCampaignIds);
		List<Id> campaignIds = new List<Id>(setCampaignIds);
		this.query = 'SELECT CIS_ID_Prospect_Name__c, Lead_Campaign__r.Status, Lead_Campaign__r.Type__c FROM Target_List__c WHERE In_Call_Plan__c = false AND Lead_Campaign__c IN (\'' + String.join(campaignIds,'\',\'') + '\') AND (Lead_Campaign__r.Status = \'' + GlobalConstants.CANCEL_PROCESS + '\' OR Lead_Campaign__r.Status = \'' + GlobalConstants.EXPIRE_PROCESS + '\') AND Status__c = \'' + GlobalConstants.STATUS_NEW + '\' ORDER BY CIS_ID_Prospect_Name__c';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Target_List__c> targetList) {
		List<Target_List__c> updateTargetList = new List<Target_List__c>();
		Map<Id, List<Target_List__c>> mapTargetsByAccount = new Map<Id, List<Target_List__c>>();

		for (Target_List__c target : targetList) {
            if(target.Lead_Campaign__r.Status == GlobalConstants.CANCEL_PROCESS) {
                if (target.Lead_Campaign__r.Type__c != null) {
                    if (target.Lead_Campaign__r.Type__c == GlobalConstants.CAMPAIGN) {
                        target.Status__c = GlobalConstants.CANCEL_CAMPAIGN;
                    } else {
                        target.Status__c = GlobalConstants.CANCEL_LEAD;
                    }
                }
            } else if(target.Lead_Campaign__r.Status == GlobalConstants.EXPIRE_PROCESS) {
                target.Status__c = GlobalConstants.LEAD_EXPIRED;    
            } else {
            	continue;
            }

            updateTargetList.add(target);
            //allAccountIds.add(target.CIS_ID_Prospect_Name__c);
        }
        if (!updateTargetList.isEmpty()) {
        	TriggerHandler.bypass('TargetListTriggerHandler');
            update updateTargetList;
        }
	}
	
	global void finish(Database.BatchableContext BC) {
		List<Campaign> updateCampaigns = new List<Campaign>();
		List<Campaign> newCampaigns = new List<Campaign>();
		newCampaigns = [SELECT Id, Status FROM Campaign WHERE Id IN :setCampaignIds];
		for (Campaign eachCamp : newCampaigns) {
			if(eachCamp.Status == GlobalConstants.CANCEL_PROCESS) {
				eachCamp.Status = GlobalConstants.CANCEL;
			} else if (eachCamp.Status == GlobalConstants.EXPIRE_PROCESS) {
				eachCamp.Status = GlobalConstants.EXPIRED;
			} else {
				continue;
			}

			updateCampaigns.add(eachCamp);
		}
		if (!updateCampaigns.isEmpty()) update updateCampaigns;

		//Database.executeBatch(new AccountLeadUpdate_Batch(allAccountIds), 2000);
	}
	
}