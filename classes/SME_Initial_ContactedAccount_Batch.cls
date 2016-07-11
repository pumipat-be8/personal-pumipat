global class SME_Initial_ContactedAccount_Batch implements Database.Batchable<sObject>, Database.Stateful {
    private String query;
    private Map<String,User_Extension__c> userMapExt;
    private Set<String> userMapExtKeySet{get{return userMapExt.keySet();}}

    global SME_Initial_ContactedAccount_Batch() {
        Map<String,User_Extension__c> userExMap = new Map<String,User_Extension__c>([SELECT Id,Call_Report__c,Call_Report_Customer_Others__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Port__c,Call_Report_for_Relationship__c,Contacted_Customer_Other__c,Contacted_Customer_Pool__c,Contacted_Customer_Port__c,Customer_Other__c,Customer_Pool__c,Customer_Port__c,Face_to_Face__c,Months__c,Phone_Call__c,Team_Structure__c,User__c,User__r.ProfileId,User__r.Profile.Name,User__r.RC_Code__c,User__r.Employee_Id__c,User__r.ManagerId,Total_visited_Customer__c,Contacted_Customer_Other_My_Penetrate__c,Contacted_Customer_Pool_My_Penetrate__c,Contacted_Customer_Port_My_Penetrate__c FROM User_Extension__c WHERE Team_Structure__c!=null]);

        userMapExt = new Map<String,User_Extension__c>();
        for(User_Extension__c eachExt : userExMap.values()){
            userMapExt.put(eachExt.User__c, eachExt);
        }

        this.query = 'select id,Count_Contacted_Call_Report__c,Count_Call_Report_RM__c from account WHERE OwnerId IN :userMapExtKeySet';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Account> accountList) {
        List<Call_Report__c> callReportList = new List<Call_Report__c>();
        Map<String,Decimal> accountMapCount = new Map<String,Decimal>();
        Map<String,Decimal> accountMapCountRM = new Map<String,Decimal>();
        //owner+account
        callReportList = [SELECT Id,CIS_ID__c,Current_Owner_Extension__r.User__r.Profile.Name FROM Call_Report__c WHERE CIS_ID__c IN :accountList AND Status__c='Contacted'];

        for(Call_Report__c eachCallReport : callReportList){
            if(!accountMapCount.containsKey(eachCallReport.CIS_ID__c))
                accountMapCount.put(eachCallReport.CIS_ID__c,0);

            if(!accountMapCountRM.containsKey(eachCallReport.CIS_ID__c))
                accountMapCountRM.put(eachCallReport.CIS_ID__c,0);

            
            if(eachCallReport.Current_Owner_Extension__r.User__r.Profile.Name == GlobalConstants.SME_RM) 
                accountMapCountRM.put(eachCallReport.CIS_ID__c,accountMapCountRM.get(eachCallReport.CIS_ID__c)+1);

            accountMapCount.put(eachCallReport.CIS_ID__c,accountMapCount.get(eachCallReport.CIS_ID__c)+1);
        }
        for(Account eachAccount : accountList){
            eachAccount.Count_Contacted_Call_Report__c = (accountMapCount.containsKey(eachAccount.Id))?accountMapCount.get(eachAccount.Id):0;
            eachAccount.Count_Call_Report_RM__c = (accountMapCountRM.containsKey(eachAccount.Id))?accountMapCountRM.get(eachAccount.Id):0;
        }
        TriggerHandler.bypass('AccountTriggerHandler');
        update accountList;
    }

    global void finish(Database.BatchableContext BC) {

    }
}