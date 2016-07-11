@isTest
private class Contact_Test {
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
	}
    
	static testMethod void  checkPrimaryContact() {
		Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :Contact_Test.accountNameRM LIMIT 1];
		
		Contact con = new Contact();
		con.LastName = 'lastname';
		con.Contact_Firstname__c = 'Firstname';
		con.Birthdate__c = '11/11/2550';
		con.AccountId = targetAccount.Id;
		con.Phone_Number__c = '023450789';
        con.Primary_Contact__c = true;
		insert con;

		Contact con2 = new Contact();
		con2.LastName = 'lastname';
		con2.Contact_Firstname__c = 'Firstname';
		con2.Birthdate__c = '11/11/2550';
		con2.AccountId = targetAccount.Id;
		con2.Phone_Number__c = '023450789';        
        
		Test.startTest();
        try {
            insert con2;
        } catch (Exception e) {
            System.assertEquals(true, e.getMessage().contains('already has primary'));
        }
			
		Test.stopTest();
	}
    
    static testMethod void  noPrimaryContact() {
		Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :Contact_Test.accountNameRM LIMIT 1];
		
		Contact con = new Contact();
		con.LastName = 'lastname';
		con.Contact_Firstname__c = 'Firstname';
		con.Birthdate__c = '11/11/2550';
		con.AccountId = targetAccount.Id;
		con.Phone_Number__c = '023450789';
		insert con;

		Contact con2 = new Contact();
		con2.LastName = 'lastname';
		con2.Contact_Firstname__c = 'Firstname';
		con2.Birthdate__c = '11/11/2550';
		con2.AccountId = targetAccount.Id;
		con2.Phone_Number__c = '023450789';        
        
		Test.startTest();
        insert con2;
		Test.stopTest();
        
        System.assertEquals(2, [SELECT Id FROM Contact WHERE AccountId = :targetAccount.Id].size());
	}
	
}