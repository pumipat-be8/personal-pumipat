/**
* @author komsan.wi@beryl8.com
* @08/07/2015 createddate
* @Modified_By pasakorn.p@beryl8.com
* @04/07/2016 added trashpool test methods 
*/
@isTest
public class CallReport_Test {
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';
    @testSetup static void setupAccount(){
        Mockup_Test mt = new Mockup_Test().setUpTest();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            CallReport_Test.setUpUW();
        }
        
    }
    public static Account createProspect() {
        Account account = new Account();
        account.Name = 'Account Name';
        account.RecordTypeId = GlobalUtility.getRecordTypeAccountIdByName(GlobalConstants.SME_PROSPECT);
        account.Identification_No_Prospect__c = '1234567890123';
        account.Birthdate_Registration_Date__c = System.today() - 365;
        return account;
    }

    public static Opportunity createOpp(Id accountId) {
        Opportunity opp = Mockup_Test.newOpportunity(accountId, 'OppName', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
        return opp;
    }
    public static void setUpUW() {
        insert new Segment_UW_Assignment__c(Name = 'ME');

        Id uwProfileId = [SELECT Id FROM Profile WHERE Name = :'SME-Head of UW' LIMIT 1].Id;
        Id uwSeniorProfileId = [SELECT Id FROM Profile WHERE Name = 'SME-Senior UW' LIMIT 1].Id;
        Id uwRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'SME_UW' LIMIT 1].Id;

        Business_Code__c buCodeTest = new Business_Code__c(Name = '123456');
        insert buCodeTest;
        Business_Code__c buCode = new Business_Code__c(Name = '111111');
        insert buCode;
        Business_Code__c buCode7 = new Business_Code__c(Name = '777777');
        insert buCode7;

        List<User> uwUserList = new List<User>();
        User uwAHHeadUser = Mockup_Test.newUser(
                'uwAHHeadUser',
                'uwAHHeadUser',
                true,
                'uwAHHeadUser@mail.com',
                'uwAHHeadUser@mail.com',
                'uwh',
                uwProfileId,
                uwRoleId,
                null,
                '700177'
            );
        uwUserList.add(uwAHHeadUser);

        User uwAHSeniorUser = Mockup_Test.newUser(
                'uwAHSeniorUser',
                'uwAHSeniorUser',
                true,
                'uwAHSeniorUser@mail.com',
                'uwAHSeniorUser@mail.com',
                'udws',
                uwSeniorProfileId,
                uwRoleId,
                null,
                '990177'
            );
        uwUserList.add(uwAHSeniorUser);

        User uwNHHeadUser = Mockup_Test.newUser(
                'uwNHHeadUser',
                'uwNHHeadUser',
                true,
                'uwNHHeadUser@mail.com',
                'uwNHHeadUser@mail.com',
                'uwh',
                uwProfileId,
                uwRoleId,
                null,
                '660066'
            );
        uwUserList.add(uwNHHeadUser);

        User uwNHSeniorUser = Mockup_Test.newUser(
                'uwNHSeniorUser',
                'uwNHSeniorUser',
                true,
                'uwNHSeniorUser@mail.com',
                'uwNHSeniorUser@mail.com',
                'udws',
                uwSeniorProfileId,
                uwRoleId,
                null,
                '989898'
            );
        uwUserList.add(uwNHSeniorUser);

        User userHeadBUAH = Mockup_Test.newUser(
                'userHeadBUAH',
                'userHeadBUAH',
                true,
                'userHeadBUAH@mail.com',
                'userHeadBUAH@mail.com',
                'uwh',
                uwProfileId,
                uwRoleId,
                null,
                '12346'
            );
        uwUserList.add(userHeadBUAH);

        User userSeniorBUAH = Mockup_Test.newUser(
                'userSeniorBUAH',
                'userSeniorBUAH',
                true,
                'userSeniorBUAH@mail.com',
                'userSeniorBUAH@mail.com',
                'udws',
                uwSeniorProfileId,
                uwRoleId,
                null,
                '52425'
            );
        uwUserList.add(userSeniorBUAH);

        User userHeadBUNH = Mockup_Test.newUser(
                'userHeadBUNH',
                'userHeadBUNH',
                true,
                'userHeadBUNH@mail.com',
                'userHeadBUNH@mail.com',
                'uwh',
                uwProfileId,
                uwRoleId,
                null,
                '312346'
            );
        uwUserList.add(userHeadBUNH);

        User userSeniorBUNH = Mockup_Test.newUser(
                'userSeniorBUNH',
                'userSeniorBUNH',
                true,
                'userSeniorBUNH@mail.com',
                'userSeniorBUNH@mail.com',
                'udws',
                uwSeniorProfileId,
                uwRoleId,
                null,
                '352425'
            );
        uwUserList.add(userSeniorBUNH);

        User userHeadBUAH2 = Mockup_Test.newUser(
                'userHeadBUAH2',
                'userHeadBUAH2',
                true,
                'userHeadBUAH2@mail.com',
                'userHeadBUAH2@mail.com',
                'uwh',
                uwProfileId,
                uwRoleId,
                null,
                '128346'
            );
        uwUserList.add(userHeadBUAH2);

        User userSeniorBUAH2 = Mockup_Test.newUser(
                'userSeniorBUAH2',
                'userSeniorBUAH2',
                true,
                'userSeniorBUAH2@mail.com',
                'userSeniorBUAH2@mail.com',
                'udws',
                uwSeniorProfileId,
                uwRoleId,
                null,
                '582425'
            );
        uwUserList.add(userSeniorBUAH2);

        User userHeadBUNH2 = Mockup_Test.newUser(
                'uwBUHeadUser',
                'uwBUHeadUser',
                true,
                'userHeadBUNH2@mail.com',
                'userHeadBUNH2@mail.com',
                'uwh',
                uwProfileId,
                uwRoleId,
                null,
                '882346'
            );
        uwUserList.add(userHeadBUNH2);

        User userSeniorBUNH2 = Mockup_Test.newUser(
                'userSeniorBUNH2',
                'userSeniorBUNH2',
                true,
                'userSeniorBUNH2@mail.com',
                'userSeniorBUNH2@mail.com',
                'udws',
                uwSeniorProfileId,
                uwRoleId,
                null,
                '882425'
            );
        uwUserList.add(userSeniorBUNH2);

        User userHeadNoRC = Mockup_Test.newUser(
                'userHeadNoRC',
                'userHeadNoRC',
                true,
                'userHeadNoRC@mail.com',
                'userHeadNoRC@mail.com',
                'uwh',
                uwProfileId,
                uwRoleId,
                null,
                '887777'
            );
        uwUserList.add(userHeadNoRC);

        User userSeniorNoRC = Mockup_Test.newUser(
                'userSeniorNoRC',
                'userSeniorNoRC',
                true,
                'userSeniorNoRC@mail.com',
                'userSeniorNoRC@mail.com',
                'udws',
                uwSeniorProfileId,
                uwRoleId,
                null,
                '772222'
            );
        uwUserList.add(userSeniorNoRC);

        insert uwUserList;

        List<UW_Area__c> uwAreaList = new List<UW_Area__c>();
        UW_Area__c uwAHArea = new UW_Area__c(
            RC_Code__c = Mockup_Test.AH_RC_CODE,
            Head_of_UW_Name__c = uwAHHeadUser.Id,
            Senior_UW_Name__c = uwAHSeniorUser.Id
        );
        uwAreaList.add(uwAHArea);

        UW_Area__c uwNHArea = new UW_Area__c(
            RC_Code__c = Mockup_Test.NH_RC_CODE,
            Head_of_UW_Name__c = uwNHHeadUser.Id,
            Senior_UW_Name__c = uwNHSeniorUser.Id
        );
        uwAreaList.add(uwNHArea);
        insert uwAreaList;

        List<UW_Business_Area__c> uwBuList = new List<UW_Business_Area__c>();
        UW_Business_Area__c uwBUAH = new UW_Business_Area__c(
            RC_Code__c = Mockup_Test.AH_RC_CODE,
            External_ID__c = Mockup_Test.AH_RC_CODE+'-'+buCodeTest.Name,
            Business_Code__c = buCodeTest.Id,
            Head_of_UW_Name__c = userHeadBUAH.Id,
            Senior_UW_Name__c = userSeniorBUAH.Id
        );
        uwBuList.add(uwBUAH);

        UW_Business_Area__c uwBUNH = new UW_Business_Area__c(
            RC_Code__c = Mockup_Test.NH_RC_CODE,
            External_ID__c = Mockup_Test.NH_RC_CODE+'-'+buCodeTest.Name,
            Business_Code__c = buCodeTest.Id,
            Head_of_UW_Name__c = userHeadBUNH.Id,
            Senior_UW_Name__c = userSeniorBUNH.Id
        );
        uwBuList.add(uwBUNH);

        UW_Business_Area__c uwBUAH2 = new UW_Business_Area__c(
            RC_Code__c = Mockup_Test.AH_RC_CODE,
            External_ID__c = Mockup_Test.AH_RC_CODE+'-'+buCode.Name,
            Business_Code__c = buCode.Id,
            Head_of_UW_Name__c = userHeadBUAH2.Id,
            Senior_UW_Name__c = userSeniorBUAH2.Id
        );
        uwBuList.add(uwBUAH2);

        UW_Business_Area__c uwBUNH2 = new UW_Business_Area__c(
            RC_Code__c = Mockup_Test.NH_RC_CODE,
            External_ID__c = Mockup_Test.NH_RC_CODE+'-'+buCode.Name,
            Business_Code__c = buCode.Id,
            Head_of_UW_Name__c = userHeadBUNH2.Id,
            Senior_UW_Name__c = userSeniorBUNH2.Id
        );
        uwBuList.add(uwBUNH2);


        UW_Business_Area__c uwBUNoRC = new UW_Business_Area__c(
            External_ID__c =  System.Label.Apply_All_Area+'-'+buCode7.Name,
            RC_Code__c = Mockup_Test.NH_RC_CODE,
            Business_Code__c = buCode7.Id,
            Head_of_UW_Name__c = userHeadNoRC.Id,
            Senior_UW_Name__c = userSeniorNoRC.Id
        );
        uwBuList.add(uwBUNoRC);
        insert uwBuList;
    }

    static testMethod void newCallReportAutoCreateEvent(){
        String expectedNote = 'expected';
        Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Call_Report__c callreportObj;
        System.runAs(userRM){
            Test.startTest();
                callreportObj = new Call_Report__c(
                    Contact_Firstname__c = 'abc',
                    Contact_Lastname__c = 'def',
                    Contact_Phone__c = '123456789',
                    CIS_ID__c = targetAccount.Id,
                    Status__c = GlobalConstants.PLAN,
                    Plan_Date__c = System.Today(),
                    Customer_Important_Note__c = expectedNote
                );
                insert callreportObj;
            Test.stopTest();
        }
        Account resultAccount = [SELECT Id,Customer_Importance_Note__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        System.assertEquals(expectedNote, resultAccount.Customer_Importance_Note__c);
        List<Event> eventList = new List<Event>();
        eventList = [SELECT Id,WhatId FROM Event WHERE Call_Plan_Call_Report__c = :callreportObj.Id];
        System.assertEquals(resultAccount.Id, eventList[0].WhatId);
        System.assertEquals(1, eventList.size());

        User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];

        List<EventRelation> eventRelationList = new List<EventRelation>();
        eventRelationList = [SELECT Id,RelationId FROM EventRelation WHERE EventId = :eventList[0].Id];
        System.assertEquals(1, eventRelationList.size());
        System.assertEquals(userTM.Id, eventRelationList[0].RelationId);
    }
    @isTest static void defaultTargetList(){
        String initialNote = 'expected';
        String expectedNote = 'expected112';
        Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];

        Campaign cm = new Campaign();
        cm.Lead_Campaign_Event_Code__c = 'TestCampaign';
        cm.Type__c = GlobalConstants.LEAD_FOR_SALES;
        cm.Sub_Type__c = 'Strong Formula';
        cm.Name = 'TestCampaign';
        cm.IsActive = true;
        cm.Status = 'Active';
        cm.StartDate = System.Today() - 1;
        cm.EndDate = System.Today() + 1;
        cm.RecordTypeId = GlobalUtility.getRecordTypeCampaignIdByName('SME- Lead / Campaign');
        insert cm;

        Target_List__c tl = new Target_List__c();
        tl.CIS_ID_Prospect_Name__c = targetAccount.Id;
        tl.Lead_Campaign__c = cm.Id;
        tl.Status__c = GlobalConstants.STATUS_NEW;
        insert tl;

        Call_Report__c callreportObj;
        callreportObj = new Call_Report__c(
            Contact_Firstname__c = 'abc',
            Contact_Lastname__c = 'def',
            Contact_Phone__c = '123456789',
            RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.NEW_CALL_PLAN_DEVNAME),
            CIS_ID__c = targetAccount.Id,
            Status__c = GlobalConstants.PLAN,
            Plan_Date__c = System.Today(),
            Customer_Important_Note__c = initialNote
        );

        Test.startTest();
            insert callreportObj;
        Test.stopTest();

        Call_Report_Lead__c resultLead = new Call_Report_Lead__c();
        resultLead = [SELECT Id,Call_Plan_Call_Report__c,Target_List__c FROM Call_Report_Lead__c WHERE Call_Plan_Call_Report__c = :callreportObj.Id LIMIT 1];
        System.assert(resultLead!=null);
        System.assertEquals(callreportObj.Id, resultLead.Call_Plan_Call_Report__c);
        System.assertEquals(tl.Id, resultLead.Target_List__c);
    }
    @isTest static void createOpportunity(){
        String initialNote = 'expected';
        String expectedNote = 'expected112';
        Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Call_Report__c callreportObj;
        System.runAs(userRM){
            callreportObj = new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Status__c = GlobalConstants.PLAN,
                RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_DEVNAME),
                Plan_Date__c = System.Today(),
                Offer_Credit_Product__c = true,
                Offer_Interest__c = GlobalConstants.INTEREST_AND_CAN_APPLY,
                Customer_Important_Note__c = initialNote,
                Expected_Credit_Amount__c = 6000
            );
            Test.startTest();
                insert callreportObj;
            Test.stopTest();
        }
        Opportunity resultOp = new Opportunity();
        resultOp = [SELECT Id FROM Opportunity WHERE Account.Name = :CallReport_Test.accountNameRM LIMIT 1];
        System.assert(resultOp!=null);
    }
    @isTest static void updateCallReportAndChangeDate(){
        String initialNote = 'expected';
        String expectedNote = 'expected112';
        Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Call_Report__c callreportObj;
        System.runAs(userRM){
            
            callreportObj = new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Status__c = GlobalConstants.PLAN,
                Plan_Date__c = System.Today(),
                Customer_Important_Note__c = initialNote
            );
            insert callreportObj;
            Account_OwnerChange_Service.callReportRunOnce = false;
            Account_OwnerChange_Service.triggerInitialCall = false;
            Test.startTest();
                callreportObj.Plan_Date__c = System.Today()+1;
                callreportObj.Customer_Important_Note__c = expectedNote;

                TriggerHandler.clearAllBypasses();
                update callreportObj;
            Test.stopTest();
        }
        Account resultAccount = [SELECT Id,Customer_Importance_Note__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        System.assertEquals(expectedNote, resultAccount.Customer_Importance_Note__c);

        List<Event> eventList = new List<Event>();
        eventList = [SELECT Id,WhatId,StartDateTime,EndDateTime FROM Event WHERE Call_Plan_Call_Report__c = :callreportObj.Id];
        System.assertEquals(callreportObj.Plan_Date__c, eventList[0].StartDateTime);
        System.assertEquals(callreportObj.Plan_Date__c.addHours(1), eventList[0].EndDateTime);
        System.assertEquals(targetAccount.Id, eventList[0].WhatId);
        System.assertEquals(1, eventList.size());
    }
    static testMethod void updateCallReportAndCancel(){
        Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Call_Report__c callreportObj;
        System.runAs(userRM){
            
            callreportObj = new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Status__c = GlobalConstants.PLAN,
                Plan_Date__c = System.Today()
            );
            insert callreportObj;
            Account_OwnerChange_Service.callReportRunOnce = false;
            Test.startTest();
                callreportObj.Status__c = GlobalConstants.CANCEL;
                callreportObj.Reason_for_Cancellation__c = 'Want to cancel';
                callreportObj.Plan_Date__c = System.Today()+1;

                update callreportObj;
            Test.stopTest();
        }
        Integer eventCount = [SELECT COUNT() FROM Event WHERE Call_Plan_Call_Report__c = :callreportObj.Id];
        System.assertEquals(0, eventCount);
    }
    static testMethod void newCallReportNoPlan(){
        Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        Call_Report__c callreportObj;
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        System.runAs(userRM){
            callreportObj = new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Status__c = GlobalConstants.PLAN,
                Plan_Date__c = System.Today(),
                Collect_Documents__c = true,
                RecordtypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_NO_PLAN_DEVNAME)
            );

            Test.startTest();
                insert callreportObj;
            Test.stopTest();
        }
        Call_Report__c finalCallReport = [SELECT Status__c FROM Call_Report__c WHERE Id = :callreportObj.Id];
        System.assertEquals(GlobalConstants.CONTACTED,finalCallReport.Status__c);
    }
    static testMethod void  stampPhoneNo() {
        Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Call_Report__c callreportObj;
        Contact con = new Contact();
        System.runAs(userRM){
            
            con.LastName = 'lastname';
            con.Contact_Firstname__c = 'Firstname';
            con.AccountId = targetAccount.Id;
            con.Phone_Number__c = '023450789';
            insert con;

            callreportObj = new Call_Report__c(
                Collect_Documents__c = true,
                CIS_ID__c = targetAccount.Id,
                Status__c = GlobalConstants.PLAN,
                Plan_Date__c = System.Today(),
                Contact__c = con.Id,
                Expected_Credit_Amount__c = 5000,
                RecordtypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_NO_PLAN_DEVNAME)

            );

            Test.startTest();
                insert callreportObj;
            Test.stopTest();
        }
        Call_Report__c finalCallReport = [SELECT Call_Report__c.Phone_Number__c FROM Call_Report__c WHERE Id = :callreportObj.Id];
        System.assertEquals(con.Phone_Number__c, finalCallReport.Phone_Number__c);
    }

     @isTest static void testActualVisitDateOfTwoCallReportInCaseOfDelete() {
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Opportunity opp;
        Call_Report__c callReport1 = new Call_Report__c();
        Call_Report__c callReport2 = new Call_Report__c();
        System.runAs(userRM){
            
            Account account = CallReport_Test.createProspect();
            insert account;

            opp = CallReport_Test.createOpp(account.Id);
            insert opp;
            Test.startTest();
            callReport1.Actual_Visit_Date__c = System.today() - 3;
            callReport1.Plan_Amount__c = 6000;
            callReport1.CIS_ID__c = account.Id;
            callReport1.Offer_Credit_Product__c = true;
            callReport1.Offer_Interest__c = GlobalConstants.INTEREST_AND_CAN_APPLY;
            callReport1.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
            callReport1.Expected_Credit_Amount__c = 5000;
            callReport1.Contact_Firstname__c = 'abc';
            callReport1.Contact_Lastname__c = 'def';
            callReport1.Contact_Phone__c = '123456789';
            insert callReport1;

            TriggerHandler.clearAllBypasses();

            callReport2.Actual_Visit_Date__c = System.today() - 5;
            callReport2.Plan_Amount__c = 6000;
            callReport2.CIS_ID__c = account.Id;
            callReport2.Offer_Credit_Product__c = true;
            callReport2.Offer_Interest__c = GlobalConstants.INTEREST_AND_CAN_APPLY;
            callReport2.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
            callReport2.Expected_Credit_Amount__c = 5000;
            callReport2.Contact_Firstname__c = 'abc';
            callReport2.Contact_Lastname__c = 'def';
            callReport2.Contact_Phone__c = '123456789';
            insert callReport2;


            Call_Report_Opportunity__c callReportOpp1 = new Call_Report_Opportunity__c();
            callReportOpp1.Opportunity_Name__c = opp.Id;
            callReportOpp1.Call_Plan_Call_Report__c = callReport1.Id;
            insert callReportOpp1;

            Call_Report_Opportunity__c callReportOpp2 = new Call_Report_Opportunity__c();
            callReportOpp2.Opportunity_Name__c = opp.Id;
            callReportOpp2.Call_Plan_Call_Report__c = callReport2.Id;
            insert callReportOpp2;

            
            delete callReportOpp2;
            Test.stopTest();
        }

        Opportunity actualOpp = [SELECT Id, Actual_Visit_Date__c FROM Opportunity WHERE Id =: opp.Id];
        System.assertEquals(callReport1.Actual_Visit_Date__c, actualOpp.Actual_Visit_Date__c);
    }

    @isTest static void testActualVisitDateOfTwoCallReportInCaseUpdateContactChannel() {
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Call_Report_Opportunity__c callReportOpp1 = new Call_Report_Opportunity__c();
        Call_Report_Opportunity__c callReportOpp2 = new Call_Report_Opportunity__c();
        Call_Report__c callReport1 = new Call_Report__c();
        Call_Report__c callReport2 = new Call_Report__c();
        Opportunity opp;
        System.runAs(userRM){
            Account account = CallReport_Test.createProspect();
            insert account;

            opp = CallReport_Test.createOpp(account.Id);
            insert opp;
            
            callReport1.Actual_Visit_Date__c = System.today() - 10;
            callReport1.Plan_Amount__c = 6000;
            callReport1.CIS_ID__c = account.Id;
            callReport1.Offer_Credit_Product__c = true;
            callReport1.Offer_Interest__c = GlobalConstants.INTEREST_AND_CAN_APPLY;
            //callReport1.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
            callReport1.Expected_Credit_Amount__c = 5000;
            callReport1.Contact_Firstname__c = 'abc';
            callReport1.Contact_Lastname__c = 'def';
            callReport1.Contact_Phone__c = '123456789';
            insert callReport1;
            
            TriggerHandler.clearAllBypasses();

            callReport2.Actual_Visit_Date__c = System.today() - 5;
            callReport2.Plan_Amount__c = 6000;
            callReport2.CIS_ID__c = account.Id;
            callReport2.Offer_Credit_Product__c = true;
            callReport2.Offer_Interest__c = GlobalConstants.INTEREST_AND_CAN_APPLY;
            callReport2.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
            callReport2.Expected_Credit_Amount__c = 5000;
            callReport2.Contact_Firstname__c = 'abc';
            callReport2.Contact_Lastname__c = 'def';
            callReport2.Contact_Phone__c = '123456789';
            insert callReport2;

            Test.startTest();
            callReportOpp1.Opportunity_Name__c = opp.Id;
            callReportOpp1.Call_Plan_Call_Report__c = callReport1.Id;
            insert callReportOpp1;
            callReportOpp2.Opportunity_Name__c = opp.Id;
            callReportOpp2.Call_Plan_Call_Report__c = callReport2.Id;
            insert callReportOpp2;

            TriggerHandler.clearAllBypasses();
            Account_OwnerChange_Service.callReportRunOnce = false;
            callReport1.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
            update callReport1;
            Test.stopTest();
        }

        Opportunity actualOpp = [SELECT Id, Actual_Visit_Date__c FROM Opportunity WHERE Id =: opp.Id];
        System.assertEquals(callReport1.Actual_Visit_Date__c, actualOpp.Actual_Visit_Date__c);

    }

    @isTest static void testActualVisitDateOfTwoCallReport() {
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Opportunity opp;
        Call_Report_Opportunity__c callReportOpp1 = new Call_Report_Opportunity__c();
        Call_Report_Opportunity__c callReportOpp2 = new Call_Report_Opportunity__c();
        Call_Report__c callReport1 = new Call_Report__c();
        Call_Report__c callReport2 = new Call_Report__c();
        System.runAs(userRM){
            Account account = CallReport_Test.createProspect();
            insert account;

            opp = CallReport_Test.createOpp(account.Id);
            insert opp;
            
            callReport1.Actual_Visit_Date__c = System.today() - 3;
            callReport1.Plan_Amount__c = 6000;
            callReport1.CIS_ID__c = account.Id;
            callReport1.Offer_Credit_Product__c = true;
            callReport1.Offer_Interest__c = GlobalConstants.INTEREST_AND_CAN_APPLY;
            callReport1.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
            callReport1.Expected_Credit_Amount__c = 5000;
            callReport1.Contact_Firstname__c = 'abc';
            callReport1.Contact_Lastname__c = 'def';
            callReport1.Contact_Phone__c = '123456789';
            insert callReport1;
            
            TriggerHandler.clearAllBypasses();

            callReport2.Actual_Visit_Date__c = System.today() - 5;
            callReport2.Plan_Amount__c = 6000;
            callReport2.CIS_ID__c = account.Id;
            callReport2.Offer_Credit_Product__c = true;
            callReport2.Offer_Interest__c = GlobalConstants.INTEREST_AND_CAN_APPLY;
            callReport2.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
            callReport2.Expected_Credit_Amount__c = 5000;
            callReport2.Contact_Firstname__c = 'abc';
            callReport2.Contact_Lastname__c = 'def';
            callReport2.Contact_Phone__c = '123456789';
            insert callReport2;

            Test.startTest();
                callReportOpp1.Opportunity_Name__c = opp.Id;
                callReportOpp1.Call_Plan_Call_Report__c = callReport1.Id;
                insert callReportOpp1;

                callReportOpp2.Opportunity_Name__c = opp.Id;
                callReportOpp2.Call_Plan_Call_Report__c = callReport2.Id;
                insert callReportOpp2;
            Test.stopTest();
        }
        Opportunity actualOpp = [SELECT Id, Actual_Visit_Date__c FROM Opportunity WHERE Id =: opp.Id];
        System.assertEquals(callReport2.Actual_Visit_Date__c, actualOpp.Actual_Visit_Date__c);

    }
    
    @isTest static void testActualVisitDateOfInsertOneCallReport() {
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Call_Report__c callReport = new Call_Report__c();
        Call_Report_Opportunity__c callReportOpp = new Call_Report_Opportunity__c();
        Opportunity opp;
        System.runAs(userRM){
            Account account = CallReport_Test.createProspect();
            insert account;

            opp = CallReport_Test.createOpp(account.Id);
            insert opp;
            
            callReport.Actual_Visit_Date__c = System.today() - 3;
            callReport.Plan_Amount__c = 6000;
            callReport.CIS_ID__c = account.Id;
            callReport.Offer_Credit_Product__c = true;
            callReport.Offer_Interest__c = GlobalConstants.INTEREST_AND_CAN_APPLY;
            callReport.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
            callReport.Expected_Credit_Amount__c = 5000;
            callReport.Contact_Firstname__c = 'abc';
            callReport.Contact_Lastname__c = 'def';
            callReport.Contact_Phone__c = '123456789';
            insert callReport;

            Test.startTest();
            
                callReportOpp.Opportunity_Name__c = opp.Id;
                callReportOpp.Call_Plan_Call_Report__c = callReport.Id;
                insert callReportOpp;
            Test.stopTest();
        }

        Opportunity actualOpp = [SELECT Id, Actual_Visit_Date__c FROM Opportunity WHERE Id =: opp.Id];
        System.assertEquals(callReport.Actual_Visit_Date__c, actualOpp.Actual_Visit_Date__c);
    }
    @isTest static void testCreateContact() {
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        Call_Report__c callReport = new Call_Report__c();

        System.runAs(userRM){
            Account account = CallReport_Test.createProspect();
            insert account;
            
            callReport.Actual_Visit_Date__c = System.today() - 3;
            callReport.Plan_Amount__c = 6000;
            callReport.CIS_ID__c = account.Id;
            callReport.Offer_Credit_Product__c = true;
            callReport.Offer_Interest__c = GlobalConstants.INTEREST_AND_CAN_APPLY;
            callReport.Contact_Channel__c = GlobalConstants.FACE_TO_FACE;
            callReport.Expected_Credit_Amount__c = 5000;
            callReport.Contact_Firstname__c = 'abc';
            callReport.Contact_Lastname__c = 'def';
            callReport.Contact_Phone__c = '123456789';
            callReport.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_DEVNAME);

            Test.startTest();
                insert callReport;
            Test.stopTest();
        }
        Call_Report__c finalCallReport = [SELECT Contact__c FROM Call_Report__c WHERE Id = :callReport.Id];
        System.assertNotEquals(null, finalCallReport.Contact__c);
    }

    @isTest static void setUWNoBU() {
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
        userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
        userRM.Segment__c = 'ME';
        update userRM;

        Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        
        Call_Report__c callReport1 = new Call_Report__c();
        System.runAs(userRM){
            
            callReport1.Actual_Visit_Date__c = System.today() - 10;
            callReport1.Plan_Amount__c = 6000;
            callReport1.CIS_ID__c = targetAccount.Id;
            callReport1.Offer_Credit_Product__c = true;
            callReport1.Offer_Interest__c = GlobalConstants.INTEREST_AND_CAN_APPLY;
            callReport1.Expected_Credit_Amount__c = 5000;
            callReport1.Contact_Firstname__c = 'abc';
            callReport1.Contact_Lastname__c = 'def';
            callReport1.Contact_Phone__c = '123456789';

            Test.startTest();
            insert callReport1;
            Test.stopTest();

            UW_Area__c finalExpectedUW = [SELECT Id,Head_of_UW_Name__c,Senior_UW_Name__c FROM UW_Area__c WHERE RC_Code__c = :Mockup_Test.AH_RC_CODE LIMIT 1];

            Call_Report__c finalCallReport = [SELECT Id, Head_of_UW_Name__c, Senior_UW_Name__c FROM Call_Report__c WHERE CIS_ID__c = :targetAccount.Id];
            System.assertEquals(finalExpectedUW.Head_of_UW_Name__c, finalCallReport.Head_of_UW_Name__c);
            System.assertEquals(finalExpectedUW.Senior_UW_Name__c, finalCallReport.Senior_UW_Name__c);
        }
    }

    @isTest static void setUWWithBU() {
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
        userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
        userRM.Segment__c = 'ME';
        update userRM;

        Business_Code__c buCode = [SELECT Name FROM Business_Code__c WHERE Name = '123456' LIMIT 1];

        System.runAs(userRM){
            Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
            targetAccount.Customer_s_Business_Code__c = '111111';
            update targetAccount;
            
            Call_Report__c callReport1 = new Call_Report__c();

            callReport1.Actual_Visit_Date__c = System.today() - 10;
            callReport1.Plan_Amount__c = 6000;
            callReport1.CIS_ID__c = targetAccount.Id;
            callReport1.Offer_Credit_Product__c = true;
            callReport1.Offer_Interest__c = GlobalConstants.INTEREST_AND_CAN_APPLY;
            callReport1.Expected_Credit_Amount__c = 5000;
            callReport1.Contact_Firstname__c = 'abc';
            callReport1.Contact_Lastname__c = 'def';
            callReport1.Contact_Phone__c = '123456789';
            callReport1.Business_Code__c = buCode.Id;

            Test.startTest();
            insert callReport1;
            Test.stopTest();
        }
        Account finalAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        UW_Business_Area__c finalExpectedUW = [SELECT Id,Head_of_UW_Name__c,Senior_UW_Name__c FROM UW_Business_Area__c WHERE Business_Code__c = :buCode.Id AND RC_Code__c = :Mockup_Test.AH_RC_CODE LIMIT 1];

        Call_Report__c finalCallReport = [SELECT Id, Head_of_UW_Name__c, Senior_UW_Name__c FROM Call_Report__c WHERE CIS_ID__c = :finalAccount.Id];
        System.assertEquals(finalExpectedUW.Head_of_UW_Name__c, finalCallReport.Head_of_UW_Name__c);
        System.assertEquals(finalExpectedUW.Senior_UW_Name__c, finalCallReport.Senior_UW_Name__c);
    }

    @isTest static void updateOpportunityUWFromCallRep(){
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
        userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
        userRM.Segment__c = 'ME';
        update userRM;      

        System.runAs(userRM){
            Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
            targetAccount.Customer_s_Business_Code__c = '111111';
            update targetAccount;

            Call_Report__c callreportObj = new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Status__c = GlobalConstants.PLAN,
                RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_DEVNAME),
                Plan_Date__c = System.Today(),
                Offer_Credit_Product__c = true,
                Offer_Interest__c = GlobalConstants.INTEREST_AND_CAN_APPLY,
                Expected_Credit_Amount__c = 6000
            );
            insert callreportObj;
            Account_OwnerChange_Service.callReportRunOnce = false;
            
            Account finalAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];

            Business_Code__c buCode = [SELECT Name FROM Business_Code__c WHERE Name = '111111' LIMIT 1];
            UW_Business_Area__c finalExpectedUW = [SELECT Id,Head_of_UW_Name__c,Senior_UW_Name__c FROM UW_Business_Area__c WHERE Business_Code__c = :buCode.Id AND RC_Code__c = :Mockup_Test.AH_RC_CODE LIMIT 1];

            Call_Report__c finalCallReport = [SELECT Id, Head_of_UW_Name__c, Senior_UW_Name__c FROM Call_Report__c WHERE CIS_ID__c = :finalAccount.Id];
            Opportunity finalOpp = [SELECT Head_of_UW_Name__c, Senior_UW_Name__c FROM Opportunity WHERE Account.Name = :CallReport_Test.accountNameRM LIMIT 1];

            System.assertEquals(finalExpectedUW.Head_of_UW_Name__c, finalCallReport.Head_of_UW_Name__c);
            System.assertEquals(finalExpectedUW.Senior_UW_Name__c, finalCallReport.Senior_UW_Name__c);
            System.assertEquals(finalCallReport.Head_of_UW_Name__c, finalOpp.Head_of_UW_Name__c);
            System.assertEquals(finalCallReport.Senior_UW_Name__c, finalOpp.Senior_UW_Name__c);
            String oldHeadUWId = finalCallReport.Head_of_UW_Name__c;
            String oldSeniorUWId = finalCallReport.Senior_UW_Name__c;
            Test.startTest();
                finalCallReport.Head_of_UW_Name__c = [SELECT Id FROM User WHERE Firstname = 'uwNHHeadUser' LIMIT 1].Id;
                finalCallReport.Senior_UW_Name__c = [SELECT Id FROM User WHERE Firstname = 'uwNHSeniorUser' LIMIT 1].Id;
            
                TriggerHandler.clearAllBypasses();
                update finalCallReport;
            Test.stopTest();

            Call_Report__c finalCallReport2 = [SELECT Id, Head_of_UW_Name__c, Senior_UW_Name__c FROM Call_Report__c WHERE CIS_ID__c = :finalAccount.Id];
            Opportunity finalOpp2 = [SELECT Head_of_UW_Name__c, Senior_UW_Name__c FROM Opportunity WHERE Account.Name = :CallReport_Test.accountNameRM LIMIT 1];

            System.assertNotEquals(finalCallReport2.Head_of_UW_Name__c, oldHeadUWId);
            System.assertNotEquals(finalCallReport2.Senior_UW_Name__c, oldSeniorUWId);
            System.assertEquals(finalCallReport2.Head_of_UW_Name__c, finalOpp2.Head_of_UW_Name__c);
            System.assertEquals(finalCallReport2.Senior_UW_Name__c, finalOpp2.Senior_UW_Name__c);
        }
            
    }

    @isTest static void updateCallRepBU(){
        Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CallReport_Test.accountNameRM LIMIT 1];
        
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
        userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
        userRM.Segment__c = 'ME';
        update userRM;      

        Business_Code__c buCode = [SELECT Name FROM Business_Code__c WHERE Name = '123456' LIMIT 1];

        System.runAs(userRM){
            Call_Report__c callreportObj = new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Contact_Phone__c = '123456789',
                CIS_ID__c = targetAccount.Id,
                Status__c = GlobalConstants.PLAN,
                RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_DEVNAME),
                Plan_Date__c = System.Today(),
                Offer_Credit_Product__c = true,
                Offer_Interest__c = GlobalConstants.INTEREST_AND_CAN_APPLY,
                Expected_Credit_Amount__c = 6000,
                Business_Code__c = buCode.Id
            );
            insert callreportObj;
            Account_OwnerChange_Service.callReportRunOnce = false;
            
            UW_Business_Area__c finalExpectedUW = [SELECT Id,Head_of_UW_Name__c,Senior_UW_Name__c FROM UW_Business_Area__c WHERE Business_Code__c = :buCode.Id AND RC_Code__c = :Mockup_Test.AH_RC_CODE LIMIT 1];

            Call_Report__c finalCallReport = [SELECT Id, Head_of_UW_Name__c, Senior_UW_Name__c FROM Call_Report__c WHERE CIS_ID__c = :targetAccount.Id];
            Opportunity finalOpp = [SELECT Head_of_UW_Name__c, Senior_UW_Name__c FROM Opportunity WHERE Account.Name = :CallReport_Test.accountNameRM LIMIT 1];

            System.assertEquals(finalExpectedUW.Head_of_UW_Name__c, finalCallReport.Head_of_UW_Name__c);
            System.assertEquals(finalExpectedUW.Senior_UW_Name__c, finalCallReport.Senior_UW_Name__c);
            System.assertEquals(finalCallReport.Head_of_UW_Name__c, finalOpp.Head_of_UW_Name__c);
            System.assertEquals(finalCallReport.Senior_UW_Name__c, finalOpp.Senior_UW_Name__c);
            String oldHeadUWId = finalCallReport.Head_of_UW_Name__c;
            String oldSeniorUWId = finalCallReport.Senior_UW_Name__c;

            Business_Code__c buCode7 = [SELECT Name FROM Business_Code__c WHERE Name = '777777' LIMIT 1];

            Test.startTest();
                finalCallReport.Business_Code__c = buCode7.Id;
                finalCallReport.Head_of_UW_Name__c = [SELECT Id FROM User WHERE Firstname = 'uwNHHeadUser' LIMIT 1].Id;
                finalCallReport.Senior_UW_Name__c = [SELECT Id FROM User WHERE Firstname = 'uwNHSeniorUser' LIMIT 1].Id;
            
                TriggerHandler.clearAllBypasses();
                update finalCallReport;
            Test.stopTest();

            Call_Report__c finalCallReport2 = [SELECT Id, Head_of_UW_Name__c, Senior_UW_Name__c FROM Call_Report__c WHERE CIS_ID__c = :targetAccount.Id];
            Opportunity finalOpp2 = [SELECT Head_of_UW_Name__c, Senior_UW_Name__c FROM Opportunity WHERE Account.Name = :CallReport_Test.accountNameRM LIMIT 1];

            UW_Business_Area__c finalExpectedUW2 = [SELECT Id,Head_of_UW_Name__c,Senior_UW_Name__c FROM UW_Business_Area__c WHERE Business_Code__c = :buCode7.Id  LIMIT 1];

            System.assertNotEquals(finalCallReport2.Head_of_UW_Name__c, oldHeadUWId);
            System.assertNotEquals(finalCallReport2.Senior_UW_Name__c, oldSeniorUWId);
            System.assertEquals(finalExpectedUW2.Head_of_UW_Name__c, finalCallReport2.Head_of_UW_Name__c);
            System.assertEquals(finalExpectedUW2.Senior_UW_Name__c, finalCallReport2.Senior_UW_Name__c);
            System.assertEquals(finalCallReport2.Head_of_UW_Name__c, finalOpp2.Head_of_UW_Name__c);
            System.assertEquals(finalCallReport2.Senior_UW_Name__c, finalOpp2.Senior_UW_Name__c);
        }
    }

    @isTest static void testTrashPoolFlagWhenCreatingCallPlan(){
        TriggerHandler.bypass('AccountTriggerHandler');
        Account customer = [SELECT Id, Name, Trash_Pool_Flag__c FROM Account WHERE Name =: accountNameTM];
        customer.Trash_Pool_Flag__c = true;
        update customer;
        TriggerHandler.clearByPass('AccountTriggerHandler');

        customer = [SELECT Id, Trash_Pool_Flag__c FROM Account WHERE Id =: customer.Id];
        System.assertEquals(true,customer.Trash_Pool_Flag__c);
        
        Business_Code__c buCode = [SELECT Name FROM Business_Code__c WHERE Name = '123456' LIMIT 1];

        Call_Report__c callPlan = new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Contact_Phone__c = '123456789',
                CIS_ID__c = customer.Id,
                Status__c = GlobalConstants.PLAN,
                RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_PLAN_DEVNAME),
                Plan_Date__c = System.Today(),
                Offer_Credit_Product__c = true,
                Offer_Interest__c = GlobalConstants.INTEREST_AND_CAN_APPLY,
                Expected_Credit_Amount__c = 6000,
                Business_Code__c = buCode.Id
            );

        Test.startTest();
        insert callPlan;
        Test.stopTest();

        

        customer = [SELECT Id, Trash_Pool_Flag__c FROM Account WHERE Id =: customer.Id];
        System.assertEquals(false,customer.Trash_Pool_Flag__c);
    }

    @isTest static void testTrashPoolFlagWhenCreatingCallReport(){
        TriggerHandler.bypass('AccountTriggerHandler');
        Account customer = [SELECT Id, Name, Trash_Pool_Flag__c FROM Account WHERE Name =: accountNameTM];
        customer.Trash_Pool_Flag__c = true;
        update customer;
        TriggerHandler.clearByPass('AccountTriggerHandler');

        customer = [SELECT Id, Trash_Pool_Flag__c FROM Account WHERE Id =: customer.Id];
        System.assertEquals(true,customer.Trash_Pool_Flag__c);

        Business_Code__c buCode = [SELECT Name FROM Business_Code__c WHERE Name = '123456' LIMIT 1];

        Call_Report__c callReport = new Call_Report__c(
                Contact_Firstname__c = 'abc',
                Contact_Lastname__c = 'def',
                Contact_Phone__c = '123456789',
                CIS_ID__c = customer.Id,
                Status__c = GlobalConstants.PLAN,
                RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_REPORT_DEVNAME),
                Plan_Date__c = System.Today(),
                Offer_Credit_Product__c = true,
                Offer_Interest__c = GlobalConstants.INTEREST_AND_CAN_APPLY,
                Expected_Credit_Amount__c = 6000,
                Business_Code__c = buCode.Id
            );

        Test.startTest();
        insert callReport;
        Test.stopTest();

        customer = [SELECT Id, Trash_Pool_Flag__c FROM Account WHERE Id =: customer.Id];
        System.assertEquals(false,customer.Trash_Pool_Flag__c);
    }
}