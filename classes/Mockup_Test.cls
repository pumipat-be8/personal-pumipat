/**
* @author komsan.wi@beryl8.com
* @08/07/2015 createddate
* @method_list
* setUpTest()
* newAccount(String accountName,String portPool,String recordTypeId)
* newCustomerRequest(String accountId,String status,String ownerId) 
*/
public class Mockup_Test {
    public static String userFirstNameRM = 'FirstNameRM';
    public static String userLastNameRM = 'LastNameRM';
    public static String userFirstNameRM2 = 'FirstNameRM2';
    public static String userLastNameRM2 = 'LastNameRM2';
    public static String userFirstNameTM = 'FirstNameTM';
    public static String userLastNameTM = 'LastNameTM';
    public static String userFirstNameAH = 'FirstNameAH';
    public static String userLastNameAH = 'LastNameAH';
    public static String userFirstNameNH = 'FirstNameNH';
    public static String userLastNameNH = 'LastNameNH';

    public static String userFirstNameRMDiff = 'FirstNameRMDiff';
    public static String userLastNameRMDiff = 'LastNameRMDiff';
    public static String userFirstNameTMDiff = 'FirstNameTMDiff';
    public static String userLastNameTMDiff = 'LastNameTMDiff';
    public static String userFirstNameAHDiff = 'FirstNameAHDiff';
    public static String userLastNameAHDiff = 'LastNameAHDiff';

    public static String userFirstNameAdmin = 'FirstNameAdmin';
    public static String userLastNameAdmin = 'LastNameAdmin';

    public static String nhRoleDeveloperName = 'nhAreaRole';
    public static String ahRoleDeveloperName = 'ahAreaRole';
    public static String tmRoleDeveloperName = 'tmAreaRole';
    public static String rmRoleDeveloperName = 'rmAreaRole';

    public static String ahRoleDeveloperNameDiff = 'ahAreaRoleDiff';
    public static String tmRoleDeveloperNameDiff = 'tmAreaRoleDiff';
    public static String rmRoleDeveloperNameDiff = 'rmAreaRoleDiff';

    public static String userEmpIdRM = 'MOCK01';
    public static String userEmpIdRM2 = 'MOCK0101';
    public static String userEmpIdTM = 'MOCK02';
    public static String userEmpIdAH = 'MOCK03';
    public static String userEmpIdNH = 'MOCK04';
    public static String userEmpIdRMDiff = 'CH0001';
    public static String userEmpIdTMDiff = 'CH0002';
    public static String userEmpIdAHDiff = 'CH0003';

    public static String RC_CODE = '41404';
    public static String AH_RC_CODE = '41400';
    public static String NH_RC_CODE = '41201';

    public static Id getRecordTypeCampaignIdByName(String name){
        return Schema.SObjectType.Campaign.getRecordTypeInfosByName().get(name).getRecordTypeId();
    }
    public static Id getRecordTypeAccountIdByName(String name){
        return Schema.SObjectType.Account.getRecordTypeInfosByName().get(name).getRecordTypeId();
    }
    public static Id getRecordTypeCallReportIdByName(String name){
        return Schema.SObjectType.Call_Report__C.getRecordTypeInfosByName().get(name).getRecordTypeId();
    }
    public Mockup_Test setUpTestOnlyAdmin() {
        Mockup_Test.setUpCustomSetting();
        return this.setUpTestAdmin();
    }
    public Mockup_Test setUpTestAdmin() {       
        System.runAs(new User(Id=UserInfo.getUserId())){
            UserRole adminRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'SME_Admin'];
            Id adminProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_ADMIN LIMIT 1].Id;
            User admin = Mockup_Test.newUser(
                Mockup_Test.userFirstNameAdmin,
                Mockup_Test.userLastNameAdmin,
                true,
                'FirstNameAdmin@mail.com',
                'FirstNameAdmin@mail.com',
                'admin',
                adminProfileId,
                adminRole.Id,
                null,
                null
            );

            insert admin;
        }

        setUpCustomSettingAdmin();

        return this;
    }

    public static void setUpCustomSettingConnectionAttribute() {
        List<ConnectionAttribute__c> attrList = new List<ConnectionAttribute__c>();
        attrList.add(new ConnectionAttribute__c(Name = 'CITimeout', AttributeValue__c ='120000'));
        attrList.add(new ConnectionAttribute__c(Name = 'httpPassword', AttributeValue__c ='rmst_723'));
        attrList.add(new ConnectionAttribute__c(Name = 'httpUsername', AttributeValue__c ='rmst_723'));
        insert attrList;
    }
    
    public static void setUpCustomSetting() {       
        List<User_Management__c> umList = new List<User_Management__c>();
        System.runAs(new User(Id=UserInfo.getUserId())){
            Id ahProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1].Id;
            Id tmProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1].Id;
            Id rmProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1].Id;
            Id adminProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_ADMIN LIMIT 1].Id;
            
            umList.add(new User_Management__c(
                    SetupOwnerId = UserInfo.getProfileId(),
                    Allow_User_Edit__c = true,
                    Allow_Change_Opportunity__c = true
                ));
            umList.add(new User_Management__c(
                    SetupOwnerId = ahProfileId,
                    Allow_User_Edit__c = true,
                    Allow_Change_Opportunity__c = true
                ));
            umList.add(new User_Management__c(
                    SetupOwnerId = tmProfileId,
                    Allow_User_Edit__c = true,
                    Allow_Change_Opportunity__c = true
                ));
            umList.add(new User_Management__c(
                    SetupOwnerId = rmProfileId,
                    Allow_User_Edit__c = true,
                    Allow_Change_Opportunity__c = true
                ));
            umList.add(new User_Management__c(
                    SetupOwnerId = adminProfileId,
                    Allow_User_Edit__c = true,
                    Allow_Change_Opportunity__c = true
                ));
            insert umList;
        }
    }
    public static void setUpCustomSettingAdmin() {
        System.runAs(new User(Id=UserInfo.getUserId())){
            User userAdmin = [SELECT Id FROM User WHERE Firstname=:userFirstNameAdmin LIMIT 1][0];

            SME_ADMIN__c smeAdminC = SME_ADMIN__c.getInstance(UserInfo.getOrganizationId());
            if (smeAdminC != null) {
                smeAdminC.User_Record_ID__c = userAdmin.Id;
                insert smeAdminC;
            }
            User_Admin__c userAdminC = User_Admin__c.getInstance(UserInfo.getOrganizationId());
            if (userAdminC != null) {
                userAdminC.User_Record_ID__c = userAdmin.Id;
                insert userAdminC;
            }
        }
    }

    public Mockup_Test setUpTestWithRCCode() {
        Mockup_Test.setUpCustomSetting();
        
        System.runAs(new User(Id=UserInfo.getUserId())){
            Profile nhProfile = [SELECT Id, Name FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1];
            insert new Job_Code__c(Name = 'ME1A', Profile_Name__c = nhProfile.Name);

            Profile ahProfile = [SELECT Id, Name FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1];
            insert new Job_Code__c(Name = 'ME2A', Profile_Name__c = ahProfile.Name);
        
            Profile tmProfile = [SELECT Id, Name FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1];
            insert new Job_Code__c(Name = 'ME3A', Profile_Name__c = tmProfile.Name);
          
            Profile rmProfile = [SELECT Id, Name FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1];
            insert new Job_Code__c(Name = 'ME4A', Profile_Name__c = rmProfile.Name);

            UserRole adminRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'SME_Admin'];
            UserRole nhRole = Mockup_Test.newRole(NH_RC_CODE, 'RC' + NH_RC_CODE, adminRole.Id);
            insert nhRole;
            UserRole ahRole = Mockup_Test.newRole(AH_RC_CODE, 'RC' + AH_RC_CODE, nhRole.Id);
            insert ahRole;
            UserRole tmRole = Mockup_Test.newRole(RC_CODE, 'RC' + RC_CODE, ahRole.Id);
            insert tmRole;
            UserRole rmRole = Mockup_Test.newRole(RC_CODE, 'RCRM' + RC_CODE, tmRole.Id);
            insert rmRole;

            Team_Structure__c tsNh = new Team_Structure__c(
                External_ID__c = NH_RC_CODE,
                RC_Code__c = NH_RC_CODE,
                AH_RC_Code__c = null,
                NH_RC_Code__c = null,
                Name = nhRoleDeveloperName,
                Segment__c = GlobalConstants.SEGMENT_SE,
                Type__c = 'Network'
            );
            insert tsNh;

            Team_Structure__c tsAh = new Team_Structure__c(
                External_ID__c = AH_RC_CODE,
                RC_Code__c = AH_RC_CODE,
                AH_RC_Code__c = null,
                NH_RC_Code__c = NH_RC_CODE,
                AH_Name__c = null,
                NH_Name__c = tsNh.Id,
                Name = ahRoleDeveloperName,
                Segment__c = GlobalConstants.SEGMENT_SE,
                Type__c = 'Area'
            );
            insert tsAh;

            Team_Structure__c tsTm = new Team_Structure__c(
                External_ID__c = RC_CODE,
                RC_Code__c = RC_CODE,
                AH_RC_Code__c = AH_RC_CODE,
                NH_RC_Code__c = NH_RC_CODE,
                AH_Name__c = tsAh.Id,
                NH_Name__c = tsNh.Id,
                Name = tmRoleDeveloperName,
                Segment__c = GlobalConstants.SEGMENT_SE,
                Type__c = 'Team'
            );
            insert tsTm;

            User nhUser = Mockup_Test.newUser(
                    Mockup_Test.userFirstNameNH,
                    Mockup_Test.userLastNameNH,
                    true,
                    userFirstNameNH+'@mail.com',
                    userFirstNameNH+'@mail.com',
                    userFirstNameNH.substring(0, 4),
                    nhProfile.Id,
                    nhRole.Id,
                    null,
                    userEmpIdNH
            );
            nhUser.RC_Code__c = NH_RC_CODE;
            nhUser.NH_RC_Code__c = NH_RC_CODE;
            nhUser.Job_Code__c = 'ME1A';
            nhUser.Status__c = 'A';
            nhUser.Segment__c = 'SE';
            insert nhUser;

            User ahUser = Mockup_Test.newUser(
                    Mockup_Test.userFirstNameAH,
                    Mockup_Test.userLastNameAH,
                    true,
                    userFirstNameAH+'@mail.com',
                    userFirstNameAH+'@mail.com',
                    userFirstNameAH.substring(0, 4),
                    ahProfile.Id,
                    ahRole.Id,
                    nhUser.Id,
                    userEmpIdAH
            );
            ahUser.RC_Code__c = AH_RC_CODE;
            ahUser.NH_RC_Code__c = NH_RC_CODE;
            ahUser.AH_RC_Code__c = AH_RC_CODE;
            ahUser.Job_Code__c = 'ME2A';
            ahUser.Status__c = 'A';
            ahUser.Segment__c = 'SE';
            insert ahUser;

            User tmUser = Mockup_Test.newUser(
                    Mockup_Test.userFirstNameTM,
                    Mockup_Test.userLastNameTM,
                    true,
                    userFirstNameTM+'@mail.com',
                    userFirstNameTM+'@mail.com',
                    userFirstNameTM.substring(0, 4),
                    tmProfile.Id,
                    tmRole.Id,
                    ahUser.Id,
                    userEmpIdTM
             );
            tmUser.Job_Code__c = 'ME3A';
            tmUser.AH_RC_Code__c = AH_RC_CODE;
            tmUser.NH_RC_Code__c = NH_RC_CODE;
            tmUser.RC_Code__c = RC_CODE;
            tmUser.Status__c = 'A';
            tmUser.Segment__c = 'SE';
            insert tmUser;

            User rmUser = Mockup_Test.newUser(
                    Mockup_Test.userFirstNameRM,
                    Mockup_Test.userLastNameRM,
                    true,
                    userFirstNameRM+'@mail.com',
                    userFirstNameRM+'@mail.com',
                    userFirstNameRM.substring(0, 4),
                    rmProfile.Id,
                    rmRole.Id,
                    tmUser.Id,
                    userEmpIdRM
             );
            rmUser.Job_Code__c = 'ME4A';
            rmUser.AH_RC_Code__c = AH_RC_CODE;
            rmUser.NH_RC_Code__c = NH_RC_CODE;
            rmUser.RC_Code__c = RC_CODE;
            rmUser.Status__c = 'A';

            insert rmUser;

            Pool_Visibility__c areaBKK1 = new Pool_Visibility__c();
            areaBKK1.Group_Indicate__c = 'Bangkok';
            areaBKK1.Name = 'RC' + Mockup_Test.NH_RC_CODE;
            areaBKK1.Role_Name__c = 'เครือข่ายลูกค้าผู้ประกอบการ 1 (กทม.1)';
            insert areaBKK1;
        }
        return this.setUpTestAdmin();
    }

    public Mockup_Test setUpTest() {
        Mockup_Test.setUpCustomSetting();
        
        Id ahProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1].Id;
        Id tmProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1].Id;
        Id rmProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1].Id;
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_ADMIN LIMIT 1].Id;

        System.runAs(new User(Id=UserInfo.getUserId())){

            UserRole ahRole = new UserRole(Name='AreaAh',DeveloperName=Mockup_Test.ahRoleDeveloperName);
            insert ahRole;

            User ahUser = Mockup_Test.newUser(
                Mockup_Test.userFirstNameAh,
                Mockup_Test.userLastNameAh,
                true,
                'FirstNameAh@mail.com',
                'FirstNameAh@mail.com',
                'ahUser',
                ahProfileId,
                ahRole.Id,
                null,
                userEmpIdAH
            );
            insert ahUser;

            UserRole tmRole = new UserRole(Name='AreaTm',DeveloperName=Mockup_Test.tmRoleDeveloperName,ParentRoleId=ahRole.Id);
            insert tmRole;

            User tmUser = Mockup_Test.newUser(
                Mockup_Test.userFirstNameTM,
                Mockup_Test.userLastNameTM,
                true,
                'FirstNameTM@mail.com',
                'FirstNameTM@mail.com',
                'tmUser',
                tmProfileId,
                tmRole.Id,
                ahUser.Id,
                userEmpIdTM
            );
            insert tmUser;
            
            UserRole rmRole = new UserRole(Name='AreaRm',DeveloperName=Mockup_Test.rmRoleDeveloperName,ParentRoleId=tmRole.Id);
            insert rmRole;

            User rmUser = Mockup_Test.newUser(
                Mockup_Test.userFirstNameRM,
                Mockup_Test.userLastNameRM,
                true,
                'FirstNameRM@mail.com',
                'FirstNameRM@mail.com',
                'rmUser',
                rmProfileId,
                rmRole.Id,
                tmUser.Id,
                userEmpIdRM
            );
            insert rmUser;
        }
        return this.setUpTestAdmin();
    }
    public Mockup_Test setUpTestWithExtension(){
        TriggerHandler.bypass('UserTriggerHandler');
        Mockup_Test.setUpCustomSetting();
        
        Id nhProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_NH LIMIT 1].Id;
        Id ahProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1].Id;
        Id tmProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1].Id;
        Id rmProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1].Id;
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_ADMIN LIMIT 1].Id;

        System.runAs(new User(Id=UserInfo.getUserId())){
            UserRole adminRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'SME_Admin'];
            UserRole nhRole = new UserRole(Name='AreaNh',DeveloperName=Mockup_Test.nhRoleDeveloperName,ParentRoleId=adminRole.Id);
            User nhUser = Mockup_Test.newUser(
                    Mockup_Test.userFirstNameNH,
                    Mockup_Test.userLastNameNH,
                    true,
                    userFirstNameNH+'@mail.com',
                    userFirstNameNH+'@mail.com',
                    userFirstNameNH.substring(0, 4),
                    nhProfileId,
                    nhRole.Id,
                    null,
                    userEmpIdNH
            );
            nhUser.RC_Code__c = NH_RC_CODE;
            nhUser.Job_Code__c = 'ME1A';
            nhUser.Status__c = 'A';
            insert nhUser;

            Team_Structure__c tsNh = new Team_Structure__c(
                AH_Name__c = null,
                OwnerId = nhUser.Id,
                RC_Code__c = NH_RC_CODE,
                Name = nhUser.Name,
                External_ID__c = nhUser.RC_Code__c
            );
            insert tsNh;

            UserRole ahRole = new UserRole(Name='AreaAh',DeveloperName=Mockup_Test.ahRoleDeveloperName,ParentRoleId=nhRole.Id);
            insert ahRole;

            User ahUser = Mockup_Test.newUser(
                Mockup_Test.userFirstNameAh,
                Mockup_Test.userLastNameAh,
                true,
                'FirstNameAh@mail.com',
                'FirstNameAh@mail.com',
                'ahUser',
                ahProfileId,
                ahRole.Id,
                nhUser.Id,
                userEmpIdAH
            );
            ahUser.RC_Code__c = AH_RC_CODE;
            ahUser.NH_RC_Code__c = NH_RC_CODE;
            ahUser.AH_RC_Code__c = AH_RC_CODE;
            ahUser.Job_Code__c = 'ME2A';
            insert ahUser;

            Team_Structure__c tsAh = new Team_Structure__c(
                NH_Name__c = tsNh.Id,
                NH_RC_Code__c = NH_RC_CODE,
                RC_Code__c = AH_RC_CODE,
                AH_Name__c = null,
                OwnerId = ahUser.Id,
                Name = ahUser.Name,
                External_ID__c = ahUser.RC_Code__c
            );
            insert tsAh;

            UserRole tmRole = new UserRole(Name='AreaTm',DeveloperName=Mockup_Test.tmRoleDeveloperName,ParentRoleId=ahRole.Id);
            insert tmRole;

            User tmUser = Mockup_Test.newUser(
                Mockup_Test.userFirstNameTM,
                Mockup_Test.userLastNameTM,
                true,
                'FirstNameTM@mail.com',
                'FirstNameTM@mail.com',
                'tmUser',
                tmProfileId,
                tmRole.Id,
                ahUser.Id,
                userEmpIdTM
            );
            tmUser.Job_Code__c = 'ME3A';
            tmUser.AH_RC_Code__c = AH_RC_CODE;
            tmUser.NH_RC_Code__c = NH_RC_CODE;
            tmUser.RC_Code__c = RC_CODE;
            insert tmUser;
    
            UserRole rmRole = new UserRole(Name='AreaRm',DeveloperName=Mockup_Test.rmRoleDeveloperName,ParentRoleId=tmRole.Id);
            insert rmRole;

            User rmUser = Mockup_Test.newUser(
                Mockup_Test.userFirstNameRM,
                Mockup_Test.userLastNameRM,
                true,
                'FirstNameRM@mail.com',
                'FirstNameRM@mail.com',
                'rmUser',
                rmProfileId,
                rmRole.Id,
                tmUser.Id,
                userEmpIdRM
            );
            rmUser.Job_Code__c = 'ME4A';
            rmUser.AH_RC_Code__c = AH_RC_CODE;
            rmUser.NH_RC_Code__c = NH_RC_CODE;
            rmUser.RC_Code__c = RC_CODE;
            rmUser.Status__c = 'A';
            insert rmUser;

            User rm2 = Mockup_Test.newUser(
                Mockup_Test.userFirstNameRM2,
                Mockup_Test.userLastNameRM2,
                true,
                'FirstNameRM2@mail.com',
                'FirstNameRM@mail.com',
                'rm2',
                rmProfileId,
                rmRole.Id,
                tmUser.Id,
                userEmpIdRM2
            );
            rmUser.Job_Code__c = 'ME4A';
            rmUser.AH_RC_Code__c = AH_RC_CODE;
            rmUser.NH_RC_Code__c = NH_RC_CODE;
            rmUser.RC_Code__c = RC_CODE;
            rmUser.Status__c = 'A';
            insert rm2;

            Team_Structure__c tsTm = new Team_Structure__c(
                NH_Name__c = tsNh.Id,
                NH_RC_Code__c = NH_RC_CODE,
                AH_Name__c = tsAh.Id,
                AH_RC_Code__c = AH_RC_CODE,
                OwnerId = rmUser.Id,
                RC_Code__c = RC_CODE,
                Name = tmUser.Name,
                External_ID__c = tmUser.RC_Code__c
            );
            insert tsTm;

            User_Extension__c nhExt = new User_Extension__c(
                User__c = nhUser.Id,
                OwnerId = nhUser.Id,
                Team_Structure__c = tsNh.Id,
                External_ID__c = nhUser.Employee_ID__c
            );
            insert nhExt;

            User_Extension__c ahExt = new User_Extension__c(
                User__c = ahUser.Id,
                OwnerId = ahUser.Id,
                Team_Structure__c = tsAh.Id,
                External_ID__c = ahUser.Employee_ID__c
            );
            insert ahExt;
            
            User_Extension__c tmExt = new User_Extension__c(
                User__c=tmUser.Id,
                OwnerId = tmUser.Id,
                Team_Structure__c = tsTm.Id,
                External_ID__c = tmUser.Employee_ID__c
            );
            insert tmExt;

            User_Extension__c rmExt = new User_Extension__c(
                User__c = rmUser.Id,
                OwnerId = rmUser.Id,
                Team_Structure__c = tsTm.Id,
                External_ID__c = rmUser.Employee_ID__c
            );
            insert rmExt;

            User_Extension__c rmExt2 = new User_Extension__c(
                User__c = rm2.Id,
                OwnerId = rm2.Id,
                Team_Structure__c = tsTm.Id,
                External_ID__c = rm2.Employee_ID__c
            );
            insert rmExt2;
        }
        return this;
    }
    public Mockup_Test setUpTestDifferentArea() {
        
        Id ahProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_AH LIMIT 1].Id;
        Id tmProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_TM LIMIT 1].Id;
        Id rmProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_RM LIMIT 1].Id;
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.SME_ADMIN LIMIT 1].Id;

        System.runAs(new User(Id=UserInfo.getUserId())){

            UserRole ahRole = new UserRole(Name='AreaAhDiff',DeveloperName=Mockup_Test.ahRoleDeveloperNameDiff);
            insert ahRole;

            User ahUser = Mockup_Test.newUser(
                Mockup_Test.userFirstNameAhDiff,
                Mockup_Test.userLastNameAhDiff,
                true,
                'FirstNameAhDiff@mail.com',
                'FirstNameAhDiff@mail.com',
                'ahUser',
                ahProfileId,
                ahRole.Id,
                null,
                userEmpIdAHDiff
            );
            insert ahUser;

            UserRole tmRole = new UserRole(Name='AreaTmDiff',DeveloperName=Mockup_Test.tmRoleDeveloperNameDiff,ParentRoleId=ahRole.Id);
            insert tmRole;

            User tmUser = Mockup_Test.newUser(
                Mockup_Test.userFirstNameTMDiff,
                Mockup_Test.userLastNameTMDiff,
                true,
                'FirstNameTMDiff@mail.com',
                'FirstNameTMDiff@mail.com',
                'tmUser',
                tmProfileId,
                tmRole.Id,
                ahUser.Id,
                userEmpIdTMDiff
            );
            insert tmUser;
            
            UserRole rmRole = new UserRole(Name='AreaRmDiff',DeveloperName=Mockup_Test.rmRoleDeveloperNameDiff,ParentRoleId=tmRole.Id);
            insert rmRole;

            User rmUser = Mockup_Test.newUser(
                Mockup_Test.userFirstNameRMDiff,
                Mockup_Test.userLastNameRMDiff,
                true,
                'FirstNameRMDiff@mail.com',
                'FirstNameRMDiff@mail.com',
                'rmUser',
                rmProfileId,
                rmRole.Id,
                tmUser.Id,
                userEmpIdRMDiff
            );
            insert rmUser;
        }
        return this;
    }
    public static User newUser(String firstName, String lastName, String employeeId, Boolean isActive, String profileId, String roleId, String managerId) {
        return  Mockup_Test.newUser(
                    firstName,
                    lastName,
                    isActive,
                    firstName+'@mail.com',
                    firstName+'@mail.com',
                    firstName.subString(0,4),
                    profileId,
                    roleId,
                    managerId,
                    employeeId
                );
    }
    public static User newUser(String firstName,String lastName,Boolean active,String userName,String email,String alias,String profileId,String roleId,String managerId,String emId) {
        User user = new User(
            FirstName = firstName,
            LastName = lastName,
            IsActive = active,
            Username = userName,
            Email = email,
            Alias = alias,
            TimeZoneSidKey = 'Asia/Bangkok',
            LocaleSidKey = 'th_TH',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = profileId,
            UserRoleId = roleId,
            ManagerId = managerId,
            Employee_ID__c = emId
        );
        return user;
    }
    public static User_Structure__c newUserStructure(String employeeId, String nhRcCode, String ahRcCode, String rcCode, String firstName, String lastName, String jobCode, String statusCode, Date effectiveDate) {
        User_Structure__c userStruc = new User_Structure__c(              
                Name = employeeId,
                NH_RC_Code__c = nhRcCode,
                AH_RC_Code__c = ahRcCode,
                RC_Code__c = rcCode,
                First_Name__c = firstName,
                Last_Name__c = lastName,
                Username__c = firstName +'@email.com',
                Email__c = firstName + '@email.com',
                Job_Code__c = jobCode,
                Status__c = statusCode,
                Effective_Date__c = effectiveDate
            );
        return userStruc;
    }
    public Mockup_Test newAccount(String accountName,String portPool,String recordTypeId) {
        insert new Account(
            Name = accountName,
            Port_Pool__c = portPool,
            RecordTypeId = recordTypeId,
            Primary_Segment_Code__c = 'SM'
        );
        return this;
    }
    public Mockup_Test newAccount(String accountName,String portPool,String ownershipText,String recordTypeId) {
        insert new Account(
            Name = accountName,
            Port_Pool__c = portPool,
            RecordTypeId = recordTypeId,
            Ownership_Text__c = ownershipText,
            Primary_Segment_Code__c = 'SM'
        );
        return this;
    }
    public Mockup_Test newAccountWithPreviousOwner(String accountName,String portPool,Id previousOwnerId,Id permanentOwnerId,String recordTypeId) {
        insert new Account(
            Name = accountName,
            Port_Pool__c = portPool,
            RecordTypeId = recordTypeId,
            Previous_Owner__c = previousOwnerId,
            Permanent_Owner__c = permanentOwnerId,
            Primary_Segment_Code__c = 'SM'
        );
        return this;
    }
    public Mockup_Test newAccountWithContact(String accountName,String contactName,String contactLastName,String portPool,String recordTypeId) {
        Account acc = new Account(
            Name = accountName,
            Port_Pool__c = portPool,
            RecordTypeId = recordTypeId
        );
        insert acc;
        insert new Contact(
            AccountId = acc.Id,
            Contact_Firstname__c = contactName,
            LastName = contactLastName,
            Phone_Number__c = '0000000000'
        );

        return this;
    }
    public static UserRole newRole(String name,String devName,String parentId) {
        return new UserRole(Name=name,DeveloperName=devName,ParentRoleId=parentId);
    }
    public static Campaign newCampaign(Id ownerId,String cname, Datetime startDateTime, Datetime endDateTime, Datetime attendeeDateTime, String status, String recTypeName,String ctype) {
        Campaign cmp =  new Campaign(
            OwnerId = ownerId,
            Name = cname,
            Lead_Campaign_Event_Code__c = cname.trim(),
            Start_Date_Time__c = startDateTime,
            End_Date_Time__c = endDateTime,
            Attendee_Confirmation_Date__c = attendeeDateTime,
            Status = status,
            RecordTypeId = getRecordTypeCampaignIdByName(recTypeName),
            Type__c = ctype
        );
        return cmp;
    }
    public static void newEvent(Id whatId, Datetime startDateTime, Datetime endDateTime) {
        insert new Event(
            StartDateTime = startDateTime,
            EndDateTime = endDateTime,
            WhatId = whatId
        );
    }
    public static void newCustomerRequest(Id accountId,String status,Id ownerId,String type,String reqOwnerType) {
        insert new Customer_Ownership_Request__c(
            CIS_ID__c = accountId,
            Approval_Status__c = status,
            Current_Owner__c = ownerId,
            OwnerId = ownerId,
            Request_Type__c = type,
            Reason__c = 'reason',
            Request_Ownership_Type__c = reqOwnerType
        );
    }
    public static void newAccountShare(Id userGroupId,Id accountId,String accountAccesslvl,String opAccesslvl) {
        insert new AccountShare(
            UserOrGroupId = userGroupId,
            AccountId = accountId,
            AccountAccessLevel = accountAccesslvl,
            OpportunityAccessLevel = opAccesslvl
        );
    }
    public static Opportunity newOpportunity(Id accId, String name, String stageName, String subMissionCh) {
        Opportunity opp = new Opportunity(
            AccountId   = accId,
            Name        = name,
            StageName   = stageName,
            Submission_Channel__c   = subMissionCh,
            Credit_Model__c = 'DLA',
            Submit_Issue__c = 'New Credit',
            Amount      = 10,
            CloseDate   = System.today() + 7,
            Tentative_Application_Submit_Date__c = System.today() + 7
        );
        return opp;
    }
    public static Task newTask(Id ownerId,Id taskWhatId) {
        Task newTask =  new Task(
            OwnerId = ownerId,
            WhatId = taskWhatId
        );
        return newTask;
    }
}