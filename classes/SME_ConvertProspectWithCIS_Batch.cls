/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   Convert prospect batch for gap of customer type retails

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
07/27/2015  Charnun.T       First Create
------------------------------------------------------------*/
global class SME_ConvertProspectWithCIS_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    public static String PROSPECT = 'SME-Prospect';
    public static String prospectRecordTypeId = String.valueOf(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(PROSPECT).GetRecordTypeId());
    
    global SME_ConvertProspectWithCIS_Batch(){
        List<sObject> tempCountRecords = [SELECT Id FROM Account WHERE RecordtypeId = :prospectRecordTypeId];
        if(tempCountRecords.size() == 0){
            SME_CIRestAsyncWebservice.convertProspectWithZeroRecord('WithCIS');
        }
    }

    public String query(){
        return  'SELECT Id,Name,Birthdate_Registration_Date__c,RecordtypeId,Identification_No_Prospect__c,Convert_Prospect_Date__c ' + 
                'FROM Account WHERE RecordtypeId = \'' + prospectRecordTypeId + '\' ';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        return Database.getQueryLocator(this.query());
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
       try{
            if(scope.size() > 0){
               SME_CIRestAsyncWebservice.convertProspectRequestWithCIS(scope); 
            }
        }catch (Exception ex) {
            GlobalUtility.logMessage('ERROR','SME_ConvertProspectWithCIS_Batch','execute_SME_ConvertProspectWithCIS_Batch',null,null,'Error when execute batch',null,ex,null);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        if(!test.isrunningtest()){
            SME_CIRestAsyncWebservice.convertProspectWithZeroRecord('WithCIS');
        }
        //GlobalUtility.logMessage('DEBUG','SME_ConvertProspectWithCIS_Batch','execute_SME_ConvertProspect_Batch',null,null,'Finish Batch',null,null,null);
    }
}