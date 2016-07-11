@isTest
private class SME_ReleaseTemporaryOwnership_Test{
    
    public static String accountNameSEProspectNoCallPlanOrOpptNotOverLabelLimit = 'SEProspectNoCallPlanOrOpptNotOverLabelLimit';
    public static String accountNameSEProspectNoCallPlanOrOpptOverLabelLimit = 'SEProspectNoCallPlanOrOpptOverLabelLimit';

    public static String accountNameMEProspectNoCallPlanOrOpptNotOverLabelLimit = 'MEProspectNoCallPlanOrOpptNotOverLabelLimit';
    public static String accountNameMEProspectNoCallPlanOrOpptOverLabelLimit = 'MEProspectNoCallPlanOrOpptOverLabelLimit';

    public static String accountNameSECustomerNoCallPlanOrOpptNotOverLabelLimit = 'SECustomerNoCallPlanOrOpptNotOverLabelLimit';
    public static String accountNameSECustomerNoCallPlanOrOpptOverLabelLimit = 'SECustomerNoCallPlanOrOpptOverLabelLimit';

    public static String accountNameMECustomerNoCallPlanOrOpptNotOverLabelLimit = 'MECustomerNoCallPlanOrOpptNotOverLabelLimit';
    public static String accountNameMECustomerNoCallPlanOrOpptOverLabelLimit = 'MECustomerNoCallPlanOrOpptOverLabelLimit';
    
    public static String accountNameSEProspectCreatedCallPlanOrOpptNotOverLabelLimit = 'SEProspectCreatedCallPlanOrOpptNotOverLabelLimit';
    public static String accountNameSEProspectCreatedCallPlanOrOpptOverLabelLimit = 'SEProspectCreatedCallPlanOrOpptOverLabelLimit';

    public static String accountNameMEProspectCreatedCallPlanOrOpptNotOverLabelLimit = 'accountNameMEProspectCreatedCallPlanOrOpptNotOverLabelLimit';
    public static String accountNameMEProspectCreatedCallPlanOrOpptOverLabelLimit = 'accountNameMEProspectCreatedCallPlanOrOpptOverLabelLimit';
    
    public static String accountNameSECustomerCreatedCallPlanOrOpptNotOverLabelLimit = 'SECustomerCreatedCallPlanOrOpptNotOverLabelLimit';
    public static String accountNameSECustomerCreatedCallPlanOrOpptOverLabelLimit = 'SECustomerCreatedCallPlanOrOpptOverLabelLimit';

    public static String accountNameMECustomerCreatedCallPlanOrOpptNotOverLabelLimit = 'MECustomerCreatedCallPlanOrOpptNotOverLabelLimit';
    public static String accountNameMECustomerCreatedCallPlanOrOpptOverLabelLimit = 'MECustomerCreatedCallPlanOrOpptOverLabelLimit';

    public static Datetime dateTimeNotOverLabelLimit = System.today();
    public static Datetime dateTimeOverLabelLimit = System.today()-100;
    

    @testSetup static void setupAccount(){
        
        
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameSEProspectNoCallPlanOrOpptNotOverLabelLimit,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_PROSPECT));
            mt.newAccount(accountNameSEProspectNoCallPlanOrOpptOverLabelLimit,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_PROSPECT));

            mt.newAccount(accountNameSEProspectCreatedCallPlanOrOpptNotOverLabelLimit,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_PROSPECT));
            mt.newAccount(accountNameSEProspectCreatedCallPlanOrOpptOverLabelLimit,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_PROSPECT));
            
            mt.newAccount(accountNameSECustomerNoCallPlanOrOpptNotOverLabelLimit,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
            mt.newAccount(accountNameSECustomerNoCallPlanOrOpptOverLabelLimit,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));

            mt.newAccount(accountNameSECustomerCreatedCallPlanOrOpptNotOverLabelLimit,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
            mt.newAccount(accountNameSECustomerCreatedCallPlanOrOpptOverLabelLimit,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameMEProspectNoCallPlanOrOpptNotOverLabelLimit,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_PROSPECT));
            mt.newAccount(accountNameMEProspectNoCallPlanOrOpptOverLabelLimit,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_PROSPECT));
            
            mt.newAccount(accountNameMEProspectCreatedCallPlanOrOpptNotOverLabelLimit,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_PROSPECT));
            mt.newAccount(accountNameMEProspectCreatedCallPlanOrOpptOverLabelLimit,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_PROSPECT));
            
            mt.newAccount(accountNameMECustomerNoCallPlanOrOpptNotOverLabelLimit,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
            mt.newAccount(accountNameMECustomerNoCallPlanOrOpptOverLabelLimit,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
            
            mt.newAccount(accountNameMECustomerCreatedCallPlanOrOpptNotOverLabelLimit,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
            mt.newAccount(accountNameMECustomerCreatedCallPlanOrOpptOverLabelLimit,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        
        }
        
        List<Account> accountList = [SELECT Id, Name, Last_CallReprt_Opty_Updated_Date__c, CreatedDate FROM Account];

        for(Account account:accountList){
            
            if(account.Name == accountNameSEProspectNoCallPlanOrOpptOverLabelLimit || account.Name == accountNameMEProspectNoCallPlanOrOpptOverLabelLimit
                || account.Name == accountNameSECustomerNoCallPlanOrOpptOverLabelLimit || account.Name == accountNameMECustomerNoCallPlanOrOpptOverLabelLimit){
                Test.setCreatedDate(account.Id,dateTimeOverLabelLimit);
            }/*
            else if(account.Name == accountNameSEProspectNoCallPlanOrOpptNotOverLabelLimit || account.Name == accountNameMEProspectNoCallPlanOrOpptNotOverLabelLimit
                || account.Name == accountNameSECustomerNoCallPlanOrOpptNotOverLabelLimit || account.Name == accountNameMECustomerNoCallPlanOrOpptNotOverLabelLimit){
                Test.setCreatedDate(account.Id,dateTimeNotOverLabelLimit);
            }*/
            if(account.Name == accountNameSEProspectCreatedCallPlanOrOpptOverLabelLimit || account.Name == accountNameMEProspectCreatedCallPlanOrOpptOverLabelLimit
                || account.Name == accountNameSECustomerCreatedCallPlanOrOpptOverLabelLimit || account.Name == accountNameMECustomerCreatedCallPlanOrOpptOverLabelLimit){
                account.Last_CallReprt_Opty_Updated_Date__c = System.today()-100;
            }
            else if(account.Name == accountNameSEProspectCreatedCallPlanOrOpptNotOverLabelLimit || account.Name == accountNameMEProspectCreatedCallPlanOrOpptNotOverLabelLimit
                || account.Name == accountNameSECustomerCreatedCallPlanOrOpptNotOverLabelLimit || account.Name == accountNameMECustomerCreatedCallPlanOrOpptNotOverLabelLimit){
                account.Last_CallReprt_Opty_Updated_Date__c = System.today();   
            }

        }
        update accountList;
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
        List<User> userList = [SELECT Id, FirstName, Segment__c FROM User];
        for(User user:userList){
            if(user.FirstName == Mockup_Test.userFirstNameRM){
                user.Segment__c = 'SE';     
            }
            else if(user.FirstName == Mockup_Test.userFirstNameTM){
                user.Segment__c = 'ME';
            }
        }
        
        update userList;
        }
    }

    @isTest static void prospectIsSEAndHasNoCallPlanOrOpptAndNotOverLabelLimit(){
        
        Test.startTest();
        TriggerHandler.bypass('AccountTriggerHandler');
        Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
        Test.stopTest();

        Account account = [SELECT Id, Customer_Owner_Release_Flag__c FROM Account WHERE Name =: accountNameSEProspectNoCallPlanOrOpptNotOverLabelLimit];
        System.assertEquals(false,account.Customer_Owner_Release_Flag__c);

    }
    
    
    @isTest static void prospectIsSEAndHasNoCallPlanOrOpptAndOverLabelLimit(){
        
        Test.startTest();
        TriggerHandler.bypass('AccountTriggerHandler');
        Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
        Test.stopTest();

        Account account = [SELECT Id, Customer_Owner_Release_Flag__c, CreatedDate FROM Account WHERE Name =: accountNameSEProspectNoCallPlanOrOpptOverLabelLimit];
        System.assertEquals(true,account.Customer_Owner_Release_Flag__c,''+account.CreatedDate);

    }
    

    @isTest static void prospectIsMEAndHasNoCallPlanOrOpptAndNotOverLabelLimit(){
        
        Test.startTest();
        TriggerHandler.bypass('AccountTriggerHandler');
        Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
        Test.stopTest();

        Account account = [SELECT Id, Customer_Owner_Release_Flag__c FROM Account WHERE Name =: accountNameMEProspectNoCallPlanOrOpptNotOverLabelLimit];
        System.assertEquals(false,account.Customer_Owner_Release_Flag__c);

    }

    
    @isTest static void prospectIsMEAndHasNoCallPlanOrOpptAndOverLabelLimit(){
        
        Test.startTest();
        TriggerHandler.bypass('AccountTriggerHandler');
        Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
        Test.stopTest();

        Account account = [SELECT Id, Customer_Owner_Release_Flag__c FROM Account WHERE Name =: accountNameMEProspectNoCallPlanOrOpptOverLabelLimit];
        System.assertEquals(true,account.Customer_Owner_Release_Flag__c);

    }
    
    
    @isTest static void customerIsSEAndHasNoCallPlanOrOpptAndNotOverLabelLimit(){
        
        Test.startTest();
        TriggerHandler.bypass('AccountTriggerHandler');
        Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
        Test.stopTest();

        Account account = [SELECT Id, Customer_Owner_Release_Flag__c FROM Account WHERE Name =: accountNameSECustomerNoCallPlanOrOpptNotOverLabelLimit];
        System.assertEquals(false,account.Customer_Owner_Release_Flag__c);

    }
    
    @isTest static void customerIsSEAndHasNoCallPlanOrOpptAndOverLabelLimit(){
        
        Test.startTest();
        TriggerHandler.bypass('AccountTriggerHandler');
        Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
        Test.stopTest();

        Account account = [SELECT Id, Customer_Owner_Release_Flag__c FROM Account WHERE Name =: accountNameSECustomerNoCallPlanOrOpptOverLabelLimit];
        System.assertEquals(true,account.Customer_Owner_Release_Flag__c);

    }
    

    @isTest static void customerIsMEAndHasNoCallPlanOrOpptAndNotOverLabelLimit(){
        
        Test.startTest();
        TriggerHandler.bypass('AccountTriggerHandler');
        Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
        Test.stopTest();

        Account account = [SELECT Id, Customer_Owner_Release_Flag__c FROM Account WHERE Name =: accountNameMECustomerNoCallPlanOrOpptNotOverLabelLimit];
        System.assertEquals(false,account.Customer_Owner_Release_Flag__c);

    }
    
    @isTest static void customerIsMEAndHasNoCallPlanOrOpptAndOverLabelLimit(){
        
        Test.startTest();
        TriggerHandler.bypass('AccountTriggerHandler');
        Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
        Test.stopTest();

        Account account = [SELECT Id, Customer_Owner_Release_Flag__c FROM Account WHERE Name =: accountNameMECustomerNoCallPlanOrOpptOverLabelLimit];
        System.assertEquals(true,account.Customer_Owner_Release_Flag__c);

    }
    

    @isTest static void prospectIsSEAndHasCallPlanOrOpptAndNotOverLabelLimit(){
        
        Test.startTest();
        TriggerHandler.bypass('AccountTriggerHandler');
        Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
        Test.stopTest();

        Account account = [SELECT Id, Customer_Owner_Release_Flag__c FROM Account WHERE Name =: accountNameSEProspectCreatedCallPlanOrOpptNotOverLabelLimit];
        System.assertEquals(false,account.Customer_Owner_Release_Flag__c);

    }

    @isTest static void prospectIsSEAndHasCallPlanOrOpptAndOverLabelLimit(){
        
        Test.startTest();
        TriggerHandler.bypass('AccountTriggerHandler');
        Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
        Test.stopTest();

        Account account = [SELECT Id, Customer_Owner_Release_Flag__c FROM Account WHERE Name =: accountNameSEProspectCreatedCallPlanOrOpptOverLabelLimit];
        System.assertEquals(true,account.Customer_Owner_Release_Flag__c);

    }

    @isTest static void prospectIsMEAndHasCallPlanOrOpptAndNotOverLabelLimit(){
        
        Test.startTest();
        TriggerHandler.bypass('AccountTriggerHandler');
        Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
        Test.stopTest();

        Account account = [SELECT Id, Customer_Owner_Release_Flag__c FROM Account WHERE Name =: accountNameMEProspectCreatedCallPlanOrOpptNotOverLabelLimit];
        System.assertEquals(false,account.Customer_Owner_Release_Flag__c);

    }
    
    @isTest static void prospectIsMEAndHasCallPlanOrOpptAndOverLabelLimit(){
        
        Test.startTest();
        TriggerHandler.bypass('AccountTriggerHandler');
        Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
        Test.stopTest();

        Account account = [SELECT Id, Customer_Owner_Release_Flag__c FROM Account WHERE Name =: accountNameMEProspectCreatedCallPlanOrOpptOverLabelLimit];
        System.assertEquals(true,account.Customer_Owner_Release_Flag__c);

    }
    
    @isTest static void customerIsSEAndHasCallPlanOrOpptAndNotOverLabelLimit(){
        
        Test.startTest();
        TriggerHandler.bypass('AccountTriggerHandler');
        Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
        Test.stopTest();

        Account account = [SELECT Id, Customer_Owner_Release_Flag__c FROM Account WHERE Name =: accountNameSECustomerCreatedCallPlanOrOpptNotOverLabelLimit];
        System.assertEquals(false,account.Customer_Owner_Release_Flag__c);

    }
    
    @isTest static void customerIsSEAndHasCallPlanOrOpptAndOverLabelLimit(){
        
        Test.startTest();
        TriggerHandler.bypass('AccountTriggerHandler');
        Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
        Test.stopTest();

        Account account = [SELECT Id, Customer_Owner_Release_Flag__c FROM Account WHERE Name =: accountNameSECustomerCreatedCallPlanOrOpptOverLabelLimit];
        System.assertEquals(true,account.Customer_Owner_Release_Flag__c);

    }
    

    @isTest static void customerIsMEAndHasCallPlanOrOpptAndNotOverLabelLimit(){
        
        Test.startTest();
        TriggerHandler.bypass('AccountTriggerHandler');
        Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
        Test.stopTest();

        Account account = [SELECT Id, Customer_Owner_Release_Flag__c FROM Account WHERE Name =: accountNameMECustomerCreatedCallPlanOrOpptNotOverLabelLimit];
        System.assertEquals(false,account.Customer_Owner_Release_Flag__c);

    }
    
    @isTest static void customerIsMEAndHasCallPlanOrOpptAndOverLabelLimit(){
        
        Test.startTest();
        TriggerHandler.bypass('AccountTriggerHandler');
        Database.executeBatch(new SME_ReleaseTemporaryOwnership_Batch());
        Test.stopTest();

        Account account = [SELECT Id, Customer_Owner_Release_Flag__c FROM Account WHERE Name =: accountNameMECustomerCreatedCallPlanOrOpptOverLabelLimit];
        System.assertEquals(true,account.Customer_Owner_Release_Flag__c);

    }
    
}