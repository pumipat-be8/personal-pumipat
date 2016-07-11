trigger TargetListTrigger on Target_List__c (before insert, before update, after insert, after update, after delete) {
	new TargetListTriggerHandler().run();
}