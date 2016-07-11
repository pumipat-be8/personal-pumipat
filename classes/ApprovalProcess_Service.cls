public without sharing class ApprovalProcess_Service {
    public static void reassignApproval(Map<Id, Bulk_Assignment__c> assignMapByCurrentUser) {
    	// Requestor
    	Map<Id, Customer_Ownership_Request__c> ownerRequestMap = new Map<Id, Customer_Ownership_Request__c>([SELECT Id, Approval_Status__c, OwnerId, Current_Owner__c FROM Customer_Ownership_Request__c WHERE Approval_Status__c = 'Approval In Progress']);

    	List<Customer_Ownership_Request__c> ownerReqUpdateList = new List<Customer_Ownership_Request__c>();
		for(Customer_Ownership_Request__c ownerReq : ownerRequestMap.values()) {
			if(assignMapByCurrentUser.containsKey(ownerReq.Current_Owner__c)) {
				Bulk_Assignment__c assignment = assignMapByCurrentUser.get(ownerReq.Current_Owner__c);
				ownerReq.Current_Owner__c = assignment.AssignmentOwner__c;
				ownerReqUpdateList.add(ownerReq);
			} else if(assignMapByCurrentUser.containsKey(ownerReq.OwnerId)) {
				//Requestor
				ownerReq.Approval_Status__c = 'Cancel';// Workflow do this
				ownerReqUpdateList.add(ownerReq);
			}
		}
		
		if(ownerReqUpdateList.size() > 0) update ownerReqUpdateList;

		List<ProcessInstanceWorkitem> workItemList = new List<ProcessInstanceWorkitem>();
		List<Approval.ProcessWorkitemRequest> workItemRequestList = New List<Approval.ProcessWorkItemRequest>();
		List<ProcessInstance> processInstanceList = new List<ProcessInstance>();
		processInstanceList = [Select ID, TargetObjectId, 
                (SELECT Id, ActorId, OriginalActorId FROM Workitems) From ProcessInstance Where Status = 'Pending' AND TargetObjectId IN :ownerRequestMap.keySet()];

        Customer_Ownership_Request__c ownerReq;
        Approval.ProcessWorkitemRequest workItemRequest;
        Bulk_Assignment__c assignment;
		for(ProcessInstance pInstance : processInstanceList){
			if(ownerRequestMap.containsKey(pInstance.TargetObjectId)) {
				ownerReq = ownerRequestMap.get(pInstance.TargetObjectId);
				for(ProcessInstanceWorkItem workItem : pInstance.WorkItems){
					//Requestor
					if(ownerReq.Approval_Status__c == 'Cancel') {
						workItemRequest = new Approval.ProcessWorkitemRequest();
		                workItemRequest.setWorkItemID(workItem.id);
		                workItemRequest.setComments('Cancel request/release customer');
		                workItemRequest.setAction('Reject');
		                workItemRequestList.add(workItemRequest);
		                break;
					}
					// Approver
					if(assignMapByCurrentUser.containsKey(workItem.ActorId)) {
						assignment = assignMapByCurrentUser.get(workItem.ActorId);
						workItem.ActorId = assignment.AssignmentOwner__c;
						//workItem.OriginalActorId = assignment.AssignmentOwner__c;
						workItemList.add(workItem);
						break;
					}
				}
			}
        }

        if(!workItemRequestList.isEmpty()) {
        	Approval.ProcessResult[] appResult = Approval.process(workItemRequestList);
        }

        if(!workItemList.isEmpty())
        	update workItemList;

    }
}