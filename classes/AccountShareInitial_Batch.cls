/**
* @author komsan.wi@beryl8.com
* @05/08/2015 createddate
*/
global class AccountShareInitial_Batch implements Database.Batchable<sObject>,Database.Stateful {
    private Map<String,String> userRoleMapping;
    private Map<Id,User> ownerUserMap;
    private String query;
    global AccountShareInitial_Batch() {
        this.query = 'SELECT Id,OwnerId,Previous_Owner__c,Port_Pool__c FROM Account';
        userRoleMapping = Account_OwnerChange_Service.queryUserRole();
        ownerUserMap = new Map<Id,User>([SELECT Id,UserRole.Name,AH_RC_CODE__c,NH_RC_CODE__c,UserRole.DeveloperName,Manager.UserRole.Name,Manager.UserRole.DeveloperName,Manager.Manager.UserRole.Name,Manager.Manager.UserRole.DeveloperName,IsActive,ProfileId,Profile.Name, ManagerId,Manager.Name,Manager.IsActive,Manager.ProfileId,Manager.Profile.Name,Manager.ManagerId,Manager.Manager.Name,Manager.Manager.IsActive,Manager.Manager.ProfileId,Manager.Manager.Profile.Name,RC_Code__c FROM User]);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accountScope) {
    	List<Account_MaskModel> accountTargetList = new List<Account_MaskModel>();
    	List<AccountShare> accountShareInsertList = new List<AccountShare>();
    	Map<String,List<String>> accountIdByGroupNameMap = new Map<String,List<String>>();
    	Set<Id> sharingRuleDeleteSet = new Set<Id>();
        List<String> accountIdByGroupNameList = new List<String>();
    	for(Account eachAccount : accountScope){
    		accountTargetList.add(new Account_MaskModel(eachAccount));
    	}
    	for(Account_MaskModel maskObj : accountTargetList){
    		maskObj
                .setPreviousOwner(ownerUserMap.get(maskObj.accObj.Previous_Owner__c))
                .setOwner(ownerUserMap.get(maskObj.accObj.OwnerId));

    		if(maskObj.haveToDeletedSharingRule) sharingRuleDeleteSet.add(maskObj.accObj.Id);

            // Old version
    		/*String sharingGroupName = Account_OwnerChange_Service.getSharingGroupName(maskObj);
            if(sharingGroupName!=null)
                accountIdByGroupNameMap.put(maskObj.accObj.Id,sharingGroupName);*/

            // New version
            List<String> sharingGroupNameList = Account_OwnerChange_Service.getSharingGroupNameWithConfig(maskObj,userRoleMapping);
            System.debug('sharingGroupNameList:'+maskObj.accObj+'::'+sharingGroupNameList);
            if(sharingGroupNameList!=null && sharingGroupNameList.size() > 0){
                accountIdByGroupNameList.addAll(sharingGroupNameList);
                accountIdByGroupNameMap.put(maskObj.accObj.Id, sharingGroupNameList);
            }
    	}

        if(!sharingRuleDeleteSet.isEmpty())
            delete [SELECT Id FROM AccountShare WHERE AccountId in :sharingRuleDeleteSet AND RowCause = 'Manual'];

        /*System.debug('sharingRuleDeleteSet:'+sharingRuleDeleteSet);
    	if(!sharingRuleDeleteSet.isEmpty()){
            List<AccountShare> deleteList = [SELECT Id FROM AccountShare WHERE AccountId in :sharingRuleDeleteSet AND RowCause = 'Manual'];
            if(deleteList.size() > 200){
                List<Id> tempSetIdDelete = new List<Id>();
                for(AccountShare eachDelete : deleteList){
                    tempSetIdDelete.add(eachDelete.Id);
                    if(tempSetIdDelete.size() >= 100){
                        //delete tempSetIdDelete;
                        tempSetIdDelete.clear();
                    }
                }
                //if(tempSetIdDelete.size() > 0)
                    //delete tempSetIdDelete;
            }
        }*/

        if(!accountIdByGroupNameMap.isEmpty()){
            List<Group> groupList = [SELECT Id,DeveloperName FROM Group WHERE DeveloperName in :accountIdByGroupNameList AND Type='RoleAndSubordinates'];
            for(String eachAccountId :accountIdByGroupNameMap.keyset()){
                for(Group eachGroup : groupList){
                    // New code
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

                    // Old code
                    /*if(eachGroup.DeveloperName == accountIdByGroupNameMap.get(eachAccountId)){
                        accountShareInsertList.add(new AccountShare(
                                CaseAccessLevel = 'none',
                                OpportunityAccessLevel = 'none',
                                AccountAccessLevel = 'read',
                                AccountId = eachAccountId,
                                UserOrGroupId = eachGroup.Id
                            ));
                        break;
                    }*/
                }
                
            }
            if(!accountShareInsertList.isEmpty()){
                System.debug('accountShareInsertList:'+accountShareInsertList);
                insert accountShareInsertList;
            }
        }
    }

    global void finish(Database.BatchableContext BC) {}
}