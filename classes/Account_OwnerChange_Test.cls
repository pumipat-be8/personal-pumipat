/**
* @author komsan.wi@beryl8.com
* @12/07/2015 createddate
*/
@isTest
private class Account_OwnerChange_Test {
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';

    public static String contactNameTM = 'tmCreatedContactName';
    public static String contactNameRM = 'rmCreatedContactName';
    public static String contactNameAH = 'ahCreatedContactName';

    public static String lastNameTM = 'tmCreatedLastName';
    public static String lastNameRM = 'rmCreatedLastName';
    public static String lastNameAH = 'ahCreatedLastName';
    @testSetup static void setupUser(){
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccountWithContact(accountNameTM,contactNameTM,lastNameTM,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccountWithContact(accountNameRM,contactNameRM,lastNameRM,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccountWithContact(accountNameAH,contactNameAH,lastNameAH,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
    }
    static testMethod void changeOwnershipWhenCreateCallReport(){
        Account targetAccount = [SELECT Id,Delete_Flag__c,OwnerId,Previous_Owner__c FROM Account WHERE Name = :Account_OwnerChange_Test.accountNameTM LIMIT 1];
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        System.assertEquals(userTM.Id,targetAccount.OwnerId);
        System.assertEquals(null,targetAccount.Previous_Owner__c);
        System.runAs(userRM){
            Call_Report__c callreportObj;
            
            callreportObj = new Call_Report__c(
                CIS_ID__c = targetAccount.Id,
                Status__c = 'Plan',
                Plan_Date__c = System.Today(),
                Offer_Interest__c = 'Interest and can apply',
                Expected_Credit_Amount__c = 100000,
                RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_PLAN_DEVNAME),
                Offer_Credit_Product__c = true,
                Actual_Visit_Date__c  = System.Today()-1
            );
            Test.startTest();
                insert callreportObj;
            Test.stopTest();
            Account finalAccount = [SELECT Id,Delete_Flag__c,OwnerId,Previous_Owner__c FROM Account WHERE Name = :Account_OwnerChange_Test.accountNameTM LIMIT 1];
            Contact finalContact = [SELECT Id,OwnerId FROM Contact WHERE Account.Name = :Account_OwnerChange_Test.accountNameTM LIMIT 1];

            System.assertEquals(userRM.Id,finalContact.OwnerId);
            System.assertEquals(userRM.Id,finalAccount.OwnerId);
            System.assertEquals(userTM.Id,finalAccount.Previous_Owner__c);
        }
    }
    static testMethod void changeOwnershipWhenCreateCallReportANDCreatedSharingRule(){
        // Create custom setting
        Pool_Visibility__c areaBKK1 = new Pool_Visibility__c();
        areaBKK1.Group_Indicate__c = 'Bangkok';
        areaBKK1.Name = 'RC' + Mockup_Test.NH_RC_CODE;
        areaBKK1.Role_Name__c = 'เครือข่ายลูกค้าผู้ประกอบการ 1 (กทม.2)';
        insert areaBKK1;

        ////////////////////////

        Account targetAccount = [SELECT Id,Delete_Flag__c,OwnerId,Previous_Owner__c FROM Account WHERE Name = :Account_OwnerChange_Test.accountNameAH LIMIT 1];
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];
        System.assertEquals(userAH.Id,targetAccount.OwnerId);
        System.assertEquals(null,targetAccount.Previous_Owner__c);
        System.runAs(userTM){
            Call_Report__c callreportObj;
            callreportObj = new Call_Report__c(
                CIS_ID__c = targetAccount.Id,
                Status__c = 'Plan',
                Plan_Date__c = System.Today(),
                Offer_Interest__c = 'Interest and can apply',
                Expected_Credit_Amount__c = 100000,
                RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_PLAN_DEVNAME),
                Offer_Credit_Product__c = true,
                Actual_Visit_Date__c  = System.Today()-1
            );
            Test.startTest();
                insert callreportObj;
            Test.stopTest();
        }
        Account finalAccount = [SELECT Id,Delete_Flag__c,OwnerId,Previous_Owner__c FROM Account WHERE Name = :Account_OwnerChange_Test.accountNameAH LIMIT 1];
        
        System.assertEquals(targetAccount.Id,finalAccount.Id);
        System.assertEquals(userTM.Id,finalAccount.OwnerId);
        System.assertEquals(userAH.Id,finalAccount.Previous_Owner__c);

        List<AccountShare> finalAccountShare = new List<AccountShare>();
        finalAccountShare = [SELECT Id FROM AccountShare WHERE AccountId = :finalAccount.Id AND RowCause='Manual'];
        System.assert(finalAccountShare!=null);
        System.assertEquals(1,finalAccountShare.size());
        
    }
    @isTest static void changeOwnershipWhenCreateCallReportANDCreatedSharingRuleANDReleaseBack(){
        // Create custom setting
        Pool_Visibility__c areaBKK1 = new Pool_Visibility__c();
        areaBKK1.Group_Indicate__c = 'Bangkok';
        areaBKK1.Name = 'RC' + Mockup_Test.NH_RC_CODE;
        areaBKK1.Role_Name__c = 'เครือข่ายลูกค้าผู้ประกอบการ 1 (กทม.2)';
        insert areaBKK1;

        ////////////////////////

        Account targetAccount = [SELECT Id,Delete_Flag__c,OwnerId,Previous_Owner__c FROM Account WHERE Name = :Account_OwnerChange_Test.accountNameAH LIMIT 1];
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];
        System.assertEquals(userAH.Id,targetAccount.OwnerId);
        System.assertEquals(null,targetAccount.Previous_Owner__c);
        Call_Report__c callreportObj;
        System.runAs(userTM){
            Opportunity targetOp = Mockup_Test.newOpportunity(targetAccount.Id, 'TestOp', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
            insert targetOp;

            callreportObj = new Call_Report__c(
                CIS_ID__c = targetAccount.Id,
                Status__c = GlobalConstants.PLAN,
                Plan_Date__c = System.Today(),
                Offer_Interest__c = 'Interest and can apply',
                Expected_Credit_Amount__c = 100000,
                RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Call_Report__c',GlobalConstants.CALL_PLAN_DEVNAME),
                Offer_Credit_Product__c = true,
                Actual_Visit_Date__c  = System.Today()-1
            );
            
            insert callreportObj;
            Call_Report__c resultCallReport = [SELECT Offer_Interest__c FROM Call_Report__c WHERE Id = :callreportObj.Id];
            //System.assertEquals('123',resultCallReport.Offer_Interest__c);
            Account finalAccount = [SELECT Id,Delete_Flag__c,OwnerId,Previous_Owner__c FROM Account WHERE Name = :Account_OwnerChange_Test.accountNameAH LIMIT 1];
            
            System.assertEquals(targetAccount.Id,finalAccount.Id);
            System.assertEquals(userTM.Id,finalAccount.OwnerId);
            System.assertEquals(userAH.Id,finalAccount.Previous_Owner__c);

            List<AccountShare> finalAccountShare = new List<AccountShare>();
            finalAccountShare = [SELECT Id FROM AccountShare WHERE AccountId = :finalAccount.Id AND RowCause='Manual'];
            System.assert(finalAccountShare!=null);
            System.assertEquals(1,finalAccountShare.size());
        }
        Account_OwnerChange_Service.triggerInitialCall = false;
    }
}