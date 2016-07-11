@isTest
//@08/04/2016 Nareerat.wo@kbtg.tech   Add test code for Test method insertingTask_InterestWithCondition at class CallReportTriggerHandler .
private class CallReportTrigger_Test {
    
    @isTest static void testFirstReschedule() {
        Integer expectedNumOfReschedule = 1;
        // Implement test code
        Account acc = new Account();
        //acc.RecordTypeId = CustomerRecordTypeId;
        acc.Name = 'TestName';
        insert acc;

        Call_Report__c callReport = new Call_Report__c();
        callReport.CIS_ID__c = acc.Id;
        insert callReport;

        Test.startTest();
        callReport.Plan_Date__c = Date.today();
        update callReport;
        Test.stopTest();

        Call_Report__c actualQueryReport = [SELECT Id,Number_of_Reschedule__c FROM Call_Report__c WHERE Id = :callReport.Id];
        System.assertEquals(expectedNumOfReschedule,actualQueryReport.Number_of_Reschedule__c);
    }    

    @isTest static void testSecondReschedule() {
        Integer expectedNumOfReschedule = 2;
        // Implement test code
        Account acc = new Account();
        //acc.RecordTypeId = CustomerRecordTypeId;
        acc.Name = 'TestName';
        insert acc;

        Call_Report__c callReport = new Call_Report__c();
        callReport.CIS_ID__c = acc.Id;
        callReport.Number_of_Reschedule__c = 1;
        insert callReport;

        Test.startTest();
        callReport.Plan_Date__c = Date.today();
        update callReport;
        Test.stopTest();

        Call_Report__c actualQueryReport = [SELECT Id,Number_of_Reschedule__c FROM Call_Report__c WHERE Id = :callReport.Id];
        System.assertEquals(expectedNumOfReschedule,actualQueryReport.Number_of_Reschedule__c);
    }

    @isTest static void testRescheduleResetDate() {
        Integer expectedNumOfReschedule = 3;
        // Implement test code
        Account acc = new Account();
        //acc.RecordTypeId = CustomerRecordTypeId;
        acc.Name = 'TestName';
        insert acc;

        Call_Report__c callReport = new Call_Report__c();
        callReport.CIS_ID__c = acc.Id;
        callReport.Number_of_Reschedule__c = 2;
        callReport.Plan_Date__c = Date.today();
        insert callReport;

        Test.startTest();
        callReport.Plan_Date__c = null;
        update callReport;
        Test.stopTest();

        Call_Report__c actualQueryReport = [SELECT Id,Number_of_Reschedule__c FROM Call_Report__c WHERE Id = :callReport.Id];
        System.assertEquals(expectedNumOfReschedule,actualQueryReport.Number_of_Reschedule__c);
    }
    
    
    //@isTest static void testInsertCallReport_CreateReminderTask() {
    //    /*
    //     * Created by: nareerat.wo@kbtg.tech
    //     * Created date: 08-Apr-2016
    //     * Description: Test code for Test method insertingTask_InterestWithCondition at class CallReportTriggerHandler when insert call report.
    //    */
    //    //Setup custom setting
    //    CallReport_Task_Setting__c cSetting = new CallReport_Task_Setting__c();
    //    cSetting.ReminderTask_NumOfDays__c= 30;
    //    cSetting.ReminderTask_Subject__c='Please takecare customer';
    //    cSetting.ReminderTask_TimeReminder__c='08:30';
    //    insert cSetting;
        
    //    Account acc = new Account();
    //    acc.Name = 'TestAcc1';
    //    insert acc;

    //    Call_Report__c callReport = new Call_Report__c();
    //    callReport.CIS_ID__c = acc.Id;
    //    callReport.Actual_Visit_Date__c = Date.today();
    //    callReport.Contact_Channel__c = 'Phone Call';
    //    callReport.Offer_Credit_Product__c = true;
    //    callReport.Offer_Interest__c = 'Interest with condition';
    //    callReport.Reason__c = '2.1 รอตัดสินใจ/รอปรึกษาครอบครัว';           

    //    Test.startTest();
    //        insert callReport;
    //    Test.stopTest();

    //    task reminderTask = [SELECT Id, WhatId, Subject, OwnerId FROM Task WHERE WhatId = :callReport.Id];
    //    list<task> listreminderTask = [SELECT Id, WhatId, Subject, OwnerId FROM Task WHERE WhatId = :callReport.Id];
    //    System.assertEquals(listreminderTask.size(), 1);
    //    System.assertEquals(reminderTask.Subject, 'Please takecare customer');
        
    //}
    
    //@isTest static void testUpdateCallReport_CreateReminderTask() {
    //     /*
    //     * Created by: nareerat.wo@kbtg.tech
    //     * Created date: 08-Apr-2016
    //     * Description: Test code for Test method insertingTask_InterestWithCondition at class CallReportTriggerHandler when update call report.
    //    */
    //    //Setup custom setting
    //    CallReport_Task_Setting__c cSetting = new CallReport_Task_Setting__c();
    //    cSetting.ReminderTask_NumOfDays__c= 30;
    //    cSetting.ReminderTask_Subject__c='Please takecare customer';
    //    insert cSetting;
        
    //    Account acc = new Account();
    //    acc.Name = 'TestAcc1';
    //    acc.CIS__c = '1111';
    //    acc.Birthdate_Registration_Date__c = system.today() - 9000;
    //    acc.Identification_No_Prospect__c='1234567890123';
        
        
    //    insert acc;
        
    //    Contact contact1 = new Contact();
    //    contact1.Accountid = acc.id;
    //    contact1.Phone_Number__c = '1234567890';
    //    contact1.lastname='BB';
    //    insert contact1;

    //    Call_Report__c callReport = new Call_Report__c();
    //    callReport.CIS_ID__c = acc.Id;
    //    callReport.Actual_Visit_Date__c = Date.today();
    //    callReport.Contact_Channel__c = 'Phone Call';
    //    callReport.Offer_Credit_Product__c = true;
    //    callReport.Offer_Interest__c = 'Interest and can apply';       
    //    callReport.Expected_Credit_Amount__c = 100000;
    //    insert callReport;
                
    //    Test.startTest();
    //        callReport.Contact__c=contact1.id;
    //        callReport.Offer_Interest__c = 'Interest with condition';
    //        callReport.Reason__c = '2.1 รอตัดสินใจ/รอปรึกษาครอบครัว';  
    //        update callReport;
            
    //    Test.stopTest();

    //    task reminderTask = [SELECT Id, WhatId, Subject, OwnerId FROM Task WHERE WhatId = :callReport.Id];
    //    list<task> listreminderTask = [SELECT Id, WhatId, Subject, OwnerId FROM Task WHERE WhatId = :callReport.Id];
    //    System.assertEquals(listreminderTask.size(), 1);
    //    System.assertEquals(reminderTask.Subject, 'Please takecare customer');
        
    //}
    
    
    
}