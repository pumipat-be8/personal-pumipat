@isTest
private class Opportunity_Test {
	public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';

	@testSetup static void setupUser(){
		Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            Opportunity_Test.setUpUW();
        }
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

	static testMethod void updateRunningNumber(){

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){

			Account testAcc = [SELECT Id, RC_Code__c FROM Account WHERE Name = :Opportunity_Test.accountNameRM LIMIT 1];

			Opportunity opp1 = Mockup_Test.newOpportunity(testAcc.Id, 'Tester1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
			insert opp1;		

			Application_Number__c appNumber = [SELECT Name, Running_Number__c, Year__c FROM Application_Number__c WHERE Name = :testAcc.RC_Code__c LIMIT 1];

			System.assertEquals(1, appNumber.Running_Number__c);

			Opportunity opp2 = [SELECT Id FROM Opportunity WHERE Id = :opp1.Id LIMIT 1];

			opp2.StageName = GlobalConstants.CREATE_WRITE_UP;
			opp2.Name = 'Tester1';
			opp2.Credit_Model__c = 'DLA';
			opp2.Submission_Channel__c = GlobalConstants.NON_CMAS;
			opp2.Submit_Issue__c = 'New Credit';
			opp2.Amount = 22;
			opp2.AccountId = testAcc.Id;
			opp2.CloseDate = System.today()+7;
			opp2.Tentative_Application_Submit_Date__c = System.today() + 7;
			opp2.APP2__c = null;

			update opp2;

			Application_Number__c finalAppNumber = [SELECT Name, Running_Number__c, Year__c FROM Application_Number__c WHERE Name = :testAcc.RC_Code__c LIMIT 1];

			System.assertEquals(2, finalAppNumber.Running_Number__c);
		}

	}

	static testMethod void targetStatusBaseOnStageName() {

		//User targetAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		Account testAcc = [SELECT Id, OwnerId FROM Account WHERE Name = :Opportunity_Test.accountNameRM LIMIT 1];
		////testAcc.OwnerId = UserInfo.getUserId();
		////update testAcc;
		//System.assertEquals(targetAH.Id, testAcc.OwnerId);
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            Campaign camp = Mockup_Test.newCampaign(UserInfo.getUserId(),'CampanignTest', System.now(), System.now().addDays(1), System.now().addDays(-1), GlobalConstants.ACTIVE, GlobalConstants.SME_EVENT, GlobalConstants.LEAD_FOR_SALES);
            insert camp;

			Target_List__c target = new Target_List__c();
			target.Lead_Campaign__c = camp.Id;
			target.CIS_ID_Prospect_Name__c = testAcc.Id;
			insert target;

			Call_Report__c callRep = new Call_Report__c();
			callRep.CIS_ID__c = testAcc.Id;
			insert callRep;
			
			Call_Report_Lead__c callLead = new Call_Report_Lead__c();
			callLead.Call_Plan_Call_Report__c = callRep.Id;
			callLead.Target_List__c = target.Id;
			insert callLead;

			Opportunity opp1 = Mockup_Test.newOpportunity(testAcc.Id, 'OppTest1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
			insert opp1;

			Opportunity_Lead__c oppLead = new Opportunity_Lead__c();
			oppLead.Target_List__c = target.Id;
			oppLead.Opportunity__c = opp1.Id;
			//oppLead.Type__c = GlobalConstants.LEAD_FOR_SALES;

			insert oppLead;
		}

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){

			Test.startTest();
				Opportunity updateOpp = [SELECT Id FROM Opportunity WHERE Name = 'OppTest1' LIMIT 1];
				updateOpp.StageName = GlobalConstants.STOCK_NEGOTIATION;
			
				update updateOpp;

				Target_List__c finalTarget = [SELECT Id, Status__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :testAcc.Id LIMIT 1];
				System.assertEquals(GlobalConstants.CUSTOMER_INTERESTED ,finalTarget.Status__c);

				Opportunity updateOpp2 = [SELECT Id FROM Opportunity WHERE Name = 'OppTest1' LIMIT 1];
				updateOpp2.StageName = GlobalConstants.WAITING_FOR_CREDIT_APPROVAL;

				update updateOpp2;
			Test.stopTest();
		}

		Target_List__c finalTarget2 = [SELECT Id, Status__c FROM Target_List__c WHERE CIS_ID_Prospect_Name__c = :testAcc.Id LIMIT 1];
		System.assertEquals(GlobalConstants.APP_IN ,finalTarget2.Status__c);
	}

	static testMethod void testInsertNoBU(){
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
    	userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
        userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
        userRM.Segment__c = 'ME';
        update userRM;

        Account targetAccount = [SELECT Id, RC_Code__c FROM Account WHERE Name = :Opportunity_Test.accountNameRM LIMIT 1];

		System.runAs(userRM){

			Opportunity opp1 = Mockup_Test.newOpportunity(targetAccount.Id, 'TestUW1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
			Test.startTest();
			insert opp1;	
			Test.stopTest();
		}

		UW_Area__c finalExpectedUW = [SELECT Id,Head_of_UW_Name__c,Senior_UW_Name__c FROM UW_Area__c WHERE RC_Code__c = :Mockup_Test.AH_RC_CODE LIMIT 1];

		Opportunity finalOpp = [SELECT Id, Head_of_UW_Name__c, Senior_UW_Name__c FROM Opportunity WHERE AccountId = :targetAccount.Id AND Name = 'TestUW1'];
        System.assertEquals(finalExpectedUW.Head_of_UW_Name__c, finalOpp.Head_of_UW_Name__c);
        System.assertEquals(finalExpectedUW.Senior_UW_Name__c, finalOpp.Senior_UW_Name__c);
	}

	static testMethod void testInsertWithBU(){
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
    	userRM.AH_RC_Code__c = Mockup_Test.AH_RC_CODE;
        userRM.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
        userRM.Segment__c = 'ME';
        update userRM;

		System.runAs(userRM){
			Account targetAccount = [SELECT Id, RC_Code__c FROM Account WHERE Name = :Opportunity_Test.accountNameRM LIMIT 1];
	        targetAccount.Customer_s_Business_Code__c = '111111';
	    	update targetAccount;

			Opportunity opp1 = Mockup_Test.newOpportunity(targetAccount.Id, 'TestUW1', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS);
			Test.startTest();
			insert opp1;	
			Test.stopTest();
		}
		Business_Code__c buCode = [SELECT Name FROM Business_Code__c WHERE Name = '111111' LIMIT 1];
		UW_Business_Area__c finalExpectedUW = [SELECT Id,Head_of_UW_Name__c,Senior_UW_Name__c FROM UW_Business_Area__c WHERE Business_Code__c = :buCode.Id AND RC_Code__c = :Mockup_Test.AH_RC_CODE LIMIT 1];

		Opportunity finalOpp = [SELECT Id, Head_of_UW_Name__c, Senior_UW_Name__c FROM Opportunity WHERE Name = 'TestUW1'];
        System.assertEquals(finalExpectedUW.Head_of_UW_Name__c, finalOpp.Head_of_UW_Name__c);
        System.assertEquals(finalExpectedUW.Senior_UW_Name__c, finalOpp.Senior_UW_Name__c);
	}

	static testMethod void testCloseWon(){
		User userRM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
		Account targetAccount = [SELECT Id, RC_Code__c FROM Account WHERE Name = :accountNameTM LIMIT 1];
		System.runAs(userRM){
			Opportunity targetOpp = Mockup_Test.newOpportunity(targetAccount.Id, 'TestOPP1', 'Waiting for Credit Setup', GlobalConstants.NON_CMAS);
			insert targetOpp;

			Opportunity_Product__c oppProduct = new Opportunity_Product__c();
			oppProduct.Opportunity__c = targetOpp.Id;
			oppProduct.Status__c = 'Setup';
            oppProduct.Front_End_Fee__c = 0;
            oppProduct.BA_Prosaving__c = 10.0;
            oppProduct.BA_Protection__c = 10.0;
            oppProduct.Setup_Amount__c = 10000;
            oppProduct.Product__c = 'ตั้งวงเงินทั้งหมดในครั้งแรก';
            oppProduct.Setup_Date__c = System.today();
            insert oppProduct;

			Test.startTest();
				Opportunity oppObj = [SELECT Id FROM Opportunity WHERE Id = :targetOpp.Id];
	            oppObj.IsCloseWon__c = true;
	            oppObj.Actual_Visit_Date__c = System.today();
	            oppObj.Approval_Status__c = 'Final Approve';
	            oppObj.Amount = 1000000;
	            oppObj.StageName = GlobalConstants.ALL_LOAN_SETUP;
	            Account_OwnerChange_Service.triggerInitialCall = false;
				update oppObj;
			Test.stopTest();
		}
		System.assertEquals(1,[SELECT Count() FROM Opportunity WHERE Name = 'TestOPP1']);
		Opportunity finalOpp = [SELECT Id, StageName, OwnerId, Port_Pool__c FROM Opportunity WHERE Name = 'TestOPP1'];
		System.assertEquals(GlobalConstants.ALL_LOAN_SETUP, finalOpp.StageName);
		System.assertEquals(userRM.Id, finalOpp.OwnerId);
		System.assertEquals(GlobalConstants.ALL_LOAN_SETUP, finalOpp.StageName);
		System.assertEquals(GlobalConstants.PORT, finalOpp.Port_Pool__c);

		Account finalAccount = [SELECT Id, Port_Pool__c, Ownership_Text__c FROM Account WHERE Name = :accountNameTM LIMIT 1];
		System.assertEquals(GlobalConstants.OWNERSHIP_PERMANENT, finalAccount.Ownership_Text__c);
		System.assertEquals(GlobalConstants.PORT, finalAccount.Port_Pool__c);
	
	}

	@isTest static void testTrashPoolFlagWhenCreateOpportunity(){
		TriggerHandler.bypass('AccountTriggerHandler');
        Account customer = [SELECT Id, Name, Trash_Pool_Flag__c FROM Account WHERE Name =: accountNameRM];
        customer.Trash_Pool_Flag__c = true;
        update customer;
        TriggerHandler.clearByPass('AccountTriggerHandler');
        customer = [SELECT Id, Trash_Pool_Flag__c FROM Account WHERE Id =: customer.Id];
        System.assertEquals(true,customer.Trash_Pool_Flag__c);

        Opportunity opportunity = Mockup_Test.newOpportunity(customer.Id, 'TestOPP1', 'Waiting for Credit Setup', GlobalConstants.NON_CMAS);
        

        Test.startTest();
        insert opportunity;
        Test.stopTest();

        customer = [SELECT Id, Trash_Pool_Flag__c FROM Account WHERE Id =: customer.Id];
        System.assertEquals(false,customer.Trash_Pool_Flag__c);

	}

	@isTest static void testLatestStageModifiedDateWhenChangeStage(){
		TriggerHandler.bypass('AccountTriggerHandler');
        Account customer = [SELECT Id, Name, Trash_Pool_Flag__c FROM Account WHERE Name =: accountNameRM];
        customer.Trash_Pool_Flag__c = true;
        update customer;
        TriggerHandler.clearByPass('AccountTriggerHandler');
        
        Opportunity opportunity = Mockup_Test.newOpportunity(customer.Id, 'TestOPP1', 'Waiting for Credit Setup', GlobalConstants.NON_CMAS);
        insert opportunity;

        opportunity = [SELECT Id, Previous_Stage__c, Latest_Stage_Modified_Date__c FROM Opportunity WHERE Name = 'TestOPP1'];
        System.assertEquals(null,opportunity.Latest_Stage_Modified_Date__c);

        opportunity.StageName = 'Stock Negotiation';
        Test.startTest();
        Date dateTest = System.today();
        update opportunity;
        Test.stopTest();


        opportunity = [SELECT Id, Previous_Stage__c, Latest_Stage_Modified_Date__c FROM Opportunity WHERE Name = 'TestOPP1'];
        System.assertEquals(dateTest.day(),opportunity.Latest_Stage_Modified_Date__c.day());
        System.assertEquals(dateTest.month(),opportunity.Latest_Stage_Modified_Date__c.month());
        System.assertEquals(dateTest.year(),opportunity.Latest_Stage_Modified_Date__c.year());

	}

	@isTest static void testPreviousStageWhenChangeStage(){
		TriggerHandler.bypass('AccountTriggerHandler');
        Account customer = [SELECT Id, Name, Trash_Pool_Flag__c FROM Account WHERE Name =: accountNameRM];
        customer.Trash_Pool_Flag__c = true;
        update customer;
        TriggerHandler.clearByPass('AccountTriggerHandler');
        
        Opportunity opportunity = Mockup_Test.newOpportunity(customer.Id, 'TestOPP1', 'Waiting for Credit Setup', GlobalConstants.NON_CMAS);
        insert opportunity;

        opportunity = [SELECT Id, Previous_Stage__c FROM Opportunity WHERE Name = 'TestOPP1'];
		System.assertEquals(null,opportunity.Previous_Stage__c);

        opportunity.StageName = 'Stock Negotiation';

		Test.startTest();
        update opportunity;
        Test.stopTest();

        opportunity = [SELECT Id, Previous_Stage__c FROM Opportunity WHERE Name = 'TestOPP1'];

        System.assertEquals('Waiting for Credit Setup',opportunity.Previous_Stage__c);
	}

	@isTest static void testPreviousRecordTypeWhenChangeStage(){
		TriggerHandler.bypass('AccountTriggerHandler');
        Account customer = [SELECT Id, Name, Trash_Pool_Flag__c FROM Account WHERE Name =: accountNameRM];
        customer.Trash_Pool_Flag__c = true;
        update customer;
        TriggerHandler.clearByPass('AccountTriggerHandler');
        
        Opportunity opportunity = Mockup_Test.newOpportunity(customer.Id, 'TestOPP1', 'Waiting for Credit Setup', GlobalConstants.NON_CMAS);
        opportunity.RecordTypeId = GlobalUtility.getRecordTypeOpportunityIdByName('Credit Opportunity');
        insert opportunity;

        opportunity = [SELECT Id, Previous_Stage__c FROM Opportunity WHERE Name = 'TestOPP1'];
		System.assertEquals(null,opportunity.Previous_Stage__c);

        opportunity.StageName = 'Stock Negotiation';
        opportunity.RecordTypeId = GlobalUtility.getRecordTypeOpportunityIdByName('Closed - Credit Opportunity');

		Test.startTest();
        update opportunity;
        Test.stopTest();

        //fix record type to string for testing assert

        opportunity = [SELECT Id, Previous_Stage__c, Previous_Record_Type__c FROM Opportunity WHERE Name = 'TestOPP1'];
        

        System.assertEquals(GlobalUtility.getRecordTypeOpportunityIdByName('Credit Opportunity'),opportunity.Previous_Record_Type__c);
	}

	@isTest static void testActiveOpportunityInitialBatch(){
		
		Account customer = [SELECT Id, Name FROM Account WHERE Name =: accountNameRM];
        Opportunity opportunityTest = Mockup_Test.newOpportunity(customer.Id, 'TestOPP1', 'Waiting for Credit Setup', GlobalConstants.NON_CMAS);
		insert opportunityTest;

		Id opportunityTestId = opportunityTest.Id;
		Id opportunityLookupAccountId = opportunityTest.AccountId;

		Test.startTest();
		Database.executeBatch(new SME_ActiveOpportunityInitial_Batch());
		Test.stopTest();

		opportunityTest = [SELECT Id, Active_Opportunity__c FROM Opportunity WHERE Id =: opportunityTestId];
		System.assertEquals(opportunityLookupAccountId, opportunityTest.Active_Opportunity__c);
	}

	@isTest static void testCurrentAHWhenInsertingOpportunity(){
		Opportunity opportunityTest;
		Account customer = [SELECT Id, Name FROM Account WHERE Name =: accountNameRM];

        User currentUserRM = [SELECT Id, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
        User currentUserAH = [SELECT Id, ManagerId, Manager.ManagerId FROM User WHERE Id =: currentUserRM.Manager.ManagerId LIMIT 1];
        Test.startTest();
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            opportunityTest = Mockup_Test.newOpportunity(customer.Id, 'TestOPP1', 'Waiting for Credit Setup', GlobalConstants.NON_CMAS);
			insert opportunityTest;
        }
        Test.stopTest();

        opportunityTest = [SELECT Id, Current_AH__c, Current_NH__c, OwnerId FROM Opportunity WHERE Id =: opportunityTest.Id];
		
		System.assertEquals(currentUserAH.Id,opportunityTest.Current_AH__c);
	}
    //Not in use yet
	@isTest static void testCurrentNHWhenInsertingOpportunity(){
		Opportunity opportunityTest;
		Account customer = [SELECT Id, Name, Trash_Pool_Flag__c FROM Account WHERE Name =: accountNameRM];
        User currentUserRM = [SELECT Id, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
        User currentUserNH = [SELECT Id, Employee_ID__c, IsActive FROM User WHERE Id =: currentUserRM.Manager.Manager.ManagerId LIMIT 1];
        currentUserNH.IsActive = true;
        update currentUserNH;

        System.debug('RM NH Id: '+ currentUserNH.Id);

		Test.startTest();
		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            opportunityTest = Mockup_Test.newOpportunity(customer.Id, 'TestOPP1', 'Waiting for Credit Setup', GlobalConstants.NON_CMAS);
			insert opportunityTest;
        }
        Test.stopTest();

        opportunityTest = [SELECT Id, Current_AH__c, Current_NH__c, OwnerId FROM Opportunity WHERE Id =: opportunityTest.Id];
		
		System.assertEquals(currentUserNH.Id,opportunityTest.Current_NH__c);
	}
    
    @isTest static void testCurrentAHAndNHWhenChangeAccountOwnerAssociatedWithOpportunityToTM(){
        
        Opportunity opportunityTest;
        Account customer = [SELECT Id, Name FROM Account WHERE Name =: accountNameRM];
        User currentUserRM = [SELECT Id, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
        User currentUserTM = [SELECT Id, ManagerId, Manager.ManagerId FROM User WHERE Id =: currentUserRM.ManagerId LIMIT 1];
        
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            opportunityTest = Mockup_Test.newOpportunity(customer.Id, 'TestOPP1', 'Waiting for Credit Setup', GlobalConstants.NON_CMAS);
            insert opportunityTest;
        }
        
        opportunityTest = [SELECT Id, Current_AH__c, Current_NH__c, OwnerId FROM Opportunity WHERE Id =: opportunityTest.Id];
        opportunityTest.Current_AH__c = null;
        opportunityTest.Current_NH__c = null;
        update opportunityTest;

        opportunityTest = [SELECT Id, Current_AH__c, Current_NH__c, OwnerId FROM Opportunity WHERE Id =: opportunityTest.Id];
        System.assertEquals(null, opportunityTest.Current_AH__c);
        System.assertEquals(null, opportunityTest.Current_NH__c);

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            customer.OwnerChangeExecutedByTrigger__c = true;
            customer.OwnerId = currentUserTM.Id;
            System.debug('Before update customer');
            Account_OwnerChange_Service.accountTriggerMap = null;
            Test.startTest();
            update customer;
            Test.stopTest();
            System.debug('After update customer');
        }

        opportunityTest = [SELECT Id, Current_AH__c, Current_NH__c, OwnerId FROM Opportunity WHERE Id =: opportunityTest.Id];
        System.assertEquals(currentUserTM.Manager.ManagerId,opportunityTest.Current_NH__c);
        System.assertEquals(currentUserTM.ManagerId,opportunityTest.Current_AH__c);
    }

    @isTest static void testChangeTeamOfOwnerOfOpportunity(){
        Opportunity opportunityTest;
        Account customer = [SELECT Id, Name FROM Account WHERE Name =: accountNameRM];
        User currentUserRM = [SELECT Id, ManagerId, Manager.ManagerId,Manager.Manager.ManagerId FROM User WHERE FirstName =: Mockup_Test.userFirstNameRM];
        User currentUserTM = [SELECT Id, ManagerId, Manager.ManagerId FROM User WHERE Id =: currentUserRM.ManagerId LIMIT 1];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            opportunityTest = Mockup_Test.newOpportunity(customer.Id, 'TestOPP1', 'Waiting for Credit Setup', GlobalConstants.NON_CMAS);
            insert opportunityTest;
        }

        opportunityTest = [SELECT Id, Current_AH__c, Current_NH__c, OwnerId FROM Opportunity WHERE Id =: opportunityTest.Id];
        opportunityTest.Current_AH__c = null;
        opportunityTest.Current_NH__c = null;
        update opportunityTest;

        currentUserRM.RC_Code__c = Mockup_Test.AH_RC_CODE;
        update currentUserRM;

        opportunityTest = [SELECT Id, Current_AH__c, Current_NH__c, OwnerId FROM Opportunity WHERE Id =: opportunityTest.Id];
        System.assertEquals(currentUserTM.ManagerId, opportunityTest.Current_AH__c);
        System.assertEquals(currentUserTM.Manager.ManagerId, opportunityTest.Current_NH__c);
    }
}