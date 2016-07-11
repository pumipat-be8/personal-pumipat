global class SME_Performance_All_Batch implements Database.Batchable<sObject>, Database.Stateful{
    private String query;
    private Map<String,User_Extension__c> userMapExt;//user,ext
    private Set<String> userMapExtKeySet{get{return userMapExt.keySet();}}//user,ext
    private Map<String,Team_Structure__c> teamMap;

    private Boolean runMontly = false;
    private Boolean shouldRunMontly = true;
    private Boolean resetStatement = false;
    private Boolean initialMonthly = false;
    private Map<String,Monthly_Performance__c> monthlyMap;

    private Map<String,User_Extension__c> userExMap;
	private Map<String,List<String>> userExIdMapTeam;
	private Date todayDateFromNow;
    private Integer currentYear;
    private Map<String,String> callReportMapOwner;


    private SME_Performance_Util util;
    //global SME_Performance_All_Batch runMontlyAlso(){
    //	runMontly = true;
    //	monthlyMap = new Map<String,Monthly_Performance__c>();
    //	return this.runMontly();
    //}
    global SME_Performance_All_Batch() {
    	this.query = 'SELECT Id,CIS__c,Port_Pool__c,Ownership__c,OwnerId,Count_Call_Report_RM__c,Count_Contacted_Call_Report__c,Owner.ProfileId,Owner.Profile.Name,Service_RM__c,Service_RM__r.RC_Code__c,Service_RM__r.ProfileId,Service_RM__r.Profile.Name,Owner.RC_Code__c,Number_of_Visited__c FROM Account WHERE OwnerId IN :userMapExtKeySet';
    	// AND Owner.isActive=true
    	userExMap = new Map<String,User_Extension__c>([SELECT Id,Call_Report__c,Call_Report_Customer_Others__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Port__c,Call_Report_for_Relationship__c,Contacted_Customer_Other__c,Contacted_Customer_Pool__c,Contacted_Customer_Port__c,Customer_Other__c,Customer_Pool__c,Customer_Port__c,Face_to_Face__c,Months__c,Phone_Call__c,Team_Structure__c,User__c,User__r.ProfileId,User__r.Profile.Name,User__r.RC_Code__c,User__r.Employee_Id__c,User__r.ManagerId,Total_visited_Customer__c,Contacted_Customer_Other_My_Penetrate__c,Contacted_Customer_Pool_My_Penetrate__c,Contacted_Customer_Port_My_Penetrate__c FROM User_Extension__c WHERE Team_Structure__c!=null]);

        teamMap = new Map<String,Team_Structure__c>([SELECT Id,Call_Report__c,Call_Report_Customer_Others__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Port__c,Call_Report_for_Relationship__c,Call_Report_for_Sales__c,Contacted_Customer_Other__c,Contacted_Customer_Pool__c,Contacted_Customer_Port__c,Customer_Other__c,Customer_Pool__c,Customer_Port__c,Face_to_Face__c,Months__c,Phone_Call__c,Name,AH_Name__c,NH_Name__c,RC_Code__c,AH_RC_Code__c,NH_RC_Code__c,Total_visited_Customer__c,Contacted_Customer_Other_My_Penetrate__c,Contacted_Customer_Pool_My_Penetrate__c,Contacted_Customer_Port_My_Penetrate__c FROM Team_Structure__c]);

        util = new SME_Performance_Util(userExMap,teamMap);
        userMapExt = util.getUserExt();
    }
    global SME_Performance_All_Batch(Map<String,User_Extension__c> userExMap,Map<String,Team_Structure__c> teamMap) {
    	this.query = 'SELECT Id,CIS__c,Port_Pool__c,Ownership__c,OwnerId,Count_Call_Report_RM__c,Count_Contacted_Call_Report__c,Owner.ProfileId,Owner.Profile.Name,Service_RM__c,Service_RM__r.RC_Code__c,Service_RM__r.ProfileId,Service_RM__r.Profile.Name,Owner.RC_Code__c,Number_of_Visited__c FROM Account WHERE OwnerId IN :userMapExtKeySet AND Owner.isActive=true';
    	this.userExMap = userExMap;
		this.teamMap = teamMap;
        util = new SME_Performance_Util(userExMap,teamMap);
        userMapExt = util.getUserExt();
    }
    global SME_Performance_All_Batch noMontly(){
        shouldRunMontly = false;
        return this;
    }
    global SME_Performance_All_Batch runMontly(Map<String,Monthly_Performance__c> monthlyMap,Boolean resetStatement,Boolean initialMonthly){
    	runMontly = true;
        this.resetStatement = resetStatement;
        this.initialMonthly = initialMonthly;
    	util.setMonthlyMap(monthlyMap);

    	return this;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
    	return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Account> accountList) {
        List<Call_Report__c> callReportList = new List<Call_Report__c>();
        //owner+account
        callReportList = [SELECT Id,Current_Owner_Extension__c,Current_Owner_Extension__r.User__c,CIS_ID__c,CIS_ID__r.OwnerId FROM Call_Report__c WHERE CIS_ID__c IN :accountList AND Status__c='Contacted'];// AND Primary_Call_Report__c=true
       
        util.setCallReportList(callReportList);

    	for(Account eachAccount : accountList){
    		util.executeAccount(eachAccount,runMontly);
    	}
    }
    
    global void finish(Database.BatchableContext BC) {
    	update util.getFinalUserExt();
        util.finalTeamTask();
    	if(runMontly) {
            GlobalUtility.resetStatement = resetStatement;
    		//upsert monthlyMap.values() External_ID__c;
    		Database.executeBatch(new SME_Monthly_DML_Batch(util.getMonthly()),2000);

            //if(!initialMonthly)
    	}
    	
    	//Database.executeBatch(new SME_DML_Batch(util.getFinalTeam()),2000);
    	update util.getFinalTeam();
    }
}