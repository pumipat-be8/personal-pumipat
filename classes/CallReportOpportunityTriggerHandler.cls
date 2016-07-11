/**
* @author komsan.wi@beryl8.com
* @30/09/2015 created new
*/
public with sharing class CallReportOpportunityTriggerHandler extends TriggerHandler{

    public override void afterDelete() {
        Set<Id> oppIdSet = new Set<Id>();
        for(Call_Report_Opportunity__c callReportOpp : (List<Call_Report_Opportunity__c>)Trigger.old) {
            oppIdSet.add(callReportOpp.Opportunity_Name__c);
        }
        CallReport_Service.updateActualVisitDateOfOpp(oppIdSet);
    }

    public override void afterInsert() {
    	Set<Id> callReportSet = new Set<Id>();
        Set<Id> opportunitySet = new Set<Id>();

    	List<Call_Report_Lead__c> callreportLeadList = new List<Call_Report_Lead__c>();
    	List<Opportunity_Lead__c> opportunityLeadList = new List<Opportunity_Lead__c>();
        Map<Id,Id> targetListMap = new Map<Id,Id>();
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();

    	Map<String,List<String>> leadMapByCallReport = new Map<String,List<String>>();
    	for(Call_Report_Opportunity__c eachCallOpp : (List<Call_Report_Opportunity__c>)Trigger.new){
    		if(eachCallOpp.Call_Plan_Call_Report__c!=null) callReportSet.add(eachCallOpp.Call_Plan_Call_Report__c);
            if(eachCallOpp.Opportunity_Name__c!=null) opportunitySet.add(eachCallOpp.Opportunity_Name__c);
    	}
    	callreportLeadList = [SELECT Id,Call_Plan_Call_Report__c,Target_List__c,Target_List__r.CIS_ID_Prospect_Name__c FROM Call_Report_Lead__c WHERE Target_List__r.Lead_Type__c =: GlobalConstants.LEAD_FOR_SALES AND Call_Plan_Call_Report__c in :callReportSet];

    	for(Call_Report_Lead__c eachCallReportLead : callreportLeadList){
    		if(eachCallReportLead.Call_Plan_Call_Report__c!=null && eachCallReportLead.Target_List__c!=null && eachCallReportLead.Target_List__r.CIS_ID_Prospect_Name__c!=null){
	    		if(!leadMapByCallReport.containsKey(eachCallReportLead.Call_Plan_Call_Report__c))
	    			leadMapByCallReport.put(eachCallReportLead.Call_Plan_Call_Report__c,new List<String>{eachCallReportLead.Target_List__c});
	    		else leadMapByCallReport.get(eachCallReportLead.Call_Plan_Call_Report__c).add(eachCallReportLead.Target_List__c);
                
                targetListMap.put(eachCallReportLead.Target_List__c,eachCallReportLead.Target_List__r.CIS_ID_Prospect_Name__c);
	    	}
    	}
        if(opportunitySet.size() > 0){
            opportunityMap = new Map<Id,Opportunity>([SELECT Id, AccountId FROM Opportunity WHERE Id IN:opportunitySet]);
            CallReport_Service.updateActualVisitDateOfOpp(opportunityMap.keySet());
        }

    	for(Call_Report_Opportunity__c eachCallOpp : (List<Call_Report_Opportunity__c>)Trigger.new){
    		if(leadMapByCallReport.containsKey(eachCallOpp.Call_Plan_Call_Report__c)){
    			List<String> targetIdList = leadMapByCallReport.get(eachCallOpp.Call_Plan_Call_Report__c);
    			for(String eachTargetId : targetIdList){
                    if(opportunityMap.get(eachCallOpp.Opportunity_Name__c).AccountId ==targetListMap.get(eachTargetId))
    		    		opportunityLeadList.add(new Opportunity_Lead__c(
    		    			Opportunity__c = eachCallOpp.Opportunity_Name__c,
    						Target_List__c = eachTargetId
    		    		));
		    	}

	    	}
    	}

    	if(opportunityLeadList.size() > 0) insert opportunityLeadList;
    }
}