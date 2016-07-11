/**
* @author chutiwat.s@beryl8.com
* @26/01/2015 update
*/
global class AccountLeadUpdate_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    String query;
    List<Id> accountIds;
    Map<Id, Map<String, Set<String>>> mapTargetsByAccount;
    Boolean isCallFromInitial;

    global AccountLeadUpdate_Batch(Set<Id> setAccountIds) {
        accountIds = new List<Id>(setAccountIds);
        mapTargetsByAccount = new Map<Id, Map<String, Set<String>>>();
        this.query = 'SELECT Id, Name, CIS_ID_Prospect_Name__c, Lead_Type__c, Lead_Campaign__r.Name, Lead_Campaign__r.Status FROM Target_List__c WHERE CIS_ID_Prospect_Name__c IN (\'' + String.join(accountIds,'\',\'') + '\') AND Lead_Campaign__r.IsActive = true AND Status__c = \'New\' ORDER BY CIS_ID_Prospect_Name__c';
    }
    
    global AccountLeadUpdate_Batch(Set<Id> setAccountIds, Boolean isCallFromInitial) {
        this.isCallFromInitial = isCallFromInitial;
        accountIds = new List<Id>(setAccountIds);
        mapTargetsByAccount = new Map<Id, Map<String, Set<String>>>();
        this.query = 'SELECT Id, Name, CIS_ID_Prospect_Name__c, Lead_Type__c, Lead_Campaign__r.Name, Lead_Campaign__r.Status FROM Target_List__c WHERE CIS_ID_Prospect_Name__c IN (\'' + String.join(accountIds,'\',\'') + '\') AND Lead_Campaign__r.IsActive = true AND Status__c = \'New\' ORDER BY CIS_ID_Prospect_Name__c';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Target_List__c> allTargetList) {
        for (Target_List__c eachTarget : allTargetList) {
            if(mapTargetsByAccount.containsKey(eachTarget.CIS_ID_Prospect_Name__c)) {
                if(mapTargetsByAccount.get(eachTarget.CIS_ID_Prospect_Name__c).get(eachTarget.Lead_Type__c) == null) {
                    Set<String> leadSetString = new Set<String>();
                    leadSetString.add(eachTarget.Lead_Campaign__r.Name);

                    mapTargetsByAccount.get(eachTarget.CIS_ID_Prospect_Name__c).put(eachTarget.Lead_Type__c, leadSetString);
                } else {
                    mapTargetsByAccount.get(eachTarget.CIS_ID_Prospect_Name__c).get(eachTarget.Lead_Type__c).add(eachTarget.Lead_Campaign__r.Name);            
                }
            } else {
                if(mapTargetsByAccount.size() >= Integer.valueOf(Label.Campaign_Lead_Batch_Size)) {
                    this.updateAccount();
                }
                
                Set<String> leadSetString = new Set<String>();
                leadSetString.add(eachTarget.Lead_Campaign__r.Name);

                mapTargetsByAccount.put(eachTarget.CIS_ID_Prospect_Name__c, new Map<String, Set<String>>{eachTarget.Lead_Type__c => leadSetString});
            }
        }

        if(mapTargetsByAccount.size() > 0) {
            this.updateAccount();    
        }
    }
    
    private void updateAccount() {
        System.debug('mapTargetsByAccount size:' + mapTargetsByAccount.size());
        System.debug('mapTargetsByAccount:' + mapTargetsByAccount);

        List<Account> updateAccount = new List<Account>();
        Account eachAccount;

        for (Id eachAccountId : mapTargetsByAccount.keySet()) {
            
            eachAccount = new Account(Id = eachAccountId);
            List<String> leadForSaleList = new List<String>();
            List<String> leadToInformList = new List<String>();
            List<String> leadToDoList = new List<String>();

            if(mapTargetsByAccount.get(eachAccountId).get(GlobalConstants.LEAD_FOR_SALES) != null) {
                leadForSaleList.addAll(mapTargetsByAccount.get(eachAccountId).get(GlobalConstants.LEAD_FOR_SALES));
            }

            if(mapTargetsByAccount.get(eachAccountId).get(GlobalConstants.LEAD_TO_INFORM) != null) {
                leadToInformList.addAll(mapTargetsByAccount.get(eachAccountId).get(GlobalConstants.LEAD_TO_INFORM));
            }

            if(mapTargetsByAccount.get(eachAccountId).get(GlobalConstants.CAMPAIGN) != null) {
                leadToInformList.addAll(mapTargetsByAccount.get(eachAccountId).get(GlobalConstants.CAMPAIGN));
            }

            if(mapTargetsByAccount.get(eachAccountId).get(GlobalConstants.LEAD_TO_DO) != null) {
                leadToDoList.addAll(mapTargetsByAccount.get(eachAccountId).get(GlobalConstants.LEAD_TO_DO));
            }
            
            eachAccount.Lead_for_Sales__c = leadForSaleList.isEmpty() ? null : String.join(leadForSaleList, ',');
            eachAccount.Lead_To_Do__c = leadToDoList.isEmpty() ? null : String.join(leadToDoList, ',');
            eachAccount.Lead_To_Inform__c = leadToInformList.isEmpty() ? null : String.join(leadToInformList, ',');
            updateAccount.add(eachAccount);
        }

        if(!updateAccount.isEmpty()) {
            Account_OwnerChange_Service.accountTriggerMap = new Map<Id,Account>();
            if(isCallFromInitial != null && isCallFromInitial) {
                update updateAccount;    
            } else {
                System.enqueueJob(new AccountLeadUpdate_Queue(updateAccount));    
            }

            mapTargetsByAccount.clear();
            if(mapTargetsByAccount.size() > 0) {
                mapTargetsByAccount = new Map<Id, Map<String, Set<String>>>();    
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        
    }
    
}