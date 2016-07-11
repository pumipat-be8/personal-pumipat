/**
* @author komsan.wi@beryl8.com
* @08/07/2015 auto create event
* @17/07/2015 change handlerEvent parameters from boolean to enum to support update case, move map account to function, remove max recursive
* @22/09/2015 Update Target_List__c.Status__c base on Call_Report__c.Status__c or Call_Report__c.Offer_Interest__c
* @3/10/2015 optimize code
* @27/01/2016 Add Temporary_Ownership_Flag__c = true on case create call plan / call report from pool (UAT-RMS-00415)
* @09/02/2016 Add UW logic
* @31/05/2016 Add new condition to support new record type
*/
public class CallReportTriggerHandler extends TriggerHandler{
    //private Map<Id,Account> accountMap;
    private String CALL_REPORT_NO_PLAN;
    private String CALL_PLAN;
    private String NEW_CALL_PLAN;
    private String CALL_REPORT;
    private String SME_PROSPECT;
    private String SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN;
    private String SECONDARY_CALL_REPORT_NO_PLAN;

    private User currentUser;

    private Map<String, Id> teamMapByRc;
    private Map<String, Id> userExtMapByEmpId;

    private List<Event> eventInsertList;
    private List<Event> eventUpdateList;
    private List<Call_Report_Lead__c> callReportLeadList;
    private Map<String,List<Opportunity>> opportunityInsertListMapByCallReport;
    
    private Set<Id> eventDeleteSet;
    private String eventSubject;
    //private Boolean hasError;
    private Map<String,Account> accountUpdateMap;
    private enum EventContext{E_CREATE, E_UPDATE, E_DELETE}

    public CallReportTriggerHandler(){
        //hasError = false;
        //this.setMaxLoopCount(1);
    }
    public override void init() {
        if(CallReport_Service.accountMapByCallReportCustomer == null)
            CallReport_Service.accountMapByCallReportCustomer = CallReport_Service.getAccountMapByCallReportCustomer(Trigger.new);
        Set<String> recordTypeSet = new Set<String>{
            GlobalConstants.CALL_REPORT_NO_PLAN_DEVNAME,
            GlobalConstants.CALL_PLAN_DEVNAME,
            GlobalConstants.NEW_CALL_PLAN_DEVNAME,
            GlobalConstants.CALL_REPORT_DEVNAME,
            GlobalConstants.SME_PROSPECT_DEVNAME,
            GlobalConstants.SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN_DEVNAME,
            GlobalConstants.SECONDARY_CALL_REPORT_NO_PLAN_DEVNAME
        };
        List<RecordType> recordTypeList = [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType ='Call_Report__c' AND DeveloperName IN :recordTypeSet];
        for(RecordType eachRecordType : recordTypeList){

            if(eachRecordType.DeveloperName == GlobalConstants.CALL_REPORT_NO_PLAN_DEVNAME)
                CALL_REPORT_NO_PLAN = eachRecordType.Id;
            if(eachRecordType.DeveloperName == GlobalConstants.CALL_PLAN_DEVNAME)
                CALL_PLAN = eachRecordType.Id;
            if(eachRecordType.DeveloperName == GlobalConstants.NEW_CALL_PLAN_DEVNAME)
                NEW_CALL_PLAN = eachRecordType.Id;
            if(eachRecordType.DeveloperName == GlobalConstants.CALL_REPORT_DEVNAME)
                CALL_REPORT = eachRecordType.Id;
            if(eachRecordType.DeveloperName == GlobalConstants.SME_PROSPECT_DEVNAME)
                SME_PROSPECT = eachRecordType.Id;
            if(eachRecordType.DeveloperName == GlobalConstants.SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN_DEVNAME)
                SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN = eachRecordType.Id;
            if(eachRecordType.DeveloperName == GlobalConstants.SECONDARY_CALL_REPORT_NO_PLAN_DEVNAME)
                SECONDARY_CALL_REPORT_NO_PLAN = eachRecordType.Id;
        }
    }
    public override void allBefore() {
        currentUser = [SELECT Id, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Employee_Id__c FROM User WHERE Id = :UserInfo.getUserId()];

        accountUpdateMap = new Map<String,Account>();
        mappingContactPhone((List<Call_Report__c>)Trigger.new);

        Set<Id> accountOwnerSet = new Set<Id>();
        Set<String> accountOwnerRcCode = new Set<String>();

        accountOwnerSet.add(UserInfo.getUserId());
        accountOwnerRcCode.add(currentUser.RC_Code__c);
        accountOwnerRcCode.add(currentUser.AH_RC_Code__c);
        accountOwnerRcCode.add(currentUser.NH_RC_Code__c);

        for(Account eachAccount : CallReport_Service.accountMapByCallReportCustomer.values()){
            accountOwnerSet.add(eachAccount.OwnerId);
            //accountOwnerRcCode.add(eachAccount.RC_Code__c);
            //accountOwnerRcCode.add(eachAccount.AH_RC_Code__c);
            //accountOwnerRcCode.add(eachAccount.NH_RC_Code__c);
        }

        if(CallReport_Service.userExtList == null) {
            CallReport_Service.userExtList = new List<User_Extension__c>();
            CallReport_Service.userExtList = [SELECT Id, External_ID__c FROM User_Extension__c WHERE User__c IN :accountOwnerSet];
        }
        if(CallReport_Service.teamStructureList == null) {
            CallReport_Service.teamStructureList = new List<Team_Structure__c>();
            CallReport_Service.teamStructureList = [SELECT Id, External_ID__c FROM Team_Structure__c WHERE External_Id__c IN :accountOwnerRcCode];
        }
        
        teamMapByRc = new Map<String, Id>();
        userExtMapByEmpId = new Map<String, Id>();

        for(Team_Structure__c eachTeam : CallReport_Service.teamStructureList) {
            teamMapByRc.put(eachTeam.External_ID__c, eachTeam.Id);
        }

        for(User_Extension__c eachUserExt : CallReport_Service.userExtList) {
            userExtMapByEmpId.put(eachUserExt.External_ID__c, eachUserExt.Id);
        }

    }
    private void mappingContactPhone(List<Call_Report__C> callReportList){
        Set<Id> contactIds = new Set<Id>();
        for(Call_Report__c eachCallReport : callReportList) {
            if (eachCallReport.Contact__c != null) {
                contactIds.add(eachCallReport.Contact__c);
            }
        }
        if(contactIds!=null && contactIds.size() > 0){
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Phone_Number__c FROM Contact WHERE Id IN :contactIds]);
            for(Call_Report__c eachCallReport : callReportList) {
                if (eachCallReport.Contact__c != null) {
                    eachCallReport.Phone_Number__c = contactMap.get(eachCallReport.Contact__c).Phone_Number__c;
                }
            }
        }
    }
    public override void beforeInsert() {
        if(!Account_OwnerChange_Service.triggerInitialCall){
            Boolean toUpdate;
            Boolean isChangeOwner;

            for(Call_Report__c eachCallReport : (List<Call_Report__c>)Trigger.new){

                if((eachCallReport.RecordTypeId == CALL_REPORT_NO_PLAN || eachCallReport.RecordTypeId == SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN) && eachCallReport.Status__c != GlobalConstants.CONTACTED)
                    eachCallReport.Status__c = GlobalConstants.CONTACTED;
                eachCallReport.Who__c = UserInfo.getUserId();
                toUpdate = false;
                isChangeOwner = false;
                if(CallReport_Service.accountMapByCallReportCustomer.containsKey(eachCallReport.CIS_ID__c)){
                    Account accountRecord = CallReport_Service.accountMapByCallReportCustomer.get(eachCallReport.CIS_ID__c);
                    if(accountRecord.Port_Pool__c!=GlobalConstants.PORT && accountRecord.OwnerId != UserInfo.getUserId()){
                        //accountRecord.Port_Pool__c = GlobalConstants.POOL;
                        System.debug('Change OwnerId:' + UserInfo.getUserId());
                        accountRecord.OwnerId = UserInfo.getUserId();
                        accountRecord.Temp_Owner_Changed_Date__c = System.Today();
                        accountRecord.OwnerChangeExecutedByTrigger__c = true;
                        accountRecord.Temporary_Ownership_Flag__c = true;
                        Account_OwnerChange_Service.temporaryOwnershipFlag = true;
                        isChangeOwner = true;
                        toUpdate = true;
                    }
                    if(eachCallReport.Customer_Important_Note__c!=null && eachCallReport.Customer_Important_Note__c!=''){
                        accountRecord.Customer_Importance_Note__c = eachCallReport.Customer_Important_Note__c;
                        toUpdate = true;
                    }
                    if((eachCallReport.RecordTypeId == CALL_REPORT || eachCallReport.RecordTypeId == CALL_REPORT_NO_PLAN || eachCallReport.RecordTypeId == SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN) && accountRecord.Current_Activity__c != GlobalConstants.CALL_REPORT){
                        accountRecord.Current_Activity__c = GlobalConstants.CALL_REPORT;
                        toUpdate = true;
                    }
                    else if((eachCallReport.RecordTypeId == CALL_PLAN || eachCallReport.RecordTypeId == NEW_CALL_PLAN) && accountRecord.Current_Activity__c != GlobalConstants.CALL_PLAN){
                        accountRecord.Current_Activity__c = GlobalConstants.CALL_PLAN;
                        toUpdate = true;
                    }
                    if(accountRecord.Current_Activity_By__c != UserInfo.getName()){
                        accountRecord.Current_Activity_By__c = UserInfo.getName();
                        toUpdate = true;
                    }
                    if(toUpdate){
                        accountRecord.Trash_Pool_Flag__c = false;
                        accountUpdateMap.put(accountRecord.Id,accountRecord);//always add if insert
                    }
                        
                    if(eachCallReport.Status__c == GlobalConstants.CONTACTED) {
                        if(accountUpdateMap.containsKey(eachCallReport.CIS_ID__c)){
                            //accountUpdateMap.get(eachCallReport.CIS_ID__c).Contacted__c = true;
                            //accountUpdateMap.get(eachCallReport.CIS_ID__c).Count_Contacted_Call_Report__c++;
                            if(accountUpdateMap.get(eachCallReport.CIS_ID__c).Count_Contacted_Call_Report__c!=null) accountUpdateMap.get(eachCallReport.CIS_ID__c).Count_Contacted_Call_Report__c++;
                            else accountUpdateMap.get(eachCallReport.CIS_ID__c).Count_Contacted_Call_Report__c=1;
                            if(accountUpdateMap.get(eachCallReport.CIS_ID__c).Count_Call_Report_RM__c!=null) accountUpdateMap.get(eachCallReport.CIS_ID__c).Count_Call_Report_RM__c++;
                            else accountUpdateMap.get(eachCallReport.CIS_ID__c).Count_Call_Report_RM__c=1;
                            accountUpdateMap.get(eachCallReport.CIS_ID__c).Last_Visited_By__c = UserInfo.getName();
                            //accountUpdateMap.get(eachCallReport.CIS_ID__c).Count_Call_Report_RM__c++;
                        }else{
                            accountRecord = CallReport_Service.accountMapByCallReportCustomer.get(eachCallReport.CIS_ID__c);       
                            //accountRecord.Contacted__c = true;
                            if(accountRecord.Count_Contacted_Call_Report__c!=null) accountRecord.Count_Contacted_Call_Report__c++;
                            else accountRecord.Count_Contacted_Call_Report__c=1;
                            if(accountRecord.Count_Call_Report_RM__c!=null) accountRecord.Count_Call_Report_RM__c++;
                            else accountRecord.Count_Call_Report_RM__c=1;
                            accountRecord.Last_Visited_By__c = UserInfo.getName();
                            accountUpdateMap.put(accountRecord.Id,accountRecord);
                        }
                    }
                    //
                    // Set User Extension and Team
                    if(teamMapByRc.containsKey(accountRecord.RC_Code__c) && !isChangeOwner) {                        
                        eachCallReport.Current_Team_Name__c = teamMapByRc.get(accountRecord.RC_Code__c);
                    } else {
                        eachCallReport.Current_Team_Name__c = teamMapByRc.get(currentUser.RC_Code__c);
                    }
                    if(teamMapByRc.containsKey(accountRecord.AH_RC_Code__c)  && !isChangeOwner) {
                        eachCallReport.Current_AH_Name__c = teamMapByRc.get(accountRecord.AH_RC_Code__c);
                    } else {
                        eachCallReport.Current_AH_Name__c = teamMapByRc.get(currentUser.AH_RC_Code__c);
                    }
                    if(teamMapByRc.containsKey(accountRecord.NH_RC_Code__c)  && !isChangeOwner) {
                        eachCallReport.Current_NH_Name__c = teamMapByRc.get(accountRecord.NH_RC_Code__c);
                    } else {
                        eachCallReport.Current_NH_Name__c = teamMapByRc.get(currentUser.NH_RC_Code__c);
                    }
                    if(userExtMapByEmpId.containsKey(accountRecord.Owner_Emp_ID__c)  && !isChangeOwner) {
                        eachCallReport.Current_Owner_Extension__c = userExtMapByEmpId.get(accountRecord.Owner_Emp_ID__c);
                    } else {
                        eachCallReport.Current_Owner_Extension__c = userExtMapByEmpId.get(currentUser.Employee_ID__c);
                    }

                    eachCallReport.Port_Pool__c = accountRecord.Port_Pool__c;
                    eachCallReport.Ownership__c = accountRecord.Ownership_Text__c;
                }
            }

            UW_Service.setUW((List<Call_Report__c>)Trigger.new);
        }
    }
    public override void beforeUpdate() {

        Boolean accountToBeUpdate;
        Call_Report__c callReportOldRecord;
        List<Call_Report__c> updatedCallReportUW = new List<Call_Report__c>();
        Account accountRecord;
        for(Call_Report__c eachCallReport : ((List<Call_Report__c>) Trigger.new)) {

            callReportOldRecord = (Call_Report__c)Trigger.oldMap.get(eachCallReport.Id);

            accountToBeUpdate = false;
            if(callReportOldRecord.RecordTypeId == CALL_PLAN && eachCallReport.RecordTypeId == CALL_REPORT && eachCallReport.Status__c != GlobalConstants.CONTACTED)
                eachCallReport.Status__c = GlobalConstants.CONTACTED;
            if(!Account_OwnerChange_Service.triggerInitialCall && CallReport_Service.accountMapByCallReportCustomer.containsKey(eachCallReport.CIS_ID__c)){
                accountRecord = CallReport_Service.accountMapByCallReportCustomer.get(eachCallReport.CIS_ID__c);
                accountRecord.Temporary_Ownership_Flag__c = true;
                Account_OwnerChange_Service.temporaryOwnershipFlag = true;

                if(eachCallReport.Customer_Important_Note__c!=null && eachCallReport.Customer_Important_Note__c != callReportOldRecord.Customer_Important_Note__c && eachCallReport.Customer_Important_Note__c!=''){
                    accountRecord.Customer_Importance_Note__c = eachCallReport.Customer_Important_Note__c;
                    accountToBeUpdate = true;
                }
                if(((callReportOldRecord.RecordTypeId != CALL_REPORT && eachCallReport.RecordTypeId == CALL_REPORT) || (callReportOldRecord.RecordTypeId != CALL_REPORT_NO_PLAN && eachCallReport.RecordTypeId == CALL_REPORT_NO_PLAN) || (callReportOldRecord.RecordTypeId != SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN && eachCallReport.RecordTypeId == SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN)) && accountRecord.Current_Activity__c != GlobalConstants.CALL_REPORT){
                    accountRecord.Current_Activity__c = GlobalConstants.CALL_REPORT;
                    accountToBeUpdate = true;
                }
                else if(((callReportOldRecord.RecordTypeId != CALL_PLAN && eachCallReport.RecordTypeId == CALL_PLAN) || (callReportOldRecord.RecordTypeId != NEW_CALL_PLAN && eachCallReport.RecordTypeId == NEW_CALL_PLAN)) && accountRecord.Current_Activity__c != GlobalConstants.CALL_PLAN){
                    accountRecord.Current_Activity__c = GlobalConstants.CALL_PLAN;
                    accountToBeUpdate = true;
                }
                if(accountRecord.Current_Activity_By__c != UserInfo.getName()){
                    accountRecord.Current_Activity_By__c = UserInfo.getName();
                    accountToBeUpdate = true;
                }
                if(accountToBeUpdate){
                    //accountRecord.Trash_Pool_Flag__c = false;
                    accountUpdateMap.put(accountRecord.Id,accountRecord);
                }
            }
            if(callReportOldRecord.Plan_Date__c != eachCallReport.Plan_Date__c){
                if (eachCallReport.Number_of_Reschedule__c != null){
                    eachCallReport.Number_of_Reschedule__c++;
                } else {
                    eachCallReport.Number_of_Reschedule__c = 1;
                }
            }

            if(eachCallReport.Business_Code__c != callReportOldRecord.Business_Code__c) {
                updatedCallReportUW.add(eachCallReport);
            }
            
            if(callReportOldRecord.Status__c != GlobalConstants.CONTACTED && eachCallReport.Status__c == GlobalConstants.CONTACTED) {
                if(accountUpdateMap.containsKey(eachCallReport.CIS_ID__c)){
                    if(accountUpdateMap.get(eachCallReport.CIS_ID__c).Owner.Profile.Name == GlobalConstants.SME_RM)
                        accountUpdateMap.get(eachCallReport.CIS_ID__c).Count_Call_Report_RM__c++;
                    accountUpdateMap.get(eachCallReport.CIS_ID__c).Count_Contacted_Call_Report__c++;
                    accountUpdateMap.get(eachCallReport.CIS_ID__c).Last_Visited_By__c = UserInfo.getName();
                }else{
                    accountRecord = CallReport_Service.accountMapByCallReportCustomer.get(eachCallReport.CIS_ID__c);       
                    if(accountRecord.Owner.Profile.Name == GlobalConstants.SME_RM)
                        accountRecord.Count_Call_Report_RM__c++;
                    accountRecord.Count_Contacted_Call_Report__c++;
                    accountRecord.Last_Visited_By__c = UserInfo.getName();
                    accountUpdateMap.put(accountRecord.Id,accountRecord);
                }
            }
            //if(callReportOldRecord.Status__c == GlobalConstants.CONTACTED && eachCallReport.Status__c != GlobalConstants.CONTACTED) {
            //    if(accountUpdateMap.containsKey(eachCallReport.CIS_ID__c)){
            //        if(accountUpdateMap.get(eachCallReport.CIS_ID__c).Owner.Profile.Name == GlobalConstants.SME_RM)
            //            accountUpdateMap.get(eachCallReport.CIS_ID__c).Count_Call_Report_RM__c--;
            //        accountUpdateMap.get(eachCallReport.CIS_ID__c).Count_Contacted_Call_Report__c--;
            //        accountUpdateMap.get(eachCallReport.CIS_ID__c).Last_Visited_By__c = accountRecord.CreatedById;
            //    }else{
            //        accountRecord = CallReport_Service.accountMapByCallReportCustomer.get(eachCallReport.CIS_ID__c);
            //        if(accountRecord.Owner.Profile.Name == GlobalConstants.SME_RM)
            //            accountRecord.Count_Call_Report_RM__c--;
            //        accountRecord.Count_Contacted_Call_Report__c--;
            //        accountRecord.Last_Visited_By__c = accountRecord.CreatedById;
            //        accountUpdateMap.put(accountRecord.Id,accountRecord);
            //    }
            //}
        }

        if(!updatedCallReportUW.isEmpty()) {
            UW_Service.setUW(updatedCallReportUW);    
        }

        /*Contact contactObj = new Contact();
        Map<String,Contact> contactMap = new Map<String,Contact>();
        Account accountRecord;
        for(Call_Report__c eachCallReport : (List<Call_Report__c>) Trigger.new) {
            if ((eachCallReport.RecordTypeId == CALL_REPORT_NO_PLAN || eachCallReport.RecordTypeId == CALL_REPORT) && eachCallReport.Contact__c == null) {
                accountRecord = CallReport_Service.accountMapByCallReportCustomer.get(eachCallReport.CIS_ID__c);
                contactObj.FirstName = eachCallReport.Contact_Firstname__c;
                contactObj.LastName = eachCallReport.Contact_Lastname__c;
                contactObj.Phone_Number__c = eachCallReport.Contact_Phone__c;
                contactObj.AccountId = accountRecord.Id;
                contactMap.put(eachCallReport.Id , contactObj);
            }
        }
        try{
            insert contactMap.values();
        }catch(Exception ex){
            String errorMessage = ex.getMessage();
            if(errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                Trigger.new.get(0).addError(errorMessage.split(',')[1].split(':')[0]);
            }
        }
        if(contactMap!=null && contactMap.size()!=null){
            for(Call_Report__c eachCallReport : (List<Call_Report__c>)Trigger.new){
                if(contactMap.containsKey(eachCallReport.Id)){
                    eachCallReport.Contact__c = contactMap.get(eachCallReport.Id).Id;
                }
            }
        }
        mappingContactPhone((List<Call_Report__c>)Trigger.new);*/
    }
    public override void beforeFinally() {
        if(!Account_OwnerChange_Service.triggerInitialCall && !accountUpdateMap.isEmpty()){
            Account_OwnerChange_Service.callReportTriggerList = (List<Call_Report__c>)Trigger.new;
            Account_OwnerChange_Service.triggerInitialCall = true;

            update accountUpdateMap.values();

            Account_OwnerChange_Service.callReportTriggerList = null;
        }
        if(CallReport_Service.userExtList != null) CallReport_Service.userExtList = null;
        if(CallReport_Service.teamStructureList != null) CallReport_Service.teamStructureList = null;
    }
    public override void allAfter() {
        eventDeleteSet = new Set<Id>();
        eventInsertList = new List<Event>();
        eventUpdateList = new List<Event>();
        callReportLeadList = new List<Call_Report_Lead__c>();
        opportunityInsertListMapByCallReport = new Map<String,List<Opportunity>>();
    }
    public override void afterInsert() {
        if(CallReport_Service.userMapByCallReportCreateby == null)
            CallReport_Service.userMapByCallReportCreateby = CallReport_Service.getUserMapByCallReportCreateby(Trigger.new);
        Account accountRecord;
        for(Call_Report__c eachCallReport : (List<Call_Report__c>)Trigger.new){
            if(CallReport_Service.accountMapByCallReportCustomer.containsKey(eachCallReport.CIS_ID__c)){
                accountRecord = CallReport_Service.accountMapByCallReportCustomer.get(eachCallReport.CIS_ID__c);
                
                if((eachCallReport.RecordTypeId == CALL_REPORT_NO_PLAN || eachCallReport.RecordTypeId == NEW_CALL_PLAN || eachCallReport.RecordTypeId == SECONDARY_CALL_REPORT_NO_PLAN || eachCallReport.RecordTypeId == SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN) && accountRecord.Campaign_Members_Leads__r!=null && accountRecord.Campaign_Members_Leads__r.size() > 0){
                    for(Target_List__c eachTargetLead : accountRecord.Campaign_Members_Leads__r){
                        callReportLeadList.add(new Call_Report_Lead__c(
                            Call_Plan_Call_Report__c = eachCallReport.Id,
                            Target_List__c = eachTargetLead.Id
                        ));
                    }
                }
                if(eachCallReport.Status__c == GlobalConstants.PLAN && eachCallReport.Plan_Date__c!=null){
                    eventSubject = String.format(GlobalConstants.ASSIGN_TO_SUBJECT,new String[]{eachCallReport.Visit_Objective__c,(accountRecord.CIS__c!=null)?accountRecord.CIS__c:accountRecord.Name});

                    this.handlerEvent(eachCallReport, accountRecord, null, EventContext.E_CREATE);
                }
            }
        }
    }
    public override void afterFinally() {
        if(!Account_OwnerChange_Service.callReportRunOnce){
            insertingContact();

            Account accountRecord;
            Account_OwnerChange_Service.callReportRunOnce = true;
            Map<Id, Target_List__c> mapUpdateTargetList = new Map<Id, Target_List__c>();
            Set<Id> setTargetIds = new Set<Id>();

            Map<Id, List<Call_Report_Lead__c>> mapLeadByCallReport = new Map<Id, List<Call_Report_Lead__c>>();
            for (Call_Report_Lead__c callLeadReport : [SELECT Id, Type__c,Target_List__c,Status__c, Call_Plan_Call_Report__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c IN :Trigger.newMap.keySet() AND (Type__c=:GlobalConstants.LEAD_FOR_SALES OR Type__c=:GlobalConstants.LEAD_TO_DO)]) {
                if(!mapLeadByCallReport.containsKey(callLeadReport.Call_Plan_Call_Report__c))
                    mapLeadByCallReport.put(callLeadReport.Call_Plan_Call_Report__c,new List<Call_Report_Lead__c>());
                mapLeadByCallReport.get(callLeadReport.Call_Plan_Call_Report__c).add(callLeadReport);
            }
            
            for(Call_Report__c eachCallReport : ((List<Call_Report__c>) Trigger.new)) {
                if(CallReport_Service.accountMapByCallReportCustomer.containsKey(eachCallReport.CIS_ID__c)){
                    accountRecord = CallReport_Service.accountMapByCallReportCustomer.get(eachCallReport.CIS_ID__c);
                    if(eachCallReport.Offer_Interest__c == GlobalConstants.INTEREST_AND_CAN_APPLY && (Trigger.old==null || (Trigger.old!=null && Trigger.oldMap.get(eachCallReport.Id).get('Offer_Interest__c') != GlobalConstants.INTEREST_AND_CAN_APPLY))){
                        if(!(accountRecord.RecordTypeId == SME_PROSPECT && (accountRecord.Birthdate_Registration_Date__c==null || accountRecord.Identification_No__c==null))){
                            if((eachCallReport.RecordTypeId == CALL_REPORT) || (eachCallReport.RecordTypeId == CALL_REPORT_NO_PLAN) || (eachCallReport.RecordTypeId == SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN)){
                                if(!opportunityInsertListMapByCallReport.containsKey(eachCallReport.Id))
                                    opportunityInsertListMapByCallReport.put(eachCallReport.Id,new List<Opportunity>());
                                
                                opportunityInsertListMapByCallReport.get(eachCallReport.Id).add(new Opportunity(
                                    Name = (accountRecord.CIS__c!=null)?accountRecord.CIS__c:accountRecord.Name,
                                    AccountId = accountRecord.Id,
                                    CloseDate = System.today(),
                                    StageName = GlobalConstants.STOCK_NEGOTIATION,
                                    Amount = eachCallReport.Expected_Credit_Amount__c,
                                    Head_of_UW_Name__c = eachCallReport.Head_of_UW_Name__c,
                                    Senior_UW_Name__C = eachCallReport.Senior_UW_Name__C,
                                    Business_Code__c = eachCallReport.Business_Code__c
                                ));
                            }
                        }
                    }
                }

                if (mapLeadByCallReport.containsKey(eachCallReport.Id)) {
                    List<Call_Report_Lead__c> callReportLeadList = mapLeadByCallReport.get(eachCallReport.Id);

                    String newTargetStatus;
                    Boolean offerIsNull = false;
                    Target_List__c tempTargetList;
                    for(Call_Report_Lead__c eachCallReportLead : callReportLeadList){
                        newTargetStatus = eachCallReportLead.Status__c;
                        offerIsNull = false;

                        if (eachCallReportLead.Type__c == GlobalConstants.LEAD_FOR_SALES) {
                            if(eachCallReport.Offer_Interest__c == null || eachCallReport.Offer_Interest__c == '') {
                                offerIsNull = true;
                            } else if (eachCallReport.Offer_Interest__c == GlobalConstants.CANNOT_APPLY || eachCallReport.Offer_Interest__c == GlobalConstants.NOT_INTEREST) {
                                newTargetStatus = GlobalConstants.NOT_INTERESTED_THIS_TIME;
                            } else if (eachCallReport.Offer_Interest__c == GlobalConstants.INTEREST_AND_CAN_APPLY || eachCallReport.Offer_Interest__c == GlobalConstants.INTEREST_WITH_CONDITION) {
                                newTargetStatus = GlobalConstants.CUSTOMER_INTERESTED;
                            }
                        } else if (eachCallReportLead.Type__c == GlobalConstants.LEAD_TO_DO && eachCallReport.Status__c != null) {
                            if (eachCallReport.Status__c == GlobalConstants.PLAN || eachCallReport.Status__c == GlobalConstants.CANCEL) {
                                newTargetStatus = GlobalConstants.STATUS_NEW;
                            } else if (eachCallReport.Status__c == GlobalConstants.CONTACTED) {
                                newTargetStatus = GlobalConstants.STATUS_DONE;
                            }
                        }

                        if (newTargetStatus != eachCallReportLead.Status__c || offerIsNull == true) {
                            tempTargetList = new Target_List__c(Id = eachCallReportLead.Target_List__c);
                            tempTargetList.Status__c = newTargetStatus;
                            if(offerIsNull) tempTargetList.In_Call_Plan__c = false;

                            mapUpdateTargetList.put(eachCallReportLead.Target_List__c, tempTargetList);
                        }                 
                    }
                }
            }
            if (mapUpdateTargetList.size() > 0) {
                update mapUpdateTargetList.values();
            }
            if(opportunityInsertListMapByCallReport!=null && !opportunityInsertListMapByCallReport.values().isEmpty()){
                List<Call_Report_Opportunity__c> callReportOppInsertList = new List<Call_Report_Opportunity__c>();
                List<Opportunity> opportunityFinalInsertList = new List<Opportunity>();
                for(List<Opportunity> eachOpportunityList : opportunityInsertListMapByCallReport.values()){
                    opportunityFinalInsertList.addAll(eachOpportunityList);
                }
                insert opportunityFinalInsertList;
                for(String eachCallReportId : opportunityInsertListMapByCallReport.keySet()){
                    List<Opportunity> opportunityListByCallReport = opportunityInsertListMapByCallReport.get(eachCallReportId);
                    for(Opportunity eachInsertOpp : opportunityListByCallReport){
                        callReportOppInsertList.add(new Call_Report_Opportunity__c(
                            Call_Plan_Call_Report__c = eachCallReportId,
                            Opportunity_Name__c = eachInsertOpp.Id
                        ));
                    }
                }
                if(callReportOppInsertList.size() > 0) insert callReportOppInsertList;
            }
        }
    }
    public override void afterUpdate() {
        if(!Account_OwnerChange_Service.callReportRunOnce){
            List<Event> eventList = [SELECT Call_Plan_Call_Report__c FROM Event WHERE Call_Plan_Call_Report__c in:Trigger.newMap.keySet()];
            List<Event> thisCallReportEvent;
            Set<Id> callReportIdSet = new Set<Id>();
            Set<Id> callRepSetForCheckOpp = new Set<Id>();
            Boolean isChangeToSLACount;
            for(Call_Report__c eachCallReport : (List<Call_Report__c>)Trigger.new){
                Call_Report__c oldCallReport = (Call_Report__c)Trigger.oldMap.get(eachCallReport.Id);

                isChangeToSLACount = oldCallReport.IsSLACount__c == false && eachCallReport.IsSLACount__c == true;

                if(isChangeToSLACount) {
                    callReportIdSet.add(eachCallReport.Id);
                }

                if((eachCallReport.Head_of_UW_Name__c != oldCallReport.Head_of_UW_Name__c || eachCallReport.Senior_UW_Name__c != oldCallReport.Senior_UW_Name__c)) {
                    callRepSetForCheckOpp.add(eachCallReport.Id);
                }

                if(eachCallReport.Status__c == GlobalConstants.CANCEL || eachCallReport.Status__c == GlobalConstants.CLOSED){
                    this.handlerEvent(eachCallReport, null, null, EventContext.E_DELETE);
                }else if(eachCallReport.Plan_Date__c!=null && eachCallReport.Plan_Date__c!=((Call_Report__c)Trigger.oldMap.get(eachCallReport.Id)).Plan_Date__c){
                    thisCallReportEvent = new List<Event>();
                    for(Event eachEvent : eventList){
                        if(eachEvent.Call_Plan_Call_Report__c == eachCallReport.Id){
                            thisCallReportEvent.add(eachEvent);
                            break;
                        }
                    }
                    this.handlerEvent(eachCallReport, null, thisCallReportEvent, EventContext.E_UPDATE);
                }
            }

            Set<Id> oppIdSetForUpdateAcutalVisitDate = new Set<Id>();
            Map<Id, Call_Report__c> callRepMapByOpp = new Map<Id, Call_Report__c>();
            if(!callReportIdSet.isEmpty()) {
                for(Call_Report_Opportunity__c callReportOpp : [SELECT Id, Opportunity_Name__c FROM Call_Report_Opportunity__c WHERE Call_Plan_Call_Report__c IN :callReportIdSet]) {
                    oppIdSetForUpdateAcutalVisitDate.add(callReportOpp.Opportunity_Name__c);
                }
            }

            if(!callRepSetForCheckOpp.isEmpty()) {
                for(Call_Report_Opportunity__c callReportOpp : [SELECT Id, Opportunity_Name__c, Call_Plan_Call_Report__c  FROM Call_Report_Opportunity__c WHERE Call_Plan_Call_Report__c IN :callRepSetForCheckOpp]) {
                    callRepMapByOpp.put(callReportOpp.Opportunity_Name__c, (Call_Report__c)Trigger.newMap.get(callReportOpp.Call_Plan_Call_Report__c));
                }
            }
            UW_Service.updateOppUW(callRepMapByOpp);
            CallReport_Service.updateActualVisitDateOfOpp(oppIdSetForUpdateAcutalVisitDate);
        }
    }
    private void handlerEvent(Call_Report__c callReportEvent, Account accountObj, List<Event> eventList,EventContext ec){
        if(ec == EventContext.E_CREATE){
            eventInsertList.add(new Event(
                EndDateTime = callReportEvent.Plan_Date__c.addHours(1),
                StartDateTime = callReportEvent.Plan_Date__c,
                Subject = eventSubject,
                WhatID = accountObj.Id,
                Call_Plan_Call_Report__c = callReportEvent.Id,
                OwnerId = (Trigger.old!=null)?callReportEvent.CreatedById:UserInfo.getUserId()
            ));
        }
        else if(ec == EventContext.E_UPDATE && eventList!=null && eventList.size() > 0){
            for(Event eachEvent : eventList){
                eventUpdateList.add(new Event(
                    Id = eachEvent.Id,
                    EndDateTime = callReportEvent.Plan_Date__c.addHours(1),
                    StartDateTime = callReportEvent.Plan_Date__c
                ));
            }
        }
        else if(ec == EventContext.E_DELETE){
            eventDeleteSet.add(callReportEvent.Id);
        }
    }
    public override void afterInsertFinally(){
        if(eventInsertList.size() > 0){
            CallReport_Service.insertEvent(eventInsertList);
            List<EventRelation> eventRelationList = new List<EventRelation>();
            Call_Report__c callReportByMap;
            for(Event eachInsertEvent : eventInsertList){
                callReportByMap = ((Map<Id,Call_Report__c>)Trigger.newMap).get(eachInsertEvent.Call_Plan_Call_Report__c);
                if(CallReport_Service.userMapByCallReportCreateby.get(UserInfo.getUserId()).ManagerId!=null)
                    eventRelationList.add(new EventRelation(
                        EventId = eachInsertEvent.Id,
                        RelationId = CallReport_Service.userMapByCallReportCreateby.get(UserInfo.getUserId()).ManagerId
                    ));
            }
            if(eventRelationList.size() > 0) CallReport_Service.insertEvent(eventRelationList);
        }
        if(callReportLeadList.size() > 0) insert callReportLeadList;
    }
    public override void afterUpdateFinally() {

        if(eventUpdateList.size() > 0)
            CallReport_Service.updateEvent(eventUpdateList);
        if(eventDeleteSet.size() > 0)
            CallReport_Service.deleteEvent(eventDeleteSet);
    }
    private void insertingContact(){
        List<Call_Report__c> callReportUpdateList = new List<Call_Report__c>();
        Contact contactObj = new Contact();
        //Set<String> contactNameList = new Set<String>();
        List<Contact> existContactList = new List<Contact>();
        Map<String,Contact> contactMap = new Map<String,Contact>();
        Account accountRecord;
        for(Call_Report__c eachCallReport : (List<Call_Report__c>) Trigger.new) {
            if ((eachCallReport.RecordTypeId == CALL_REPORT_NO_PLAN || eachCallReport.RecordTypeId == CALL_REPORT || eachCallReport.RecordTypeId == SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN) && eachCallReport.Contact__c == null) {
                accountRecord = CallReport_Service.accountMapByCallReportCustomer.get(eachCallReport.CIS_ID__c);
                contactObj.FirstName = eachCallReport.Contact_Firstname__c;
                contactObj.LastName = eachCallReport.Contact_Lastname__c;
                contactObj.Phone_Number__c = eachCallReport.Contact_Phone__c;
                contactObj.AccountId = accountRecord.Id;
                contactMap.put(eachCallReport.Id , contactObj);
                //contactNameList.add(eachCallReport.Contact_Lastname__c);
            }
        }
        //existContactList = [SELECT Id FROM Contact WHERE LastName IN :contactNameList];
        //system.assertEquals('s',existContactList+'');
        //if(existContactList==null || existContactList.size() == 0){
        Boolean hasError = false;
            try{
                insert contactMap.values();
            }catch(Exception ex){
                hasError = true;
                String errorMessage = ex.getMessage();
                if(errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                    Trigger.new.get(0).addError('Contact Error: '+errorMessage.split(',')[1].split(':')[0]);
                }else Trigger.new.get(0).addError('Contact Error: '+errorMessage);
            }
            if(!hasError){
                if(contactMap!=null && contactMap.size()!=null){
                    for(Call_Report__c eachCallReport : (List<Call_Report__c>)Trigger.new){
                        if(contactMap.containsKey(eachCallReport.Id)){
                            callReportUpdateList.add(new Call_Report__c(
                                Id = eachCallReport.Id,
                                Contact__c = contactMap.get(eachCallReport.Id).Id,
                                Phone_Number__c = eachCallReport.Contact_Phone__c,
                                Contact_Firstname__c =null,
                                Contact_Lastname__c=null,
                                Contact_Phone__c=null
                            ));
                        }
                    }
                }
                if(callReportUpdateList!=null && callReportUpdateList.size() > 0){
                    //mappingContactPhone(callReportUpdateList);
                    TriggerHandler.bypass('CallReportTriggerHandler'); //consider?
                    try{
                        update callReportUpdateList;
                    }catch(Exception ex){
                        String errorMessage = ex.getMessage();
                        if(errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                            Trigger.new.get(0).addError(errorMessage.split(',')[1].split(':')[0]);
                        }else Trigger.new.get(0).addError(errorMessage);
                    }
                }
            }
        //}else Trigger.new.get(0).addError('error ?');
    }
}