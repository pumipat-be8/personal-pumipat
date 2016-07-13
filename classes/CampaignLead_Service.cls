public class CampaignLead_Service {
	public static void updateTargetlistStatusFromLatestOpp(List<Target_List__c> updateTargetList) {
        Set<String> recordTypeSet = new Set<String>{
            GlobalConstants.CALL_REPORT_NO_PLAN_DEVNAME,
            GlobalConstants.CALL_REPORT_DEVNAME,
            GlobalConstants.SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN_DEVNAME,
            GlobalConstants.SECONDARY_CALL_REPORT_NO_PLAN_DEVNAME
        };
        Set<Id> accountIds = new Set<Id>();
        for(Target_List__c eachTarget : updateTargetList) {
            if(eachTarget.CIS_ID_Prospect_Name__c != null)
                accountIds.add(eachTarget.CIS_ID_Prospect_Name__c);
        }
        Set<Id> oppIds = new Set<Id>();
        Map<Id, Account> targetAccountMap = new Map<Id, Account>([SELECT Id, (SELECT Id, StageName, CreatedDate FROM Opportunities ORDER BY CreatedDate DESC LIMIT 1) FROM Account WHERE Id IN:accountIds]);        
        for(Account eachAccount : targetAccountMap.values()) {
            if(eachAccount.Opportunities != null && eachAccount.Opportunities.size() > 0) {
                oppIds.add(eachAccount.Opportunities[0].Id);
            }
        }

        List<Call_Report_Opportunity__c> callReportOppList = new List<Call_Report_Opportunity__c>();
        callReportOppList = [SELECT Call_Plan_Call_Report__c, Opportunity_Name__c FROM Call_Report_Opportunity__c WHERE Opportunity_Name__c IN :oppIds];
        Set<Id> callReportIds = new Set<Id>();
        Map<Id, Id> callReportMapByOpp = new Map<Id, Id>();
        for(Call_Report_Opportunity__c eachCallOpp : callReportOppList) {
            if(eachCallOpp.Call_Plan_Call_Report__c != null)
                callReportIds.add(eachCallOpp.Call_Plan_Call_Report__c);
            if(eachCallOpp.Opportunity_Name__c != null)
                callReportMapByOpp.put(eachCallOpp.Opportunity_Name__c, eachCallOpp.Call_Plan_Call_Report__c);
        }

        Map<Id, Call_Report__c> callReportMap = new Map<Id, Call_Report__c>([SELECT Id, Status__c, Offer_Interest__c, Offer_Credit_Product__c, Collect_Documents__c, Negotiation__c, CreatedDate FROM Call_Report__c WHERE Id IN:callReportIds AND RecordType.DeveloperName IN :recordTypeSet]);

        Account eachAccount;
        Opportunity eachOpportunity;
        Call_Report__c eachCallReport;

        for(Target_List__c eachTarget : updateTargetList) {
            if(eachTarget.CIS_ID_Prospect_Name__c != null && targetAccountMap.containsKey(eachTarget.CIS_ID_Prospect_Name__c)) {
                eachAccount = targetAccountMap.get(eachTarget.CIS_ID_Prospect_Name__c);
                if(eachAccount.Opportunities != null && eachAccount.Opportunities.size() > 0) {
                    eachOpportunity = eachAccount.Opportunities[0];
                    if(eachOpportunity.StageName == GlobalConstants.AUTO_CLOSED || eachOpportunity.StageName == GlobalConstants.CLOSE_LOST) {
                        if(callReportMapByOpp.containsKey(eachOpportunity.Id)) {
                            eachCallReport = callReportMap.get(callReportMapByOpp.get(eachOpportunity.Id));
                        } else { // Not found Call Report
                            eachTarget.Status__c = eachOpportunity.StageName;
                        }
                    } else { // Opportunity StageName != Auto Closed OR Close Lost
                        eachTarget.Status__c = eachOpportunity.StageName;
                    }
                }
            }
        }
    }

    public static void getLatestLeadFromTargetList(Set<Id> targetListIds, List<Call_Report__c> callReportList) {
        List<Call_Report_Lead__c> callReportLeadList = new List<Call_Report_Lead__c>();
        Opportunity_Lead__c eachExistOpportunityLead;
        Call_Report_Lead__c eachExistCallReportLead;
        Map<Id, List<Target_List__c>> targetListsMapByAccountId = new Map<Id, List<Target_List__c>>();
        List<Target_List__c> targetLists = [SELECT Id, CIS_ID_Prospect_Name__c, 
                                            (SELECT Id, Opportunity__r.StageName FROM Opportunities_Leads__r ORDER BY CreatedDate DESC LIMIT 1), 
                                            (SELECT Id, Call_Plan_Call_Report__c, Call_Plan_Call_Report__r.RecordTypeId FROM Call_Reports_Leads__r ORDER BY CreatedDate DESC LIMIT 1) 
                                                FROM Target_List__c WHERE Id IN :targetListIds AND Lead_Campaign__r.Status = :GlobalConstants.ACTIVE];
        for(Target_List__c eachTarget : targetLists) {
            //Dont need to check null for Master Detail
            //if(eachTarget.CIS_ID_Prospect_Name__c != null)
            if(!targetListsMapByAccountId.containsKey(eachTarget.CIS_ID_Prospect_Name__c))
                targetListsMapByAccountId.put(eachTarget.CIS_ID_Prospect_Name__c, new List<Target_List__c>());
            
            targetListsMapByAccountId.get(eachTarget.CIS_ID_Prospect_Name__c).add(eachTarget);
        }

        for(Call_Report__c eachNewCallReport : callReportList) {
            if(targetListsMapByAccountId.containsKey(eachNewCallReport.CIS_ID__c)) {
                targetLists = targetListsMapByAccountId.get(eachNewCallReport.CIS_ID__c);
                for(Target_List__c eachTarget : targetLists) {
                    if(eachTarget.Opportunities_Leads__r != null && eachTarget.Opportunities_Leads__r.size() > 0) { // Have Existing Opportunity Lead
                        eachExistOpportunityLead = eachTarget.Opportunities_Leads__r.get(0);
                        if(eachExistOpportunityLead.Opportunity__r.StageName == GlobalConstants.CLOSE_WON) {
                            // Not Create
                        } else if(eachExistOpportunityLead.Opportunity__r.StageName == GlobalConstants.AUTO_CLOSED || eachExistOpportunityLead.Opportunity__r.StageName == GlobalConstants.CLOSE_LOST) {
                            // Create 
                        } else {
                            // Create Not Update Status
                        }
                    } else if(eachTarget.Call_Reports_Leads__r != null && eachTarget.Call_Reports_Leads__r.size() > 0) { // Have Existing CallReport Lead
                        eachExistCallReportLead = eachTarget.Call_Reports_Leads__r.get(0);
                        if(eachExistCallReportLead.Call_Plan_Call_Report__r.RecordTypeId == 'Call Plan') {

                        } else if(eachExistCallReportLead.Call_Plan_Call_Report__r.RecordTypeId == 'Call Report') {

                        }
                    } else { // No existing Call Plan / Call Report / Opportunity => Create and Update Status
                        callReportLeadList.add(new Call_Report_Lead__c(
                            Call_Plan_Call_Report__c = eachNewCallReport.Id,
                            Target_List__c = eachTarget.Id
                        ));
                    }
                }
            }
        }
    }

    public static void checkCallReportExistingLead(Set<Id> targetListIds) {
        Map<Id, Call_Report_Lead__c> callReportLeadMapByTargetList = new Map<Id, Call_Report_Lead__c>();
        List<Call_Report_Lead__c> callReportLeadList = [SELECT Id, Call_Plan_Call_Report__c, Target_List__c FROM Call_Report_Lead__c WHERE Target_List__c IN:targetListIds];
        for(Call_Report_Lead__c eachCallReportLead : callReportLeadList) {
            if(eachCallReportLead.Target_List__c != null) 
                callReportLeadMapByTargetList.put(eachCallReportLead.Target_List__c, eachCallReportLead);
        }
    }
}