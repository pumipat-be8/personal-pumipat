/**
*@author pasakorn.p@beryl8.com
*@06/07/2016 created batch to set the Active_Opportunity__c field to have value
**/
global class SME_ActiveOpportunityInitial_Batch implements Database.Batchable<sObject>{
	global SME_ActiveOpportunityInitial_Batch() {
		
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		String query = 'SELECT Id, AccountId, Active_Opportunity__c FROM Opportunity';
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Opportunity> opportunityList){
		for(Opportunity eachOpportunity : opportunityList){
			eachOpportunity.Active_Opportunity__c = eachOpportunity.AccountId;
		}
		update opportunityList;
	}

	global void finish(Database.BatchableContext BC){

	}
}