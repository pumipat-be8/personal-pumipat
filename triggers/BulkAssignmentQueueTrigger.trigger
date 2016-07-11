/**
* @author charnun.t@beryl8.com
* @08/04/2016 createddate
*/
trigger BulkAssignmentQueueTrigger on Bulk_Assignment_Queue__c (after update) {
	List<Bulk_Assignment_Queue__c> tempBulkAssignmentQueueList = Trigger.new;
	if(tempBulkAssignmentQueueList.size() == 1 && tempBulkAssignmentQueueList.get(0).Status__c == 'Execute'){
		SME_CalculateOwnershipAssignment_Service.executeBulkAssignmentBatch();
	}
}