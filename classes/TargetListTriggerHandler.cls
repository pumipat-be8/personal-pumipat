public without sharing class TargetListTriggerHandler extends TriggerHandler {
    private Set<Id> campIds;
    private Set<Id> accountIds;

    public override void allBefore() {
        campIds = new Set<Id>();
        accountIds = new Set<Id>();
    }

    public override void beforeInsert() {
        for(Target_List__c eachTarget : (List<Target_List__c>) Trigger.new) {
            if(eachTarget.Lead_Campaign__c != null)
                campIds.add(eachTarget.Lead_Campaign__c);
            if(eachTarget.CIS_ID_Prospect_Name__c != null)
                accountIds.add(eachTarget.CIS_ID_Prospect_Name__c);
        }
    }

    public override void beforeUpdate() {
        Target_List__c oldRecord;
        for(Target_List__c eachTarget : (List<Target_List__c>) Trigger.new) {
            oldRecord = (Target_List__c) Trigger.oldMap.get(eachTarget.Id);
            if(eachTarget.Lead_Campaign__c != oldRecord.Lead_Campaign__c || eachTarget.CIS_ID_Prospect_Name__c != oldRecord.CIS_ID_Prospect_Name__c) {
                if(eachTarget.Lead_Campaign__c != null)
                    campIds.add(eachTarget.Lead_Campaign__c);
                if(eachTarget.CIS_ID_Prospect_Name__c != null)
                    accountIds.add(eachTarget.CIS_ID_Prospect_Name__c);
            }
        }

        /*
         * Created by: chumphon.k@kbtg.tech
         * Created date: 22-Mar-2016
         * Description: CR-006 Clear NewBooking and re-calculate Thankyou campaign reward
        */
        List<Target_List__c> updateTargetList = new List<Target_List__c>();
        Target_List__c oldTarget = (Target_List__c)Trigger.old[0];
        Target_List__c newTarget = (Target_List__c)Trigger.new[0];
        if(oldTarget.Status__c != newTarget.Status__c && oldTarget.Status__c == 'Registered') {

            // *** Get campaign id of NewBooking and Thankyou
            Campaign_Setting__c campaignSetting = Campaign_Setting__c.getOrgDefaults();
            String campaignNewBookingCode = campaignSetting.NewBooking_Code__c;
            String campaignThankyouCode = campaignSetting.ThankYou_Code__c;
            Id campaignNewBookingID, campaignThankyouID;

            List<Campaign> campaignNewBooking = [SELECT Id FROM Campaign Where Lead_Campaign_Event_Code__c = :campaignNewBookingCode And IsActive = true];
            if(campaignNewBooking.Size() > 0){campaignNewBookingID = campaignNewBooking[0].Id;}
            List<Campaign> campaignThankyou = [SELECT Id FROM Campaign Where Lead_Campaign_Event_Code__c = :campaignThankyouCode And IsActive = true];
            if(campaignThankyou.Size() > 0){campaignThankyouID = campaignThankyou[0].Id;}
            
            if(campaignNewBookingID != null && String.isNotBlank(campaignNewBookingID) && campaignThankyouID != null && String.isNotBlank(campaignThankyouID)){
                if(oldTarget.Lead_Campaign__c == campaignNewBookingID) {
                    // Clear NewBooking and re-calculate Thankyou campaign reward
                    newTarget.Campaign_Reward_Calc__c = '-';
                    CampaignRewardCalculation calc = new CampaignRewardCalculation();
            
                    for(Target_List__c target : [Select ID, Status__c, Opportunity__r.Total_Front_End_Fee__c, Opportunity__r.Total_BA_Prosaving__c, Opportunity__r.Total_BA_Protection__c FROM Target_List__c WHERE Lead_Campaign__c = :campaignThankyouID and Opportunity__c = :newTarget.Opportunity__c]) {
                        target.Campaign_Reward_Calc__c = calc.CalculateThankyou(target.Opportunity__r.Total_Front_End_Fee__c, target.Opportunity__r.Total_BA_Prosaving__c, target.Opportunity__r.Total_BA_Protection__c);
                        updateTargetList.add(Target);
                    }
                    if(updateTargetList.size() > 0) update updateTargetList;
                }
            }
        }
    }

    public override void beforeFinally() {
        if(campIds != null && !campIds.isEmpty()) concatExternalId();
    }

    public void concatExternalId() {
        Id RECORDTYPE_SME_CUSTOMER = GlobalUtility.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER);
        Id RECORDTYPE_SME_PROSPECT = GlobalUtility.getRecordTypeAccountIdByName(GlobalConstants.SME_PROSPECT);

        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, RecordTypeId, CIS__c FROM Account WHERE Id IN :accountIds]);
        Map<Id, Campaign> campaignMap = new Map<Id, Campaign>([SELECT Id, Lead_Campaign_Event_Code__c FROM Campaign WHERE Id IN :campIds]);

        for(Target_List__c eachTarget : (List<Target_List__c>) Trigger.new) {
            if(accountMap.containsKey(eachTarget.CIS_ID_Prospect_Name__c) && campaignMap.containsKey(eachTarget.Lead_Campaign__c)) {
                if(accountMap.get(eachTarget.CIS_ID_Prospect_Name__c).RecordTypeId == RECORDTYPE_SME_PROSPECT) {
                    eachTarget.External_ID__c = campaignMap.get(eachTarget.Lead_Campaign__c).Lead_Campaign_Event_Code__c + '' + accountMap.get(eachTarget.CIS_ID_Prospect_Name__c).Id;
                } else if(accountMap.get(eachTarget.CIS_ID_Prospect_Name__c).RecordTypeId == RECORDTYPE_SME_CUSTOMER) {
                    eachTarget.External_ID__c = campaignMap.get(eachTarget.Lead_Campaign__c).Lead_Campaign_Event_Code__c + '' + accountMap.get(eachTarget.CIS_ID_Prospect_Name__c).CIS__c;
                }
            }
        }
    }
}