/**
* @author komsan.wi@beryl8.com
* @05/10/2015 createddate
*/
@isTest
private class YearEndAssignment_ListView_Test {
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
        Integer pagesize = 150;
        YearEndAssignment_ListView_Controller yearController = new YearEndAssignment_ListView_Controller();
        insert new Year_End_Config__c(
        	Page_Size__c = pagesize
        );
        System.assertEquals(yearController.rows, pagesize);
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccountWithContact(accountNameTM,contactNameTM,lastNameTM,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
            System.assertEquals(yearController.getSelectedResource(), yearController.staticPrefix + '_tmnewer');
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccountWithContact(accountNameRM,contactNameRM,lastNameRM,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
            System.assertEquals(yearController.getSelectedResource(), yearController.staticPrefix + '_rmnew');
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccountWithContact(accountNameAH,contactNameAH,lastNameAH,'Pool',Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
            System.assertEquals(yearController.getSelectedResource(), yearController.staticPrefix + '_ahnew');
        }
    }
    static testMethod void staticMethod(){
    	YearEndAssignment_ListView_Controller yearController = new YearEndAssignment_ListView_Controller();
    	System.assertNotEquals('', yearController.getSelectedCountFields());
    	System.assertNotEquals('', yearController.getCustomerOwnerRequestFields());
    	System.assertNotEquals('', yearController.getYearEndFields());
    	System.assertNotEquals('', yearController.getYearEndSelFields());

        System.assertNotEquals('', yearController.getCustomerOwnerRequestFieldsForDes());
        System.assertNotEquals('', yearController.getYearEndFieldsForDes());
        System.assertNotEquals('', yearController.getYearEndSelFieldsForDes());
        System.assertNotEquals('', yearController.userLowerSet);
        System.assertNotEquals('', yearController.empId);
        System.assertNotEquals('', yearController.rcCode);

        YearEndModel.SavingResponse se = new YearEndModel.SavingResponse();
        YearEndModel.CRUDResponse ce = new YearEndModel.CRUDResponse();
        YearEndModel.Picklist pt = new YearEndModel.Picklist('','');
        YearEndModel.PicklistResponse pe = new YearEndModel.PicklistResponse();
        YearEndModel.ReferOut rt = new YearEndModel.ReferOut();
        YearEndModel.SelectedName sme = new YearEndModel.SelectedName();
        YearEndModel.SavingRequest st = new YearEndModel.SavingRequest();
        YearEndModel.QueryObj qj = new YearEndModel.QueryObj();
        YearEndModel.QueryPickListObj qjm = new YearEndModel.QueryPickListObj();
        YearEndModel.FieldInfo fo = new YearEndModel.FieldInfo();

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){

			List<YearEndModel.FieldInfo> yearInfoList = YearEndAssignment_ListView_Controller.describeFields('Year_End_Assignment__c',new List<String>{'Id'});
			System.assertNotEquals(0, yearInfoList.size());
		}
    }
    @isTest static void testPicklist(){
    	YearEndAssignment_ListView_Controller yearController = new YearEndAssignment_ListView_Controller();

    	Year_End_Assignment__c yearObj = new Year_End_Assignment__c(
            Status__c = GlobalConstants.STATUS_NEW,
            CIS_ID_Unique__c = [SELECT Id,Name FROM Account WHERE Name=:accountNameTM][0].Name,
    		CIS_ID__c = [SELECT Id FROM Account WHERE Name=:accountNameTM][0].Id,
			Owner_Employee_ID__c = [SELECT Id,Employee_ID__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0].Employee_ID__c
    	);
		insert yearObj;

		Year_End_Assignment__c yearQueryObj = new Year_End_Assignment__c();
		yearQueryObj = [SELECT Id,OwnerId FROM Year_End_Assignment__c WHERE Id=:yearObj.Id LIMIT 1];

		System.assert(yearQueryObj!=null);
		System.assertEquals([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0].Id, yearQueryObj.OwnerId);

		System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){

            List<String> yearFieldList = new List<String>();
            String[] yearEndFieldArray = yearController.getYearEndFieldsForDes().split(',');

            for(Integer i =0,yearEndSize = yearEndFieldArray.size(); i < yearEndSize; ++i)
                yearFieldList.add(yearEndFieldArray[i]);

            Map<String,String> resultMap = YearEndAssignment_ListView_Controller.describeMapFields('Year_End_Assignment__c', yearFieldList);

            System.assert(resultMap.size() > 0);

			YearEndModel.QueryObj qo = new YearEndModel.QueryObj();
			qo.sobjname = 'Year_End_Assignment__c';
        	qo.fields = yearController.getYearEndFields();
        	qo.filter = new List<Map<String, String>>{new Map<String, String>{'property'=>'Id !','value'=>'null'}};
        	qo.start = 0;
        	qo.recordCount = 10;
        	qo.sortParams = new List<Map<String, String>>{new Map<String, String>{'property'=>'Id','direction'=>'ASC'}};

			YearEndModel.CRUDResponse yearResults = YearEndAssignment_ListView_Controller.query(qo);
			System.assertEquals(true,yearResults.success);
			System.assertEquals(1,yearResults.records.size());
			System.assertEquals(1,yearResults.total);

            YearEndModel.QueryPickListObj qpo = new YearEndModel.QueryPickListObj();
            qpo.scope = 'Status__c';

            YearEndModel.PicklistResponse picklistResults = YearEndAssignment_ListView_Controller.queryPicklist(qpo);

            System.assertEquals(true,picklistResults.success);
            System.assert(picklistResults.records.size()>0);
            System.assertEquals(null,picklistResults.total);

			YearEndModel.QueryPickListObj qplo = new YearEndModel.QueryPickListObj();
			qplo.scope = 'Province';

			YearEndModel.PicklistResponse picklistLoResults = YearEndAssignment_ListView_Controller.queryLocation(qplo);
			System.assertEquals(true,picklistLoResults.success);
			System.assertEquals(0,picklistLoResults.records.size());
			System.assertEquals(null,picklistLoResults.total);

            YearEndModel.QueryPickListObj qpoBy = new YearEndModel.QueryPickListObj();
            qpoBy.scope = Mockup_Test.RC_CODE;

            YearEndModel.PicklistResponse picklistByResults = YearEndAssignment_ListView_Controller.querySelectedBy(qpoBy);
            System.assertEquals(true,picklistByResults.success);
            System.assertNotEquals(0,picklistByResults.records.size());
            System.assertEquals(null,picklistByResults.total);

            YearEndModel.QueryPickListObj qpoByRM = new YearEndModel.QueryPickListObj();
            qpoByRM.scope = Mockup_Test.RC_CODE;

            YearEndModel.PicklistResponse picklistByRMResults = YearEndAssignment_ListView_Controller.querySelectedByOnlyRM(qpoByRM);
            System.assertEquals(true,picklistByRMResults.success);
            System.assertNotEquals(0,picklistByRMResults.records.size());
            System.assertEquals(null,picklistByRMResults.total);
		}
    }
    @isTest static void testAsAH(){
        YearEndAssignment_ListView_Controller yearController = new YearEndAssignment_ListView_Controller();

        Year_End_Assignment__c yearObj = new Year_End_Assignment__c(
            Status__c = GlobalConstants.STATUS_NEW,
            CIS_ID_Unique__c = [SELECT Id,Name FROM Account WHERE Name=:accountNameAH][0].Name,
            CIS_ID__c = [SELECT Id FROM Account WHERE Name=:accountNameAH][0].Id,
            Owner_Employee_ID__c = [SELECT Id,Employee_ID__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0].Employee_ID__c
        );
        insert yearObj;

        Year_End_Assignment__c yearQueryObj = new Year_End_Assignment__c();
        yearQueryObj = [SELECT Id,OwnerId FROM Year_End_Assignment__c WHERE Id=:yearObj.Id LIMIT 1];

        System.assert(yearQueryObj!=null);
        System.assertEquals([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0].Id, yearQueryObj.OwnerId);

        User userTM = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){

            //#1 try to submitted
            YearEndModel.SavingRequest sr = new YearEndModel.SavingRequest();
            sr.contx = 'SUBMITTED';

            YearEndModel.SavingResponse srs = YearEndAssignment_ListView_Controller.saveYearEnd(sr);
            System.assertEquals(false,srs.success);
            System.assertEquals(Label.YearEnd_TheListisnotcompleted_cannotsubmit,srs.errorMessage);

            //#2 select and confirm
            sr = new YearEndModel.SavingRequest();
            sr.contx = 'REFER_OUTCONFIRM';
            sr.referOut = new YearEndModel.ReferOut();
            sr.referOut.referoutReason = GlobalConstants.BAD;
            sr.selectName = new YearEndModel.SelectedName();
            sr.selectName.selectedbyNamepanel = userTM.Id;
            sr.yearlist = new List<String>{yearObj.Id};

            srs = YearEndAssignment_ListView_Controller.saveYearEnd(sr);
            System.assertEquals(true,srs.success);

            Year_End_Assignment_Selection__c yearQuerySelObj = new Year_End_Assignment_Selection__c();

            yearQuerySelObj = [SELECT Id,Year_End_Assignment__c,Selected_By__c,Refer_Out_Reason__c,Refer_Out__c FROM Year_End_Assignment_Selection__c WHERE Year_End_Assignment__c=:yearObj.Id LIMIT 1];
            System.assert(yearQuerySelObj!=null);

            System.assertEquals(userTM.Id,yearQuerySelObj.Selected_By__c);
            System.assertEquals(GlobalConstants.BAD,yearQuerySelObj.Refer_Out_Reason__c);
            System.assertEquals(true,yearQuerySelObj.Refer_Out__c);

            yearQueryObj = [SELECT Id,Final_Assigned_RM__c,Final_Refer_Out__c FROM Year_End_Assignment__c WHERE Id=:yearObj.Id LIMIT 1];
            System.assertEquals(userTM.Id,yearQueryObj.Final_Assigned_RM__c);

            //#3 Submmit all
            sr = new YearEndModel.SavingRequest();
            sr.contx = 'SUBMITTED';

            srs = YearEndAssignment_ListView_Controller.saveYearEnd(sr);
            System.assertEquals(true,srs.success);

            Year_End_Assignment__c yearQueryObjResult = [SELECT Id,Status__c,Final_Assigned_RM__c,Final_Refer_Out__c FROM Year_End_Assignment__c WHERE Id=:yearObj.Id LIMIT 1];

            System.assertEquals(GlobalConstants.SUBMITTED ,yearQueryObjResult.Status__c);
        }
    }
    @isTest static void testAsTM(){
        YearEndAssignment_ListView_Controller yearController = new YearEndAssignment_ListView_Controller();

        Year_End_Assignment__c yearObj = new Year_End_Assignment__c(
            Status__c = GlobalConstants.STATUS_NEW,
            CIS_ID_Unique__c = [SELECT Id,Name FROM Account WHERE Name=:accountNameTM][0].Name,
            CIS_ID__c = [SELECT Id FROM Account WHERE Name=:accountNameTM][0].Id,
            Owner_Employee_ID__c = [SELECT Id,Employee_ID__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0].Employee_ID__c
        );
        insert yearObj;

        Year_End_Assignment__c yearQueryObj = new Year_End_Assignment__c();
        yearQueryObj = [SELECT Id,OwnerId FROM Year_End_Assignment__c WHERE Id=:yearObj.Id LIMIT 1];

        System.assert(yearQueryObj!=null);
        System.assertEquals([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0].Id, yearQueryObj.OwnerId);

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){

            //#1 select and confirm
            YearEndModel.SavingRequest sr = new YearEndModel.SavingRequest();
            sr.contx = 'SELECTEDCONFIRM';
            sr.yearlist = new List<String>{yearObj.Id};
            YearEndModel.SavingResponse srs = YearEndAssignment_ListView_Controller.saveYearEnd(sr);
            System.assertEquals(true,srs.success);

            Year_End_Assignment_Selection__c yearQuerySelObj = new Year_End_Assignment_Selection__c();
            yearQuerySelObj = [SELECT Id,Year_End_Assignment__c,Selected_By__c,Refer_Out__c FROM Year_End_Assignment_Selection__c WHERE Year_End_Assignment__c=:yearObj.Id LIMIT 1];
            System.assert(yearQuerySelObj!=null);
            System.assertEquals(UserInfo.getUserId(),yearQuerySelObj.Selected_By__c);
            System.assertEquals(false,yearQuerySelObj.Refer_Out__c);

            yearQueryObj = [SELECT Id,Final_Assigned_RM__c FROM Year_End_Assignment__c WHERE Id=:yearObj.Id LIMIT 1];
            System.assertEquals(UserInfo.getUserId(),yearQueryObj.Final_Assigned_RM__c);

            //#2 remove confirmation
            sr = new YearEndModel.SavingRequest();
            sr.yearlist = new List<String>{yearQuerySelObj.Id};
            sr.deleteFinalAssign = true;

            srs = YearEndAssignment_ListView_Controller.deleteYearEndSel(sr);
            System.assertEquals(true,srs.success);

            yearQuerySelObj = [SELECT Id,Year_End_Assignment__c FROM Year_End_Assignment_Selection__c WHERE Year_End_Assignment__c=:yearObj.Id LIMIT 1];
            System.assert(yearQuerySelObj!=null);

            yearQueryObj = [SELECT Id,Final_Assigned_RM__c FROM Year_End_Assignment__c WHERE Id=:yearObj.Id LIMIT 1];
            System.assertEquals(null,yearQueryObj.Final_Assigned_RM__c);

            //#3 remove selection
            sr = new YearEndModel.SavingRequest();
            sr.yearlist = new List<String>{yearQuerySelObj.Id};

            srs = YearEndAssignment_ListView_Controller.deleteYearEndSel(sr);
            System.assertEquals(true,srs.success);

            Integer countYearQuerySelObj = [SELECT count() FROM Year_End_Assignment_Selection__c WHERE Year_End_Assignment__c=:yearObj.Id];
            System.assertEquals(0,countYearQuerySelObj);

            yearQueryObj = [SELECT Id,Final_Assigned_RM__c FROM Year_End_Assignment__c WHERE Id=:yearObj.Id LIMIT 1];
            System.assertEquals(null,yearQueryObj.Final_Assigned_RM__c);

            //#4 duplicate case
            sr = new YearEndModel.SavingRequest();
            sr.yearlist = new List<String>{yearQuerySelObj.Id};

            srs = YearEndAssignment_ListView_Controller.deleteYearEndSel(sr);
            System.assertEquals(false,srs.success);
            System.assertEquals(false,srs.duplicate);
            System.assertEquals(Label.Cannotprocessyourrequest,srs.errorMessage);
        }
    }
    @isTest static void testAsRM(){
        YearEndAssignment_ListView_Controller yearController = new YearEndAssignment_ListView_Controller();

        Year_End_Assignment__c yearObj = new Year_End_Assignment__c(
            Status__c = GlobalConstants.STATUS_NEW,
            CIS_ID_Unique__c = [SELECT Id,Name FROM Account WHERE Name=:accountNameRM][0].Name,
            CIS_ID__c = [SELECT Id FROM Account WHERE Name=:accountNameRM][0].Id,
            Owner_Employee_ID__c = [SELECT Id,Employee_ID__c FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0].Employee_ID__c
        );
        insert yearObj;

        Year_End_Assignment__c yearQueryObj = new Year_End_Assignment__c();
        yearQueryObj = [SELECT Id,OwnerId FROM Year_End_Assignment__c WHERE Id=:yearObj.Id LIMIT 1];

        System.assert(yearQueryObj!=null);
        System.assertEquals([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0].Id, yearQueryObj.OwnerId);

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){

            //#1 select
            YearEndModel.SavingRequest sr = new YearEndModel.SavingRequest();
            sr.contx = 'SELECTED';
            sr.yearlist = new List<String>{yearObj.Id};
            YearEndModel.SavingResponse srs = YearEndAssignment_ListView_Controller.saveYearEnd(sr);
            System.assertEquals(true,srs.success);

            Year_End_Assignment_Selection__c yearQuerySelObj = new Year_End_Assignment_Selection__c();
            yearQuerySelObj = [SELECT Id,Year_End_Assignment__c FROM Year_End_Assignment_Selection__c WHERE Year_End_Assignment__c=:yearObj.Id LIMIT 1];
            System.assert(yearQuerySelObj!=null);

            yearQueryObj = [SELECT Id,Final_Assigned_RM__c FROM Year_End_Assignment__c WHERE Id=:yearObj.Id LIMIT 1];
            System.assertEquals(null,yearQueryObj.Final_Assigned_RM__c);

            //#2 remove selection
            sr = new YearEndModel.SavingRequest();
            sr.yearlist = new List<String>{yearQuerySelObj.Id};

            srs = YearEndAssignment_ListView_Controller.deleteYearEndSel(sr);
            System.assertEquals(true,srs.success);

            Integer countYearQuerySelObj = [SELECT count() FROM Year_End_Assignment_Selection__c WHERE Year_End_Assignment__c=:yearObj.Id];
            System.assertEquals(0,countYearQuerySelObj);

            yearQueryObj = [SELECT Id,Final_Assigned_RM__c FROM Year_End_Assignment__c WHERE Id=:yearObj.Id LIMIT 1];
            System.assertEquals(null,yearQueryObj.Final_Assigned_RM__c);

            //#3 refer out
            sr = new YearEndModel.SavingRequest();
            sr.contx = 'REFER_OUT';
            sr.referOut = new YearEndModel.ReferOut();
            sr.referOut.referoutReason = GlobalConstants.BAD;
            sr.yearlist = new List<String>{yearObj.Id};
            srs = YearEndAssignment_ListView_Controller.saveYearEnd(sr);
            System.assertEquals(true,srs.success);

            yearQuerySelObj = new Year_End_Assignment_Selection__c();

            yearQuerySelObj = [SELECT Id,Year_End_Assignment__c,Selected_By__c,Refer_Out_Reason__c,Refer_Out__c FROM Year_End_Assignment_Selection__c WHERE Year_End_Assignment__c=:yearObj.Id LIMIT 1];
            System.assert(yearQuerySelObj!=null);

            System.assertEquals(UserInfo.getUserId(),yearQuerySelObj.Selected_By__c);
            System.assertEquals(GlobalConstants.BAD,yearQuerySelObj.Refer_Out_Reason__c);
            System.assertEquals(true,yearQuerySelObj.Refer_Out__c);

            yearQueryObj = [SELECT Id,Final_Assigned_RM__c FROM Year_End_Assignment__c WHERE Id=:yearObj.Id LIMIT 1];
            System.assertEquals(null,yearQueryObj.Final_Assigned_RM__c);
        }
        //#4 login tm to confirm
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            Year_End_Assignment_Selection__c yearQuerySelObjtm = [SELECT Id,Year_End_Assignment__c,Selected_By__c,Refer_Out_Reason__c,Refer_Out__c FROM Year_End_Assignment_Selection__c WHERE Year_End_Assignment__c=:yearObj.Id LIMIT 1];

            YearEndModel.SavingRequest srtm = new YearEndModel.SavingRequest();
            srtm.contx = 'CONFIRM';
            srtm.yearlist = new List<String>{yearQuerySelObjtm.Id};
            YearEndModel.SavingResponse srstm = YearEndAssignment_ListView_Controller.saveYearEnd(srtm);
            System.assertEquals(true,srstm.success);

            yearQueryObj = [SELECT Id,Final_Assigned_RM__c,Final_Refer_Out__c FROM Year_End_Assignment__c WHERE Id=:yearObj.Id LIMIT 1];

            System.assertEquals([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0].Id,yearQueryObj.Final_Assigned_RM__c);
            System.assertEquals(true,yearQueryObj.Final_Refer_Out__c);
        }
    }
}