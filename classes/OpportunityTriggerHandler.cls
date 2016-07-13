/**
* @author komsan.wi@beryl8.com
* @16/07/2015 createddate
* @06/10/2015 use normal map for target list instead of map of list to prevent duplicate list, beware for wrong stage when uploading object
* @27/01/2015 Add Temporary_Ownership_Flag__c = true on case create opportunity from pool (UAT-RMS-00415)
* @06/07/2016 Update Target status based on RTM : A2 - ISCR028
* @07/07/2016 Stamp Current AH and Current NH
*/
public class OpportunityTriggerHandler extends TriggerHandler{
    private List<Account> accountUpdateList;
    private Map<Id,Account> accountMap;
    private Map<Id,User> userMap;

    private User currentUser;
    private User currentUserAH;
    private User currentUserNH;

    private Map<String, Id> teamMapByRc;
    private Map<String, Id> userExtMapByEmpId;

    public override void allBefore() {
        Set<Id> accountSet = new Set<Id>();
        Map<String,Application_Number__c> applicationNumberUpsertList = new Map<String,Application_Number__c>();
        accountMap = new Map<Id,Account>();
        accountUpdateList = new List<Account>();
        Application_Number__c applicationNumberByRC;
        String currentYear = (System.now().yearGmt() > 2555)?String.valueOf(System.now().yearGmt()):String.valueOf(System.now().yearGmt()+543);
        String runningNumberString;

        userMap = new Map<Id,User>([SELECT Id,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId, Profile.Name FROM User WHERE Profile.Name !=: GlobalConstants.SME_ADMIN]);
        
        currentUser = [SELECT Id, IsActive,RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Employee_Id__c, AH_Employee_ID__c, NH_Employee_ID__c FROM User WHERE Id = :UserInfo.getUserId()];
        //currentUserAH = [SELECT Id, IsActive FROM User WHERE Employee_ID__c =: currentUser.AH_Employee_ID__c LIMIT 1];
        //currentUserNH = [SELECT Id, IsActive FROM User WHERE Employee_ID__c =: currentUser.NH_Employee_ID__c LIMIT 1];
        // Init Team and User Extension
        
        Set<Id> accountOwnerSet = new Set<Id>();
        Set<String> accountOwnerRcCode = new Set<String>();

        accountOwnerSet.add(UserInfo.getUserId());
        accountOwnerRcCode.add(currentUser.RC_Code__c);
        accountOwnerRcCode.add(currentUser.AH_RC_Code__c);
        accountOwnerRcCode.add(currentUser.NH_RC_Code__c);

        for (Opportunity eachOpportunity : (List<Opportunity>)Trigger.new){
                accountSet.add(eachOpportunity.AccountId);

        }
        if(Opportunity_Service.accountMap == null)
            Opportunity_Service.accountMap = new Map<Id,Account>([SELECT Id, Trash_Pool_Flag__c, Primary_Segment_Code__c, Current_Activity__c,Current_Activity_By__c,Last_Setup_By__c,Last_Setup_Date__c,Owner_Emp_ID__c, Port_Pool__c, OwnerId, Owner.Segment__c, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, Ownership_Text__c, Owner.AH_RC_CODE__c, Owner.NH_RC_CODE__c, Customer_Owner_Release_Flag__c, Temp_Owner_Changed_Date__c, Owner.Profile.Name, Previous_Owner__c, (SELECT Id,Lead_Type__c,CIS_ID_Prospect_Name__r.CIS__c,CIS_ID_Prospect_Name__r.Name_Surname_TH__c FROM Campaign_Members_Leads__r WHERE Lead_Campaign__r.IsActive=true AND Status__c='New' AND Lead_Campaign__r.Sub_Type__c IN ('Strong Hybrid','Strong Formula','Refinance','Cheque','Refer','BA','LI', 'Account Plan',null) AND (Lead_Type__c =: GlobalConstants.LEAD_FOR_SALES OR Lead_Type__c =: GlobalConstants.LEAD_TO_DO OR Lead_Type__c =: GlobalConstants.LEAD_TO_INFORM)) FROM Account WHERE Id IN :accountSet]);

        for(Account eachAccount : Opportunity_Service.accountMap.values()){
            accountOwnerSet.add(eachAccount.OwnerId);
            accountOwnerRcCode.add(eachAccount.RC_Code__c);
        }

        if(Opportunity_Service.userExtList == null) {
            Opportunity_Service.userExtList = new List<User_Extension__c>();
            Opportunity_Service.userExtList = [SELECT Id, External_ID__c FROM User_Extension__c WHERE User__c IN :accountOwnerSet];
        }
        if(Opportunity_Service.teamStructureList == null){
            Opportunity_Service.teamStructureList = new List<Team_Structure__c>();
            Opportunity_Service.teamStructureList = [SELECT Id, External_ID__c FROM Team_Structure__c WHERE External_Id__c IN :accountOwnerRcCode];
        }

        for(Opportunity eachOpportunity : ((List<Opportunity>)Trigger.new)) {
            if(Opportunity_Service.accountMap.containsKey(eachOpportunity.AccountId)){
                Account accountRecord = Opportunity_Service.accountMap.get(eachOpportunity.AccountId);
                if(eachOpportunity.APP2__c == null && eachOpportunity.Tentative_Application_Submit_Date__c != null && eachOpportunity.StageName == GlobalConstants.CREATE_WRITE_UP){
                    String rcCode;
                    // Add dummy name for No Rc Code
                    if (accountRecord.RC_Code__c != null) {
                        rcCode = accountRecord.RC_Code__c;
                    } else {
                        rcCode = GlobalConstants.NO_RC_CODE;
                    }
                    applicationNumberByRC = Application_Number__c.getValues(rcCode);
                    if(applicationNumberByRC!=null){
                        applicationNumberByRC.Running_Number__c = applicationNumberByRC.Running_Number__c + 1;

                        if (currentYear != applicationNumberByRC.Year__c) {
                            applicationNumberByRC.Year__c = currentYear;
                            applicationNumberByRC.Running_Number__c = 1;
                            applicationNumberByRC.Name = rcCode;
                        }

                    } else {
                        applicationNumberByRC = new Application_Number__c();
                        applicationNumberByRC.Name = rcCode;
                        applicationNumberByRC.Running_Number__c = 1;
                        applicationNumberByRC.Year__c = currentYear;
                    }

                    runningNumberString = '000' + Integer.valueOf(applicationNumberByRC.Running_Number__c);

                    //if(eachOpportunity.Submission_Channel__c == GlobalConstants.NON_CMAS)
                    eachOpportunity.APP2__c = runningNumberString.substring(runningNumberString.length() - 4);

                    applicationNumberUpsertList.put(rcCode, applicationNumberByRC);
                }
            }

        }

        teamMapByRc = new Map<String, Id>();
        userExtMapByEmpId = new Map<String, Id>();

        for(Team_Structure__c eachTeam : Opportunity_Service.teamStructureList) {
            teamMapByRc.put(eachTeam.External_ID__c, eachTeam.Id);
        }

        for(User_Extension__c eachUserExt : Opportunity_Service.userExtList) {
            userExtMapByEmpId.put(eachUserExt.External_ID__c, eachUserExt.Id);
        }

        if (applicationNumberUpsertList.size() > 0) {
            upsert applicationNumberUpsertList.values();
        }

        
    }
    public override void beforeInsert() {
        Boolean isChangeOwner;
        Boolean addAccount = false;
        for(Opportunity eachOpportunity : (List<Opportunity>)Trigger.new){
            addAccount = false;
            //eachOpportunity.CloseDate = System.today() + 45;

            if(Opportunity_Service.accountMap.containsKey(eachOpportunity.AccountId)){
                Account accountRecord = Opportunity_Service.accountMap.get(eachOpportunity.AccountId);
                isChangeOwner = false;
                
                Id userIdRelatedToOpportunity = eachOpportunity.OwnerId;
                User userRelatedToOpportunity = userMap.get(userIdRelatedToOpportunity);
                if(userRelatedToOpportunity.Profile.Name == GlobalConstants.SME_RM){
                    eachOpportunity.Current_AH__c = userRelatedToOpportunity.Manager.ManagerId;
                    eachOpportunity.Current_NH__c = userRelatedToOpportunity.Manager.Manager.ManagerId;
                }
                if(userRelatedToOpportunity.Profile.Name == GlobalConstants.SME_TM){
                    eachOpportunity.Current_AH__c = userRelatedToOpportunity.ManagerId;
                    eachOpportunity.Current_NH__c = userRelatedToOpportunity.Manager.ManagerId;
                }
                if(userRelatedToOpportunity.Profile.Name == GlobalConstants.SME_AH){
                    eachOpportunity.Current_AH__c = null;
                    eachOpportunity.Current_NH__c = userRelatedToOpportunity.ManagerId;
                }
                if(userRelatedToOpportunity.Profile.Name == GlobalConstants.SME_NH){
                    eachOpportunity.Current_AH__c = null;
                    eachOpportunity.Current_NH__c = null;
                }

                
                if(accountRecord.Port_Pool__c!=GlobalConstants.PORT && accountRecord.OwnerId != eachOpportunity.OwnerId){
                    //accountRecord.Port_Pool__c = GlobalConstants.POOL;
                    isChangeOwner = true;
                    accountRecord.OwnerId = eachOpportunity.OwnerId;
                    accountRecord.Temp_Owner_Changed_Date__c = System.Today();
                    accountRecord.OwnerChangeExecutedByTrigger__c = true;
                    accountRecord.Temporary_Ownership_Flag__c = true;
                    Account_OwnerChange_Service.temporaryOwnershipFlag = true;
                    addAccount = true;
                }
                if(eachOpportunity.StageName == GlobalConstants.ALL_LOAN_SETUP) {
                    accountRecord.Last_Setup_By__c = UserInfo.getName();
                    accountRecord.Last_Setup_Date__c = System.today();
                    accountRecord.Current_Activity__c = GlobalConstants.CLOSE_WON;
                    if(accountRecord.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_LM 
                        || accountRecord.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_MI 
                        || accountRecord.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_PC 
                        || accountRecord.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_SM 
                        || accountRecord.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_TC 
                        || accountRecord.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_UM 
                        || accountRecord.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_XS) {
                        if(accountRecord.Ownership_Text__c == GlobalConstants.OWNERSHIP_TEMPORARY) {
                            accountRecord.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
                            accountRecord.Permanent_Owner_Extension__c = userExtMapByEmpId.get(currentUser.Employee_ID__c);
                            accountRecord.Permanent_Team_Name__c = teamMapByRc.get(currentUser.RC_Code__c);
                            accountRecord.Permanent_AH_Name__c = teamMapByRc.get(currentUser.AH_RC_Code__c);
                            accountRecord.Permanent_NH_Name__c = teamMapByRc.get(currentUser.NH_RC_Code__c);
                        }
                        accountRecord.Service_RM__c = null;
                        accountRecord.Port_Pool__c = GlobalConstants.PORT;
                        eachOpportunity.Port_Pool__c = GlobalConstants.PORT;
                        eachOpportunity.Ownership__c = GlobalConstants.OWNERSHIP_PERMANENT;
                        eachOpportunity.Current_Owner_Extension__c = userExtMapByEmpId.get(currentUser.Employee_ID__c);
                        eachOpportunity.Current_Team_Name__c = teamMapByRc.get(currentUser.RC_Code__c);
                        eachOpportunity.Current_AH_Name__c = teamMapByRc.get(currentUser.AH_RC_Code__c);
                        eachOpportunity.Current_NH_Name__c = teamMapByRc.get(currentUser.NH_RC_Code__c);
                    }
                    addAccount = true;
                }else if(accountRecord.Current_Activity__c == null || accountRecord.Current_Activity__c != GlobalConstants.OPP){
                    accountRecord.Current_Activity__c = GlobalConstants.OPP;
                    addAccount = true;
                }

                if(accountRecord.Current_Activity_By__c == null || accountRecord.Current_Activity_By__c != UserInfo.getName()){
                    accountRecord.Current_Activity_By__c = UserInfo.getName();
                    addAccount = true;
                }
                
                if(addAccount){
                    accountRecord.Trash_Pool_Flag__c = false;
                    accountUpdateList.add(accountRecord);
                } 
                

                // Set User Extension and Team
                if(teamMapByRc.containsKey(accountRecord.RC_Code__c) && !isChangeOwner) {                        
                    eachOpportunity.Current_Team_Name__c = teamMapByRc.get(accountRecord.RC_Code__c);
                } else {
                    eachOpportunity.Current_Team_Name__c = teamMapByRc.get(currentUser.RC_Code__c);
                }
                if(teamMapByRc.containsKey(accountRecord.AH_RC_Code__c)  && !isChangeOwner) {
                    eachOpportunity.Current_AH_Name__c = teamMapByRc.get(accountRecord.AH_RC_Code__c);
                } else {
                    eachOpportunity.Current_AH_Name__c = teamMapByRc.get(currentUser.AH_RC_Code__c);
                }
                if(teamMapByRc.containsKey(accountRecord.NH_RC_Code__c)  && !isChangeOwner) {
                    eachOpportunity.Current_NH_Name__c = teamMapByRc.get(accountRecord.NH_RC_Code__c);
                } else {
                    eachOpportunity.Current_NH_Name__c = teamMapByRc.get(currentUser.NH_RC_Code__c);
                }
                if(userExtMapByEmpId.containsKey(accountRecord.Owner_Emp_ID__c)  && !isChangeOwner) {
                    eachOpportunity.Current_Owner_Extension__c = userExtMapByEmpId.get(accountRecord.Owner_Emp_ID__c);
                } else {
                    eachOpportunity.Current_Owner_Extension__c = userExtMapByEmpId.get(currentUser.Employee_ID__c);
                }

                eachOpportunity.Port_Pool__c = accountRecord.Port_Pool__c;
                eachOpportunity.Ownership__c = accountRecord.Ownership_Text__c;
            }

            eachOpportunity.Previous_Record_Type__c = null;
            eachOpportunity.Previous_Stage__c = null;
            eachOpportunity.Latest_Stage_Modified_Date__c = null;
        }
 
        UW_Service.setUW((List<Opportunity>)Trigger.new);
    }
    public override void beforeUpdate() {
        Account_OwnerChange_Service.temporaryOwnershipFlag = false;
        Boolean addAccount = false;
        for (Opportunity eachOpportunity : ((List<Opportunity>) Trigger.new)) {
            addAccount = false;
            Opportunity oldRecord = (Opportunity)Trigger.oldMap.get(eachOpportunity.Id);
            Account accountRecord = Opportunity_Service.accountMap.get(eachOpportunity.AccountId);
            Id userIdRelatedToOpportunity = eachOpportunity.OwnerId;
            User userRelatedToOpportunity = userMap.get(userIdRelatedToOpportunity);

            if(eachOpportunity.OwnerId != oldRecord.OwnerId || eachOpportunity.Current_Team_Name__c != oldRecord.Current_Team_Name__c){
                System.debug('Opptest change owner');
                if(userRelatedToOpportunity.Profile.Name == GlobalConstants.SME_RM){
                    eachOpportunity.Current_AH__c = userRelatedToOpportunity.Manager.ManagerId;
                    eachOpportunity.Current_NH__c = userRelatedToOpportunity.Manager.Manager.ManagerId;
                }
                if(userRelatedToOpportunity.Profile.Name == GlobalConstants.SME_TM){
                    System.debug('In TM');
                    eachOpportunity.Current_AH__c = userRelatedToOpportunity.ManagerId;
                    eachOpportunity.Current_NH__c = userRelatedToOpportunity.Manager.ManagerId;
                }
                if(userRelatedToOpportunity.Profile.Name == GlobalConstants.SME_AH){
                    System.debug('In AH');
                    eachOpportunity.Current_AH__c = null;
                    eachOpportunity.Current_NH__c = userRelatedToOpportunity.ManagerId;
                }
                if(userRelatedToOpportunity.Profile.Name == GlobalConstants.SME_NH){
                    eachOpportunity.Current_AH__c = null;
                    eachOpportunity.Current_NH__c = null;
                }
            }
            if(eachOpportunity.StageName != oldRecord.StageName){
                eachOpportunity.Previous_Record_Type__c = oldRecord.RecordTypeId;
                eachOpportunity.Previous_Stage__c = oldRecord.StageName;
                eachOpportunity.Latest_Stage_Modified_Date__c = System.now();
            }
            if(oldRecord.StageName == GlobalConstants.CREDIT_APPROVAL_PROCESS && eachOpportunity.StageName == GlobalConstants.CREDIT_WRITE_UP){
                eachOpportunity.Resubmit_Approval__c = true;
            }
            if(accountRecord != null) {
                if(oldRecord.StageName != GlobalConstants.ALL_LOAN_SETUP && eachOpportunity.StageName == GlobalConstants.ALL_LOAN_SETUP) {
                    accountRecord.Last_Setup_By__c = UserInfo.getName();
                    accountRecord.Last_Setup_Date__c = System.today();
                    accountRecord.Current_Activity__c = GlobalConstants.CLOSE_WON;
                    if(accountRecord.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_LM 
                        || accountRecord.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_UR 
                        || accountRecord.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_SR 
                        || accountRecord.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_LR
                        || accountRecord.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_MI 
                        || accountRecord.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_PC 
                        || accountRecord.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_SM 
                        || accountRecord.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_TC 
                        || accountRecord.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_UM 
                        || accountRecord.Primary_Segment_Code__c == GlobalConstants.PRIMARY_SEGMENT_CODE_XS) {
                        if(accountRecord.Ownership_Text__c == GlobalConstants.OWNERSHIP_TEMPORARY) {
                            accountRecord.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
                            accountRecord.Permanent_Owner_Extension__c = userExtMapByEmpId.get(currentUser.Employee_ID__c);
                            accountRecord.Permanent_Team_Name__c = teamMapByRc.get(currentUser.RC_Code__c);
                            accountRecord.Permanent_AH_Name__c = teamMapByRc.get(currentUser.AH_RC_Code__c);
                            accountRecord.Permanent_NH_Name__c = teamMapByRc.get(currentUser.NH_RC_Code__c);
                        }
                        accountRecord.Service_RM__c = null;
                        accountRecord.Port_Pool__c = GlobalConstants.PORT;
                        eachOpportunity.Port_Pool__c = GlobalConstants.PORT;
                        eachOpportunity.Ownership__c = GlobalConstants.OWNERSHIP_PERMANENT;
                        eachOpportunity.Current_Owner_Extension__c = userExtMapByEmpId.get(currentUser.Employee_ID__c);
                        eachOpportunity.Current_Team_Name__c = teamMapByRc.get(currentUser.RC_Code__c);
                        eachOpportunity.Current_AH_Name__c = teamMapByRc.get(currentUser.AH_RC_Code__c);
                        eachOpportunity.Current_NH_Name__c = teamMapByRc.get(currentUser.NH_RC_Code__c);
                    }
                    addAccount = true;
                }else if(accountRecord.Current_Activity__c == null || accountRecord.Current_Activity__c != GlobalConstants.OPP){
                    accountRecord.Current_Activity__c = GlobalConstants.OPP;
                    addAccount = true;
                }
                if(accountRecord.Current_Activity_By__c == null || accountRecord.Current_Activity_By__c != UserInfo.getName()){
                    accountRecord.Current_Activity_By__c = UserInfo.getName();
                    addAccount = true;
                }
            }
                
            if(addAccount){
                //accountRecord.Trash_Pool_Flag__c = false;
                accountUpdateList.add(accountRecord);
            } 
            System.debug('User Active : '+currentUser.IsActive);
            
        }
    }

    public override void allAfter() {
        //Update target status base on Stagename

        //Map<Id, List<Target_List__c>> targetListMapByOpp = new Map<Id, List<Target_List__c>>();
        Map<Id, Target_List__c> targetListMapById = new Map<Id, Target_List__c>();

        List<Opportunity_Lead__c> oppLeadList = new List<Opportunity_Lead__c>();
        oppLeadList = [SELECT Id, Opportunity__c, Target_List__c, Type__c FROM Opportunity_Lead__c WHERE Opportunity__c IN :Trigger.newMap.keySet() AND Type__c = :GlobalConstants.LEAD_FOR_SALES];
        Boolean isUpdate;
        for (Opportunity_Lead__c eachOppLead : oppLeadList) {
            Opportunity eachOpportunity = (Opportunity) Trigger.newMap.get(eachOppLead.Opportunity__c);
            isUpdate = false;
            
            Target_List__c target = new Target_List__c(Id = eachOppLead.Target_List__c);

            if(Trigger.old != null) {
                Opportunity oldOpp = (Opportunity) Trigger.oldMap.get(eachOppLead.Opportunity__c);

                if (oldOpp.Approved_Amount__c != eachOpportunity.Approved_Amount__c) {
                    target.Approved_Amount__c = eachOpportunity.Approved_Amount__c;
                    isUpdate = true;
                }

                if (oldOpp.Setup_Amount__c != eachOpportunity.Setup_Amount__c) {
                    target.Setup_Amount__c = eachOpportunity.Setup_Amount__c;
                    isUpdate = true;
                }
            } else {
                target.Setup_Amount__c = eachOpportunity.Setup_Amount__c;
                target.Approved_Amount__c = eachOpportunity.Approved_Amount__c;
                isUpdate = true;
            }

            // --- ISCR028 ---
            if (eachOpportunity.StageName != null) {
                target.Status__c = eachOpportunity.StageName;
                isUpdate = true;
            }
            
            if (isUpdate)
                targetListMapById.put(target.Id, target);
        }
        
        if (!targetListMapById.isEmpty()) {
            update targetListMapById.values();
            /*for(List<Target_List__c> eachTargetList : targetListMapByOpp.values()) {
                update eachTargetList;
            }*/
            // Add more REST callout to update Central CRM
            //SME_UpdateCampaignLeadResultResponse returnValue = SME_CIRestWebservice.UPDATE_CAMPAIGN_LEAD_ENDPOINT(targetListMapByOpp);
        }

    }

    public override void beforeFinally() {
        if(!Account_OwnerChange_Service.triggerInitialCall && !accountUpdateList.isEmpty()){
            Account_OwnerChange_Service.opportunityTriggerList = (List<Opportunity>)Trigger.new;
            Account_OwnerChange_Service.triggerInitialCall = true;
            Account_OwnerChange_Service.temporaryOwnershipFlag = true;
            update accountUpdateList;
            Account_OwnerChange_Service.opportunityTriggerList = null;
        }
    }
     public override void afterInsert(){

        List<Opportunity_Lead__c> oppLeadList = new List<Opportunity_Lead__c>();
        /*
         * Created by: chumphon.k@kbtg.tech
         * Created date: 16-Mar-2016
         * Description: CR-006 Auto assign targer list to campaign NewBooking
        */
        String NewBookingCode = Campaign_Setting__c.getOrgDefaults().NewBooking_Code__c;
        List<Target_List__c> insertTargetList = new List<Target_List__c>();
        List<Campaign> campaignNewBooking = new List<Campaign>();
        if(NewBookingCode != null && String.isNotBlank(NewBookingCode)) {
            campaignNewBooking = [SELECT Id FROM Campaign Where Lead_Campaign_Event_Code__c = :NewBookingCode And IsActive = true];
        }
        Account accountRecord;
        for(Opportunity eachOpportunity : (List<Opportunity>)Trigger.new){
            if(campaignNewBooking.Size() > 0){
                Target_List__c target = new Target_List__c();
                target.Lead_Campaign__c = campaignNewBooking[0].Id;
                target.Opportunity__c = eachOpportunity.Id;
                target.CIS_ID_Prospect_Name__c = eachOpportunity.AccountId;
                target.Status__c = 'New';
                insertTargetList.add(target);
            }
            accountRecord = Opportunity_Service.accountMap.get(eachOpportunity.AccountId);
            for(Target_List__c eachTargetLead : accountRecord.Campaign_Members_Leads__r){
                oppLeadList.add(new Opportunity_Lead__c(
                    Opportunity__c = eachOpportunity.Id,
                    Target_List__c = eachTargetLead.Id
                ));
            }
        }
        if(oppLeadList.size() > 0) insert oppLeadList;
        if(insertTargetList.size() > 0) insert insertTargetList;
    }

    public override void afterUpdate(){
        /*
         * Created by: chumphon.k@kbtg.tech
         * Created date: 18-Mar-2016
         * Description: CR-006 Auto assign targer list to campaign Thankyou and calculate campaign reward
        */
        List<Target_List__c> insertTargetList = new List<Target_List__c>();
        List<Target_List__c> updateTargetList = new List<Target_List__c>();

        Campaign_Setting__c campaignSetting = Campaign_Setting__c.getOrgDefaults();
        String campaignNewBookingCode = campaignSetting.NewBooking_Code__c;
        String campaignThankyouCode = campaignSetting.ThankYou_Code__c;
        Id campaignNewBookingID, campaignThankyouID;

        List<Campaign> campaignNewBooking = [SELECT Id FROM Campaign Where Lead_Campaign_Event_Code__c = :campaignNewBookingCode And IsActive = true];
        if(campaignNewBooking.Size() > 0){campaignNewBookingID = campaignNewBooking[0].Id;}
        List<Campaign> campaignThankyou = [SELECT Id FROM Campaign Where Lead_Campaign_Event_Code__c = :campaignThankyouCode And IsActive = true];
        if(campaignThankyou.Size() > 0){campaignThankyouID = campaignThankyou[0].Id;}

        if(campaignNewBookingID != null && String.isNotBlank(campaignNewBookingID) && campaignThankyouID != null && String.isNotBlank(campaignThankyouID)){
            // Map target list by Opportunity Id
            Map<Id, Target_List__c> targetNewbookingMapByOppId = new Map<Id, Target_List__c>();
            Map<Id, Target_List__c> targetThankyouMapByOppId = new Map<Id, Target_List__c>();
            for(Target_List__c target : [Select Opportunity__c, Lead_Campaign__c, Name, Status__c, Approved_Amount__c, Setup_Amount__c, Campaign_Reward_Calc__c, Option__c FROM Target_List__c WHERE Opportunity__c IN :Trigger.New]){
                if(target.Lead_Campaign__c == campaignNewBookingID) targetNewbookingMapByOppId.put(target.Opportunity__c, target);
                if(target.Lead_Campaign__c == campaignThankyouID) targetThankyouMapByOppId.put(target.Opportunity__c, target);
            }

            for(Opportunity eachOpportunity : (List<Opportunity>)Trigger.new){
                if(Trigger.old != null){
                    Opportunity oldOpp = (Opportunity) Trigger.oldMap.get(eachOpportunity.Id);
                    if(oldOpp.StageName != eachOpportunity.StageName){
                    
                        CampaignRewardCalculation calc = new CampaignRewardCalculation();

                        if(eachOpportunity.StageName == 'All Loan Setup'){
                            // After Close Won, calculate campaign reword for registered target list in campaign NewBooking
                            Target_List__c tlNewBooking = targetNewbookingMapByOppId.get(eachOpportunity.Id);
                           if(tlNewBooking != null){
                                if(tlNewBooking.Status__c == 'Registered'){
                                    tlNewBooking.Approved_Amount__c = eachOpportunity.Approved_Amount__c;
                                    tlNewBooking.Setup_Amount__c = eachOpportunity.Setup_Amount__c;
                                    tlNewBooking.Campaign_Reward_Calc__c  = calc.CalculateNewBooking(eachOpportunity.Setup_Amount__c, eachOpportunity.Total_Front_End_Fee__c, tlNewBooking.Option__c); //'Calculate new booking reword in construction';
                                    updateTargetList.add(tlNewBooking);
                                } else if(tlNewBooking.Status__c != GlobalConstants.LEAD_EXPIRED){
                                    // After close won. If not yet register targetlist in campaign NewBooking, expire it!
                                    tlNewBooking.Status__c = GlobalConstants.LEAD_EXPIRED;
                                    updateTargetList.add(tlNewBooking);
                                }
                            }

                            // After Close Won, auto insert target list in campaign Thankyou
                            Decimal CalcAmount = eachOpportunity.Total_Front_End_Fee__c + eachOpportunity.Total_BA_Prosaving__c + eachOpportunity.Total_BA_Protection__c;
                            if(targetThankyouMapByOppId.size() == 0){
                                if(CalcAmount >= 100000){
                                    Target_List__c target = new Target_List__c();
                                    target.Lead_Campaign__c = campaignThankyouID;
                                    target.Opportunity__c = eachOpportunity.Id;
                                    target.CIS_ID_Prospect_Name__c = eachOpportunity.AccountId;
                                    target.Status__c = GlobalConstants.STATUS_NEW;
                                    target.Approved_Amount__c = eachOpportunity.Approved_Amount__c;
                                    target.Setup_Amount__c = eachOpportunity.Setup_Amount__c;
                                    target.Campaign_Reward_Calc__c = calc.CalculateThankyou(eachOpportunity.Total_Front_End_Fee__c, eachOpportunity.Total_BA_Prosaving__c, eachOpportunity.Total_BA_Protection__c);
                                    insertTargetList.add(target);
                                }
                            } else {
                                // To support case back state and re close won again
                                Target_List__c target = targetThankyouMapByOppId.get(eachOpportunity.Id);
                                if(target != null){
                                    target.Approved_Amount__c = eachOpportunity.Approved_Amount__c;
                                    target.Setup_Amount__c = eachOpportunity.Setup_Amount__c;
                                    target.Campaign_Reward_Calc__c = calc.CalculateThankyou(eachOpportunity.Total_Front_End_Fee__c, eachOpportunity.Total_BA_Prosaving__c, eachOpportunity.Total_BA_Protection__c);
                                    updateTargetList.add(target);
                                }
                            }
                        } else if(eachOpportunity.StageName == 'Closed Lost' || eachOpportunity.StageName == 'Auto Closed'){
                            // Auto expire targetlist which not register in campaign NewBooking
                            Target_List__c tlNewBooking = targetNewbookingMapByOppId.get(eachOpportunity.Id);
                            if(tlNewBooking != null){
                                if (tlNewBooking.Status__c != 'Registered' && tlNewBooking.Status__c != 'Lead Expired'){
                                    tlNewBooking.Status__c = GlobalConstants.LEAD_EXPIRED;
                                    updateTargetList.add(tlNewBooking);
                                }
                            }
                        }
                    }
                }
            }
            if(insertTargetList.size() > 0) insert insertTargetList;
            if(updateTargetList.size() > 0) update updateTargetList;
        }
    }
}