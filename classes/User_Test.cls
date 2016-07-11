@isTest
private class User_Test {

    public static String accountNameTM = 'tmCreatedAccountName';
    public static String accountNameRMPer = 'tmCreatedAccountPer';
    public static String accountNameRMTemp = 'rmCreatedAccountTemp';
    public static String accountNameAH = 'ahCreatedAccountName';

    public static String newRMEmpId = 'TEST01';
    public static String newTMEmpId = 'TEST02';
    public static String newAHEmpId = 'TEST03';
    public static String newNHEmpId = 'TEST04';

    public static String newRMName  = 'NewRM';
    public static String newTMName  = 'NewTM';
    public static String newAHName  = 'NewAH';
    public static String newNHName  = 'NewNH';

    public static String newRCCode = '84044';
    public static String newAHRCCode = '85055';
    public static String newNHRCCode = '86066';

    public static Map<String,User> mapUserMapByFirstName = new Map<String,User>();

    @testSetup static void setupUser(){
        TriggerHandler.bypass('TeamStructureTriggerHandler');
        TestUtils.enable_isRunningTest = true;

        Mockup_Test mt = new Mockup_Test().setUpTestWithRCCode();

        Chatter_Group_Manager__c customSetting = new Chatter_Group_Manager__c(Name = Mockup_Test.userFirstNameRM + ' ' + Mockup_Test.userLastNameRM);
        insert customSetting;

        List<User> listUser = [SELECT Id,FirstName FROM User];

        for(User eachUser : listUser){
            mapUserMapByFirstName.put(eachUser.FirstName, eachUser);
        }

        System.runAs(mapUserMapByFirstName.get(Mockup_Test.userFirstNameRM)){
            mt.newAccount(accountNameRMPer,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_PERMANENT,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
            mt.newAccount(accountNameRMTemp,GlobalConstants.POOL,GlobalConstants.OWNERSHIP_TEMPORARY,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
            Account accountPer = [SELECT Id, OwnerId, Owner.Employee_Id__c FROM Account WHERE Name = :User_Test.accountNameRMPer LIMIT 1];
            // New Task
            Task newTask = Mockup_Test.newTask(UserInfo.getuserid(), accountPer.Id);
            insert newTask;

            // New Customer Owner Request
            Mockup_Test.newCustomerRequest(accountPer.Id,'Open',UserInfo.getUserId(),GlobalConstants.REQUEST_OWNERSHIP, GlobalConstants.PORT);
            Customer_Ownership_Request__c customerRequest = [SELECT Id FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:accountPer.Id LIMIT 1];
            customerRequest.Approval_Status__c = GlobalConstants.APPROVED;
            update customerRequest;
        }
        System.runAs(mapUserMapByFirstName.get(Mockup_Test.userFirstNameTM)){
            User rmUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameRM LIMIT 1];
            mt.newAccount(accountNameTM,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
            Account targetAccount = [SELECT Id FROM Account WHERE Name = :User_Test.accountNameTM LIMIT 1];
            targetAccount.Service_RM__c = rmUser.Id;
            update targetAccount;
        }
        System.runAs(mapUserMapByFirstName.get(Mockup_Test.userFirstNameAH)){
            mt.newAccount(accountNameAH,GlobalConstants.POOL,Mockup_Test.getRecordTypeAccountIdByName(GlobalConstants.SME_CUSTOMER));
        }
    }

    @isTest static void updateUser() {
        TestUtils.enable_isRunningTest = true;

        String RM_SEC_RC = '78201';

        Team_Structure__c tsTm2 = new Team_Structure__c(
            Name = 'Test Team',
            RC_Code__c = RM_SEC_RC,
            External_ID__c = RM_SEC_RC
            );
        insert tsTm2;

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
        Test.startTest();
            User targetRM = [SELECT Id, RC_Code__c, Employee_Id__c FROM User WHERE FirstName = :Mockup_Test.userFirstNameRM LIMIT 1];
            targetRM.RC_Code__c = RM_SEC_RC;
            update targetRM;
        Test.stopTest();
        }
    
        User newTargetRM = [SELECT Id, RC_Code__c, Employee_Id__c, ManagerId FROM User WHERE FirstName = :Mockup_Test.userFirstNameRM LIMIT 1];
        User_Extension__c newRmUserExt = [SELECT Id, External_Id__c, Team_Structure__r.External_Id__c FROM User_Extension__c WHERE User__c = :newTargetRM.Id LIMIT 1];
        System.assertEquals(RM_SEC_RC, newRmUserExt.Team_Structure__r.External_Id__c);

     //   Account targetAccount = [SELECT Id, OwnerId FROM Account WHERE Name = :User_Test.accountNameRMPer LIMIT 1];
        //System.assertEquals(newTargetRM.ManagerId, targetAccount.OwnerId);
        Account targetTempAccount = [SELECT Id, Owner.Employee_Id__c FROM Account WHERE Name = :accountNameRMTemp];
        System.assertEquals(newTargetRM.Id, targetTempAccount.OwnerId);
    }

    @isTest static void updateUserChangeVisibility() {
        TestUtils.enable_isRunningTest = true;

        Profile nhProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
        Profile ahProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1];
        Profile tmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
        Profile rmProfile = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];

        UserRole userRoleNh = [SELECT Id FROM UserRole WHERE DeveloperName = :('RC' + Mockup_Test.NH_RC_CODE)];
        User userAH = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAH LIMIT 1];

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            List<Team_Structure__c> listTeamStructure = new List<Team_Structure__c>();

            UserRole newNHRole = Mockup_Test.newRole(newNHRCCode, 'RC' + newNHRCCode, null);
            insert newNHRole;

            UserRole newAHRole = Mockup_Test.newRole(newAHRCCode, 'RC' + newAHRCCode, newNHRole.Id);
            insert newAHRole;

            UserRole newTmRole = Mockup_Test.newRole(newRCCode, 'RC' + newRCCode, newAHRole.Id);
            insert newTmRole;

            UserRole newRmRole = Mockup_Test.newRole(newRCCode, 'RCRM' + newRCCode, newTmRole.Id);
            insert newRmRole;

            Team_Structure__c tsNh = new Team_Structure__c(
                RC_Code__c = newNHRCCode,
                External_ID__c = newNHRCCode
            );
            listTeamStructure.add(tsNh);

            Team_Structure__c tsAh = new Team_Structure__c(
                NH_RC_Code__c = newNHRCCode,
                RC_Code__c = newAHRCCode,
                External_ID__c = newAHRCCode
            );
            listTeamStructure.add(tsAh);

            Team_Structure__c tsTm = new Team_Structure__c(
                NH_RC_Code__c = newNHRCCode,
                AH_RC_Code__c = newAHRCCode,
                RC_Code__c = newRCCode,
                External_ID__c = newRCCode
            );
            listTeamStructure.add(tsTm);

            insert listTeamStructure;
            //Pool_Visibility__c areaBKK1 = new Pool_Visibility__c();
      //      areaBKK1.Group_Indicate__c = 'Bangkok';
      //      areaBKK1.Name = 'RC' + Mockup_Test.AH_RC_CODE;
      //      areaBKK1.Role_Name__c = 'ผู้บริหารธุรกิจ คป.1-1';
      //      insert areaBKK1;

            Pool_Visibility__c areaBKK2 = new Pool_Visibility__c();
            areaBKK2.Group_Indicate__c = 'Chiangmai';
            areaBKK2.Name = 'RC' + newNHRCCode;
            areaBKK2.Role_Name__c = 'ผู้บริหารธุรกิจ คป.1-2';
            insert areaBKK2;

            Test.startTest();
                User targetRM = [SELECT Id, RC_Code__c, Employee_Id__c FROM User WHERE FirstName = :Mockup_Test.userFirstNameRM LIMIT 1];
                targetRM.RC_Code__c = newRCCode;
                targetRM.AH_RC_Code__c = newAHRCCode;
                targetRM.NH_RC_Code__c = newNHRCCode;
                update targetRM;
            Test.stopTest();
        }
        
        User newTargetRM = [SELECT Id, RC_Code__c, Employee_Id__c, ManagerId FROM User WHERE FirstName = :Mockup_Test.userFirstNameRM LIMIT 1];
        Account targetAccount = [SELECT Id, OwnerId FROM Account WHERE Name = :User_Test.accountNameRMPer LIMIT 1];
        System.assertEquals(newTargetRM.ManagerId, targetAccount.OwnerId);
        Account targetTempAccount = [SELECT Id, Owner.Employee_Id__c FROM Account WHERE Name = :accountNameRMTemp];
        System.assertEquals(newTargetRM.ManagerId, targetTempAccount.OwnerId);

    }

    @isTest static void inactiveRM() {
        TestUtils.enable_isRunningTest = true;
        Test.startTest();
            System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
                User targetRM = [SELECT Id, RC_Code__c, Employee_Id__c FROM User WHERE FirstName = :Mockup_Test.userFirstNameRM LIMIT 1];
                targetRM.IsActive = false;
                targetRM.Status__c = 'I';
                update targetRM;
            }

        Test.stopTest();
        
        User newTargetTM = [SELECT Id FROM User WHERE FirstName = :Mockup_Test.userFirstNameTM LIMIT 1];

        Account targetAccount = [SELECT Id, OwnerId, Owner.Employee_Id__c FROM Account WHERE Name = :User_Test.accountNameRMPer LIMIT 1];
        System.assertEquals(newTargetTM.Id, targetAccount.OwnerId);
        Task targetTask = [SELECT Id, Status, OwnerId FROM Task WHERE WhatId = :targetAccount.Id];
        System.assertEquals('Closed by System', targetTask.Status);

        Account targetAccountTM = [SELECT Id, Service_RM__c FROM Account WHERE Name = :User_Test.accountNameTM LIMIT 1];
        System.assertEquals(null, targetAccountTM.Service_RM__c);
    }

    @isTest static void testCreateUserThenCreateGroupChatter() {
        TestUtils.enable_isRunningTest = true;
        CollaborationGroup resultGroup;
        CollaborationGroup resultNhGroup;
        List<CollaborationGroup> allGroup;
        List<CollaborationGroupMember> resultGroupMember;
        List<CollaborationGroupMember> resultNhGroupMember;

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){
            Test.startTest();

                Team_Structure__c teamStructure = [SELECT Name,Segment__c FROM Team_Structure__c WHERE External_ID__c = :Mockup_Test.NH_RC_CODE];
                String groupName = GroupChatterService.createGroupNameFromTeamNameAndSegment(teamStructure.Name,teamStructure.Segment__c);
                resultGroup = [SELECT Id,Name,MemberCount,CollaborationType FROM CollaborationGroup WHERE Name = :groupName];
                resultGroupMember = [SELECT Id FROM CollaborationGroupMember WHERE CollaborationGroupId = :resultGroup.Id AND CollaborationRole = 'Standard'];
                
                resultNhGroup = [SELECT Id,Name,MemberCount,CollaborationType FROM CollaborationGroup WHERE Name = :GlobalConstants.SEGMENT_SE];
                resultNhGroupMember = [SELECT Id FROM CollaborationGroupMember WHERE CollaborationGroupId = :resultNhGroup.Id AND CollaborationRole = 'Standard'];

                allGroup = [SELECT Id,Name,MemberCount,CollaborationType FROM CollaborationGroup];
            Test.stopTest();
        }

        System.assertEquals(2, allGroup.size());
        System.assertEquals(5, resultGroup.MemberCount);
        System.assertEquals(4, resultGroupMember.size());
        System.assertEquals('Private', resultGroup.CollaborationType);

        System.assertEquals(2, resultNhGroup.MemberCount);
        System.assertEquals(1, resultNhGroupMember.size());
        System.assertEquals('Private', resultNhGroup.CollaborationType);
    }

    @isTest static void testUpdateUserProfileFromRmToTmSameTeamThenDoNothing() {
        TriggerHandler.bypass('TeamStructureTriggerHandler');
        TestUtils.enable_isRunningTest = true;
        String rmUser = 'testGroupRmUser1';
        CollaborationGroup resultGroup;
        List<CollaborationGroup> allGroup;
        List<CollaborationGroupMember> resultGroupMember;
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            UserRole rmRole = [SELECT Id FROM UserRole WHERE DeveloperName= :('RCRM' + Mockup_Test.RC_CODE)];
            User tmUser = [SELECT Id FROM User WHERE Employee_ID__c = :Mockup_Test.userEmpIdTM];
            Id rmProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1].Id;
            Id tmProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1].Id;
            User newUser = Mockup_Test.newUser(rmUser,
                                                rmUser,
                                                true,
                                                rmUser+'@mail.com',
                                                rmUser+'@mail.com',
                                                'rmUser',
                                                rmProfileId,
                                                rmRole.Id,
                                                tmUser.Id,
                                                'MockUserGroup1'
            );
            insert newUser;

            Test.startTest();

                newUser.ProfileId = tmProfileId;
                update newUser;

                Team_Structure__c teamStructure = [SELECT Name,Segment__c FROM Team_Structure__c WHERE External_ID__c = :Mockup_Test.NH_RC_CODE];
                String groupName = GroupChatterService.createGroupNameFromTeamNameAndSegment(teamStructure.Name,teamStructure.Segment__c);
                resultGroup = [SELECT Id,Name,MemberCount,CollaborationType FROM CollaborationGroup WHERE Name = :groupName];
                resultGroupMember = [SELECT Id,Member.Name,CollaborationRole FROM CollaborationGroupMember WHERE CollaborationGroupId = :resultGroup.Id AND CollaborationRole = 'Standard'];
                allGroup = [SELECT Id,Name,MemberCount,CollaborationType FROM CollaborationGroup];
            Test.stopTest();
        }

        System.assertEquals(2, allGroup.size());
        System.assertEquals(5, resultGroup.MemberCount);
        System.assertEquals(4, resultGroupMember.size());
        System.assertEquals('Private', resultGroup.CollaborationType);

        for(CollaborationGroupMember member : resultGroupMember){
            if(member.Member.Name == Mockup_Test.userFirstNameAdmin){
                System.assertEquals('Admin',member.CollaborationRole);
            }
        }
    }

    @isTest static void testUpdateUserTeamThenRemoveUserFromOldGroupAndAddUserToNewGroup() {
        TriggerHandler.bypass('TeamStructureTriggerHandler');
        TestUtils.enable_isRunningTest = true;
        String ahUser = 'testGroupAhUser1';
        String nhUser = 'testGroupNhUser1';
        String NH_RC_CODE = '1234';
        String AH_RC_CODE = '5678';
        CollaborationGroup resultGroup1;
        CollaborationGroup resultGroup2;
        CollaborationGroup resultGroupAllNH;
        List<CollaborationGroup> listResultGroup;
        List<CollaborationGroupMember> resultGroupMember1;
        List<CollaborationGroupMember> resultGroupMember2;
        List<Team_Structure__c> listTeamStructure = new List<Team_Structure__c>();
        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            UserRole ahRole = [SELECT Id FROM UserRole WHERE DeveloperName= :('RC' + Mockup_Test.AH_RC_CODE)];

            List<Profile> listProfile = [SELECT Id, Name FROM Profile];
            Map<String ,Id> mapProfileIdByName = new Map<String ,Id>();
            for(Profile pf : listProfile){
                mapProfileIdByName.put(pf.Name, pf.Id);
            }

            Id nhProfileId = mapProfileIdByName.get(GlobalConstants.SME_NH);
            Id ahProfileId = mapProfileIdByName.get(GlobalConstants.SME_AH);

            Team_Structure__c tsNh = new Team_Structure__c(
                External_ID__c = NH_RC_CODE,
                RC_Code__c = NH_RC_CODE,
                AH_RC_Code__c = null,
                NH_RC_Code__c = null,
                Name = Mockup_Test.nhRoleDeveloperName + '1',
                Segment__c = GlobalConstants.SEGMENT_ME,
                Type__c = 'Network'
            );
            listTeamStructure.add(tsNh);

            Team_Structure__c tsAh = new Team_Structure__c(
                External_ID__c = AH_RC_CODE,
                RC_Code__c = AH_RC_CODE,
                AH_RC_Code__c = null,
                NH_RC_Code__c = NH_RC_CODE,
                AH_Name__c = null,
                NH_Name__c = tsNh.Id,
                Name = Mockup_Test.ahRoleDeveloperName + '1',
                Segment__c = GlobalConstants.SEGMENT_ME,
                Type__c = 'Area'
            );
            listTeamStructure.add(tsAh);

            insert listTeamStructure;

            User newNhUser = Mockup_Test.newUser(nhUser,
                                                nhUser,
                                                true,
                                                nhUser+'@mail.com',
                                                nhUser+'@mail.com',
                                                'nhUser',
                                                nhProfileId,
                                                null,
                                                null,
                                                'MockUserGroup1'
            );
            newNhUser.RC_Code__c = NH_RC_CODE;
            newNhUser.NH_RC_Code__c = NH_RC_CODE;
            newNhUser.Job_Code__c = 'ME1A';
            newNhUser.Status__c = 'A';

            insert newNhUser;

            User newAhUser = Mockup_Test.newUser(ahUser,
                                                ahUser,
                                                true,
                                                ahUser+'@mail.com',
                                                ahUser+'@mail.com',
                                                'ahUser',
                                                ahProfileId,
                                                ahRole.Id,
                                                newNhUser.Id,
                                                'MockUserGroup2'
            );
            newAhUser.RC_Code__c = AH_RC_CODE;
            newAhUser.NH_RC_Code__c = NH_RC_CODE;
            newAhUser.AH_RC_Code__c = AH_RC_CODE;
            newAhUser.Job_Code__c = 'ME2A';
            newAhUser.Status__c = 'A';
            insert newAhUser;

            Test.startTest();

                User destinationManager = [SELECT Id FROM User WHERE Employee_ID__c = :Mockup_Test.userEmpIdNH];
                newAhUser.RC_Code__c = Mockup_Test.AH_RC_CODE;
                newAhUser.NH_RC_Code__c = Mockup_Test.NH_RC_CODE;
                newAhUser.ManagerId = destinationManager.Id;
                update newAhUser;

            Test.stopTest();
        }

        Map<String ,Team_Structure__c> mapTeamByExternalId = new Map<String ,Team_Structure__c>();
        listTeamStructure = [SELECT Name,Segment__c,External_ID__c FROM Team_Structure__c];
        for(Team_Structure__c eachTeam : listTeamStructure){
            mapTeamByExternalId.put(eachTeam.External_ID__c, eachTeam);
        }

        Map<String ,CollaborationGroup> mapGroupByName = new Map<String ,CollaborationGroup>();
        listResultGroup = [SELECT Id,Name,MemberCount,CollaborationType FROM CollaborationGroup];
        for(CollaborationGroup eachGroup : listResultGroup){
            mapGroupByName.put(eachGroup.Name, eachGroup);
        }

        Team_Structure__c teamStructure1 = mapTeamByExternalId.get(Mockup_Test.NH_RC_CODE);

        String groupName1 = GroupChatterService.createGroupNameFromTeamNameAndSegment(teamStructure1.Name,teamStructure1.Segment__c);
        resultGroup1 = mapGroupByName.get(groupName1);

        Team_Structure__c teamStructure2 = mapTeamByExternalId.get(NH_RC_CODE);
        String groupName2 = GroupChatterService.createGroupNameFromTeamNameAndSegment(teamStructure2.Name,teamStructure2.Segment__c);
        resultGroup2 = mapGroupByName.get(groupName2);

        resultGroupAllNH = mapGroupByName.get(GlobalConstants.SEGMENT_SE);

        System.assertEquals(3, listResultGroup.size());

        System.assertEquals(3, resultGroup2.MemberCount);
        System.assertEquals('Private', resultGroup2.CollaborationType);

        System.assertEquals(6, resultGroup1.MemberCount);
        System.assertEquals('Private', resultGroup1.CollaborationType);

        System.assertNotEquals(null,resultGroupAllNH);
    }

    @isTest static void testInactiveNhThenDeleteNhFromAllNhGroupAndDeleteNhFromOwnGroup() {
        TriggerHandler.bypass('TeamStructureTriggerHandler');
        TestUtils.enable_isRunningTest = true;
        CollaborationGroup resultGroupAllNH;
        CollaborationGroup resultGroupNH;
        List<CollaborationGroup> listResultGroup;
        List<CollaborationGroupMember> resultGroupMemberAllNh;
        List<CollaborationGroupMember> resultGroupMemberNh;
        List<Team_Structure__c> listTeamStructure = new List<Team_Structure__c>();
        
        Map<String ,Team_Structure__c> mapTeamByExternalId = new Map<String ,Team_Structure__c>();
        listTeamStructure = [SELECT Name,Segment__c,External_ID__c FROM Team_Structure__c];
        System.debug('listTeamStructure '+listTeamStructure);
        for(Team_Structure__c eachTeam : listTeamStructure){
            mapTeamByExternalId.put(eachTeam.External_ID__c, eachTeam);
        }

        Team_Structure__c teamStructure = mapTeamByExternalId.get(Mockup_Test.NH_RC_CODE);

        String groupNameNH = GroupChatterService.createGroupNameFromTeamNameAndSegment(teamStructure.Name,teamStructure.Segment__c);

        CollaborationGroup cbgAllNH = [SELECT Id,Name,MemberCount,CollaborationType FROM CollaborationGroup WHERE Name = :GlobalConstants.SEGMENT_SE LIMIT 1];
        CollaborationGroup cbgNH = [SELECT Id,Name,MemberCount,CollaborationType FROM CollaborationGroup WHERE Name = :groupNameNH LIMIT 1];

        System.assertEquals(2, cbgAllNH.MemberCount);
        System.assertEquals('Private', cbgAllNH.CollaborationType);
        System.assertEquals(5, cbgNH.MemberCount);
        System.assertEquals('Private', cbgNH.CollaborationType);

        System.runAs([SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameAdmin LIMIT 1][0]){

            Test.startTest();
            
                User nhUser = [SELECT Id FROM User WHERE Firstname=:Mockup_Test.userFirstNameNH LIMIT 1];
                System.debug('nhUser = '+nhUser);
                nhUser.isActive = false;
                update nhUser;

            Test.stopTest();
        }

        Map<String ,CollaborationGroup> mapGroupByName = new Map<String ,CollaborationGroup>();
        listResultGroup = [SELECT Id,Name,MemberCount,CollaborationType FROM CollaborationGroup];
        for(CollaborationGroup eachGroup : listResultGroup){
            mapGroupByName.put(eachGroup.Name, eachGroup);
        }        
        
        resultGroupNH = mapGroupByName.get(groupNameNH);
        resultGroupAllNH = mapGroupByName.get(GlobalConstants.SEGMENT_SE);

        System.assertEquals(2, listResultGroup.size());

        System.assertEquals(4, resultGroupNH.MemberCount);
        System.assertEquals('Private', resultGroupNH.CollaborationType);

        System.assertNotEquals(null,resultGroupAllNH);
        System.assertEquals(1, resultGroupAllNH.MemberCount);
        System.assertEquals('Private', resultGroupAllNH.CollaborationType);

    }
}