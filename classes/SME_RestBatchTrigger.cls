/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   Restful API to send result status and error exception back to SFDC

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
07/30/2015  Charnun.T       First Create
------------------------------------------------------------*/
@RestResource(urlMapping='/BatchTrigger/*')
global class SME_RestBatchTrigger 
{   
    @HttpPost
    global static void doBatchTrigger(RestResponseModel.batchTrigger_model jsonResponse)
    {
        System.debug('jsonResponse::'+jsonResponse);
        if(jsonResponse.batch_Name == 'HRIS'){
            //Database.executeBatch(new UserStructureUpdateUser_Batch(GlobalConstants.SME_NH));
            // Phase 2 Ownership change batch HRIS
            Database.executeBatch(new SME_PrepareOwnershipAssignment_Batch());
        }else if(jsonResponse.batch_Name == 'ConvertProspect'){
        	Database.executeBatch(new SME_ConvertProspect_Batch());
        }else if(jsonResponse.batch_Name == 'ConvertProspectWithCIS'){
            Database.executeBatch(new SME_ConvertProspectWithCIS_Batch());
        }
    }
}