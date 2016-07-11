/**
* @author komsan.wi@beryl8.com
* @08/07/2015 createddate
*/
trigger AccountTrigger on Account(before insert,before update,after update) {
    if(GlobalUtility.accounFromYearend){
        /*SME_Admin__c sa = SME_Admin__c.getOrgDefaults();
        if(sa!=null){
            for(Account eachAccount : (List<Account>)Trigger.new){
                if(eachAccount.OwnerId == sa.User_Record_ID__c && eachAccount.Port_Pool__c!=null) {
                    eachAccount.Port_Pool__c = null;
                }
            }
        }*/
    }
    else if(Account_OwnerChange_Service.accountTriggerMap==null){
        new AccountTriggerHandler().run();
    } 
    if(trigger.isBefore && trigger.isInsert) {
        SME_Admin__c sa = SME_Admin__c.getOrgDefaults();
        if(sa!=null){
            List<User> integrationUserList = new List<User>();//in:integrationIdSet
            System.debug('UserInfo.getUserId():'+UserInfo.getUserId());
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
}