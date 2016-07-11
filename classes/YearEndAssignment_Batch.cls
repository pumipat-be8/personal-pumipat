/**
 * @author komsan.wi@beryl8.com
 * @16/07/2015 create new
 * @17/09/2015 update
 * @25/09/2015 remove stateful, change static variable to constants
 * @27/01/2015 Add Temporary_Ownership_Flag__c = false
 */

global class YearEndAssignment_Batch extends ApplicationLog_Service implements Database.Batchable<sObject> ,Database.AllowsCallouts{
    private List<Account> accountList;
    private SME_Admin__c sa;
    private String SUBMIT_VAL = GlobalConstants.Submitted;
    private String queryString;
    public YearEndAssignment_Batch(){
        accountList = new List<Account>();
        sa = SME_Admin__c.getOrgDefaults();
        queryString = query();
    }
    public YearEndAssignment_Batch(String yearId){
        accountList = new List<Account>();
        sa = SME_Admin__c.getOrgDefaults();
        queryString = query() + ' AND Id = \''+yearId+'\'';
    }
    public YearEndAssignment_Batch(Boolean flaging){
        accountList = new List<Account>();
        sa = SME_Admin__c.getOrgDefaults();
        queryString = query() + ' AND Final_Refer_Out__c =true';
    }
    private String query(){
        return 'SELECT Id,CIS_ID__c,CIS_ID__r.OwnerId,Final_Assigned_RM__c,Segment_Proposed__c,Final_Refer_Out__c,Final_Port_Pool__c,Final_Service_RM__c,Refer_Out_Reason__c,Refer_Out_Segment__c FROM Year_End_Assignment__c WHERE  Status__c=\'Submitted\'';
    }
    global Database.queryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(queryString);
    }
    global void execute(Database.BatchableContext BC, List<Year_End_Assignment__c> yearEnd){
        accountList = new List<Account>();
        for(Year_End_Assignment__c eachYearEnd : yearEnd){
            if (!eachYearEnd.Final_Refer_Out__c && ((eachYearEnd.Final_Port_Pool__c != null && eachYearEnd.Final_Assigned_RM__c!= sa.User_Record_ID__c) || eachYearEnd.Final_Assigned_RM__c== sa.User_Record_ID__c)) {
                if(eachYearEnd.CIS_ID__r.OwnerId!=eachYearEnd.Final_Assigned_RM__c)
                    accountList.add(new Account (
                            Id = eachYearEnd.CIS_ID__c,
                            OwnerId = eachYearEnd.Final_Assigned_RM__c,
                            Service_RM__c = eachYearEnd.Final_Service_RM__c,
                            Port_Pool__c = (eachYearEnd.Final_Assigned_RM__c!=sa.User_Record_ID__c)?eachYearEnd.Final_Port_Pool__c:null,
                            Previous_Owner__c = null,
                            OwnerChangeExecutedByTrigger__c = true,
                            Temporary_Ownership_Flag__c = false,
                            Previous_Owner_Emp_ID__c = null,
                            Previous_Owner_Segment_Code__c = null,
                            
                            Port_Pool_Flag_Previous_Owner__c = null
                        ));
            }else if (eachYearEnd.Final_Refer_Out__c && (eachYearEnd.Refer_Out_Reason__c == GlobalConstants.BAD || eachYearEnd.Refer_Out_Reason__c == GlobalConstants.DEAD || eachYearEnd.Refer_Out_Reason__c == GlobalConstants.CLOSED_BUSINESS || eachYearEnd.Refer_Out_Reason__c == GlobalConstants.AMLO_LIST || eachYearEnd.Refer_Out_Reason__c == GlobalConstants.EXIT_PLAN || eachYearEnd.Refer_Out_Reason__c == GlobalConstants.CRIMINAL_OFFENSE || eachYearEnd.Refer_Out_Reason__c == GlobalConstants.OTHER_SEGMENT)) {
                //refer out
                if(eachYearEnd.CIS_ID__r.OwnerId!=sa.User_Record_ID__c)
                accountList.add(
                    new Account(
                        Id = eachYearEnd.CIS_ID__c,
                        OwnerId = sa.User_Record_ID__c,
                        Service_RM__c = null,
                        Previous_Owner__c = null,
                        Primary_Segment_Code__c = (eachYearEnd.Refer_Out_Reason__c == GlobalConstants.OTHER_SEGMENT)?eachYearEnd.Segment_Proposed__c:null,
                        Other_Segment__c = (eachYearEnd.Refer_Out_Reason__c == GlobalConstants.OTHER_SEGMENT)?eachYearEnd.Refer_Out_Segment__c:null,
                        OwnerChangeExecutedByTrigger__c = true,
                        Temporary_Ownership_Flag__c = false,
                        Previous_Owner_Emp_ID__c = null,
                        Previous_Owner_Segment_Code__c = null,
                        Port_Pool__c = null,
                        Port_Pool_Flag_Previous_Owner__c = null
                    )
                );
            }else if(eachYearEnd.Refer_Out_Reason__c != GlobalConstants.REJECT){
                if(eachYearEnd.CIS_ID__r.OwnerId!='00528000000aAuWAAU')
                accountList.add(
                    new Account(
                        Id = eachYearEnd.CIS_ID__c,
                        OwnerId = '00528000000aAuWAAU',
                        Service_RM__c = null,
                        Previous_Owner__c = null,
                        Primary_Segment_Code__c = null,
                        Other_Segment__c = null,
                        OwnerChangeExecutedByTrigger__c = true,
                        Temporary_Ownership_Flag__c = false,
                        Previous_Owner_Emp_ID__c = null,
                        Previous_Owner_Segment_Code__c = null,
                        Port_Pool_Flag_Previous_Owner__c = null
                    )
                );
            }//else this.addLog('YearEndAssignment_Batch', 'Cannot Assign Selected YearEnd Record : ' + eachYearEnd.Id);
            
        }
        clearance();
    }
    protected override void clearance(){
        if(accountList!=null && accountList.size() > 0){
            try{
                Account_OwnerChange_Service.callingFromYearEndBatch = true;
                GlobalUtility.accounFromYearend = true;
                update accountList;
                Database.executeBatch(new SME_YearEndContactChangeOwner_Batch());
            }catch(Exception dex){
                this.addLog('YearEndAssignment_Batch',dex);
            }
        }
        super.clearance();
    }
    global void finish(Database.BatchableContext BC){}
}