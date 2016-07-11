/**
* @author chutiwat.s@beryl8.com
* @26/01/2015 update
*/
global class AccountLeadInitial_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    String query;
    Set<Id> accountIds;
    Boolean isClearOldData;

    global AccountLeadInitial_Batch() {
        this.isClearOldData = true;
        accountIds = new Set<Id>();
        this.query = 'SELECT Id FROM Account';
    }

    global AccountLeadInitial_Batch(Boolean isClearOldData) {
        this.isClearOldData = isClearOldData;
        accountIds = new Set<Id>();
        this.query = 'SELECT Id FROM Account';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        List<Account> updateAccounts = new List<Account>();
        for(Account eachAccount : accountList) {
            if(isClearOldData != null && isClearOldData) {
                eachAccount.Lead_To_Do__c = '';
                eachAccount.Lead_To_Inform__c = '';
                eachAccount.Lead_for_Sales__c = '';

                updateAccounts.add(eachAccount);
            }
                
            accountIds.add(eachAccount.Id);
        }

        if(!updateAccounts.isEmpty())
            update updateAccounts;
    }
    
    global void finish(Database.BatchableContext BC) {
        if(!accountIds.isEmpty()) {
            System.debug('accountIds size:' + accountIds.size());
            Set<Id> splitGroupAccount = new Set<Id>();
            for(Id each:accountIds){
                splitGroupAccount.add(each);
                if(splitGroupAccount.size() >= 30000){
                    Database.executeBatch(new AccountLeadUpdate_Batch(splitGroupAccount, true), 2000);
                    splitGroupAccount = new Set<Id>();
                }
            }
            if(splitGroupAccount.size() > 0){
                Database.executeBatch(new AccountLeadUpdate_Batch(splitGroupAccount, true), 2000);
            }
        }
    }
    
}