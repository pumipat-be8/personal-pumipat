/**
* @author komsan.wi@beryl8.com
* @28/09/2015 created new
*/
public without sharing class ValueChain_Controller {
    public Target_List__c target {get;set;}
    public Boolean shouldReload {get;set;}
    public String optionType {get;set;}
    public String rewardType {get;set;}
    public Boolean isNewBooking {get;set;}
    private String[] targetIdArray;
    public static final Id campaignNewBookingID;

    static{
        String campaignNewBookingCode = Campaign_Setting__c.getOrgDefaults().NewBooking_Code__c;
        List<Campaign> campaignNewBooking = [SELECT Id FROM Campaign Where Lead_Campaign_Event_Code__c = :campaignNewBookingCode And IsActive = true];
        if(campaignNewBooking!=null && campaignNewBooking.Size() > 0){
            campaignNewBookingID = campaignNewBooking[0].Id;
        }
    }

    public ValueChain_Controller(ApexPages.StandardController stdController) {
        String valuelist = ApexPages.currentPage().getParameters().get('valuelist');
        String targetid = ApexPages.currentPage().getParameters().get('id');        
        shouldReload = false;
        //optionType = 'A';
        optionType = '';
        if(valuelist!=null){
            targetIdArray = valuelist.split(',');
        }else {
            targetIdArray = new String[]{targetid};
        }
        CheckNewBooking();
        target = new Target_List__c();
    }

    public ValueChain_Controller() {                
        String valuelist = ApexPages.currentPage().getParameters().get('valuelist');
        targetIdArray = valuelist.split(',');
        //optionType = 'A';
        optionType = '';
        shouldReload = false;
        CheckNewBooking();
        target = new Target_List__c();
    }

    private void CheckNewBooking(){
        List<Target_List__c> targetListNewBooking = [Select Id FROM Target_List__c WHERE Lead_Campaign__c = :campaignNewBookingID and Id in :targetIdArray];
        isNewBooking = (targetListNewBooking !=null && targetListNewBooking.size() > 0) ? true : false;
    }

    public void savingtarget(){
        shouldReload = true;
        List<Target_List__c> targetUpdateList = new List<Target_List__c>();
        for(Target_List__c tmpTarget : [Select Id,Lead_Campaign__c FROM Target_List__c WHERE Id IN : targetIdArray]){
            tmpTarget.Status__c = 'Registered';
            tmpTarget.Mobile_No__c = target.Mobile_No__c;
            tmpTarget.Registered_DateTime__c = System.Now(); // Add by Chumphon K., CR018 12-May-2016
            if(tmpTarget.Lead_Campaign__c == campaignNewBookingID){
                tmpTarget.Reward__c = rewardType;
                tmpTarget.Option__c = optionType;
            }
            targetUpdateList.add(tmpTarget);
        }
        try{
            System.debug('targetUpdateList='+targetUpdateList);
            update targetUpdateList;    
        }catch(Exception ex){
            shouldReload = false;
        }
    }

    public List<SelectOption> getOptionTypeItems() {        
        return getTypeItems(Target_List__c.Option__c.getDescribe(),false);
    }

    public List<SelectOption> getRewardTypeItems() {         
        return getTypeItems(Target_List__c.Reward__c.getDescribe(),true);
    }

    private List<SelectOption> getTypeItems(Schema.DescribeFieldResult fieldResult,boolean isCombobox) {
        List<SelectOption> options = new List<SelectOption>();        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        if(isCombobox){
            options.add(new SelectOption('','Please Select'));   
        }
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getValue(),f.getLabel()));
        }       
        return options;
    }
}