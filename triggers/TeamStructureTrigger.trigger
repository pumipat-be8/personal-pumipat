trigger TeamStructureTrigger on Team_Structure__c(before insert,after insert, before update, after update) {
	new TeamStructureTriggerHandler().run(); 
}