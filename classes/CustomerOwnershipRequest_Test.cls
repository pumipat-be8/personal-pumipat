/**
* @author komsan.wi@beryl8.com
* @16/07/2015 createddate
*/
@isTest
private class CustomerOwnershipRequest_Test {
	public static String accountNameTM = 'tmCreatedAccountName';
	public static String accountNameTMPer = 'tmCreatedAccountPer';
	public static String accountNameRMPer = 'accountNameRMPer';
	public static String accountNameRMPer1 = 'accountNameRMPer1';
	public static String accountNameRMPer2 = 'accountNameRMPer2';
	public static String userRcCode1 = '52215';
	public static String userRcCode2 = '52216';
	public static String targetFirstName1 = 'manualNhUserFirstName1';
	public static String targetLastName1 = 'manualNhUserLastName1';
	public static String targetFirstName2 = 'manualNhUserFirstName2';
	public static String targetLastName2 = 'manualNhUserLastName2';

	@testSetup static void setupAccount(){
        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRMPer,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
            mt.newAccount(accountNameRMPer1,GlobalConstants.PORT,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
            mt.newAccount(accountNameRMPer2,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
        	mt.newAccount(accountNameTMPer,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
            Mockup_Test.newAccountShare(
            	[SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0].Id,
				[SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameTM LIMIT 1][0].Id,
				'edit',
				'edit'
            );
        }

        setupDataForTestReleaseOtherSegment();
	}

	private static void setupDataForTestReleaseOtherSegment(){
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		Account targetAccount = [SELECT Id FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameRMPer1 LIMIT 1];
		System.runAs(userRM){
			Customer_Ownership_Request__c customerRequestNew = new Customer_Ownership_Request__c(
				CIS_ID__c = targetAccount.Id,
				Request_Type__c = GlobalConstants.RELEASE_OWNERSHIP,
				Refer_Out_Reason__c = GlobalConstants.REASON_NOT_SME,
				Not_SME_Segment_Flag__c = false,
				Refer_Out_Segment__c = 'MB',
				Reason__c = 'reason'
			);
			insert customerRequestNew;
		}
		Customer_Ownership_Request__c customerRequest = [SELECT Id FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:targetAccount.Id LIMIT 1];
		customerRequest.Approval_Status__c = GlobalConstants.APPROVED;
		update customerRequest;
	}
	/*@isTest static void sendRequestApprovalFromAction(){
		User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameTM LIMIT 1];
		System.runAs(userRM){
			//insert new Customer_Ownership_Request__c(
			//		CIS_ID__c = targetAccount.Id,
			//		Request_Type__c = GlobalConstants.REQUEST_OWNERSHIP,
			//		Want_to_request_for_ownership__c = true
			//	);
			Mockup_Test.newCustomerRequest(targetAccount.Id,'Pending',userRM.Id,GlobalConstants.REQUEST_OWNERSHIP, GlobalConstants.PORT);
			Customer_Ownership_Request__c customerRequest = [SELECT Id FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:targetAccount.Id LIMIT 1];
			Test.startTest();
				customerRequest.Approval_Status__c = GlobalConstants.APPROVED;
				update customerRequest;
			Test.stopTest();
		}
        Account finalAccount = [SELECT Id,OwnerId,Previous_Owner__c,Port_Pool__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameTM LIMIT 1];
        System.assertEquals(GlobalConstants.PORT,finalAccount.Port_Pool__c);
        System.assertEquals(userRM.Id,finalAccount.OwnerId);
        System.assertEquals(userTM.Id,finalAccount.Previous_Owner__c);
	}

	@isTest static void sendReleaseApprovalFromAction(){
		User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameTM LIMIT 1];
		System.runAs(userTM){
			insert new Customer_Ownership_Request__c(
					CIS_ID__c = targetAccount.Id,
					Request_Type__c = GlobalConstants.RELEASE_OWNERSHIP,
					Want_to_request_for_ownership__c = true
				);
			Mockup_Test.newCustomerRequest(targetAccount.Id,'Pending',userRM.Id,GlobalConstants.RELEASE_OWNERSHIP, GlobalConstants.PORT);
			Customer_Ownership_Request__c customerRequest = [SELECT Id FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:targetAccount.Id LIMIT 1];
			Test.startTest();
				customerRequest.Approval_Status__c = GlobalConstants.APPROVED;
				update customerRequest;
			Test.stopTest();
		}
	}
	@isTest static void changeOwnerWhenApproved(){
		User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameTM LIMIT 1];
		System.runAs(userRM){
			Mockup_Test.newCustomerRequest(targetAccount.Id,'Pending',userRM.Id,GlobalConstants.REQUEST_OWNERSHIP, GlobalConstants.PORT);
			Customer_Ownership_Request__c customerRequest = [SELECT Id FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:targetAccount.Id LIMIT 1];
			Test.startTest();
				customerRequest.Approval_Status__c = GlobalConstants.APPROVED;
				update customerRequest;
			Test.stopTest();
		}
        Account finalAccount = [SELECT Id,Delete_Flag__c,OwnerId,Previous_Owner__c,Port_Pool__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameTM LIMIT 1];
        System.assertEquals(GlobalConstants.PORT,finalAccount.Port_Pool__c);
        System.assertEquals(userRM.Id,finalAccount.OwnerId);
        System.assertEquals(userTM.Id,finalAccount.Previous_Owner__c);
	}*/

	@isTest static void releaseOtherSegment(){
		Account accountPer = [SELECT Id,Primary_Segment_Code__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameRMPer1 LIMIT 1];
        accountPer.Primary_Segment_Code__c = 'MB';
        update accountPer;

        Account finalAccount = [SELECT Id, Owner.Profile.Name FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameRMPer1 LIMIT 1];
        System.assertEquals('SME-Admin',finalAccount.Owner.Profile.Name);
	}

	@isTest static void releaseWrongAreaWithNH(){
		String expectedOwnerNameResult = targetFirstName1 + ' ' + targetLastName1;
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		Account releaseAccount = [SELECT Id ,Current_Owner_Extension__r.Name,Current_Team_Name__r.External_ID__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameRMPer LIMIT 1];
		
		System.assertEquals(null,releaseAccount.Current_Owner_Extension__r.Name);
		System.assertNotEquals(userRcCode1,releaseAccount.Current_Team_Name__r.External_ID__c);

		Test.startTest();
			Profile nhProfile = [SELECT Id, Name FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];

			Team_Structure__c tsNh = new Team_Structure__c(
				AH_Name__c = null,
				RC_Code__c = Mockup_Test.NH_RC_CODE,
				External_ID__c = userRcCode1
			);
			insert tsNh;

			User manualNhUser = Mockup_Test.newUser(
		            targetFirstName1,
			    	targetLastName1,
		            true,
		            targetFirstName1 +'@mail.com',
		            targetFirstName1 +'@mail.com',
		            targetFirstName1.substring(0, 4),
		            nhProfile.Id,
		            null,
		            null,
		            'MANUAL_MOCK001'
		    );
		    manualNhUser.RC_Code__c = userRcCode1;
		    manualNhUser.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
		    manualNhUser.Job_Code__c = 'ME1A';
		    manualNhUser.Status__c = 'A';
		    insert manualNhUser;
		Test.stopTest();

		Team_Structure__c tempTs = [SELECT Id,Name FROM Team_Structure__c WHERE External_ID__c =:userRcCode1];
		Master_Map__c mapObject = new Master_Map__c(
			Code__c = '77667',
			Type__c = 'test type'
		);
		insert mapObject;
		
		System.runAs(userRM){
			Customer_Ownership_Request__c customerRequestNew = new Customer_Ownership_Request__c(
				CIS_ID__c = releaseAccount.Id,
				Request_Type__c = GlobalConstants.RELEASE_OWNERSHIP,
				Refer_Out_Reason__c = GlobalConstants.REASON_WRONG_AREA,
				Not_SME_Segment_Flag__c = false,
				Refer_Out_Segment__c = 'ME',
				Reason__c = 'reason',
				Refer_Out_Team__c = tempTs.Name,
				Refer_Out_Area__c = mapObject.Id
			);
			insert customerRequestNew;
		}

		Customer_Ownership_Request__c customerRequest = [SELECT Id,Current_Owner__r.Name FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:releaseAccount.Id LIMIT 1];
		customerRequest.Approval_Status__c = GlobalConstants.APPROVED;
		update customerRequest;		

        Account finalAccount = [SELECT Id, Name, Current_Owner_Extension__r.Name,Current_Team_Name__r.External_ID__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameRMPer LIMIT 1];
        
        System.assertEquals(expectedOwnerNameResult,finalAccount.Current_Owner_Extension__r.Name);
        System.assertEquals(userRcCode1,finalAccount.Current_Team_Name__r.External_ID__c);
	}

	@isTest static void releaseTmPool(){
		User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		Account releaseAccount = [SELECT Id,OwnerId FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameRMPer LIMIT 1];
		
		System.assertEquals(userRM.Id,releaseAccount.OwnerId);

		System.runAs(userRM){
			Customer_Ownership_Request__c customerRequestNew = new Customer_Ownership_Request__c(
				CIS_ID__c = releaseAccount.Id,
				Request_Type__c = GlobalConstants.RELEASE_OWNERSHIP,
				Refer_Out_Reason__c = 'TM Pool',
				Not_SME_Segment_Flag__c = false,
				Reason__c = 'reason'
			);
			insert customerRequestNew;

			Customer_Ownership_Request__c customerRequest = [SELECT Id,Current_Owner__r.Name FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:releaseAccount.Id LIMIT 1];
			customerRequest.Approval_Status__c = GlobalConstants.APPROVED;
			update customerRequest;
		}

        Account finalAccount = [SELECT Id, Name, OwnerId FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameRMPer LIMIT 1];
        
        System.assertEquals(userTM.Id,finalAccount.OwnerId);
	}

	@isTest static void requestTmPoolAccountPool(){
		User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		Account releaseAccount = [SELECT Id,OwnerId FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameRMPer2 LIMIT 1];
		
		System.assertEquals(userRM.Id,releaseAccount.OwnerId);

		System.runAs(userRM){
			Customer_Ownership_Request__c customerRequestNew = new Customer_Ownership_Request__c(
				CIS_ID__c = releaseAccount.Id,
				Request_Type__c = GlobalConstants.REQUEST_OWNERSHIP,
				Request_Ownership_Type__c = GlobalConstants.POOL,
				Not_SME_Segment_Flag__c = false,
				Reason__c = 'reason'
			);
			insert customerRequestNew;

			Customer_Ownership_Request__c customerRequest = [SELECT Id,Current_Owner__r.Name FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:releaseAccount.Id LIMIT 1];
			customerRequest.Approval_Status__c = GlobalConstants.APPROVED;
			update customerRequest;
		}

        Account finalAccount = [SELECT Id, Name, OwnerId, Permanent_Owner__c,Port_Pool__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameRMPer2 LIMIT 1];
        
        System.assertEquals(userRM.Id,finalAccount.OwnerId);
        System.assertEquals(GlobalConstants.POOL,finalAccount.Port_Pool__c);
	}
	@isTest static void releaseWrongAreaStatusApprovalInProgress(){
		//TriggerHandler.bypass('TeamStructureTriggerHandler');
		String expectedOwnerNameResult = targetFirstName1 + ' ' + targetLastName1;

		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		Account releaseAccount = [SELECT Id ,Current_Owner_Extension__r.Name,Current_Team_Name__r.External_ID__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameRMPer LIMIT 1];
		
		System.assertEquals(null,releaseAccount.Current_Owner_Extension__r.Name);
		System.assertNotEquals(userRcCode1,releaseAccount.Current_Team_Name__r.External_ID__c);

		Test.startTest();
			Profile ahProfile = [SELECT Id, Name FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1];
			Profile rmProfile = [SELECT Id, Name FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];

			Team_Structure__c tsAh = new Team_Structure__c(
				AH_Name__c = null,
				RC_Code__c = Mockup_Test.AH_RC_CODE,
				External_ID__c = userRcCode1,
				Name = 'Ah Team 1',
                Segment__c = GlobalConstants.SEGMENT_SE,
                Type__c = 'Area'
			);
			insert tsAh;

			Team_Structure__c tsNh = new Team_Structure__c(
				AH_Name__c = null,
				RC_Code__c = Mockup_Test.NH_RC_CODE,
				External_ID__c = userRcCode2,
				Name = 'เครือข่ายลูกค้าผู้ประกอบการ 2 Team 1',
                Segment__c = GlobalConstants.SEGMENT_SE,
                Type__c = 'Network'
			);
			insert tsNh;

			User manualAhUser = Mockup_Test.newUser(
		            targetFirstName1,
			    	targetLastName1,
		            true,
		            targetFirstName1 +'@mail.com',
		            targetFirstName1 +'@mail.com',
		            targetFirstName1.substring(0, 4),
		            ahProfile.Id,
		            null,
		            null,
		            'MANUAL_MOCK001'
		    );
		    manualAhUser.RC_Code__c = userRcCode1;
		    manualAhUser.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		    manualAhUser.Job_Code__c = 'ME1A';
		    manualAhUser.Status__c = 'A';
		    insert manualAhUser;

		    User manualRmUser2 = Mockup_Test.newUser(
		            targetFirstName2,
			    	targetLastName2,
		            true,
		            targetFirstName2 +'@mail.com',
		            targetFirstName2 +'@mail.com',
		            targetFirstName2.substring(0, 4),
		            rmProfile.Id,
		            null,
		            manualAhUser.Id,
		            'MANUAL_MOCK002'
		    );
		    manualRmUser2.RC_Code__c = userRcCode2;
		    manualRmUser2.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
		    manualRmUser2.Job_Code__c = 'ME1A';
		    manualRmUser2.Status__c = 'A';
		    insert manualRmUser2;

		Test.stopTest();

		Team_Structure__c tempTs = [SELECT Id,Name FROM Team_Structure__c WHERE External_ID__c =:userRcCode1];

		System.runAs(userRM){	
			Master_Map__c mapObject = new Master_Map__c(
				Code__c = '77667',
				Type__c = 'test type'
			);
			insert mapObject;
			Customer_Ownership_Request__c customerRequestNew = new Customer_Ownership_Request__c(
				CIS_ID__c = releaseAccount.Id,
				Request_Type__c = GlobalConstants.RELEASE_OWNERSHIP,
				Refer_Out_Reason__c = GlobalConstants.REASON_WRONG_AREA,
				Not_SME_Segment_Flag__c = false,
				Refer_Out_Segment__c = 'ME',
				Reason__c = 'reason',
				Refer_Out_Team__c = tempTs.Name,
				Refer_Out_Area__c = mapObject.Id
			);
			insert customerRequestNew;
		}
		Team_Structure__c defaultTs = [SELECT Id,Name FROM Team_Structure__c WHERE External_ID__c =:userRcCode2];
				
		Customer_Ownership_Request__c customerRequest = [SELECT Id,Current_Owner__r.Name FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:releaseAccount.Id LIMIT 1];
		
		customerRequest.Approval_Status__c = 'Approval In Progress';
		customerRequest.Refer_Out_Team__c = defaultTs.Name;
		update customerRequest;		

        Customer_Ownership_Request__c customerRequestResult = [SELECT Id,Current_Owner__r.Name,Current_Owner_TM__r.Name,Current_Owner_AH__r.Name,Current_Owner_NH__r.Name FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:releaseAccount.Id LIMIT 1];
		
        System.assertEquals(expectedOwnerNameResult,customerRequestResult.Current_Owner__r.Name);
        System.assertEquals(expectedOwnerNameResult,customerRequestResult.Current_Owner_TM__r.Name);
        System.assertEquals(null,customerRequestResult.Current_Owner_AH__r.Name);
        System.assertEquals(null,customerRequestResult.Current_Owner_NH__r.Name);
	}

	//@isTest static void changeOwnerWhenApproved2(){
	//	User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1];
	//	User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
	//	User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];
	//	Account targetAccount = [SELECT Id,Delete_Flag__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameTM LIMIT 1];
	//	System.runAs(userAH){
	//		Mockup_Test.newCustomerRequest(targetAccount.Id,'Pending',userRM.Id,GlobalConstants.REQUEST_OWNERSHIP, GlobalConstants.PORT);
	//		Customer_Ownership_Request__c customerRequest = [SELECT Id FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:targetAccount.Id LIMIT 1];
	//		Year_End_Assignment__c yearEnd = new Year_End_Assignment__c();
	//		yearEnd.CIS_ID_Unique__c = [SELECT Id,Name FROM Account WHERE Name=:accountNameTM][0].Name;
 //   		yearEnd.CIS_ID__c = [SELECT Id FROM Account WHERE Name=:accountNameTM][0].Id;
	//		insert yearEnd;

	//		Test.startTest();
	//			customerRequest.Approval_Status__c = GlobalConstants.APPROVED;
	//			customerRequest.Year_End_Assignment__c = yearEnd.Id;
	//			customerRequest.Requestor_AH__c = userAH.Id;
	//			update customerRequest;
	//		Test.stopTest();
		
	//		Customer_Ownership_Request__c customerOwnerReq = [SELECT Requestor_AH__c FROM Customer_Ownership_Request__c WHERE Year_End_Assignment__c = :yearEnd.Id LIMIT 1];
	//		Year_End_Assignment__c finalYE = [SELECT Id, OwnerId FROM Year_End_Assignment__c LIMIT 1][0];
	//        Account finalAccount = [SELECT Id,Delete_Flag__c,OwnerId,Previous_Owner__c,Port_Pool__c FROM Account WHERE Name = :CustomerOwnershipRequest_Test.accountNameTM LIMIT 1];
	//        //System.assertEquals(userRM.Id,finalAccount.OwnerId);
	//        //System.assertEquals(userTM.Id,finalAccount.Previous_Owner__c);
	//        System.assertEquals(finalYE.OwnerId, customerOwnerReq.Requestor_AH__c);
	//	}
	//}
}