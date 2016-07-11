public class CalculateOwnershipAssignment_Queue implements Queueable {
	public List<Bulk_Assignment__c> bulkAssignList;
	public boolean needToCreateQueue;

	public CalculateOwnershipAssignment_Queue(List<Bulk_Assignment__c> bulkAssignList) {
		this.bulkAssignList = bulkAssignList;
	}

	public CalculateOwnershipAssignment_Queue(List<Bulk_Assignment__c> bulkAssignList, Boolean needToCreateQueue) {
		this.bulkAssignList = bulkAssignList;
		this.needToCreateQueue = needToCreateQueue;
	}

	public void execute(QueueableContext context) {
		if(bulkAssignList != null && !bulkAssignList.isEmpty()) {
			if(needToCreateQueue != null && needToCreateQueue) {
				Bulk_Assignment_Queue__c bulkQueue = new Bulk_Assignment_Queue__c();
		        bulkQueue.Status__c = 'Create';
		        bulkQueue.StartTime__c = System.now();
		        insert bulkQueue;

				for(Bulk_Assignment__c eachAssign : bulkAssignList) {
					eachAssign.BulkAssignmentQueue__c = bulkQueue.Id;
				}

				insert bulkAssignList;
			}
			SME_BulkAssignment_Service.bulkAssignment(bulkAssignList);
		}
	}
}