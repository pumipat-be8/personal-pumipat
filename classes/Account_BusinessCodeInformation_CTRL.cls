public with sharing class Account_BusinessCodeInformation_CTRL {

	private final sObject mysObject;
    private String cis;
    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public String customerBusinessCode {get; set;}
    public String industryClassificationCode {get; set;}
    public String businessCodeNameEN {get; set;}
    public String businessCodeNameTH {get; set;}
    public Id accountId;

    // Test Add comment


    public Account_BusinessCodeInformation_CTRL(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
        accountId = (Id)this.mysObject.get('Id');
    }

    public void init() {
        retreiveBusinessCodeRealTime();
        Account thisAccount =  [SELECT Id, CIS__c, Customer_s_Business_Code__c, Business_Code_Name_EN__c, Business_Code_Name_TH__c, Industry_Classification_Code__c FROM Account WHERE Id = :accountId LIMIT 1];
        cis = thisAccount.CIS__c;
        if(customerBusinessCode == null) customerBusinessCode = thisAccount.Customer_s_Business_Code__c;
        if(businessCodeNameEN == null) businessCodeNameEN = thisAccount.Business_Code_Name_EN__c;
        if(businessCodeNameTH == null) 
        {
            List<Business_Code__c> businessCodeObj = [select Business_Code_Description__c from Business_Code__c where Name= :customerBusinessCode LIMIT 1];
            if( businessCodeObj.size()>0 )
            {
                businessCodeNameTH = businessCodeObj[0].Business_Code_Description__c;    
            }            
        }
        if(industryClassificationCode == null) industryClassificationCode = thisAccount.Industry_Classification_Code__c; 
    }

    public void retreiveBusinessCodeRealTime() {
        try {
            SME_TransactBPResultResponse response = SME_CIRestWebservice.getTransactBPRequest(this.cis);
            if(response == null || response.returnResponse == null) return ;
            if(response.returnResponse.transactBP.size() == 1) {
                SME_TransactBPResultResponse.transactBP_model transactBPModel = response.returnResponse.transactBP[0];
                customerBusinessCode = transactBPModel.BSN_CD;
                businessCodeNameTH = transactBPModel.BSN_NM;
            }   
        } catch (Exception e) {

        }
        //customerBusinessCode = 'CODE';
    }        

//        - Customer's Business Code BSN_CD
//- Business Code Name (EN)
//- Business Code Name (TH)
//- Industry Classification Code
    //}
}