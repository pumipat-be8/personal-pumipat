/**
* @author komsan.wi@beryl8.com
* @16/07/2015 createddate
* @21/09/2015 update
* @2/10/2015 add exception when cis has not be specify
* @27/01/2015 Add Temporary_Ownership_Flag__c = false
*/
public without sharing class CustomerOwnershipRequestTriggerHandler extends TriggerHandler{
    private Map<Id,Account> accountMap;
    private List<Account> accountList;
    private Map<Id,Year_End_Assignment__c> yearEndMap;
    private Map<Id,User> currentUserMap;
    private Map<String,Id> currentUserExtensionMap;
    private Map<String,Id> teamStructerMapByRC;
    private Map<Id,Year_End_Assignment__c> yearEndUpdateMap;
    private List<Year_End_Assignment_Selection__c> yearEndSelList;
    private SME_Admin__c sa;

    public override void allBefore() {
        Set<Id> accountSet = new Set<Id>();
        Set<Id> currentOwnerSet = new Set<Id>();
        accountList = new List<Account>();
        accountMap = new Map<Id,Account>();
        currentUserMap = new Map<Id,User>();
        currentUserExtensionMap = new Map<String,Id>();
        teamStructerMapByRC = new Map<String,Id>();

        Set<Id> yearEndSet = new Set<Id>();
        yearEndUpdateMap = new Map<Id,Year_End_Assignment__c>();
        yearEndSelList = new List<Year_End_Assignment_Selection__c>();
        yearEndMap = new Map<Id,Year_End_Assignment__c>();

        for(Customer_Ownership_Request__c eachOwnerRequest : (List<Customer_Ownership_Request__c>)Trigger.new){
            if(eachOwnerRequest.CIS_ID__c!=null) 
                accountSet.add(eachOwnerRequest.CIS_ID__c);
            else eachOwnerRequest.addError('This Request has no CIS.');

            if (eachOwnerRequest.Year_End_Assignment__c != null) {
                yearEndSet.add(eachOwnerRequest.Year_End_Assignment__c);
            }
            if(eachOwnerRequest.Current_Owner__c!=null) currentOwnerSet.add(eachOwnerRequest.Current_Owner__c);
            if(eachOwnerRequest.OwnerId!=null) currentOwnerSet.add(eachOwnerRequest.OwnerId);
        }
        currentOwnerSet.add(UserInfo.getUserId());
        accountMap = new Map<Id,Account>([SELECT Id,Port_Pool__c,Ownership_Text__c,Owner.Profile.Name,Customer_Owner_Release_Flag__c,Previous_Owner__c,Previous_Owner__r.Profile.Name,Primary_Segment_Code__c,Previous_Owner__r.Email,Customer_Owner_Changed_Date__c,OwnerId,RC_Code__c,Permanent_Owner_Extension__c FROM Account WHERE Id IN :accountSet]);
        yearEndMap = new Map<Id,Year_End_Assignment__c>([SELECT Id FROM Year_End_Assignment__c WHERE Id IN :yearEndSet]);
        currentUserMap = new Map<Id,User>([SELECT Id,Profile.Name,Name,ManagerId,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c,Employee_ID__c,Segment__c FROM User WHERE Id IN :currentOwnerSet]);
        Set<String> rcCodeSet = new Set<String>();
        for(User eachUser : currentUserMap.values()) {
            rcCodeSet.add(eachUser.RC_Code__c);
            rcCodeSet.add(eachUser.AH_RC_Code__c);
            rcCodeSet.add(eachUser.NH_RC_Code__c);
        }
        List<Team_Structure__c> teamStructureList = new List<Team_Structure__c>([SELECT Id, External_ID__c FROM Team_Structure__c WHERE External_ID__c IN :rcCodeSet]);
        for(Team_Structure__c eachTeam : teamStructureList) {
            teamStructerMapByRC.put(eachTeam.External_ID__c, eachTeam.Id);
        }

        List<User_Extension__c> userExtensionList = new List<User_Extension__c>([SELECT Id, User__c FROM User_Extension__c WHERE User__c IN :currentOwnerSet]);
        for(User_Extension__c eachExt : userExtensionList) {
            if(eachExt.User__c != null)
            currentUserExtensionMap.put(eachExt.User__c, eachExt.Id);
        }
        //system.assertEquals('test',accountObj.OwnerId+'');

    }
    public override void beforeInsert() {
        User currentUser = currentUserMap.get(UserInfo.getUserId());
        Customer_Ownership_Request__c eachOwnerRequest = (Customer_Ownership_Request__c)Trigger.new.get(0);
        Integer countOwnerRequest = [SELECT count() FROM Customer_Ownership_Request__c WHERE CIS_ID__c = :eachOwnerRequest.CIS_ID__c AND OwnerID = : UserInfo.getUserId() AND Approval_Status__c='Approval In Progress' LIMIT 1];

        if(eachOwnerRequest.CIS_ID__c!=null){
            Account accountObj = accountMap.get(eachOwnerRequest.CIS_ID__c);
            if(eachOwnerRequest.Request_Type__c == GlobalConstants.REQUEST_OWNERSHIP){
                //if(currentUser.Profile.Name!=GlobalConstants.SME_RM)
                //    Trigger.new.get(0).addError('Only RM can request for official ownership');
                //else 
                if(accountObj.OwnerId == currentUser.Id && accountObj.Port_Pool__c == 'Port')
                    Trigger.new.get(0).addError('Customer already in your port');
                else if(countOwnerRequest != 0)
                    Trigger.new.get(0).addError(System.Label.CANNOT_REQUEST_OWNERSHIP);
                else if(!(accountObj.Primary_Segment_Code__c=='SM' || accountObj.Primary_Segment_Code__c=='SR' || accountObj.Primary_Segment_Code__c=='LM' || accountObj.Primary_Segment_Code__c=='LR' || accountObj.Primary_Segment_Code__c=='UM' || accountObj.Primary_Segment_Code__c=='UR') && eachOwnerRequest.Request_Ownership_Type__c == GlobalConstants.PORT)
                    Trigger.new.get(0).addError('Other Customer cannot assign to Port');
                else if(accountObj.Owner.Profile.Name==GlobalConstants.SME_ADMIN && eachOwnerRequest.Request_Ownership_Type__c == GlobalConstants.POOL_TEMPORARY) {
                    Trigger.new.get(0).addError('Cannot request customer when ownership is pool and owner is SME Admin');
                }
                else{
                    Ownership_Service.fromTrigger = true;
                    Ownership_Service.createOwnerShip(accountObj , currentUser);
                }
            }else if(eachOwnerRequest.Request_Type__c == GlobalConstants.RELEASE_OWNERSHIP){

                if((accountObj.OwnerId == currentUser.Id && accountObj.Port_Pool__c == 'Port' && currentUser.Profile.Name=='SME-RM') || (accountObj.OwnerId == currentUser.Id && accountObj.Port_Pool__c != '' && currentUser.Profile.Name=='SME-TM')){
                    Ownership_Service.fromTrigger = true;
                    Ownership_Service.releaseOwnership(accountObj , currentUser);
                }else Trigger.new.get(0).addError('Customer must be in your port to release ownership');
            }
        }
    }
    public override void beforeUpdate() {
        sa = SME_Admin__c.getOrgDefaults();
        Set<String> teamReferSet = new Set<String>();
        Customer_Ownership_Request__c oldCustomerReqObj;
        for(Customer_Ownership_Request__c eachOwnerRequest : (List<Customer_Ownership_Request__c>)Trigger.new){
            oldCustomerReqObj = (Customer_Ownership_Request__c) Trigger.oldMap.get(eachOwnerRequest.Id);
            if(eachOwnerRequest.Refer_Out_Team__c != oldCustomerReqObj.Refer_Out_Team__c && (eachOwnerRequest.Refer_Out_Reason__c == 'Wrong Area' || eachOwnerRequest.Refer_Out_Reason__c == 'Other Team')) {
                teamReferSet.add(eachOwnerRequest.Refer_Out_Team__c);
            }
        }
        List<User_Extension__c> userExtList = new List<User_Extension__c>([SELECT Id, User__c, Team_Structure__c, Team_Structure__r.Name FROM User_Extension__c WHERE Team_Structure__r.Name IN :teamReferSet]);

        Map<Id, String> teamMapByUserId = new Map<Id, String>();

        Set<Id> assignUserIds = new Set<Id>();
        for(User_Extension__c eachUserExt : userExtList) {
            assignUserIds.add(eachUserExt.User__c);
            teamMapByUserId.put(eachUserExt.User__c, eachUserExt.Team_Structure__r.Name);
        }
        Map<String, User> userMapByTeamName = new Map<String, User>();
        List<User> assignUserList = new List<User>([SELECT Id,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.Manager.Email,Manager.Manager.Manager.Email,Profile.Name,Email,AH_Employee_ID__c,NH_Employee_ID__c FROM User WHERE IsActive = true AND Id IN :assignUserIds]);
        for(User eachUser : assignUserList) {
            if(teamMapByUserId.containsKey(eachUser.Id) && teamMapByUserId.containsKey(eachUser.Id)) {
                userMapByTeamName.put(teamMapByUserId.get(eachUser.Id), eachUser);
            }
        }

        Ownership_Service.updateRequestOwnership(accountMap, currentUserMap.get(UserInfo.getUserId()), (List<Customer_Ownership_Request__c>) Trigger.new);

        if(Ownership_Service.shareRecordToUpdate == null) {
            Ownership_Service.shareRecordToUpdate = new List<Customer_Ownership_Request__Share>();
        }
        Customer_Ownership_Request__Share ownerShareObj;
        User currentUser;
        User ownerUser;
        for(Customer_Ownership_Request__c eachOwnerRequest : (List<Customer_Ownership_Request__c>)Trigger.new){
            if(accountMap.containsKey(eachOwnerRequest.CIS_ID__c)){
                oldCustomerReqObj = (Customer_Ownership_Request__c) Trigger.oldMap.get(eachOwnerRequest.Id);
                Account accountRecord = accountMap.get(eachOwnerRequest.CIS_ID__c);
                if(accountRecord != null) {
                    if(eachOwnerRequest.Approval_Status__c != GlobalConstants.CANCEL && 
                        accountRecord.Previous_Owner__c != null && 
                        accountRecord.Previous_Owner__r.Profile.Name != GlobalConstants.SME_ADMIN && 
                        accountRecord.Previous_Owner__c != eachOwnerRequest.Requestor_TM__c && 
                        (eachOwnerRequest.Current_Owner__c==null || (eachOwnerRequest.Current_Owner__c!=null && currentUserMap.containsKey(eachOwnerRequest.Current_Owner__c) && 
                            accountRecord.Previous_Owner__c != currentUserMap.get(eachOwnerRequest.Current_Owner__c).ManagerId))){
                        eachOwnerRequest.Previous_Owner_Email__c = accountRecord.Previous_Owner__r.Email;
                    }

                    if(eachOwnerRequest.Approval_Status__c != GlobalConstants.CANCEL && eachOwnerRequest.OwnerId != eachOwnerRequest.Current_Owner__c && eachOwnerRequest.Current_Owner__c != oldCustomerReqObj.Current_Owner__c) {
                        ownerShareObj = new Customer_Ownership_Request__Share();
                        ownerShareObj.ParentId = eachOwnerRequest.Id;
                        ownerShareObj.UserOrGroupId = eachOwnerRequest.Current_Owner__c;
                        ownerShareObj.AccessLevel = 'Read';
                        ownerShareObj.RowCause = 'Manual';
                        Ownership_Service.shareRecordToUpdate.add(ownerShareObj);
                    }

                    if(eachOwnerRequest.Request_Type__c == GlobalConstants.REQUEST_OWNERSHIP){
                        if(!(accountRecord.Primary_Segment_Code__c=='SM' || accountRecord.Primary_Segment_Code__c=='SR' || accountRecord.Primary_Segment_Code__c=='LM' || accountRecord.Primary_Segment_Code__c=='LR' || accountRecord.Primary_Segment_Code__c=='UM' || accountRecord.Primary_Segment_Code__c=='UR') && eachOwnerRequest.Request_Ownership_Type__c == GlobalConstants.PORT)
                            eachOwnerRequest.addError('Other Customer cannot assign to Port');
                        if(accountRecord.Owner.Profile.Name==GlobalConstants.SME_ADMIN && eachOwnerRequest.Request_Ownership_Type__c == GlobalConstants.POOL_TEMPORARY)
                            eachOwnerRequest.addError('Cannot request customer when ownership is pool and owner is SME Admin');
                    }

                    // Status Approved
                    if(eachOwnerRequest.Approval_Status__c==GlobalConstants.APPROVED){
                        if(eachOwnerRequest.Request_Type__c == GlobalConstants.REQUEST_OWNERSHIP){
                            if (eachOwnerRequest.Year_End_Assignment__c == null) {
                                if(eachOwnerRequest.Request_Ownership_Type__c == GlobalConstants.PORT) {
                                    accountRecord.Port_Pool__c = GlobalConstants.PORT;    
                                } else {
                                    if(accountRecord.Ownership_Text__c == GlobalConstants.OWNERSHIP_PERMANENT) {
                                        if(eachOwnerRequest.Current_Owner_TM__c!=null)
                                            accountRecord.Permanent_Owner__c = eachOwnerRequest.Current_Owner_TM__c;
                                        else if(eachOwnerRequest.Current_Owner_AH__c!=null)
                                            accountRecord.Permanent_Owner__c = eachOwnerRequest.Current_Owner_AH__c;
                                        else if(eachOwnerRequest.Current_Owner_NH__c!=null)
                                            accountRecord.Permanent_Owner__c = eachOwnerRequest.Current_Owner_NH__c;
                                    }
                                        
                                    accountRecord.Port_Pool__c = GlobalConstants.POOL;
                                    //if(accountRecord.Ownership_Text__c == GlobalConstants.OWNERSHIP_PERMANENT)
                                    //    Account_OwnerChange_Service.ownershipRequestPool = true;
                                }
                                
                                accountRecord.OwnerId = eachOwnerRequest.OwnerId;
                                accountRecord.Temporary_Ownership_Flag__c = false;
                                accountRecord.OwnerChangeExecutedByTrigger__c = true;
                                Account_OwnerChange_Service.callingFromYearEndBatch = false;
                                
                                if(currentUserExtensionMap.containsKey(eachOwnerRequest.Current_Owner__c))
                                    accountRecord.Previous_Owner_Extension__c = currentUserExtensionMap.get(eachOwnerRequest.Current_Owner__c);
                                
                                currentUser = currentUserMap.get(eachOwnerRequest.Current_Owner__c);
                                if(teamStructerMapByRC.containsKey(currentUser.AH_RC_Code__c))
                                    accountRecord.Previous_AH_Name__c = teamStructerMapByRC.get(currentUser.AH_RC_Code__c);
                                if(teamStructerMapByRC.containsKey(currentUser.NH_RC_Code__c))
                                    accountRecord.Previous_NH_Name__c = teamStructerMapByRC.get(currentUser.NH_RC_Code__c);
                                if(teamStructerMapByRC.containsKey(currentUser.RC_Code__c))
                                    accountRecord.Previous_Team_Name__c = teamStructerMapByRC.get(currentUser.RC_Code__c);

                                accountRecord.Last_CallReprt_Opty_Updated_Date__c = System.now();
                                accountRecord.Service_RM__c = null;

                                accountList.add(accountRecord);
                            } else {
                                if (yearEndMap.containsKey(eachOwnerRequest.Year_End_Assignment__c)) {
                                    Year_End_Assignment__c yearEnd = yearEndMap.get(eachOwnerRequest.Year_End_Assignment__c);
                                    // TODO : Check role is ah
                                    if (eachOwnerRequest.Requestor_AH__c != null) {
                                        yearEnd.OwnerId = eachOwnerRequest.Requestor_AH__c;
                                    }
                                    yearEnd.Final_Assigned_RM__c = eachOwnerRequest.OwnerId;
                                    yearEnd.Final_Port_Pool__c = eachOwnerRequest.Assigned_Port_Pool__c;
                                    yearEnd.Final_Service_RM__c = eachOwnerRequest.Service_RM_User__c;
                                    yearEnd.Status__c = GlobalConstants.STATUS_NEW;
                                    //yearEnd.Service_RM__c = eachOwnerRequest.Service_RM__c;

                                    yearEndUpdateMap.put(yearEnd.Id,yearEnd);
                                    yearEndSelList.add(new Year_End_Assignment_Selection__c(
                                        Year_End_Assignment__c = yearEnd.Id,
                                        Selected_By__c = eachOwnerRequest.OwnerId,
                                        Refer_Out__c = false
                                    ));
                                }
                            }
                        }else if(eachOwnerRequest.Request_Type__c == GlobalConstants.RELEASE_OWNERSHIP){
                            if(eachOwnerRequest.Refer_Out_Reason__c!='Other Team' && eachOwnerRequest.Refer_Out_Reason__c!='Wrong Area'){
                                accountRecord.OwnerChangeExecutedByTrigger__c = true;
                                if (eachOwnerRequest.Refer_Out_Reason__c == 'TM Pool') {
                                    Account_OwnerChange_Service.isTMPool = true;
                                    Account_OwnerChange_Service.isChangeOwnership = true;
                                    accountRecord.Port_Pool__c = GlobalConstants.POOL;
                                    accountRecord.OwnerId = eachOwnerRequest.Current_Owner__c;
                                    accountRecord.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
                                    accountRecord.Temporary_Ownership_Flag__c = false;
                                    accountRecord.Previous_Owner__c = null;
                                    if (eachOwnerRequest.Service_RM__c == 'Yes') {
                                        accountRecord.Service_RM__c = eachOwnerRequest.OwnerId;
                                    }
                                } else if (eachOwnerRequest.Refer_Out_Reason__c == 'Bad' || eachOwnerRequest.Refer_Out_Reason__c == 'Dead' || eachOwnerRequest.Refer_Out_Reason__c == 'Closed Business' || eachOwnerRequest.Refer_Out_Reason__c == 'AMLO List' || eachOwnerRequest.Refer_Out_Reason__c == 'Exit Plan' || eachOwnerRequest.Refer_Out_Reason__c == 'Criminal Offense') {
                                    accountRecord.Previous_Owner__c = null;
                                    accountRecord.Service_RM__c = null;
                                    accountRecord.OwnerId = sa.User_Record_ID__c;
                                } 
                                //else if (eachOwnerRequest.Refer_Out_Reason__c == GlobalConstants.REASON_NOT_SME) {}
                                accountList.add(accountRecord);
                            } else {
                                Account_OwnerChange_Service.callingFromYearEndBatch = false;
                                accountRecord.OwnerChangeExecutedByTrigger__c = true;
                                Account_OwnerChange_Service.isChangeOwnership = true;
                                accountRecord.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
                                accountRecord.Port_Pool__c = GlobalConstants.POOL;
                                accountRecord.OwnerId = eachOwnerRequest.Current_Owner__c;
                                accountRecord.Temporary_Ownership_Flag__c = false;

                                ownerUser = currentUserMap.get(eachOwnerRequest.OwnerId);
                                if(teamStructerMapByRC.containsKey(ownerUser.AH_RC_Code__c))
                                    accountRecord.Previous_AH_Name__c = teamStructerMapByRC.get(ownerUser.AH_RC_Code__c);
                                if(teamStructerMapByRC.containsKey(ownerUser.NH_RC_Code__c))
                                    accountRecord.Previous_NH_Name__c = teamStructerMapByRC.get(ownerUser.NH_RC_Code__c);
                                if(teamStructerMapByRC.containsKey(ownerUser.RC_Code__c))
                                    accountRecord.Previous_Team_Name__c = teamStructerMapByRC.get(ownerUser.RC_Code__c);

                                currentUser = currentUserMap.get(eachOwnerRequest.Current_Owner__c);
                                if(teamStructerMapByRC.containsKey(currentUser.AH_RC_Code__c))
                                    accountRecord.Permanent_AH_Name__c = teamStructerMapByRC.get(currentUser.AH_RC_Code__c);
                                if(teamStructerMapByRC.containsKey(currentUser.NH_RC_Code__c))
                                    accountRecord.Permanent_NH_Name__c = teamStructerMapByRC.get(currentUser.NH_RC_Code__c);
                                if(teamStructerMapByRC.containsKey(currentUser.RC_Code__c))
                                    accountRecord.Permanent_Team_Name__c = teamStructerMapByRC.get(currentUser.RC_Code__c);

                                if(teamStructerMapByRC.containsKey(currentUser.AH_RC_Code__c))
                                    accountRecord.Current_AH_Name__c = teamStructerMapByRC.get(currentUser.AH_RC_Code__c);
                                if(teamStructerMapByRC.containsKey(currentUser.NH_RC_Code__c))
                                    accountRecord.Current_NH_Name__c = teamStructerMapByRC.get(currentUser.NH_RC_Code__c);
                                if(teamStructerMapByRC.containsKey(currentUser.RC_Code__c))
                                    accountRecord.Current_Team_Name__c = teamStructerMapByRC.get(currentUser.RC_Code__c);

                                accountList.add(accountRecord);
                            }
                        }
                    } else { // Status != Approved
                        if(eachOwnerRequest.Request_Type__c == GlobalConstants.RELEASE_OWNERSHIP && eachOwnerRequest.Refer_Out_Team__c != oldCustomerReqObj.Refer_Out_Team__c && (eachOwnerRequest.Refer_Out_Reason__c == 'Wrong Area' || eachOwnerRequest.Refer_Out_Reason__c == 'Other Team')) {
                            currentUser = currentUserMap.get(eachOwnerRequest.Current_Owner__c);
                            User assignUser;
                            if(userMapByTeamName.containsKey(eachOwnerRequest.Refer_Out_Team__c)) {
                                assignUser = userMapByTeamName.get(eachOwnerRequest.Refer_Out_Team__c);
                            }

                            String tmString;
                            String ahString;
                            String nhString;
                            String currentOwner;
                            if(assignUser != null && assignUser.Profile.Name == GlobalConstants.SME_RM){
                                tmString = assignUser.ManagerId;
                                ahString = (assignUser.Manager!=null)?assignUser.Manager.ManagerId:null;
                                nhString = (assignUser.Manager!=null && assignUser.Manager.Manager!=null)?assignUser.Manager.Manager.ManagerId:null;
                            }
                            else if(assignUser != null && assignUser.Profile.Name == GlobalConstants.SME_TM){
                                tmString = assignUser.Id;
                                ahString = assignUser.ManagerId;
                                nhString = (assignUser.Manager!=null)?assignUser.Manager.ManagerId:null;
                            }
                            else if(assignUser != null && assignUser.Profile.Name == GlobalConstants.SME_AH){
                                ahString = assignUser.Id;
                                nhString = assignUser.ManagerId;
                            }
                            else if(assignUser != null && assignUser.Profile.Name == GlobalConstants.SME_NH){
                                nhString = assignUser.Id;
                            }

                            if(assignUser != null && assignUser.Manager != null)
                                currentOwner = assignUser.ManagerId;
                            else if(assignUser != null && assignUser.Manager.Manager != null)
                                currentOwner = assignUser.Manager.ManagerId;
                            else if(assignUser != null && assignUser.Manager.Manager.Manager != null)
                                currentOwner = assignUser.Manager.Manager.ManagerId;

                            eachOwnerRequest.Current_Owner__c = currentOwner;
                            eachOwnerRequest.Current_Owner_TM__c = tmString;
                            eachOwnerRequest.Current_Owner_AH__c = ahString;
                            eachOwnerRequest.Current_Owner_NH__c = nhString;
                        }
                    }
                }        
            }
        }
    }
    public override void afterInsert() {
        if(Ownership_Service.fromTrigger && Ownership_Service.shareRecordToUpdate!=null){
            for(Customer_Ownership_Request__Share ownershipShare : Ownership_Service.shareRecordToUpdate)
                ownershipShare.ParentId = (Id)Trigger.new.get(0).get('Id');
            insert Ownership_Service.shareRecordToUpdate;
            Ownership_Service.shareRecordToUpdate = null;
        }
    }

    public override void afterUpdate() {
        if(Ownership_Service.shareRecordToUpdate != null){
            insert Ownership_Service.shareRecordToUpdate;
            Ownership_Service.shareRecordToUpdate = null;
        }
    }

    public override void beforeFinally() {
        if(!accountList.isEmpty()){
            Account_OwnerChange_Service.triggerInitialCall = true;
            update accountList;
        }
        if(yearEndUpdateMap!=null && !yearEndUpdateMap.values().isEmpty()){
            delete [SELECT Id FROM Year_End_Assignment_Selection__c WHERE Year_End_Assignment__c IN :yearEndUpdateMap.keySet()];
            update yearEndUpdateMap.values();
        }
        if(!yearEndSelList.isEmpty()){
            insert yearEndSelList;
        }

    }
}