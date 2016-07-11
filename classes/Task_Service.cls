public class Task_Service {
    public static void reassignTask(Map<Id, Bulk_Assignment__c> assignMapByCurrentUser) {
    	List<Task> taskList = new List<Task>();
    	taskList = [SELECT Id, OwnerId, WhoId, WhatId, Status FROM Task WHERE Status IN ('Not Started','In Progress','Waiting on someone else','Deferred') AND OwnerId IN:assignMapByCurrentUser.keyset() AND WhatId != null];
    	for(Task eachTask : taskList) {
    		if(assignMapByCurrentUser.containsKey(eachTask.OwnerId)) {
    			eachTask.Status = GlobalConstants.CLOSED_BY_SYSTEM;
    			//eachTask.OwnerId = assignMapByCurrentUser.get(eachTask.OwnerId).AssignmentOwner__c;
    		}
    	}
    	if(taskList.size() > 0)
    		update taskList;
    }
}