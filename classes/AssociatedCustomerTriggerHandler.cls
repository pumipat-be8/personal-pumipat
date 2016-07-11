/**
* @author charnun.t@beryl8.com
* @08/04/2016 createddate
*/
public without sharing class AssociatedCustomerTriggerHandler extends TriggerHandler{
	public override void afterInsert() {
        List<Associated_Customer__c> associatedCustomerList = Trigger.new;

        if(associatedCustomerList.size() == 1){
            // Get data from call report
            Call_Report__c newCallReport;
            Call_Report__c getCallReportDetails = [SELECT Actual_Visit_Date__c,Id FROM Call_Report__c where Id =:associatedCustomerList.get(0).Call_Plan_Call_Report__c];
            if(associatedCustomerList.get(0).RecordTypeId == GlobalUtility.getRecordTypeIdFromSObjectByDevName('Associated_Customer__c','Interested')){
            	
            	// Add more feature to create duplicate call reports without plan on this scenario
            	System.debug('AssociatedCustomerTriggerHandler:'+ Trigger.new);
            	if(associatedCustomerList.get(0).Borrower_Type__c == 'Co Borrower'){
            		// Co borrower
                    System.debug('getCallReportDetails:'+ getCallReportDetails);
                    newCallReport = new Call_Report__c();

                    newCallReport.Offer_Interest__c = 'Interest and can apply';
                    newCallReport.Contact_Channel__c = 'Face to Face';
                    newCallReport.CIS_ID__c = associatedCustomerList.get(0).Customer__c;
                    newCallReport.Actual_Visit_Date__c = getCallReportDetails.Actual_Visit_Date__c;
                    newCallReport.Offer_Credit_Product__c = true;
                    newCallReport.Co_Borrower__c = true;
                    newCallReport.Status__c = 'Contacted';
                    newCallReport.Primary_Call_Report__c = false;
                    newCallReport.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c','Secondary_Call_Report_No_plan');
                    newCallReport.Primary_Call_Plan_Call_Report__c = getCallReportDetails.Id;

                    System.debug('newCallReport::'+newCallReport);
                    try{
                        insert newCallReport;
                    }catch(Exception e){
                        System.debug('System Error when try to insert Second Call Plan/Call Report from Associated Customer');
                    }
            	}
            }else if(associatedCustomerList.get(0).RecordTypeId == GlobalUtility.getRecordTypeIdFromSObjectByDevName('Associated_Customer__c','Not_Interested')){
                newCallReport = new Call_Report__c();

                newCallReport.Offer_Interest__c = 'Not Interest';
                newCallReport.Contact_Channel__c = 'Face to Face';
                newCallReport.CIS_ID__c = associatedCustomerList.get(0).Customer__c;
                newCallReport.Actual_Visit_Date__c = getCallReportDetails.Actual_Visit_Date__c;
                newCallReport.Offer_Credit_Product__c = true;
                newCallReport.Status__c = 'Contacted';
                newCallReport.Reason__c = '4.5 อื่น ๆ (โปรดระบุ)';
                newCallReport.Memo__c = 'Associated Customer ลูกค้าไม่สนใจ';
                newCallReport.Primary_Call_Report__c = false;
                newCallReport.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c','Secondary_Call_Report_No_plan');
                newCallReport.Primary_Call_Plan_Call_Report__c = getCallReportDetails.Id;

                System.debug('newCallReport::'+newCallReport);
                try{
                    insert newCallReport;
                }catch(Exception e){
                    System.debug('System Error when try to insert Second Call Plan/Call Report from Associated Customer');
                }
            }
            if(newCallReport != null){
                // Add Second Call Report to Associated Customer
                Associated_Customer__c tempAssociated = new Associated_Customer__c(Id=associatedCustomerList.get(0).Id);
                tempAssociated.Secondary_Call_Plan_Call_Report__c = newCallReport.Id;
                try{
                    update tempAssociated;
                }catch(Exception e){
                    System.debug('System Error when try to update Second Call Plan/Call Report in Associated Customer');
                }
            }
        }
    }
}