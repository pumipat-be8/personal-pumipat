public without sharing class SME_BulkAssignment_Service {

	public static void bulkAssignment(List<Bulk_Assignment__c> bulkAssignList) {
		//List<Bulk_Assignment_Queue__c> bulkQueue = new List<Bulk_Assignment_Queue__c>();
		//bulkQueue = [SELECT Id FROM Bulk_Assignment_Queue__c WHERE Status__c = 'Execute' ORDER BY Name ASC];
		
		//List<Bulk_Assignment__c> bulkAssignList = new List<Bulk_Assignment__c>();
		//if(bulkQueue.size() > 0)
		//	bulkAssignList = [SELECT Id, BulkAssignmentQueue__c, CIS_ID__c, Permanent_Owner__c, AssignmentOwner__c, CurrentOwner__c, Port_Pool__c, Ownership__c, Service_RM__c FROM Bulk_Assignment__c WHERE BulkAssignmentQueue__r.Status__c = 'Execute' AND BulkAssignmentQueue__c = :bulkQueue.get(0).Id];

		List<Account> accountList = new List<Account>();
		Map<Id, Bulk_Assignment_Queue__c> updateBulkQueueMap = new Map<Id, Bulk_Assignment_Queue__c>();
		Bulk_Assignment_Queue__c queueBulk;
		Account eachAccount;
		for(Bulk_Assignment__c eachAssignment : bulkAssignList) {
			eachAccount = new Account (
	            Id = eachAssignment.CIS_ID__c,
	            OwnerChangeExecutedByTrigger__c = true,
	            OwnerId = eachAssignment.AssignmentOwner__c,
	            Permanent_Owner__c = eachAssignment.Permanent_Owner__c,
	            is_from_Bulk_Reassign__c = (eachAssignment.Ownership__c != null && eachAssignment.Ownership__c != ''),
	            Ownership_Text__c = eachAssignment.Ownership__c,
	            Service_RM__c = eachAssignment.Service_RM__c
	        );
	        if(eachAssignment.Permanent_Owner__c != null)
	        	eachAccount.Port_Pool__c = eachAssignment.Port_Pool__c;
			accountList.add(eachAccount);

	        eachAssignment.Status__c = 'Complete';
	        if(!updateBulkQueueMap.containsKey(eachAssignment.BulkAssignmentQueue__c))
	        	updateBulkQueueMap.put(eachAssignment.BulkAssignmentQueue__c, new Bulk_Assignment_Queue__c(Id = eachAssignment.BulkAssignmentQueue__c, Status__c = 'Complete', FinishTime__c = System.now()));
		}
        if(updateBulkQueueMap.size() > 0)
        	update updateBulkQueueMap.values();

        update bulkAssignList;
        update accountList;

        SME_BulkAssignment_Service.finish();
	}

	public static void finish() {
        Integer bulkQueueCount = [SELECT Count() FROM Bulk_Assignment_Queue__c WHERE Status__c = 'Execute'];
        if(bulkQueueCount > 0) {
        	SME_CalculateOwnershipAssignment_Service.executeBulkAssignmentBatch();
        }
	}
}