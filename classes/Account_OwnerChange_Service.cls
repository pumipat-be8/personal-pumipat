/**
* @author komsan.wi@beryl8.com
* @14/07/2015 createddate
* @27/01/2015 Add Temporary_Ownership_Flag__c = false
*/
public class Account_OwnerChange_Service {

    public static Boolean temporaryOwnershipFlag = false;
    public static Boolean updateContactPrefOnce = false;
    public static Boolean triggerInitialCall = false;
    public static Boolean callingFromYearEndBatch = false;
    public static Boolean isTMPool = false;
    public static Boolean isChangeOwnership = false;
    public static Boolean callReportRunOnce = false;
    //public static Boolean ownershipRequestPool = false;
    public static Boolean forceUnloadRelatedObject = false;
    public static List<Call_Report__c> callReportTriggerList;
    public static List<Opportunity> opportunityTriggerList;
    public static Map<Id,Account> accountTriggerMap;

    private static List<Pool_Visibility__c> poolVisibilityList;
    private static RecordType propectRecord;

    public static List<sObject> updateGlobalList;

    public static List<accountShare> accountShareAfter;
    public static List<accountShare> accountShareAfterForPortPool;
    public static Set<Id> gettingOwnerSet(List<Account_MaskModel> accountTargetList){
        Set<Id> ownerIdSet = new Set<Id>();
        for(Account_MaskModel eachMask : accountTargetList){
            ownerIdSet.add(eachMask.accObj.OwnerId);
            if(eachMask.accObj.Previous_Owner__c != null)
                ownerIdSet.add(eachMask.accObj.Previous_Owner__c);
            if(eachMask.accObj.Permanent_Owner__c != null)
                ownerIdSet.add(eachMask.accObj.Permanent_Owner__c);
            ownerIdSet.add(SME_Admin__c.getOrgDefaults().User_Record_ID__c);
            ownerIdSet.add(User_Admin__c.getOrgDefaults().User_Record_ID__c);
            if(eachMask.temporaryNewOwnerUserId!=null) ownerIdSet.add(eachMask.temporaryNewOwnerUserId);
            if(eachMask.temporaryPreviousOwnerUserId!=null) ownerIdSet.add(eachMask.temporaryPreviousOwnerUserId);
        }
        return ownerIdSet;
    }
    public static Map<Id,User> queryUserMap(Set<Id> ownerIdSet){
        Map<Id,User> ownerUserMap = new Map<Id,User>([SELECT Id,UserRole.Name,Employee_ID__c,AH_RC_CODE__c,NH_RC_CODE__c,UserRole.DeveloperName,Manager.UserRole.Name,Manager.UserRole.DeveloperName,Manager.Manager.UserRole.Name,Manager.Manager.UserRole.DeveloperName,IsActive,ProfileId,Profile.Name, ManagerId,Manager.Name,Manager.IsActive,Manager.ProfileId,Manager.Profile.Name,Manager.ManagerId,Manager.Manager.Name,Manager.Manager.IsActive,Manager.Manager.ProfileId,Manager.Manager.Profile.Name,RC_Code__c,Manager.Employee_ID__c,Manager.Manager.Employee_ID__c FROM User WHERE Id in: ownerIdSet]);
        return ownerUserMap;
    }
    
    public static Map<String,String> queryUserRole(){
        Map<String,String> userRoleMapping = new Map<String,String>();
        Map<Id,String> userRoleCodeMapping = new Map<Id,String>();
        List<UserRole> userRoleList =[SELECT DeveloperName,Id,ParentRoleId FROM UserRole];
        for(UserRole eachUserRole : userRoleList){
            userRoleCodeMapping.put(eachUserRole.Id,eachUserRole.DeveloperName);
        }
        for(UserRole eachUserRole : userRoleList){
            userRoleMapping.put(eachUserRole.DeveloperName, userRoleCodeMapping.get(eachUserRole.ParentRoleId));
        }
        return userRoleMapping;
    }
    
    public static List<String> getSharingGroupNameWithConfig(Account_MaskModel accountMaskObj,Map<String,String> userRoleMapping){
        //Sharing with Config sharing rule
        String rolePrefix = 'RC';
        Map<String,String> poolVisibilityRoleMap = new Map<String,String>();
        Map<String,List<String>> poolVisibilityGroupMap = new Map<String,List<String>>();
        if(poolVisibilityList == null)
            poolVisibilityList =[SELECT Group_Indicate__c,Name FROM Pool_Visibility__c];
            
        for(Pool_Visibility__c eachPoolVisibility : poolVisibilityList){
            poolVisibilityRoleMap.put(eachPoolVisibility.Name, eachPoolVisibility.Group_Indicate__c);
            if(poolVisibilityGroupMap.containsKey(eachPoolVisibility.Group_Indicate__c)){
                poolVisibilityGroupMap.get(eachPoolVisibility.Group_Indicate__c).add(eachPoolVisibility.Name);
            }else{
                List<String> roleList = new List<String>();
                roleList.add(eachPoolVisibility.Name);
                poolVisibilityGroupMap.put(eachPoolVisibility.Group_Indicate__c,roleList);
            }
        }
        if(accountMaskObj.isPoolAccount && (Account_Util.isProfile(GlobalConstants.SME_TM,accountMaskObj.ownerUser)||Account_Util.isProfile(GlobalConstants.SME_AH,accountMaskObj.ownerUser)||Account_Util.isProfile(GlobalConstants.SME_NH,accountMaskObj.ownerUser))){
            String userRCCode = '';
            if(accountMaskObj.ownerUser.RC_Code__c != null && accountMaskObj.ownerUser.RC_Code__c != ''){
                userRCCode = rolePrefix+accountMaskObj.ownerUser.RC_Code__c;
                Integer count = 1;
                do{
                    if(poolVisibilityRoleMap.containsKey(userRoleMapping.get(userRCCode))){
                        return poolVisibilityGroupMap.get(poolVisibilityRoleMap.get(userRoleMapping.get(userRCCode)));
                    }else{
                        userRCCode = userRoleMapping.get(userRCCode);
                    }
                    count++;
                }while(count < 11);
            }
        }

        return null; 
    }
    
    /*public static String getSharingGroupName(Account_MaskModel accountMaskObj){
        //sharing rule case
        // CaseAccessLevel
        //        ContactAccessLevel
        //        AccountAccessLevel
        //        AccountId
        //        OpportunityAccessLevel
        //        RowCause
        //        UserOrGroupId
        String rolePrefix = 'RC';
        if(accountMaskObj.isPoolAccount && Account_Util.isProfile(GlobalConstants.SME_TM,accountMaskObj.ownerUser)){
            if(accountMaskObj.ownerUser.Manager!=null)
                return accountMaskObj.ownerUser.Manager.UserRole.DeveloperName;
            else if(accountMaskObj.ownerUser.AH_RC_CODE__c!=null) return rolePrefix+accountMaskObj.ownerUser.AH_RC_CODE__c;
        }else if(accountMaskObj.isPoolAccount && Account_Util.isProfile(GlobalConstants.SME_AH,accountMaskObj.ownerUser)){
            return accountMaskObj.ownerUser.UserRole.DeveloperName;
        }else if(accountMaskObj.isPoolAccount && Account_Util.isProfile(GlobalConstants.SME_NH,accountMaskObj.ownerUser) && accountMaskObj.previousOwnerUser!=null){
            if(Account_Util.isProfile(GlobalConstants.SME_RM,accountMaskObj.previousOwnerUser)){
                if(accountMaskObj.previousOwnerUser.Manager!=null && accountMaskObj.previousOwnerUser.Manager.Manager!=null)
                    return accountMaskObj.previousOwnerUser.Manager.Manager.UserRole.DeveloperName;
                else if(accountMaskObj.previousOwnerUser.AH_RC_CODE__c!=null) return rolePrefix+accountMaskObj.previousOwnerUser.AH_RC_CODE__c;
                //return accountMaskObj.ownerUser.Manager.Manager.UserRole.DeveloperName;
            }
            if(Account_Util.isProfile(GlobalConstants.SME_TM,accountMaskObj.previousOwnerUser) && accountMaskObj.previousOwnerUser.Manager!=null){
                if(accountMaskObj.previousOwnerUser.Manager!=null)
                    return accountMaskObj.previousOwnerUser.Manager.UserRole.DeveloperName;
                else if(accountMaskObj.previousOwnerUser.AH_RC_CODE__c!=null) return rolePrefix+accountMaskObj.previousOwnerUser.AH_RC_CODE__c; 
                //return accountMaskObj.ownerUser.Manager.UserRole.DeveloperName;
            }
            if(Account_Util.isProfile(GlobalConstants.SME_AH,accountMaskObj.previousOwnerUser)){
                return accountMaskObj.previousOwnerUser.UserRole.DeveloperName;
                //return accountMaskObj.ownerUser.UserRole.DeveloperName;
            }
        }
        return null;
    }*/
    public static List<AccountShare> setAccountShareInsertList(List<String> accountIdByGroupNameList,Map<String,List<String>> accountIdByGroupNameMap){
        List<AccountShare> accountShareInsertList = new List<AccountShare>();
        if(!accountIdByGroupNameMap.isEmpty()){
            //have sharing rules to add
            List<Group> groupList = [SELECT Id,DeveloperName FROM Group WHERE DeveloperName in :accountIdByGroupNameList AND Type='RoleAndSubordinates'];
            for(String eachAccountId :accountIdByGroupNameMap.keyset()){
                for(Group eachGroup : groupList){
                    List<String> tempGroupList = accountIdByGroupNameMap.get(eachAccountId);
                    for(String eachtempGroup : tempGroupList){
                        if(eachGroup.DeveloperName == eachtempGroup){
                            accountShareInsertList.add(new AccountShare(
                                    CaseAccessLevel = 'none',
                                    OpportunityAccessLevel = 'none',
                                    AccountAccessLevel = 'read',
                                    AccountId = eachAccountId,
                                    UserOrGroupId = eachGroup.Id
                            ));
                        }
                    }
                }
                
            }
            if(!accountShareInsertList.isEmpty()){
                return accountShareInsertList;
            }
        }
        return accountShareInsertList;
    }

    public static void setAccountShareForPortPool(List<Account_MaskModel> accountTargetList){
        Map<String,List<String>> accountIdByGroupNameMap = new Map<String,List<String>>();
        Set<Id> accountOwnerSet = Account_OwnerChange_Service.gettingOwnerSet(accountTargetList);
        Map<Id,User> ownerUserMap = Account_OwnerChange_Service.queryUserMap(accountOwnerSet);
        Map<String,String> userRoleMapping = Account_OwnerChange_Service.queryUserRole();
        List<AccountShare> accountShareInsertList = new List<AccountShare>();
        List<String> accountIdByGroupNameList = new List<String>();
        Set<Id> sharingRuleDeleteSet = new Set<Id>();

        if(poolVisibilityList == null)
            poolVisibilityList =[SELECT Group_Indicate__c,Name FROM Pool_Visibility__c];
        for(Account_MaskModel maskObj : accountTargetList){
            maskObj
                .setPreviousOwner(ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId))
                .setOwner(ownerUserMap.get(maskObj.temporaryNewOwnerUserId));

            Id finalNewOwnerId = Account_OwnerChange_Service.getNewOwnerAssignment(maskObj);
            maskObj.setOwner(ownerUserMap.get(finalNewOwnerId));

            List<String> sharingGroupNameList = Account_OwnerChange_Service.getSharingGroupNameWithConfig(maskObj,userRoleMapping);
            System.debug('sharingGroupNameList For Port/Pool:'+maskObj.accObj+'::'+sharingGroupNameList);
            if(sharingGroupNameList!=null && sharingGroupNameList.size() > 0){
                accountIdByGroupNameList.addAll(sharingGroupNameList);
                accountIdByGroupNameMap.put(maskObj.accObj.Id, sharingGroupNameList);
            }
            if(maskObj.haveToDeletedSharingRule) sharingRuleDeleteSet.add(maskObj.accObj.Id);
        }
        accountShareInsertList = Account_OwnerChange_Service.setAccountShareInsertList(accountIdByGroupNameList,accountIdByGroupNameMap);
        if(!accountShareInsertList.isEmpty()){
            Account_OwnerChange_Service.accountShareAfterForPortPool = accountShareInsertList;
        }
        if(!sharingRuleDeleteSet.isEmpty()){
            delete [SELECT Id FROM AccountShare WHERE AccountId in :sharingRuleDeleteSet AND RowCause = 'Manual'];
        }
    }

    public static Id getNewOwnerAssignment(Account_MaskModel accountMaskObj){
        Id finalOwnerId = accountMaskObj.temporaryNewOwnerUserId;
        
        if(accountMaskObj.ownerInActive && !Account_Util.isProfile(GlobalConstants.SME_ADMIN, accountMaskObj.ownerUser)){
            if(accountMaskObj.managerOfOwnerActive){
                finalOwnerId = accountMaskObj.ownerUser.ManagerId;
            }else if(accountMaskObj.managerOfManagerOfOwnerActive){
                finalOwnerId = accountMaskObj.ownerUser.Manager.ManagerId;
            }else{
                //fallback case
                finalOwnerId = User_Admin__c.getOrgDefaults().User_Record_ID__c;
            }
        }
        return finalOwnerId;
    }

    public static void ownerChange(List<Account_MaskModel> accountTargetList){

        Set<Id> sharingRuleDeleteSet = new Set<Id>();
        //Set<String> sharingGroupNameSet = new Set<String>();
        Map<String,List<String>> accountIdByGroupNameMap = new Map<String,List<String>>();
        Set<Id> relatedUpdateSet = new Set<Id>();
        //List<Account> accountUpdateList = new List<Account>();
        List<sObject> updateList = new List<sObject>();
        List<AccountShare> accountShareInsertList = new List<AccountShare>();
        //get ownerset
        Set<Id> accountOwnerSet = Account_OwnerChange_Service.gettingOwnerSet(accountTargetList);
        //get user map by ownerset
        Map<Id,User> ownerUserMap = Account_OwnerChange_Service.queryUserMap(accountOwnerSet);
        // Add more feature to support account share with config
        Map<String,String> userRoleMapping = Account_OwnerChange_Service.queryUserRole();
        List<String> accountIdByGroupNameList = new List<String>();

        Set<String> accountOwnerRcCode = new Set<String>();
        //Set<String> accountOwnerEmp = new Set<String>();
        SME_Admin__c sa = SME_Admin__c.getOrgDefaults();
        User_Admin__c userAdmin = User_Admin__c.getOrgDefaults();

        for(Account_MaskModel maskObj : accountTargetList){
            if(ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId).Manager != null) {
                accountOwnerSet.add(ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId).ManagerId);
            } else if(ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId).Manager.Manager != null) {
                accountOwnerSet.add(ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId).Manager.ManagerId);
            } else if(ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId).Manager.Manager.Manager != null) {
                accountOwnerSet.add(ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId).Manager.Manager.ManagerId);
            }
        }
        System.debug('ownerUserMap:'+ownerUserMap);

        List<User_Extension__c> userExtList = new List<User_Extension__c>();
        userExtList = [SELECT Id, User__c, External_ID__c, Team_Structure__c, Team_Structure__r.RC_Code__c, Team_Structure__r.AH_RC_CODE__c, Team_Structure__r.NH_RC_CODE__c FROM User_Extension__c WHERE User__c IN :accountOwnerSet];
        List<Team_Structure__c> teamStructureList = new List<Team_Structure__c>();
        teamStructureList = [SELECT Id, External_ID__c FROM Team_Structure__c];

        Map<String, User_Extension__c> userExtMapByUserId = new Map<String, User_Extension__c>();
        for(User_Extension__c eachUserExt : userExtList) { 
            if(eachUserExt.User__c != null)
                userExtMapByUserId.put(eachUserExt.User__c, eachUserExt);
        }

        Map<String, Id> teamMapByRc = new Map<String, Id>();
        for(Team_Structure__c eachTeam : teamStructureList) { 
            teamMapByRc.put(eachTeam.External_ID__c, eachTeam.Id);
        }

        if(propectRecord == null)
            propectRecord = [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType ='Account' AND DeveloperName = :GlobalConstants.SME_PROSPECT_DEVNAME];

        if(poolVisibilityList == null)
            poolVisibilityList =[SELECT Group_Indicate__c,Name FROM Pool_Visibility__c];

        for(Account_MaskModel maskObj : accountTargetList){
            //set up owner and previous from input

            maskObj
                .setPreviousOwner(ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId))
                .setOwner(ownerUserMap.get(maskObj.temporaryNewOwnerUserId));

            Id finalNewOwnerId = Account_OwnerChange_Service.getNewOwnerAssignment(maskObj);
            /*
                previous owner id : maskObj.previousOwnerId
                current owner id : finalNewOwnerId
            */
            maskObj.setOwner(ownerUserMap.get(finalNewOwnerId)); //reassign just in case , new owner inactive
            //all process start here
            
            //doing sharing case
            /*String sharingGroupName = Account_OwnerChange_Service.getSharingGroupName(maskObj);
            if(sharingGroupName!=null)
                accountIdByGroupNameMap.put(maskObj.accObj.Id,sharingGroupName);*/

            List<String> sharingGroupNameList = Account_OwnerChange_Service.getSharingGroupNameWithConfig(maskObj,userRoleMapping);
            System.debug('sharingGroupNameList:'+maskObj.accObj+'::'+sharingGroupNameList);
            if(sharingGroupNameList!=null && sharingGroupNameList.size() > 0){
                accountIdByGroupNameList.addAll(sharingGroupNameList);
                accountIdByGroupNameMap.put(maskObj.accObj.Id, sharingGroupNameList);
            }
            
            if(maskObj.haveToDeletedSharingRule) sharingRuleDeleteSet.add(maskObj.accObj.Id);

            // Related list
            if(!Account_OwnerChange_Service.forceUnloadRelatedObject && maskObj.haveToUpdateRelatedObject) relatedUpdateSet.add(maskObj.accObj.Id);

            maskObj.accObj.OwnerId = finalNewOwnerId;
            maskObj.accObj.Temporary_Ownership_Flag__c = temporaryOwnershipFlag;
            maskObj.accObj.Customer_Owner_Release_Flag__c = false;

            // Set Extension and Team Structure
            maskObj.accObj.Current_Owner_Extension__c = userExtMapByUserId.containsKey(ownerUserMap.get(finalNewOwnerId).Id) ? userExtMapByUserId.get(ownerUserMap.get(finalNewOwnerId).Id).Id : null;
            
            // If one level up and Profile is AH or NH don't change Team Structure Set
            System.debug('newOwner Profile:'+ownerUserMap.get(finalNewOwnerId).Profile.Name);
            System.debug('Ownership_Text__c:'+maskObj.accObj.Ownership_Text__c);
            System.debug('maskObj.accObj.is_from_Bulk_Reassign__c:'+maskObj.accObj.is_from_Bulk_Reassign__c);
            if(ownerUserMap.get(finalNewOwnerId).Profile.Name == GlobalConstants.SME_AH && ownerUserMap.get(finalNewOwnerId).AH_RC_Code__c != ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId).AH_RC_Code__c) {
                maskObj.accObj.Current_AH_Name__c = teamMapByRc.get(ownerUserMap.get(finalNewOwnerId).AH_RC_Code__c);
                maskObj.accObj.Current_NH_Name__c = teamMapByRc.get(ownerUserMap.get(finalNewOwnerId).NH_RC_Code__c);
            } else if(ownerUserMap.get(finalNewOwnerId).Profile.Name == GlobalConstants.SME_NH && ownerUserMap.get(finalNewOwnerId).NH_RC_Code__c != ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId).NH_RC_Code__c) {
                maskObj.accObj.Current_NH_Name__c = teamMapByRc.get(ownerUserMap.get(finalNewOwnerId).NH_RC_Code__c);
            } else if(ownerUserMap.get(finalNewOwnerId).Profile.Name == GlobalConstants.SME_RM || ownerUserMap.get(finalNewOwnerId).Profile.Name == GlobalConstants.SME_TM || ownerUserMap.get(finalNewOwnerId).Profile.Name == GlobalConstants.SME_ADMIN) {
                maskObj.accObj.Current_AH_Name__c = teamMapByRc.get(ownerUserMap.get(finalNewOwnerId).AH_RC_Code__c);
                maskObj.accObj.Current_NH_Name__c = teamMapByRc.get(ownerUserMap.get(finalNewOwnerId).NH_RC_Code__c);
                maskObj.accObj.Current_Team_Name__c = teamMapByRc.get(ownerUserMap.get(finalNewOwnerId).RC_Code__c);
            }

            if(propectRecord != null && maskObj.accObj.RecordTypeId == propectRecord.Id) {
                // Prospect
                maskObj.accObj.Port_Pool__c = '';
                maskObj.accObj.Ownership_Text__c = GlobalConstants.OWNERSHIP_TEMPORARY;
            } else if(Account_OwnerChange_Service.isChangeOwnership || maskObj.accObj.is_from_Bulk_Reassign__c) {
                maskObj.accObj.is_from_Bulk_Reassign__c = false;
            } else {
                // Customer_Relationship__c
                if(maskObj.accObj.Port_Pool__c == GlobalConstants.PORT || 
                    ((maskObj.accObj.Current_Team_Name__c == maskObj.accObj.Permanent_Team_Name__c) && 
                        (maskObj.accObj.Permanent_Owner_Extension__c == maskObj.accObj.Current_Owner_Extension__c))) {
                    maskObj.accObj.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
                } else {
                    maskObj.accObj.Ownership_Text__c = GlobalConstants.OWNERSHIP_TEMPORARY;
                }
            }

            if(Account_Util.isProfile(GlobalConstants.SME_ADMIN, ownerUserMap.get(finalNewOwnerId)) && ((String)sa.User_Record_ID__c).contains(finalNewOwnerId)) {
                maskObj.accObj.Ownership_Text__c = null;
                maskObj.accObj.Permanent_Owner_Extension__c = null;
                maskObj.accObj.Permanent_AH_Name__c = null;
                maskObj.accObj.Permanent_NH_Name__c = null;
                maskObj.accObj.Permanent_Team_Name__c = null;
            }
            
            if(maskObj.accObj.Ownership_Text__c == GlobalConstants.OWNERSHIP_PERMANENT) {
                maskObj.accObj.Permanent_Owner_Extension__c = maskObj.accObj.Current_Owner_Extension__c;
                if(!((String)userAdmin.User_Record_ID__c).contains(finalNewOwnerId)) {
                    maskObj.accObj.Permanent_AH_Name__c = maskObj.accObj.Current_AH_Name__c;
                    maskObj.accObj.Permanent_NH_Name__c = maskObj.accObj.Current_NH_Name__c;
                    maskObj.accObj.Permanent_Team_Name__c = maskObj.accObj.Current_Team_Name__c;
                }
            }

            if(maskObj.accObj.Permanent_Owner__c != null && ownerUserMap.containsKey(maskObj.accObj.Permanent_Owner__c) && userExtMapByUserId.containsKey(ownerUserMap.get(maskObj.accObj.Permanent_Owner__c).Id)) {
                User_Extension__c tempExtension = userExtMapByUserId.get(ownerUserMap.get(maskObj.accObj.Permanent_Owner__c).Id);
                maskObj.accObj.Permanent_Owner_Extension__c = tempExtension.Id;
                maskObj.accObj.Permanent_AH_Name__c = teamMapByRc.get(tempExtension.Team_Structure__r.AH_RC_Code__c);
                maskObj.accObj.Permanent_NH_Name__c = teamMapByRc.get(tempExtension.Team_Structure__r.NH_RC_Code__c);
                maskObj.accObj.Permanent_Team_Name__c = teamMapByRc.get(tempExtension.Team_Structure__r.RC_Code__c);
                maskObj.accObj.Permanent_Owner__c = null;
            }

            // Ownership = Temporary and Port/Pool = Pool
            //if(Account_OwnerChange_Service.ownershipRequestPool && maskObj.accObj.Permanent_Team_Name__c != maskObj.accObj.Current_Team_Name__c) {
            //    if(ownerUserMap.containsKey(maskObj.temporaryPreviousOwnerUserId)) {
            //        if(ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId).Profile.Name == GlobalConstants.SME_TM && userExtMapByUserId.containsKey(ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId).Id)) {
            //            maskObj.accObj.Permanent_Owner_Extension__c = userExtMapByUserId.get(ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId).Id).Id;
            //        } else if(ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId).Manager != null && ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId).Manager.IsActive && userExtMapByUserId.containsKey(ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId).ManagerId)) {
            //            maskObj.accObj.Permanent_Owner_Extension__c = userExtMapByUserId.get(ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId).ManagerId).Id;
            //        } else if(ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId).Manager.Manager != null && ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId).Manager.Manager.IsActive && userExtMapByUserId.containsKey(ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId).Manager.ManagerId)) {
            //            maskObj.accObj.Permanent_Owner_Extension__c = userExtMapByUserId.get(ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId).Manager.ManagerId).Id;
            //        }
            //    }
            //}
            System.debug('finalMaskAcc:'+maskObj.accObj);
            //System.debug('each maskObj:'+maskObj);
            //if(maskObj.temporaryPreviousOwnerUserId!=null) maskObj.accObj.Previous_Owner_Emp_ID__c = ownerUserMap.get(maskObj.temporaryPreviousOwnerUserId).Employee_ID__c;
        }

        if(!sharingRuleDeleteSet.isEmpty())
            delete [SELECT Id FROM AccountShare WHERE AccountId in :sharingRuleDeleteSet AND RowCause = 'Manual'];

        // Re-factor to class setAccountShareInsertList
        accountShareInsertList = Account_OwnerChange_Service.setAccountShareInsertList(accountIdByGroupNameList,accountIdByGroupNameMap);
        if(!accountShareInsertList.isEmpty()){
            Account_OwnerChange_Service.accountShareAfter = accountShareInsertList;
        }

        //finish all work
        if(relatedUpdateSet.size() > 0){
            Set<Id> taskWhatIds = new Set<Id>();
            taskWhatIds.addAll(relatedUpdateSet);
            //call report

            /*if(cancelCallplanRecordTypeId !=null && cancelCallReportNoRecordTypeId !=null && cancelCallReportRecordTypeId !=null){
                if(Account_OwnerChange_Service.callReportTriggerList!=null){
                    //accountMap
                    for(Call_Report__c eachCallReport : Account_OwnerChange_Service.callReportTriggerList){
                        for(Account_MaskModel eachMask : accountTargetList){
                            if((eachMask.accObj.Id == eachCallReport.CIS_ID__c && eachMask.accObj.Port_Pool__c != null) || Account_Util.isProfile(GlobalConstants.SME_ADMIN, eachMask.ownerUser)){
                                if((eachCallReport.createdById!=null && eachMask.ownerUser.Id != eachCallReport.createdById) || (eachCallReport.createdById==null && eachMask.ownerUser.Id != UserInfo.getUserId())){

                                    if(eachCallReport.Status__c == GlobalConstants.PLAN){
                                        eachCallReport.Status__c = GlobalConstants.CLOSED;
                                        eachCallReport.RecordTypeId = cancelCallplanRecordTypeId;
                                    }else if(eachCallReport.Status__c == GlobalConstants.CONTACTED){
                                        if(eachCallReport.Plan_Date__c!=null)
                                            eachCallReport.RecordTypeId = cancelCallReportRecordTypeId;
                                        else eachCallReport.RecordTypeId = cancelCallReportNoRecordTypeId;
                                        eachCallReport.Status__c = GlobalConstants.CLOSED;
                                    }
                                }
                                break;
                            }
                        }
                    }
                }else{
                    List<Call_Report__c> callReportUpdateList = new List<Call_Report__c>();
                    callReportUpdateList = [SELECT Id,Plan_Date__c,Offer_Interest__c,CreatedById,CIS_ID__c,CIS_ID__r.OwnerId,RecordTypeId,Status__c,CIS_ID__r.Owner.ProfileId,CIS_ID__r.Port_Pool__c,CIS_ID__r.Owner.Profile.Name FROM Call_Report__c WHERE CIS_ID__c IN :relatedUpdateSet];
                    if(callReportUpdateList!=null && callReportUpdateList.size() > 0){
                        for(Call_Report__c eachCallReport : callReportUpdateList){
                            for(Account_MaskModel eachMask : accountTargetList){
                                if((eachMask.accObj.Id == eachCallReport.CIS_ID__c && eachMask.accObj.Port_Pool__c != null) || Account_Util.isProfile(GlobalConstants.SME_ADMIN, eachMask.ownerUser)){

                                    if(eachMask.ownerUser.Id != eachCallReport.CreatedById){
                                        if(eachCallReport.Status__c == GlobalConstants.PLAN){
                                            eachCallReport.Status__c = GlobalConstants.CLOSED;
                                            eachCallReport.RecordTypeId = cancelCallplanRecordTypeId;
                                            updateList.add(eachCallReport);
                                        }else if(eachCallReport.Status__c == GlobalConstants.CONTACTED){
                                            if(eachCallReport.Plan_Date__c!=null)
                                                eachCallReport.RecordTypeId = cancelCallReportRecordTypeId;
                                            else eachCallReport.RecordTypeId = cancelCallReportNoRecordTypeId;
                                            eachCallReport.Status__c = GlobalConstants.CLOSED;
                                            updateList.add(eachCallReport);
                                        }
                                    }
                                    break;   
                                }
                            }
                        }
                    }
                }
            }*/

            Set<String> targetRecordType = new Set<String>{GlobalConstants.CLOSED_CANCELLED_CALLPLAN_DEVNAME,GlobalConstants.CLOSED_CANCELLED_CALLREPORT_NO_P_DEVNAME,GlobalConstants.CLOSED_CANCELLED_CALLREPORT_DEVNAME};
            List<RecordType> recordTypeList= [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType ='Call_Report__c' AND DeveloperName IN :targetRecordType];

            Id cancelCallplanRecordTypeId;
            Id cancelCallReportNoRecordTypeId;
            Id cancelCallReportRecordTypeId;
            for(RecordType eachRecordType : recordTypeList){
                if(eachRecordType.DeveloperName == GlobalConstants.CLOSED_CANCELLED_CALLPLAN_DEVNAME)
                    cancelCallplanRecordTypeId = eachRecordType.Id;
                else if(eachRecordType.DeveloperName == GlobalConstants.CLOSED_CANCELLED_CALLREPORT_NO_P_DEVNAME)
                    cancelCallReportNoRecordTypeId = eachRecordType.Id;
                else if(eachRecordType.DeveloperName == GlobalConstants.CLOSED_CANCELLED_CALLREPORT_DEVNAME)
                    cancelCallReportRecordTypeId = eachRecordType.Id;
            }
            
            if(cancelCallplanRecordTypeId != null && cancelCallReportNoRecordTypeId != null && cancelCallReportRecordTypeId != null) {
                if(Account_OwnerChange_Service.callReportTriggerList != null) {
                    for(Call_Report__c eachCallReport : Account_OwnerChange_Service.callReportTriggerList){
                        for(Account_MaskModel eachMask : accountTargetList) {
                            if(eachMask.accObj.Id == eachCallReport.CIS_ID__c) {
                                taskWhatIds.add(eachCallReport.Id);
                                if(Account_Util.isProfile(GlobalConstants.SME_ADMIN,eachMask.ownerUser)){
                                    if(eachCallReport.Status__c == GlobalConstants.PLAN){
                                        eachCallReport.Status__c = GlobalConstants.CLOSED;
                                        eachCallReport.RecordTypeId = cancelCallplanRecordTypeId;
                                    }else if(eachCallReport.Status__c == GlobalConstants.CONTACTED){
                                        eachCallReport.Status__c = GlobalConstants.CLOSED;
                                        if(eachCallReport.Primary_Call_Report__c) {
                                            if(eachCallReport.Plan_Date__c != null)
                                                eachCallReport.RecordTypeId = cancelCallReportRecordTypeId;
                                            else 
                                                eachCallReport.RecordTypeId = cancelCallReportNoRecordTypeId;    
                                        }
                                    }
                                }
                                if(eachCallReport.Status__c != GlobalConstants.CONTACTED && eachCallReport.Status__c != GlobalConstants.CLOSED && eachCallReport.Status__c != GlobalConstants.CANCEL) {
                                    // Add Change Owner
                                    eachCallReport.Current_Team_Name__c = eachMask.accObj.Current_Team_Name__c;
                                    eachCallReport.Current_AH_Name__c = eachMask.accObj.Current_AH_Name__c;
                                    eachCallReport.Current_NH_Name__c = eachMask.accObj.Current_NH_Name__c;
                                    eachCallReport.Current_Owner_Extension__c = eachMask.accObj.Current_Owner_Extension__c;
                                    eachCallReport.Ownership__c = eachMask.accObj.Ownership_Text__c;
                                    eachCallReport.Port_Pool__c = eachMask.accObj.Port_Pool__c;
                                }
                                break;
                            }
                        }
                    }
                }

                List<Call_Report__c> callReportUpdateList = new List<Call_Report__c>();
                callReportUpdateList = [SELECT Id,Primary_Call_Report__c,Plan_Date__c,Offer_Interest__c,CreatedById,CIS_ID__c,CIS_ID__r.OwnerId,RecordTypeId,Status__c,CIS_ID__r.Owner.ProfileId,CIS_ID__r.Port_Pool__c,CIS_ID__r.Owner.Profile.Name FROM Call_Report__c WHERE CIS_ID__c IN :relatedUpdateSet];
                if(callReportUpdateList!=null && callReportUpdateList.size() > 0){
                    for(Call_Report__c eachCallReport : callReportUpdateList){
                        for(Account_MaskModel eachMask : accountTargetList){
                            if(eachMask.accObj.Id == eachCallReport.CIS_ID__c){
                                taskWhatIds.add(eachCallReport.Id);
                                if(Account_Util.isProfile(GlobalConstants.SME_ADMIN,eachMask.ownerUser)){
                                    if(eachCallReport.Status__c == GlobalConstants.PLAN){
                                        eachCallReport.Status__c = GlobalConstants.CLOSED;
                                        eachCallReport.RecordTypeId = cancelCallplanRecordTypeId;
                                        updateList.add(eachCallReport);
                                    }else if(eachCallReport.Status__c == GlobalConstants.CONTACTED){
                                        eachCallReport.Status__c = GlobalConstants.CLOSED;
                                        if(eachCallReport.Primary_Call_Report__c) {
                                            if(eachCallReport.Plan_Date__c != null)
                                                eachCallReport.RecordTypeId = cancelCallReportRecordTypeId;
                                            else
                                                eachCallReport.RecordTypeId = cancelCallReportNoRecordTypeId;    
                                        }
                                        updateList.add(eachCallReport);
                                    }
                                }
                                if(eachCallReport.Status__c != GlobalConstants.CONTACTED && eachCallReport.Status__c != GlobalConstants.CLOSED && eachCallReport.Status__c != GlobalConstants.CANCEL) {
                                    // Add Change Owner
                                    eachCallReport.Current_Team_Name__c = eachMask.accObj.Current_Team_Name__c;
                                    eachCallReport.Current_AH_Name__c = eachMask.accObj.Current_AH_Name__c;
                                    eachCallReport.Current_NH_Name__c = eachMask.accObj.Current_NH_Name__c;
                                    eachCallReport.Current_Owner_Extension__c = eachMask.accObj.Current_Owner_Extension__c;
                                    eachCallReport.Ownership__c = eachMask.accObj.Ownership_Text__c;
                                    eachCallReport.Port_Pool__c = eachMask.accObj.Port_Pool__c;
                                    updateList.add(eachCallReport);
                                }
                                break;
                            }
                        }
                    }
                }
            }

            // Opportunity
            if(Account_OwnerChange_Service.opportunityTriggerList!=null){
                for(Opportunity eachOpportunity : Account_OwnerChange_Service.opportunityTriggerList){
                    for(Account_MaskModel eachMask : accountTargetList){
                        if(eachMask.accObj.Id == eachOpportunity.AccountId){
                            taskWhatIds.add(eachOpportunity.Id);
                            if(Account_Util.isProfile(GlobalConstants.SME_ADMIN,eachMask.ownerUser)){
                                if(!eachOpportunity.IsClosed){
                                    if(eachOpportunity.StageName != GlobalConstants.PARTIAL_LOAN_SETUP && eachOpportunity.StageName!=GlobalConstants.ALL_LOAN_SETUP && eachOpportunity.StageName != GlobalConstants.CLOSE_LOST)
                                        eachOpportunity.StageName = GlobalConstants.AUTO_CLOSED;
                                    //eachOpportunity.OwnerId = eachMask.ownerUser.Id;
                                }
                            }else if(!eachOpportunity.IsClosed && (eachOpportunity.StageName != GlobalConstants.PARTIAL_LOAN_SETUP && eachOpportunity.StageName!=GlobalConstants.ALL_LOAN_SETUP && eachOpportunity.StageName != GlobalConstants.AUTO_CLOSED && eachOpportunity.StageName != GlobalConstants.CLOSE_LOST)){
                                // Add Change Owner
                                eachOpportunity.OwnerId = eachMask.ownerUser.Id;
                                eachOpportunity.Current_Team_Name__c = eachMask.accObj.Current_Team_Name__c;
                                eachOpportunity.Current_AH_Name__c = eachMask.accObj.Current_AH_Name__c;
                                eachOpportunity.Current_NH_Name__c = eachMask.accObj.Current_NH_Name__c;
                                eachOpportunity.Current_Owner_Extension__c = eachMask.accObj.Current_Owner_Extension__c;
                                eachOpportunity.Ownership__c = eachMask.accObj.Ownership_Text__c;
                                eachOpportunity.Port_Pool__c = eachMask.accObj.Port_Pool__c;
                            }
                        }
                        break;
                    }
                }
            }else{
                List<Opportunity> opportunityUpdateList = new List<Opportunity>();
                Boolean toUpdate = false;
                opportunityUpdateList = [SELECT Id,StageName,IsClosed,OwnerId,AccountId,Account.OwnerId,Account.Owner.ProfileId,Account.Owner.Profile.Name FROM Opportunity WHERE AccountId IN :relatedUpdateSet];
                if(opportunityUpdateList!=null && opportunityUpdateList.size() > 0){
                    for(Opportunity eachOpportunity : opportunityUpdateList){
                        for(Account_MaskModel eachMask : accountTargetList){
                            if(eachMask.accObj.Id == eachOpportunity.AccountId){
                                taskWhatIds.add(eachOpportunity.Id);
                                toUpdate = false;
                                if(Account_Util.isProfile(GlobalConstants.SME_ADMIN,eachMask.ownerUser)){
                                    if(!eachOpportunity.IsClosed){
                                        if(eachOpportunity.StageName != GlobalConstants.PARTIAL_LOAN_SETUP && eachOpportunity.StageName!=GlobalConstants.ALL_LOAN_SETUP && eachOpportunity.StageName != GlobalConstants.CLOSE_LOST){
                                            eachOpportunity.StageName = GlobalConstants.AUTO_CLOSED;
                                            toUpdate = true;
                                        }
                                        //eachOpportunity.OwnerId = eachMask.ownerUser.Id;
                                        //toUpdate = true;
                                    }
                                }else if(!eachOpportunity.IsClosed && (eachOpportunity.StageName != GlobalConstants.PARTIAL_LOAN_SETUP && eachOpportunity.StageName!=GlobalConstants.ALL_LOAN_SETUP && eachOpportunity.StageName != GlobalConstants.AUTO_CLOSED && eachOpportunity.StageName != GlobalConstants.CLOSE_LOST)){
                                    // Add Change Owner
                                    eachOpportunity.OwnerId = eachMask.ownerUser.Id;
                                    eachOpportunity.Current_Team_Name__c = eachMask.accObj.Current_Team_Name__c;
                                    eachOpportunity.Current_AH_Name__c = eachMask.accObj.Current_AH_Name__c;
                                    eachOpportunity.Current_NH_Name__c = eachMask.accObj.Current_NH_Name__c;
                                    eachOpportunity.Current_Owner_Extension__c = eachMask.accObj.Current_Owner_Extension__c;
                                    eachOpportunity.Ownership__c = eachMask.accObj.Ownership_Text__c;
                                    eachOpportunity.Port_Pool__c = eachMask.accObj.Port_Pool__c;
                                    toUpdate = true;
                                }

                                if(toUpdate){
                                    updateList.add(eachOpportunity);
                                }
                            }
                        }
                    }
                }
            }
            //contact
            List<Contact> contactUpdateList = new List<Contact>();
            Boolean toUpdate = false;
            contactUpdateList = [SELECT Id,OwnerId,AccountId FROM Contact WHERE AccountId IN :relatedUpdateSet];
            if(contactUpdateList!=null && contactUpdateList.size() > 0){
                for(Contact eachContact : contactUpdateList){
                    for(Account_MaskModel eachMask : accountTargetList){
                        if(eachMask.accObj.Id == eachContact.AccountId){
                            toUpdate = false;
                            if(eachMask.ownerUser.Id!=eachContact.OwnerId){
                                eachContact.OwnerId = eachMask.ownerUser.Id;
                                toUpdate = true;
                            }
                            if(toUpdate){
                                updateList.add(eachContact);
                            }
                        }
                    }
                }
            }
            //Task
            List<Task> taskUpdateList = new List<Task>();
            taskUpdateList = [SELECT Id, WhatId, Status FROM Task WHERE Status IN ('Not Started','In Progress','Waiting on someone else','Deferred') AND WhatId IN :taskWhatIds AND IsRecurrence = false];
            if(taskUpdateList!=null && taskUpdateList.size() > 0){
                for(Task eachTask : taskUpdateList){
                    if(eachTask.WhatId != null) {
                        eachTask.Status = GlobalConstants.CLOSED_BY_SYSTEM;
                        updateList.add(eachTask);
                    }
                }
            }
            if(!updateList.isEmpty()){
                Account_OwnerChange_Service.updateGlobalList = updateList;
            }
        }

    }
}