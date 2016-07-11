/**
 * @author: komsan.wi@beryl8.com.com
 * @komsan.wi: 27/07/2015 create new
 */
@isTest
private class Ownership_Service_Test {
	public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';
    public static String accountNameRMPort = 'accountNameRMPort';
    public static String accountNameRMPool = 'accountNameRMPool';
	@testSetup static void setupAccount(){
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
            mt.newAccount(accountNameRMPort,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
            mt.newAccount(accountNameRMPool,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
	}
    static testMethod void releaseTempOwnership(){
        User targetUserAdmin = [SELECT Id,RC_Code__c,ManagerId FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1];
        User targetUserRM = [SELECT Id,RC_Code__c,ManagerId FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User targetUserTM = [SELECT Id,RC_Code__c,ManagerId FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        Account targetAccount = [SELECT Id,Port_Pool__c,OwnerId,Owner.Employee_Id__c,RC_Code__c,Previous_Owner__c FROM Account WHERE Name = :Ownership_Service_Test.accountNameRM LIMIT 1];

        User_Extension__c userExt = [SELECT Id,External_ID__c FROM User_Extension__c WHERE External_ID__c = :Mockup_Test.userEmpIdTM LIMIT 1];
        targetAccount.Permanent_Owner_Extension__c = userExt.Id;
        update targetAccount;

        Ownership_Service.Response res = Ownership_Service.releaseTemporaryOwnership(JSON.serialize(targetAccount), targetUserAdmin.Id);
        System.assertEquals(true, res.success);

        Account finalAccount = [SELECT OwnerID, Port_Pool__c, Ownership_Text__c FROM Account  WHERE Name = :Ownership_Service_Test.accountNameRM LIMIT 1];
        System.assertEquals(targetUserTM.Id, finalAccount.OwnerID);
        System.assertEquals(GlobalConstants.POOL, finalAccount.Port_Pool__c);
        System.assertEquals(GlobalConstants.OWNERSHIP_PERMANENT, finalAccount.Ownership_Text__c);
    }

	static testMethod void releaseOwnership(){
        User targetUserRM = [SELECT Id,RC_Code__c,ManagerId FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User targetUserTM = [SELECT Id,RC_Code__c,ManagerId FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        Account targetAccount = [SELECT Id,Port_Pool__c,OwnerId,RC_Code__c,Previous_Owner__c FROM Account WHERE Name = :Ownership_Service_Test.accountNameRMPort LIMIT 1];
        
        User_Extension__c userExt = [SELECT Id,External_ID__c FROM User_Extension__c WHERE External_ID__c = :Mockup_Test.userEmpIdTM LIMIT 1];
        targetAccount.Permanent_Owner_Extension__c = userExt.Id;
        targetAccount.Previous_Owner__c = targetUserTM.Id;
        update targetAccount;

        System.runAs(targetUserRM){

            Ownership_Service.Response res = Ownership_Service.releaseOwnership(JSON.serialize(targetAccount), JSON.serialize(targetUserRM));
            System.assertEquals(true, res.success);

            List<Customer_Ownership_Request__c> ownerShipList = [SELECT OwnerID FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:targetAccount.Id];
            System.assertEquals(1, ownerShipList.size());
            System.assertEquals(targetUserRM.Id, ownerShipList[0].OwnerID);
        }
	}
	static testMethod void createOwnership(){
        Account targetAccount = [SELECT Id,Port_Pool__c,OwnerId,Owner.Employee_Id__c,RC_Code__c FROM Account WHERE Name = :Ownership_Service_Test.accountNameTM LIMIT 1];

        User targetUser = [SELECT Id,RC_Code__c,ManagerId FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User_Extension__c userExt = [SELECT Id,External_ID__c FROM User_Extension__c WHERE External_ID__c = :targetAccount.Owner.Employee_Id__c LIMIT 1];
        targetAccount.Permanent_Owner_Extension__c = userExt.Id;
        update targetAccount;

        System.runAs(targetUser){
            Ownership_Service.Response res = Ownership_Service.createOwnerShip(JSON.serialize(targetAccount), JSON.serialize(targetUser));
            System.assertEquals(true, res.success);

            List<Customer_Ownership_Request__c> ownerShipList = [SELECT OwnerID FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:targetAccount.Id];
            System.assertEquals(1, ownerShipList.size());
            System.assertEquals(targetUser.Id, ownerShipList[0].OwnerID);
        }
	}

    static testMethod void releaseFlagOwnership(){
        User targetUserAdmin = [SELECT Id,RC_Code__c,ManagerId FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1];
        User targetUserRM = [SELECT Id,RC_Code__c,ManagerId FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User targetUserTM = [SELECT Id,RC_Code__c,ManagerId FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
        Account targetAccount = [SELECT Id,Port_Pool__c,OwnerId,Owner.Employee_Id__c,RC_Code__c,Previous_Owner__c FROM Account WHERE Name = :Ownership_Service_Test.accountNameRMPool LIMIT 1];

        Test.startTest();
            targetAccount.Customer_Owner_Release_Flag__c = true;
            update targetAccount;
        Test.stopTest();
        
        Account finalAccount = [SELECT OwnerID, Port_Pool__c, Ownership_Text__c, Customer_Owner_Release_Flag__c FROM Account WHERE Name=:accountNameRMPool LIMIT 1];
        System.assertEquals(false, finalAccount.Customer_Owner_Release_Flag__c);
        //System.assertEquals(targetUserTM.Id, finalAccount.OwnerID);
        //System.assertEquals(GlobalConstants.POOL, finalAccount.Port_Pool__c);
        //System.assertEquals(GlobalConstants.OWNERSHIP_PERMANENT, finalAccount.Ownership_Text__c);
        
    }
}