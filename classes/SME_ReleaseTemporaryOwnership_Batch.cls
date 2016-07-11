global class SME_ReleaseTemporaryOwnership_Batch implements Database.Batchable<sObject>{
    String query;
    String defaultLabelLimit;
    Integer minimumLabelLimit;
    Map<String,Boolean> checkReleaseOwnership;
    Map<String,String> limitOfReleaseOwnership;
    
    global SME_ReleaseTemporaryOwnership_Batch(){
        
        limitOfReleaseOwnership = new Map<String,String>{
            'checkReleaseProspectOwnershipSE' => Label.Release_Prospect_Ownership_SE,
            'checkReleaseProspectOwnershipME' => Label.Release_Prospect_Ownership_ME,
            'checkReleaseProspectOwnershipForCallPlanCallReportSE' => Label.Release_Prospect_Ownership_for_Call_Plan_Call_Report_SE,
            'checkReleaseProspectOwnershipForCallPlanCallReportME' => Label.Release_Prospect_Ownership_for_Call_Plan_Call_Report_ME,
            'checkReleaseCustomerOwnershipForCallPlanCallReportSE' => Label.Release_Customer_Ownership_for_Call_Plan_Call_Report_SE,
            'checkReleaseCustomerOwnershipForCallPlanCallReportME' => Label.Release_Customer_Ownership_for_Call_Plan_Call_Report_ME
        };

        checkReleaseOwnership = new Map<String,Boolean>{
            'checkReleaseProspectOwnershipSE' => true,
            'checkReleaseProspectOwnershipME' => true,
            'checkReleaseProspectOwnershipForCallPlanCallReportSE' => true,
            'checkReleaseProspectOwnershipForCallPlanCallReportME' => true,
            'checkReleaseCustomerOwnershipForCallPlanCallReportSE' => true,
            'checkReleaseCustomerOwnershipForCallPlanCallReportME' => true
        };
        

        defaultLabelLimit = '90';
        minimumLabelLimit = 90;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        getMinLimitDateAndCheckIfLabelNull();
        query = 'SELECT CreatedDate, Customer_Owner_Release_Flag__c, Last_CallReprt_Opty_Updated_Date__c, Owner.Segment__c, RecordType.DeveloperName FROM Account WHERE Ownership_Text__c = \'Temporary\' AND (Last_CallReprt_Opty_Updated_Date__c <= LAST_N_DAYS:'+minimumLabelLimit+' OR Last_CallReprt_Opty_Updated_Date__c = null) AND Owner.Segment__c IN (\'SE\',\'ME\')';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> accountList){
        Datetime accountCreatedDatetime;
        Date accountCreatedDate;
        Date today = System.today();
        Integer dateDifference = 0;
        List<Account> accountToUpdate = new List<Account>();

        for(Account account: accountList){  
            if(account.Last_CallReprt_Opty_Updated_Date__c == null){
                accountCreatedDatetime = account.CreatedDate;
                accountCreatedDate = Date.newInstance(accountCreatedDatetime.year(), accountCreatedDatetime.month(), accountCreatedDatetime.day());
                dateDifference = accountCreatedDate.daysBetween(today);
                
                    if(account.Owner.Segment__c == GlobalConstants.SEGMENT_SE && checkReleaseOwnership.get('checkReleaseProspectOwnershipSE')){
                        if(dateDifference >= Integer.valueOf(limitOfReleaseOwnership.get('checkReleaseProspectOwnershipSE'))){
                            account.Customer_Owner_Release_Flag__c = true;
                            accountToUpdate.add(account);
                        }
                    }
                    else if(account.Owner.Segment__c == GlobalConstants.SEGMENT_ME && checkReleaseOwnership.get('checkReleaseProspectOwnershipME')){
                        if(dateDifference >= Integer.valueOf(limitOfReleaseOwnership.get('checkReleaseProspectOwnershipME'))){
                            account.Customer_Owner_Release_Flag__c = true;
                            accountToUpdate.add(account);
                        }
                    }

            }
            else{
                accountCreatedDatetime = account.Last_CallReprt_Opty_Updated_Date__c;
                accountCreatedDate = Date.newInstance(accountCreatedDatetime.year(), accountCreatedDatetime.month(), accountCreatedDatetime.day());
                dateDifference = accountCreatedDate.daysBetween(today);

                if(account.RecordType.DeveloperName == GlobalConstants.SME_PROSPECT_DEVNAME){
                    if(account.Owner.Segment__c == GlobalConstants.SEGMENT_SE && checkReleaseOwnership.get('checkReleaseProspectOwnershipForCallPlanCallReportSE')){
                        if(dateDifference >= Integer.valueOf(limitOfReleaseOwnership.get('checkReleaseProspectOwnershipForCallPlanCallReportSE'))){
                            account.Customer_Owner_Release_Flag__c = true;
                            accountToUpdate.add(account);
                        }
                    }
                    else if(account.Owner.Segment__c == GlobalConstants.SEGMENT_ME && checkReleaseOwnership.get('checkReleaseProspectOwnershipForCallPlanCallReportME')){
                        if(dateDifference >= Integer.valueOf(limitOfReleaseOwnership.get('checkReleaseProspectOwnershipForCallPlanCallReportME'))){
                            account.Customer_Owner_Release_Flag__c = true;
                            accountToUpdate.add(account);
                        }
                    }
                }
                else if(account.RecordType.DeveloperName == GlobalConstants.SME_CUSTOMER_DEVNAME){
                    if(account.Owner.Segment__c == GlobalConstants.SEGMENT_SE && checkReleaseOwnership.get('checkReleaseCustomerOwnershipForCallPlanCallReportSE')){
                        if(dateDifference >= Integer.valueOf(limitOfReleaseOwnership.get('checkReleaseCustomerOwnershipForCallPlanCallReportSE'))){
                            account.Customer_Owner_Release_Flag__c = true;
                            accountToUpdate.add(account);
                        }
                    }
                    else if(account.Owner.Segment__c == GlobalConstants.SEGMENT_ME && checkReleaseOwnership.get('checkReleaseCustomerOwnershipForCallPlanCallReportME')){
                        if(dateDifference >= Integer.valueOf(limitOfReleaseOwnership.get('checkReleaseCustomerOwnershipForCallPlanCallReportME'))){
                            account.Customer_Owner_Release_Flag__c = true;
                            accountToUpdate.add(account);
                        }
                    }
                }
            }
        }
        update accountToUpdate;
    }

    global void finish(Database.BatchableContext BC){

    }

    public void getMinLimitDateAndCheckIfLabelNull(){
        for(String label:limitOfReleaseOwnership.keySet()){
            
            if(limitOfReleaseOwnership.get(label) == null){
                checkReleaseOwnership.put(label,false);
            }
            else if(Integer.valueOf(limitOfReleaseOwnership.get(label)) == 0){
                limitOfReleaseOwnership.put(label,defaultLabelLimit);
                if(Integer.valueOf(limitOfReleaseOwnership.get(label)) < minimumLabelLimit){
                    minimumLabelLimit = Integer.valueOf(limitOfReleaseOwnership.get(label));
                }
            }

        }
    }
}