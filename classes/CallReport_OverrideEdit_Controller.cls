/**
* @author komsan.wi@beryl8.com
* @07/07/2015 createddate
*/
public without sharing class CallReport_OverrideEdit_Controller {
    public CallReport_OverrideEdit_Controller(ApexPages.StandardController stdController) {
    }

    public CallReport_OverrideEdit_Controller() {
    }

    public PageReference redirectToNewPage() {
        CallPlanCallReportField__c callPlanCallReportField = CallPlanCallReportField__c.getOrgDefaults();
        //String accountIdString = ApexPages.currentPage().getParameters().get('accountId');
        //Account accountObj = [SELECT Customer_s_Business_Code__c FROM Account WHERE Id = :accountIdString LIMIT 1];
        //PageReference pageRef = new PageReference('/'+callPlanCallReportField.CallReportObjectId__c+'/e?CF00NN0000001cLxi='+accountObj.Customer_s_Business_Code__c);

        PageReference pageRef = new PageReference('/'+callPlanCallReportField.CallReportObjectId__c+'/e?');
        //pageRef.getParameters().put(callPlanCallReportField.AccountIdFieldId__c, callPlanCallReportField);
        pageRef.getParameters().put('retURL', ApexPages.currentPage().getParameters().get('retURL'));
        pageRef.getParameters().put('save_new_url', ApexPages.currentPage().getParameters().get('save_new_url'));
        pageRef.getParameters().put('scontrolCaching', ApexPages.currentPage().getParameters().get('scontrolCaching'));

        pageRef.getParameters().put('RecordType', callPlanCallReportField.NewCallPlanRecordTypeId__c);
        pageRef.getParameters().put('ent', callPlanCallReportField.Entity_Id__c);
        pageRef.getParameters().put('nooverride', '1');
       //retURL={!Account.Id}&saveURL=%2Fapex%2FCallReport_OverrideEdit%3FaccountId%3D{!Account.Id}&RecordType={!$Setup.CallPlanCallReportField__c.NewCallPlanRecordTypeId__c}&ent={!$Setup.CallPlanCallReportField__c.Entity_Id__c}
       pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference redirect(){
        String newidString = ApexPages.currentPage().getParameters().get('newid');
        String accountIdString = ApexPages.currentPage().getParameters().get('accountId');
        String primaryFlagString = ApexPages.currentPage().getParameters().get('primaryFlag');
        String primaryCallReportIdString = ApexPages.currentPage().getParameters().get('primaryCallReportId');
        String associatedIdString = ApexPages.currentPage().getParameters().get('associatedId');
        PageReference pageRef;
        System.debug('newidString::'+newidString);
        System.debug('accountIdString::'+accountIdString);
        System.debug('primaryFlagString::'+primaryFlagString);
        System.debug('primaryCallReportIdString::'+primaryCallReportIdString);
        System.debug('associatedIdString::'+associatedIdString);
        List<Call_Report__c> callReportObj = new List<Call_Report__c>();
        callReportObj = [SELECT Id,Offer_Interest__c,Expected_Credit_Amount__c,Primary_Call_Report__c FROM Call_Report__c WHERE Id = :newidString LIMIT 1];
        System.debug('callReportObj::'+callReportObj);
        if(callReportObj!=null && callReportObj.size() > 0){
            if(primaryCallReportIdString != null && primaryCallReportIdString != '' && primaryFlagString != null && primaryFlagString == '0' && callReportObj.get(0).Primary_Call_Report__c != false){
                Call_Report__c updateCallReport = new Call_Report__c(Id=callReportObj.get(0).Id);
                updateCallReport.Primary_Call_Report__c = false;
                updateCallReport.Primary_Call_Plan_Call_Report__c = Id.valueOf(primaryCallReportIdString);
                update updateCallReport;
                if(associatedIdString != null && associatedIdString != ''){
                    Associated_Customer__c tempAssociated = new Associated_Customer__c(Id=Id.valueOf(associatedIdString));
                    tempAssociated.Secondary_Call_Plan_Call_Report__c = Id.valueOf(newidString);

                    update tempAssociated;
                }

            }
            List<Call_Report_Opportunity__c> currentOpportunity = new List<Call_Report_Opportunity__c>();
            currentOpportunity = [SELECT Opportunity_Name__c FROM Call_Report_Opportunity__c WHERE Call_Plan_Call_Report__c =:newidString ORDER BY CreatedDate DESC LIMIT 1];
            System.debug('currentOpportunity::'+currentOpportunity);
            /*Account accountObj = [SELECT Id,Name,CIS__c FROM Account WHERE Id = :accountIdString LIMIT 1];
            Opportunity opObj = new Opportunity(
                Name = (accountObj.CIS__c!=null)?accountObj.CIS__c:accountObj.Name,
                AccountId = accountIdString,
                CloseDate = System.today()+45,
                StageName = GlobalConstants.STOCK_NEGOTIATION,
                Amount = callReportObj.Expected_Credit_Amount__c
            );
            insert opObj;
            insert new Call_Report_Opportunity__c(
                Call_Plan_Call_Report__c = newidString,
                Opportunity_Name__c = opObj.Id
            );*/
            if(currentOpportunity!=null && currentOpportunity.size() > 0)
                pageRef = new PageReference('/'+currentOpportunity.get(0).Opportunity_Name__c);
            else if(primaryCallReportIdString!=null)
                pageRef = new PageReference('/'+primaryCallReportIdString);
            else if(newidString!=null)
                pageRef = new PageReference('/'+newidString);
        }else if(newidString!=null){
            pageRef = new PageReference('/'+newidString);
        }
        return pageRef;
    }
    public PageReference redirectToListView(){
        Schema.DescribeSObjectResult r = Call_Report__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        PageReference pageRef = new PageReference('/'+keyPrefix);
        return pageRef;
    }
}