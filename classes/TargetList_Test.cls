@isTest
private class TargetList_Test {
    
    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRM = 'rmCreatedAccountName';
    public static String accountNameAH = 'ahCreatedAccountName';
    //Added By Nareerat W. 28/03/2016 CR-006 Test class TargetlistTriggerHandler
    public static string strNewBooking='NEWBOOKING';
    public static string strThankyou='THANKYOU';
    //End Added By Nareerat W. 28/03/2016 CR-006 Test class TargetlistTriggerHandler

    @testSetup static void setupAccount(){
        Mockup_Test mt = new Mockup_Test().setUpTest();

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameTM LIMIT 1][0]){
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1][0]){
            mt.newAccount(accountNameRM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
             //Added By Nareerat W. 28/03/2016 CR-006 Test class TargetlistTriggerHandler
            TargetList_Test.setupCampaign();
            //End Added By Nareerat W. 28/03/2016 CR-006 Test class TargetlistTriggerHandler
        }
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
    }
    
    public static void setupCampaign(){
        /*
         * Created by: Nareerat W.
         * Created date: 28-Mar-2016
         * Description: Prepare Data for CR-006 Test class TargetlistTriggerHandler
        */
            Campaign_Setting__c cSetting = new Campaign_Setting__c();
            cSetting.NewBooking_Code__c= strNewBooking;
            cSetting.ThankYou_Code__c= strThankyou;
            cSetting.Register_Period__c=30;
            insert cSetting;
        
            Campaign CampaignNewBooking = new Campaign();
            CampaignNewBooking.name=strNewBooking;
            CampaignNewBooking.type__c='Campaign';
            CampaignNewBooking.Lead_Campaign_Event_Code__c=strNewBooking;
            CampaignNewBooking.StartDate=system.today();
            CampaignNewBooking.status='Active';
            CampaignNewBooking.IsActive=true;           
            insert CampaignNewBooking;
        
            Campaign CampaignThankyou = new Campaign();
            CampaignThankyou.name=strThankyou;
            CampaignThankyou.type__c='Campaign';
            CampaignThankyou.Lead_Campaign_Event_Code__c=strThankyou;
            CampaignThankyou.StartDate=system.today();
            CampaignThankyou.status='Active';
            CampaignThankyou.IsActive=true;         
            insert CampaignThankyou;
    }

   static testMethod void testUpdateTarget_To_NotRegister() {
        /*
         * Created by: Nareerat W.
         * Created date: 28-Mar-2016
         * Description:  CR-006 Test class TargetlistTriggerHandler
        */
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1][0]) {

            Account testAcc = [SELECT Id FROM Account WHERE Name = :TargetList_Test.accountNameAH LIMIT 1];
            testAcc.OwnerId = UserInfo.getUserId();
            update testAcc;
            
            Opportunity opp1 = Mockup_Test.newOpportunity(testAcc.Id, 'TestNewOpp_3', GlobalConstants.CREATE_WRITE_UP, GlobalConstants.NON_CMAS); 
    
            Test.startTest();           
                insert opp1;
            
                Target_List__c targetNewBook =[SELECT Id, Name, Status__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :strNewBooking and Opportunity__c= :opp1.Id LIMIT 1];
                targetNewBook.Status__c='Registered';
                update targetNewBook;

                opp1.StageName = GlobalConstants.STOCK_NEGOTIATION;         
                update opp1;  
                    
                opp1.Actual_Application_Submit_Date__c=system.today();
                opp1.Actual_RM_Submit_Date__c=system.today();
                opp1.StageName = 'Waiting for Credit Setup';
                update opp1;           
            
                Opportunity_Product__c oppProduct1=new Opportunity_Product__c();
                oppProduct1.Product__c='ตั้งวงเงินทั้งหมดในครั้งแรก';
                oppProduct1.Status__c='Setup';
                oppProduct1.Opportunity__c=opp1.Id;
                oppProduct1.Setup_Amount__c=9000000;
                oppProduct1.Setup_Date__c=system.today();
                oppProduct1.Front_End_Fee__c=1000000;
                oppProduct1.BA_Prosaving__c=900000;
                oppProduct1.BA_Protection__c=1000000;
                insert oppProduct1;
                
                opp1.StageName = GlobalConstants.ALL_LOAN_SETUP;            
                update opp1;
                
               targetNewBook.Status__c='Lead Expired';
               update targetNewBook;                    

            Test.stopTest();
            
            Target_List__c listNewBook =[SELECT Id, Name, Status__c, Campaign_Reward_Calc__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :strNewBooking  and opportunity__c = :opp1.Id LIMIT 1];
            List<Target_List__c> listThankyou =[SELECT Id, Name, Status__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :strThankyou and opportunity__c = :opp1.Id];
            System.assertEquals(listThankyou.size(),1);
            System.assertEquals(listNewBook.Campaign_Reward_Calc__c,'-');
            
        }
    }

    static testMethod void testConcatExternalId() {
        Account testAcc = [SELECT Id, CIS__c FROM Account WHERE Name = :TargetList_Test.accountNameAH LIMIT 1];
        Campaign targetCampaign = [SELECT Id, Lead_Campaign_Event_Code__c FROM Campaign WHERE Name = 'NEWBOOKING'];
        Test.startTest();                   
            insert new Target_List__c(
                Lead_Campaign__c = targetCampaign.Id, 
                CIS_ID_Prospect_Name__c = testAcc.Id);
        Test.stopTest();
        
        Target_List__c finalTarget =[SELECT Id, External_Id__c FROM Target_List__c WHERE Lead_Campaign__r.Lead_Campaign_Event_Code__c= :strNewBooking LIMIT 1];

        System.assertEquals(targetCampaign.Lead_Campaign_Event_Code__c + '' + testAcc.CIS__c, finalTarget.External_ID__c);
    }
    
}