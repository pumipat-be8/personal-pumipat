/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   Convert prospect batch for gap of customer type retails

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
07/27/2015  Charnun.T       First Create
------------------------------------------------------------*/
global class SME_ConvertProspect_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    public static String PROSPECT = 'SME-Prospect';
    public static String prospectRecordTypeId = String.valueOf(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(PROSPECT).GetRecordTypeId());

    global SME_ConvertProspect_Batch(){
        List<sObject> tempCountRecords = [SELECT Id FROM Account WHERE Birthdate_Registration_Date__c != null AND Identification_No_Prospect__c != null AND RecordtypeId = :prospectRecordTypeId];
        if(tempCountRecords.size() == 0){
            SME_CIRestAsyncWebservice.convertProspectWithZeroRecord('WithIdentification');
        }
    }
    
    public String query(){
        return  'SELECT Id,Name,Birthdate_Registration_Date__c,RecordtypeId,Identification_No_Prospect__c,Convert_Prospect_Date__c ' + 
                'FROM Account WHERE RecordtypeId = \'' + prospectRecordTypeId + '\' AND (Birthdate_Registration_Date__c != null ' +
                'AND Identification_No_Prospect__c != null)';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //GlobalUtility.logMessage('DEBUG','SME_ConvertProspect_Batch','execute_SME_ConvertProspect_Batch',null,null,'Start Batch',null,null,null);
        return Database.getQueryLocator(this.query());
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
       try{
            if(scope.size() > 0){
               SME_CIRestAsyncWebservice.convertProspectRequest(scope); 
            }
        }catch (Exception ex) {
            GlobalUtility.logMessage('ERROR','SME_ConvertProspect_Batch','execute_SME_ConvertProspect_Batch',null,null,'Error when execute batch',null,ex,null);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        if(!test.isrunningtest()){
            SME_CIRestAsyncWebservice.convertProspectWithZeroRecord('WithIdentification');
        }
        //GlobalUtility.logMessage('DEBUG','SME_ConvertProspect_Batch','execute_SME_ConvertProspect_Batch',null,null,'Finish Batch',null,null,null);
    }
}