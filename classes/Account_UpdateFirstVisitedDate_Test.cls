/***********************************************************************
*  Created By		: Chumphon Kaewpraphan
*  Date Created		: 21 April 2016
*
*  Description		: Test class for batch Account_UpdateFirstVisitedDate_Batch
*
*  Modification List:
*  Name         	Date            Modification Description
*  ----------		-----------		------------------------------
*  Chumphon K.		26-Apr-2016 	Initial Code Creation
*  
***********************************************************************/
@isTest
public class Account_UpdateFirstVisitedDate_Test {
    
    static testMethod void testUpdateFirstVisitedDate(){
        Account acc = new Account();
        acc.Name = 'TestAcc1';
        insert acc;

        Call_Report__c callReport = new Call_Report__c();
        callReport.CIS_ID__c = acc.Id;
        callReport.Actual_Visit_Date__c = Date.today()-1;
        callReport.Contact_Channel__c = 'Phone Call';
        callReport.Offer_Credit_Product__c = true;
        callReport.Offer_Interest__c = 'Interest with condition';
        callReport.Reason__c = '2.1 รอตัดสินใจ/รอปรึกษาครอบครัว';  
        insert callReport;
        
        Account updateAccount = [SELECT Id, First_Visited_Date__c FROM Account WHERE Id = :acc.Id LIMIT 1];
        updateAccount.First_Visited_Date__c = null;
        update updateAccount;

         Test.startTest();
             Database.executeBatch(new Account_UpdateFirstVisitedDate_Batch());
         Test.stopTest();
        
        Account result = [SELECT Id, First_Visited_Date__c FROM Account WHERE Id = :acc.Id LIMIT 1];
        System.assertEquals(Date.today()-1, result.First_Visited_Date__c);
    }
}