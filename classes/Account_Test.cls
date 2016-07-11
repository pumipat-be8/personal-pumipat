/**
* @author komsan.wi@beryl8.com
* @08/07/2015 createddate
*/
@isTest
private class Account_Test {
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
        /*System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }*/
	}
	static testMethod void deletedProspect45day(){
		Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :Account_Test.accountNameRM LIMIT 1];
		Test.startTest();
			targetAccount.Delete_Flag__c = true;
			update targetAccount;
		Test.stopTest();
		Integer countResult = [SELECT COUNT() FROM Account WHERE Name = :Account_Test.accountNameRM];
		System.assertEquals(0,countResult);
	}
	/*static testMethod void updateAccountOwnerId(){
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){

		Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :Account_Test.accountNameRM LIMIT 1];
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
        User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
		
		Test.startTest();
			targetAccount.Delete_Flag__c = false;
			targetAccount.OwnerId = userRM.Id;
			update targetAccount;
		Test.stopTest();

		Account finalAccount = [SELECT Id,OwnerId,Customer_Owner_Changed_Date__c,Previous_Owner__c FROM Account WHERE Name = :Account_Test.accountNameRM LIMIT 1];
		System.assertEquals(userRM.Id, finalAccount.Previous_Owner__c);
		System.assertEquals(userTM.Id, finalAccount.OwnerId);
		System.assertEquals(System.today(), finalAccount.Customer_Owner_Changed_Date__c);

		}
	}*/
}