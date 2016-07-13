/**
* @author komsan.wi@beryl8.com
* @16/07/2015 created new
* @18/09/2015 update
*/
public class AccountTriggerHandler extends TriggerHandler{
    private List<Customer_Ownership_Request__c> customerRequestList;
    private List<Account_MaskModel> maskAccountList;
    private List<Account_MaskModel> maskAccountListForPortPool;
    private Set<Id> deletedAccountSet;
    private SME_Admin__c sa;
    public override void allBefore(){
        sa = SME_Admin__c.getOrgDefaults();
    }
    public override void beforeInsert() {
        if(Account_Service.allUserMap == null) {
            Account_Service.allUserMap = new Map<Id, User>([SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c FROM User]);
        }
        User currentUser = Account_Service.allUserMap.get(UserInfo.getUserId());

        if(UserExtension_Service.allUserExtMapByUser == null) 
            UserExtension_Service.allUserExtMapByUser = UserExtension_Service.getUserExtensionMapByUser();

        if(UserExtension_Service.allTeamMapByRc == null) 
            UserExtension_Service.allTeamMapByRc = UserExtension_Service.getAllTeamStructureMapByRC();

        for(Account eachAccount : (List<Account>)Trigger.new) {
            if(eachAccount.OwnerId != null)
                currentUser = Account_Service.allUserMap.get(eachAccount.OwnerId);
            // ADD Extension and Team Structure
            eachAccount.Current_Owner_Extension__c = UserExtension_Service.allUserExtMapByUser.get(currentUser.Id);
            eachAccount.Current_AH_Name__c = UserExtension_Service.allTeamMapByRc.get(currentUser.AH_RC_Code__c);
            eachAccount.Current_NH_Name__c = UserExtension_Service.allTeamMapByRc.get(currentUser.NH_RC_Code__c);
            eachAccount.Current_Team_Name__c = UserExtension_Service.allTeamMapByRc.get(currentUser.RC_Code__c);

            if(eachAccount.Ownership_Text__c == null || eachAccount.Ownership_Text__c == '') {
                eachAccount.Ownership_Text__c = GlobalConstants.OWNERSHIP_TEMPORARY;
            }
        }

        if(sa!=null){
            List<User> integrationUserList = new List<User>();//in:integrationIdSet
            integrationUserList = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId() AND Profile.Name = :GlobalConstants.INTEGRATION_USER];
            if(integrationUserList!=null && integrationUserList.size() > 0){
                Map<Id,User> integrationUserMap = new Map<Id,User>(integrationUserList);
                for(Account eachAccount : (List<Account>)Trigger.new){
                    if(integrationUserMap.containsKey(UserInfo.getUserId())) {
                        eachAccount.OwnerId = sa.User_Record_ID__c;
                    }
                }
            }
        }
    }
    public override void beforeUpdate() {
        Account oldRecord;
        System.debug(LoggingLevel.INFO,'In account0');
        if(sa!=null){
            System.debug('In account1');
            Set<Id> accSegmentUpdatedSet = new Set<Id>();
            for(Account eachAccount : (List<Account>)Trigger.new){
                if(eachAccount.Customer_Owner_Release_Flag__c){
                    eachAccount.OwnerChangeExecutedByTrigger__c = true;
                    eachAccount.Customer_Owner_Release_Flag__c = false;
                    eachAccount.Service_RM__c = null;

                    if(eachAccount.RecordTypeId == GlobalUtility.getRecordTypeAccountIdByName(GlobalConstants.SME_PROSPECT)) {
                        eachAccount.OwnerId = sa.User_Record_ID__c;
                        System.debug('In account2');
                    } else {

                        Ownership_Service.releaseOwnership(eachAccount);
                    }
                }
                oldRecord = (Account)Trigger.oldMap.get(eachAccount.Id);
                if(eachAccount.Primary_Segment_Code__c != null && eachAccount.Primary_Segment_Code__c != oldRecord.Primary_Segment_Code__c && !(eachAccount.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_LM 
                        || eachAccount.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_MI 
                        || eachAccount.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_PC 
                        || eachAccount.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_SM 
                        || eachAccount.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_TC 
                        || eachAccount.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_UM 
                        || eachAccount.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_XS)) {
                    accSegmentUpdatedSet.add(eachAccount.Id);
                }
            }
        
            customerRequestList = new List<Customer_Ownership_Request__c>();
            customerRequestList = [SELECT Id, CIS_ID__c, Refer_Out_Segment__c, Not_SME_Segment_Flag__c FROM Customer_Ownership_Request__c WHERE Approval_Status__c = :GlobalConstants.APPROVED AND Refer_Out_Reason__c = :GlobalConstants.REASON_NOT_SME AND Not_SME_Segment_Flag__c = false AND Refer_Out_Segment__c != null AND CIS_ID__c IN :accSegmentUpdatedSet];
            List<Customer_Ownership_Request__c> updateCustomerRelease = new List<Customer_Ownership_Request__c>();
            Account tempAccount;
            for(Customer_Ownership_Request__c eachRequest : customerRequestList) {
                if(Trigger.newMap.containsKey(eachRequest.CIS_ID__c)) {
                    tempAccount = (Account) Trigger.newMap.get(eachRequest.CIS_ID__c);
                    tempAccount.OwnerId = sa.User_Record_ID__c;
                    tempAccount.Service_RM__c = null;

                    eachRequest.Not_SME_Segment_Flag__c = true;
                    updateCustomerRelease.add(eachRequest);
                }
            }
            customerRequestList = updateCustomerRelease;
        }
        maskAccountList = new List<Account_MaskModel>();
        maskAccountListForPortPool = new List<Account_MaskModel>();
        for(Account eachAccount : (List<Account>)Trigger.new){
            oldRecord = (Account)Trigger.oldMap.get(eachAccount.Id);
            System.debug(LoggingLevel.INFO,'accounttrigger1');
            System.debug(LoggingLevel.INFO,''+eachAccount.Delete_Flag__c);
            System.debug(LoggingLevel.INFO,''+eachAccount.OwnerId);
            System.debug(LoggingLevel.INFO,''+oldRecord.OwnerId);
            if(eachAccount.Delete_Flag__c == false && eachAccount.OwnerId != null && oldRecord.OwnerId != eachAccount.OwnerId ) {
                eachAccount.Temporary_Ownership_Flag__c = Account_OwnerChange_Service.temporaryOwnershipFlag;
                eachAccount.Customer_Owner_Changed_Date__c = System.Today();
                System.debug('accounttrigger2');
                Account_MaskModel accountMaskModel = new Account_MaskModel(eachAccount);
                accountMaskModel.temporaryNewOwnerUserId = eachAccount.OwnerId;
                accountMaskModel.temporaryPreviousOwnerUserId = oldRecord.OwnerId;
                if(!Account_OwnerChange_Service.callingFromYearEndBatch) {
                    eachAccount.Previous_Owner__c = oldRecord.OwnerId;
                    eachAccount.Previous_Owner_Emp_ID__c = oldRecord.Owner_Emp_ID__c;
                    eachAccount.Previous_Owner_Segment_Code__c = oldRecord.Primary_Segment_Code__c;
                    eachAccount.Port_Pool_Flag_Previous_Owner__c = oldRecord.Port_Pool__c;
                    System.debug('accounttrigger3');
                    // Previous Extension Set
                    eachAccount.Previous_Owner_Extension__c = oldRecord.Current_Owner_Extension__c;
                    eachAccount.Previous_AH_Name__c = oldRecord.Current_AH_Name__c;
                    eachAccount.Previous_NH_Name__c = oldRecord.Current_NH_Name__c;
                    eachAccount.Previous_Team_Name__c = oldRecord.Current_Team_Name__c;
                }else {
                    // Year End Clear All
                    System.debug('Clear all');
                    eachAccount.Previous_Owner__c = null;
                    eachAccount.Previous_Owner_Emp_ID__c = null;
                    eachAccount.Previous_Owner_Segment_Code__c = null;
                    eachAccount.Port_Pool_Flag_Previous_Owner__c = null;
                    eachAccount.Service_RM__c = null;
                }
                maskAccountList.add(accountMaskModel);
            }else if(eachAccount.Port_Pool__c != null && oldRecord.Port_Pool__c != eachAccount.Port_Pool__c){
                Account_MaskModel accountMaskModel = new Account_MaskModel(eachAccount);
                accountMaskModel.temporaryNewOwnerUserId = eachAccount.OwnerId;
                accountMaskModel.temporaryPreviousOwnerUserId = oldRecord.OwnerId;
                maskAccountListForPortPool.add(accountMaskModel);
                System.debug('maskAccountListForPortPool::'+maskAccountListForPortPool);
            }
        }
    }
    public override void beforeUpdateFinally() {
        if(!maskAccountList.isEmpty()){
            Account_OwnerChange_Service.triggerInitialCall = true;
            Account_OwnerChange_Service.accountShareAfter = null;
            Account_OwnerChange_Service.ownerChange(maskAccountList);
        }
        if(!maskAccountListForPortPool.isEmpty()){
            Account_OwnerChange_Service.accountShareAfterForPortPool = null;
            Account_OwnerChange_Service.setAccountShareForPortPool(maskAccountListForPortPool);
        }
        if(sa != null && sa.User_Record_ID__c != null)
        for(Account eachAccount : (List<Account>)Trigger.new){
            if(((String)sa.User_Record_ID__c).contains(eachAccount.OwnerId) && eachAccount.Port_Pool__c!=null) {
                System.debug('Clear Port Pool');
                eachAccount.Port_Pool__c = null;
            }
        }
    }
    public override void afterUpdate() {
        deletedAccountSet = new Set<Id>();
        for(Account eachAccount : (List<Account>)Trigger.new){
            if(eachAccount.Delete_Flag__c == true){
                deletedAccountSet.add(eachAccount.Id);
            }
        }
    }
    public override void afterUpdateFinally() {
        TriggerHandler.bypass('AccountTriggerHandler');
        Account_OwnerChange_Service.accountTriggerMap = (Map<Id,Account>)Trigger.newMap;
        if(deletedAccountSet.size() > 0){
            delete [SELECT Id FROM Account WHERE Id in:deletedAccountSet];
            deletedAccountSet.clear();
        }
        if(Account_OwnerChange_Service.accountShareAfter!=null){
            insert Account_OwnerChange_Service.accountShareAfter;
            Account_OwnerChange_Service.accountShareAfter = null;
        }
        if(Account_OwnerChange_Service.accountShareAfterForPortPool!=null){
            System.debug('accountShareAfterForPortPool::'+Account_OwnerChange_Service.accountShareAfterForPortPool);
            insert Account_OwnerChange_Service.accountShareAfterForPortPool;
            Account_OwnerChange_Service.accountShareAfterForPortPool = null;
        }
        if(Account_OwnerChange_Service.updateGlobalList!=null){
            if(Account_OwnerChange_Service.updateGlobalList.size() > 10000) {
                Database.executeBatch(new SME_DML_Batch(Account_OwnerChange_Service.updateGlobalList),2000);
            } else {
                update Account_OwnerChange_Service.updateGlobalList;    
            }
            Account_OwnerChange_Service.updateGlobalList = null;
            Account_OwnerChange_Service.temporaryOwnershipFlag = false;
        }
        if(customerRequestList != null && customerRequestList.size() > 0)
            update customerRequestList;

        TriggerHandler.clearBypass('AccountTriggerHandler');
    }
}