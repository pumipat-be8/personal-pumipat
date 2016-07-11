/**
* @author komsan.wi@beryl8.com
* @16/07/2015 createddate
* @17/09/2015 update
*/
@isTest
private class YearEndAssignment_Batch_Test {
    public static String accountNameTM = 'tmCreatedAccountName';
    @testSetup static void setupAccount(){
        Mockup_Test mt = new Mockup_Test().setUpTest();
        
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,'',Mockup_Test.getRecordTypeAccountIdByName('SME-Customer'));
        }
    }

    //static testMethod void yearEndAssignChangeAccount(){
    //  Account targetAccount = [SELECT Id,Delete_Flag__c,OwnerId,Previous_Owner__c,CIS__c,Name FROM Account WHERE Name = :YearEndAssignment_Batch_Test.accountNameTM LIMIT 1];
    //  User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
 //       User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
    //  insert new Year_End_Assignment__c(
            //CIS_ID_Unique__c = targetAccount.Name,
    //      CIS_ID__c = targetAccount.Id,
    //      Final_Assigned_RM__c = userRM.Id,
    //      Status__c = GlobalConstants.SUBMITTED,
    //      //Final_Refer_Out__c = false,
    //      Final_Service_RM__c = userRM.Id,
    //      Final_Port_Pool__c = GlobalConstants.POOL
    //  );
    //  Test.startTest();
 //         Database.executeBatch(new YearEndAssignment_Batch());
 //       Test.stopTest();
        
    //  Account finalAccount = [SELECT Id,OwnerId,Previous_Owner__c,Port_Pool__c,Customer_Owner_Changed_Date__c,Service_RM__c FROM Account WHERE Name = :YearEndAssignment_Batch_Test.accountNameTM LIMIT 1];

 //       System.assertEquals(userRM.Id,finalAccount.OwnerId);
 //       System.assertEquals(userRM.Id, finalAccount.Service_RM__c);
 //       System.assertEquals(userTM.Id,finalAccount.Previous_Owner__c);
 //       System.assertEquals(GlobalConstants.POOL,finalAccount.Port_Pool__c);
 //       System.assertEquals(System.Today(),finalAccount.Customer_Owner_Changed_Date__c);
    //}

    static testMethod void yearEndAssignAccount(){
        Account targetAccount = [SELECT Id,Delete_Flag__c,OwnerId,Previous_Owner__c,CIS__c,Name FROM Account WHERE Name = :YearEndAssignment_Batch_Test.accountNameTM LIMIT 1];
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        insert new Year_End_Assignment__c(
            CIS_ID_Unique__c = targetAccount.Name,
            CIS_ID__c = targetAccount.Id,
            Final_Assigned_RM__c = userTM.Id,
            Status__c = GlobalConstants.SUBMITTED,
            Final_Refer_Out__c = false,
            Final_Service_RM__c = userRM.Id,
            Final_Port_Pool__c = GlobalConstants.POOL
        );
        Test.startTest();
            Database.executeBatch(new YearEndAssignment_Batch());
        Test.stopTest();
        
        Account finalAccount = [SELECT Id,OwnerId,Previous_Owner__c,Port_Pool__c,Customer_Owner_Changed_Date__c,Service_RM__c FROM Account WHERE Name = :YearEndAssignment_Batch_Test.accountNameTM LIMIT 1];

        //System.assertEquals(userTM.Id, finalAccount.OwnerId);
        //System.assertEquals(userRM.Id, finalAccount.Service_RM__c);
        //System.assertEquals(null, finalAccount.Previous_Owner__c);
        //System.assertEquals(GlobalConstants.POOL, finalAccount.Port_Pool__c);
        //System.assertEquals(System.Today(), finalAccount.Customer_Owner_Changed_Date__c);

    }

    static testMethod void yearEndAssignAccountDead(){
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            Account targetAccount = [SELECT Id,Delete_Flag__c,OwnerId,Previous_Owner__c,CIS__c,Name FROM Account WHERE Name = :YearEndAssignment_Batch_Test.accountNameTM LIMIT 1];
            User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
            User userAdmin = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1];
            insert new Year_End_Assignment__c(
                CIS_ID_Unique__c = targetAccount.Name,
                CIS_ID__c = targetAccount.Id,               
                Final_Assigned_RM__c = userRM.Id,
                Final_Refer_Out__c = true,
                Status__c = GlobalConstants.SUBMITTED,
                Refer_Out_Reason__c = 'Exit Plan'
            );
            Test.startTest();
                Database.executeBatch(new YearEndAssignment_Batch());
            Test.stopTest();
            
            Account finalAccount = [SELECT Id, Service_RM__c ,OwnerId , Previous_Owner__c, Port_Pool__c, Customer_Owner_Changed_Date__c FROM Account WHERE Name = :YearEndAssignment_Batch_Test.accountNameTM LIMIT 1];
            
            //System.assertEquals(System.Today(),finalAccount.Customer_Owner_Changed_Date__c);
            //System.assertEquals(userAdmin.Id,finalAccount.OwnerId);
            //System.assertEquals(null, finalAccount.Service_RM__c);
            //System.assertEquals(null, finalAccount.Port_Pool__c);
            //System.assertEquals(null, finalAccount.Previous_Owner__c);
        }
        
    }

    static testMethod void yearEndAssignAccountOther(){
        Account targetAccount = [SELECT Id,Delete_Flag__c,OwnerId,Previous_Owner__c,CIS__c,Name FROM Account WHERE Name = :YearEndAssignment_Batch_Test.accountNameTM LIMIT 1];
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User userAdmin = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1];
        Year_End_Assignment__c yearEnd = new Year_End_Assignment__c(
            CIS_ID_Unique__c = targetAccount.Name,
            CIS_ID__c = targetAccount.Id,
            Final_Assigned_RM__c = userRM.Id,
            Status__c = GlobalConstants.SUBMITTED,
            Final_Refer_Out__c = true,
            Segment_Proposed__c = 'MB',
            Refer_Out_Reason__c = GlobalConstants.OTHER_SEGMENT
        );
        insert yearEnd;
        Test.startTest();
            Database.executeBatch(new YearEndAssignment_Batch());
        Test.stopTest();
        
        Account finalAccount = [SELECT Id,Service_RM__c,Delete_Flag__c,OwnerId,Previous_Owner__c,Port_Pool__c,Customer_Owner_Changed_Date__c,Primary_Segment_Code__c FROM Account WHERE Name = :YearEndAssignment_Batch_Test.accountNameTM LIMIT 1];
        
        //System.assertEquals(yearEnd.Segment_Proposed__c, finalAccount.Primary_Segment_Code__c);
        //System.assertEquals(System.Today(),finalAccount.Customer_Owner_Changed_Date__c);
        //System.assertEquals(userAdmin.Id,finalAccount.OwnerId);
        //System.assertEquals(null, finalAccount.Service_RM__c);
        //System.assertEquals(null, finalAccount.Port_Pool__c);
        //System.assertEquals(null, finalAccount.Previous_Owner__c);
    }

    static testMethod void yearEndAssignAccountNegativeCase(){
        Account targetAccount = [SELECT Id,Delete_Flag__c,OwnerId,Previous_Owner__c,CIS__c,Name FROM Account WHERE Name = :YearEndAssignment_Batch_Test.accountNameTM LIMIT 1];
        User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        insert new Year_End_Assignment__c(
            CIS_ID_Unique__c = targetAccount.Name,
            CIS_ID__c = targetAccount.Id,
            Status__c = GlobalConstants.SUBMITTED
        );
        Test.startTest();
            Database.executeBatch(new YearEndAssignment_Batch());
        Test.stopTest();
        
        Account finalAccount = [SELECT Id,Delete_Flag__c,OwnerId,Previous_Owner__c,Port_Pool__c,Customer_Owner_Changed_Date__c FROM Account WHERE Name = :YearEndAssignment_Batch_Test.accountNameTM LIMIT 1];
        
        //System.assertEquals(null,finalAccount.Customer_Owner_Changed_Date__c);
        //System.assertEquals(userTM.Id,finalAccount.OwnerId);
        //System.assertEquals(null,finalAccount.Previous_Owner__c);
    }
}