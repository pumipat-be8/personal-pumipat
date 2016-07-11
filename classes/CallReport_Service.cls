/**
* @author komsan.wi@beryl8.com
* @08/07/2015 createddate
* @17/07/2015 remove future annotation, change delete condition from whatid to Call_Plan_Call_Report__c, use upsert instead of insert due to additional req.
*/
public class CallReport_Service {
    public static List<User_Extension__c> userExtList;
    public static List<Team_Structure__c> teamStructureList;
    public static Map<Id,Account> accountMap;
    public static Map<Id,Account> accountMapByCallReportCustomer;
    public static Map<Id,User> userMapByCallReportCreateby;
    public static void updateEvent(List<sObject> sObjectList){
        //try{
            update sObjectList;
        //}catch(DMLException dex){
            //throw
        //}
    }
    public static void insertEvent(List<sObject> sObjectList){
        //try{
            insert sObjectList;
        //}catch(DMLException dex){
            //throw
        //}
    }
    public static void deleteEvent(Set<Id> callReportIdSet){
        //try{
            delete [SELECT Id FROM Event WHERE Call_Plan_Call_Report__c IN:callReportIdSet];
        //}catch(DMLException dex){system.debug('DML Exception : ' + dex);}
    }
    public static Map<Id,Account> getAccountMapByCallReportCustomer(List<Call_Report__c> callReportList){
        Set<Id> accountSet = new Set<Id>();
        
        Map<Id,Account> accountMapResult = new Map<Id,Account>();

        for(Call_Report__c eachCallReport : (List<Call_Report__c>)callReportList){
            accountSet.add(eachCallReport.CIS_ID__c);
        }
        //SME-Campaign/Lead'
        accountMapResult = new Map<Id,Account>([SELECT Id,Last_Visited_By__c,Trash_Pool_Flag__c,Current_Activity__c,Current_Activity_By__c,Ownership_Text__c,Count_Call_Report_RM__c,Count_Contacted_Call_Report__c, Owner_Emp_ID__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, CIS__c,Identification_No__c,Temp_Owner_Changed_Date__c,Customer_Owner_Release_Flag__c,Name,Port_Pool__c,OwnerId,Owner.Profile.Name,Owner.ManagerId,Owner.AH_RC_CODE__c,Owner.NH_RC_CODE__c,Previous_Owner__c,Customer_Importance_Note__c,RecordTypeId,RecordType.Name,Birthdate_Registration_Date__c,Identification_No_Prospect__c,(SELECT Id,Lead_Type__c,CIS_ID_Prospect_Name__r.CIS__c,CIS_ID_Prospect_Name__r.Name_Surname_TH__c FROM Campaign_Members_Leads__r WHERE Lead_Campaign__r.IsActive=true AND Status__c='New' AND Lead_Campaign__r.Sub_Type__c IN ('Strong Hybrid','Strong Formula','Refinance','Cheque','Refer','BA','LI', 'Account Plan',null) AND (Lead_Type__c =: GlobalConstants.LEAD_FOR_SALES OR Lead_Type__c =: GlobalConstants.LEAD_TO_DO OR Lead_Type__c =: GlobalConstants.LEAD_TO_INFORM)) FROM Account WHERE Id IN :accountSet]);
        return accountMapResult;
    }
    
    public static Map<Id,User> getUserMapByCallReportCreateby(List<Call_Report__c> callReportList){
        Set<Id> userSet = new Set<Id>();
        
        Map<Id,User> userMap = new Map<Id,User>();

        for(Call_Report__c eachCallReport : (List<Call_Report__c>) callReportList){
            userSet.add(eachCallReport.CreatedById);
        }
        userMap = new Map<Id,User>([SELECT Id,ManagerId FROM User WHERE Id IN :userSet]);
        return userMap;
    }

    public static void updateActualVisitDateOfOpp(Set<Id> oppIdSet) {
        List<Call_Report_Opportunity__c> callReportOppList = [SELECT Id, Opportunity_Name__c, Call_Plan_Call_Report__r.Actual_visit_Date__c FROM Call_Report_Opportunity__c WHERE Opportunity_Name__c IN :oppIdSet AND Call_Plan_Call_Report__r.IsSLACount__c = true ORDER BY Call_Plan_Call_Report__r.Actual_visit_Date__c ASC];
        Map<Id, Opportunity> oppMapByIdForUpdate = new Map<Id, Opportunity>();
        for(Call_Report_Opportunity__c callReportOpp : callReportOppList) {
            if(!oppMapByIdForUpdate.containsKey(callReportOpp.Opportunity_Name__c)) {
                Opportunity updateOpp = new Opportunity(Id = callReportOpp.Opportunity_Name__c, 
                                                        Actual_visit_Date__c = callReportOpp.Call_Plan_Call_Report__r.Actual_visit_Date__c);
                oppMapByIdForUpdate.put(callReportOpp.Opportunity_Name__c, updateOpp);
            }
        }

        if(!oppMapByIdForUpdate.isEmpty()) {
            update oppMapByIdForUpdate.values();
        }
    }
}