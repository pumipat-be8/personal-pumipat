/**
* @author komsan.wi@beryl8.com
* @17/09/2015 create new
*/
global without sharing class YearEndAssignment_Webservice {
	global class CustomerObject{
		webservice String year_id;
		webservice String customer_id;
		webservice String cis_id;
        webservice Decimal selected_count;
		webservice String name;
		webservice String segment;
		webservice String high_value;
		webservice String flag_port;
		webservice String credit_status;
		webservice String existing_rm_name;
		webservice String team;
		webservice String tm_name;
		webservice String ah_name;
		webservice String nh_name;
        webservice String approval_status;
		global CustomerObject(Year_End_Assignment__c eachYearEnd,String approvalStatus){
			year_id = eachYearEnd.Id;
			customer_id = eachYearEnd.CIS_ID__r.Id;
			cis_id = eachYearEnd.CIS_ID_Unique__c;
            selected_count = eachYearEnd.Selected_Count__c;
			name = eachYearEnd.Customer_Name__c;
			segment = eachYearEnd.Segment_Original__c;
			high_value = eachYearEnd.High_Value_Flag__c;
			flag_port = eachYearEnd.Port_Pool__c;
			credit_status = eachYearEnd.Credit_Status__c;
			existing_rm_name = eachYearEnd.RM_Name__c;
			team = eachYearEnd.Team__c;
			tm_name = eachYearEnd.TM_Name__c;
			ah_name = eachYearEnd.AH_Name__c;
			nh_name = eachYearEnd.NH_Name__c;
            approval_status = approvalStatus;
		}
	}
	global class CustomerResponse {
        webservice Boolean success;
        webservice String errorMessage;
        webservice List<YearEndAssignment_Webservice.CustomerObject> records;
        global CustomerResponse() {
            success = true;
            records = new List<YearEndAssignment_Webservice.CustomerObject>();
        }
    }
    global class SelectedName {
        //webservice String selectedbyNamepanel;
        //webservice String portPoolpanel;
        //webservice String serviceRMpanel;
        webservice String selectedbyNameRequestpanel;
        webservice String portPoolRequestpanel;
        webservice String serviceRMRequestpanel;
    }
	webService static YearEndAssignment_Webservice.CustomerResponse createRequest(String selectNameString,List<String> yearlist) {
		YearEndAssignment_Webservice.CustomerResponse resp = new YearEndAssignment_Webservice.CustomerResponse();
        YearEndAssignment_Webservice.SelectedName selectName = (YearEndAssignment_Webservice.SelectedName)JSON.deserialize(selectNameString, YearEndAssignment_Webservice.SelectedName.class);
        Savepoint sp = Database.setSavepoint();
		try{
            system.debug(selectName);
            system.debug(yearlist);
            
            resp.success = true;

			List<Customer_Ownership_Request__c> ownerRequestList = new List<Customer_Ownership_Request__c>();
            List<Customer_Ownership_Request__Share> ownerRequestShareList = new List<Customer_Ownership_Request__Share>();
            List<Approval.ProcessSubmitRequest> approvalList = new List<Approval.ProcessSubmitRequest>();
            List<Year_End_Assignment__c> yearEndList = [SELECT Id,CIS_ID__c,RM_Employee_ID__c,OwnerId FROM Year_End_Assignment__c WHERE Id in :yearlist];
            /*Set<String> employeeIdSet = new Set<String>();
            for(Year_End_Assignment__c eachYearEnd : yearEndList){
                if(eachYearEnd.RM_Employee_ID__c!=null) employeeIdSet.add(eachYearEnd.RM_Employee_ID__c);
            }*/
            User currentUser = [SELECT Id,ManagerId FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
            //List<User> rmUserList = new List<User>();
            //Set<Id> userTargetSet = new Set<Id>();
            //Map<String,User> rmUserMapByEmployeeId = new Map<String,User>();
            //rmUserList = [SELECT Id,ManagerId,Manager.ManagerId,Employee_ID__c FROM User WHERE Employee_ID__c in:employeeIdSet LIMIT 1];
            //for(User eachRM : rmUserList){
                //rmUserMapByEmployeeId.put(eachRM.OwnerId,eachRM);
                //userTargetSet.add(eachRM.Id);
            //}
            //if(userTargetSet!=null && userTargetSet.size() > 0 ){
                List<Customer_Ownership_Request__c> currentRequest = new List<Customer_Ownership_Request__c>();
                String currentRequestName = (selectName!=null && selectName.selectedbyNameRequestpanel!=null)?selectName.selectedbyNameRequestpanel:UserInfo.getUserId();
                currentRequest = [SELECT Id,Year_End_Assignment__c,Approval_Status__c FROM Customer_Ownership_Request__c WHERE Year_End_Assignment__c IN :yearlist AND OwnerId =:currentRequestName AND (Approval_Status__c='Approval In Progress' OR Approval_Status__c='Open') ORDER BY CreatedDate DESC];

                if(currentRequest!=null && currentRequest.size() > 0){
                    resp.success = false;
                    resp.records = null;
                    resp.errorMessage = 'You have already make a request to this records';
                    return resp;
                }
            /*}else {
                resp.success = false;
                resp.records = null;
                resp.errorMessage = 'This Record has no Employee ID';
                return resp;
            }*/

            //if(currentUser.ManagerId!=null){
                for(Year_End_Assignment__c eachYearEnd : yearEndList){
                    //if(rmUserMapByEmployeeId!=null && rmUserMapByEmployeeId.containsKey(eachYearEnd.RM_Employee_ID__c)){
                        // && rmUserMapByEmployeeId.get(eachYearEnd.RM_Employee_ID__c).Manager!=null
                        ownerRequestList.add(new Customer_Ownership_Request__c(
                            Year_End_Assignment__c = eachYearEnd.Id,
                            OwnerId = (selectName!=null && selectName.selectedbyNameRequestpanel!=null && selectName.selectedbyNameRequestpanel!='')?selectName.selectedbyNameRequestpanel:UserInfo.getUserId(),
                            Service_RM_User__c = (selectName!=null && selectName.serviceRMRequestpanel!=null && selectName.serviceRMRequestpanel!='')?selectName.serviceRMRequestpanel:null,
                            Assigned_Port_Pool__c = (selectName!=null && selectName.portPoolRequestpanel!=null && selectName.portPoolRequestpanel!='')?selectName.portPoolRequestpanel:'Port',
                            Request_Type__c = GlobalConstants.REQUEST_OWNERSHIP,
                            Reason__c = GlobalConstants.YEAR_END_ASSIGNMENT,
                            CIS_ID__c = eachYearEnd.CIS_ID__c,
                            Requestor_AH__c = currentUser.ManagerId,
                            Requestor_TM__c = UserInfo.getUserId(),
                            Current_Owner__c = eachYearEnd.OwnerId
                        ));
                        /*
                        Current_Owner__c = (eachYearEnd.OwnerId!=null && rmUserMapByEmployeeId!=null && rmUserMapByEmployeeId.containsKey(eachYearEnd.OwnerId))?rmUserMapByEmployeeId.get(eachYearEnd.OwnerId).ManagerId:null,
                            Current_Owner_AH__c = (eachYearEnd.OwnerId!=null && rmUserMapByEmployeeId!=null && rmUserMapByEmployeeId.containsKey(eachYearEnd.OwnerId) && rmUserMapByEmployeeId.get(eachYearEnd.OwnerId).Manager!=null)?rmUserMapByEmployeeId.get(eachYearEnd.OwnerId).Manager.ManagerId:null*/
                    //}
                    /*else{
                        resp.success = false;
                        resp.records = null;
                        resp.errorMessage = 'Current User of this Year End has no AH Manager';
                        break;
                    }*/
                }
                if(resp.success && ownerRequestList.size() > 0){
                    insert ownerRequestList;
                    Approval.ProcessSubmitRequest eachApproval;
                    for(Customer_Ownership_Request__c eachRequest : ownerRequestList){

                        if(eachRequest.Current_Owner__c!=UserInfo.getUserId()){
                            
                            ownerRequestShareList.add(new Customer_Ownership_Request__Share(
                                ParentID = eachRequest.Id,
                                UserOrGroupId = eachRequest.Current_Owner__c,
                                AccessLevel = 'Edit'
                            ));
                        }
                        eachApproval = new Approval.ProcessSubmitRequest();
                        eachApproval.setComments('Submitting request for approval Customer Request.');
                        eachApproval.setObjectId(eachRequest.id);
                        eachApproval.setSubmitterId(UserInfo.getUserId());
                        eachApproval.setProcessDefinitionNameOrId('SME_Customer_Ownership_Request_Year_End');
                        eachApproval.setSkipEntryCriteria(true);

                        approvalList.add(eachApproval);
                    }
                    if(ownerRequestShareList!=null && ownerRequestShareList.size() > 0)
                        insert ownerRequestShareList;

                    Approval.ProcessResult result;
                    for(Approval.ProcessSubmitRequest eachApprovalForSubmit : approvalList){
                        //Approval.ProcessResult result = Approval.process(req1);
                        result = Approval.process(eachApprovalForSubmit);
                        //if(result.isSuccess())
                    }
                }
            /*}else {
                resp.success = false;
                resp.records = null;
                resp.errorMessage = 'You has no Manager';
                Database.rollback(sp);
            }*/
		}catch (Exception e) {
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            Database.rollback(sp);
        }
        return resp;
	}
 	webService static YearEndAssignment_Webservice.CustomerResponse getCustomers(String cis) { 
        YearEndAssignment_Webservice.CustomerResponse resp = new YearEndAssignment_Webservice.CustomerResponse();
        try{
        	List<Year_End_Assignment__c> yearEndList = new List<Year_End_Assignment__c>();
            yearEndList = Database.query('SELECT Id,Selected_Count__c,CIS_ID__r.Id,CIS_ID_Unique__c,Customer_Name__c,Segment_Original__c,High_Value_Flag__c,Port_Pool__c,Credit_Status__c,RM_Name__c,Team__c,TM_Name__c,AH_Name__c,NH_Name__c FROM Year_End_Assignment__c WHERE CIS_ID__r.CIS__c = \''+cis+'\' AND Status__c=\'New\'');
            if(yearEndList!=null && yearEndList.size() > 0){
                Map<Id,Year_End_Assignment__c> yearEndMap = new Map<Id,Year_End_Assignment__c>(yearEndList);
                Set<Id> availiableIds = new Set<Id>();
                List<UserRecordAccess> userRecList = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId =: UserInfo.getUserId() AND RecordId in: yearEndMap.keySet()];
                for(UserRecordAccess eachAccess : userRecList){
                    if(!eachAccess.HasReadAccess) availiableIds.add(eachAccess.RecordId);
                }
                //List<ProcessInstance> piList = new List<ProcessInstance>();
                Map<String,String> requestMap = new Map<String,String>();
                User userObj = [SELECT Id,RC_Code__c FROM User WHERE Id=: UserInfo.getUserId() LIMIT 1];
                Map<Id,User> userList = new Map<Id,User>([SELECT Id FROM User WHERE RC_Code__c=:userObj.RC_Code__c]);
                /*piList = [ Select Id,Status,TargetObjectId From ProcessInstance WHERE TargetObjectId =: yearEndMap.keySet()];*/
                List<Customer_Ownership_Request__c> currentRequest = new List<Customer_Ownership_Request__c>();
                currentRequest = [SELECT Id,Year_End_Assignment__c,Approval_Status__c FROM Customer_Ownership_Request__c WHERE Year_End_Assignment__c IN :yearEndMap.keySet() AND OwnerId IN :userList.keySet() AND (Approval_Status__c='Approval In Progress' OR Approval_Status__c='Open') ORDER BY CreatedDate DESC LIMIT 1];

                /*for(ProcessInstance eachPi : piList){
                    piMap.put(eachPi.TargetObjectId,eachPi.Status);
                }*/
                for(Customer_Ownership_Request__c eachRequest : currentRequest){
                    requestMap.put(eachRequest.Year_End_Assignment__c,eachRequest.Approval_Status__c);
                }
                
            	for(Year_End_Assignment__c eachYearEnd : yearEndList){
                    if(availiableIds.contains(eachYearEnd.Id))
                        resp.records.add(new YearEndAssignment_Webservice.CustomerObject(eachYearEnd,(requestMap!=null && requestMap.containsKey(eachYearEnd.Id))?requestMap.get(eachYearEnd.Id):null));
            	}
                if(resp.records.size() > 0){
                	resp.success = true;
                }else {
                    resp.success = false;
                    resp.records = null;
                    resp.errorMessage = 'No Records found.';
                }
            }else {
                resp.success = false;
                resp.records = null;
                resp.errorMessage = 'No Records found.';
            }
        }catch (Exception e) {
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
        }
        return resp;
    }   
}