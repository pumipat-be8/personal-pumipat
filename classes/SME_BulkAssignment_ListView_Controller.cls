public without sharing class SME_BulkAssignment_ListView_Controller {

    public Boolean hasError{get;set;}
    public Integer rows{get{return Integer.valueOf(Label.Page_Size);}}

    @TestVisible
    private String staticPrefix = 'extjs_reassign_data';
    public SME_BulkAssignment_ListView_Controller() {
        hasError = false;
    }

    // AH name under correct NH role
    @RemoteAction
    public static ModelExtensions.PicklistByFilterKeyResponse querySelectedAHByNH(ModelExtensions.QueryPickListObj qobj) {
        ModelExtensions.PicklistByFilterKeyResponse resp = new ModelExtensions.PicklistByFilterKeyResponse();
        User currentUser = checkMirrorUser();
        try {
            List<UserRole> userRoleList = [SELECT Id,Name,DeveloperName FROM UserRole WHERE ParentRoleId = :currentUser.UserRoleId];
            if(qobj.extra!=null)
                resp.records.add(new ModelExtensions.PicklistByFilterKey('',Label.YearEnd_ShowAll,''));
            for(UserRole eachUserRole : userRoleList){
                resp.records.add(new ModelExtensions.PicklistByFilterKey(eachUserRole.Id+'',eachUserRole.Name+'',eachUserRole.DeveloperName.replace('RC', '')+''));
            }
        } catch (Exception e) {
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }

    // TM name under correct AH role
    @RemoteAction
    public static ModelExtensions.PicklistByFilterKeyResponse querySelectedTMByAH(ModelExtensions.QueryPickListObj qobj) {
        ModelExtensions.PicklistByFilterKeyResponse resp = new ModelExtensions.PicklistByFilterKeyResponse();
        User currentUser = checkMirrorUser();
        try {
            List<UserRole> userRoleNHList;
            List<UserRole> userRoleList;
            if(qobj.scope!=null){
                userRoleList = [SELECT Id,Name,DeveloperName FROM UserRole WHERE ParentRoleId = :qobj.scope];
            }else{
                userRoleNHList = [SELECT Id FROM UserRole WHERE ParentRoleId = :currentUser.UserRoleId];
                userRoleList = [SELECT Id,Name,DeveloperName FROM UserRole WHERE ParentRoleId IN:userRoleNHList];
            }
            if(qobj.extra!=null)
                resp.records.add(new ModelExtensions.PicklistByFilterKey('',Label.YearEnd_ShowAll,''));
            for(UserRole eachUserRole : userRoleList){
                resp.records.add(new ModelExtensions.PicklistByFilterKey(eachUserRole.Id+'',eachUserRole.Name+'',eachUserRole.DeveloperName.replace('RC', '').replace('RM', '')+''));
            }
        } catch (Exception e) {
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }

    // Same NH level
    // Want to add more filter about only AH
    @RemoteAction
    public static ModelExtensions.PicklistByFilterKeyResponse querySelectedBy(ModelExtensions.QueryPickListObj qobj) {
        System.debug('qobj::'+qobj);
        ModelExtensions.PicklistByFilterKeyResponse resp = new ModelExtensions.PicklistByFilterKeyResponse();
        User currentUser = checkMirrorUser();
        try {
            List<User> finalResult = new List<User>();
            User thisUser;
            if(qobj.scope != null){
                if(qobj.subScope == 'AHLevel'){
                    thisUser = [SELECT UserRoleId,UserRole.ParentRoleId FROM User WHERE UserRoleId = :qobj.scope LIMIT 1];
                }else if(qobj.subScope == 'AHLevelServiceRM'){
                    thisUser = [SELECT UserRoleId,UserRole.ParentRoleId FROM User WHERE UserRoleId = :qobj.scope LIMIT 1];
                }else{
                    thisUser = [SELECT UserRoleId,UserRole.ParentRoleId FROM User WHERE UserRole.ParentRoleId = :qobj.scope LIMIT 1];
                }
            }else{
                thisUser = [SELECT UserRoleId,UserRole.ParentRoleId FROM User WHERE Id = :currentUser.Id LIMIT 1];
            }
            String roleIdQueryString = thisUser.UserRole.ParentRoleId;
            if(qobj.subScope == 'TMLevel' || qobj.subScope == 'TMLevelServiceRM'){
                roleIdQueryString = thisUser.UserRoleId;
            }

            //got ah level or all tm level
            List<User> userSameLevelList;
            if(qobj.subScope == 'ServiceRM'){
                userSameLevelList = Database.query('SELECT Id,Name,Profile.Name FROM User WHERE IsActive=true AND UserRole.ParentRoleId =\''+roleIdQueryString+'\'');
            }else if(qobj.subScope == 'AHLevelServiceRM'){
                userSameLevelList = Database.query('SELECT Id,Name,Profile.Name FROM User WHERE IsActive=true AND UserRole.ParentRoleId =\''+roleIdQueryString+'\'');
            }else if(qobj.subScope == 'AHLevel'){
                userSameLevelList = Database.query('SELECT Id,Name,Profile.Name FROM User WHERE IsActive=true AND (UserRoleId '+' =\''+roleIdQueryString+'\' OR UserRole.ParentRoleId =\''+roleIdQueryString+'\')');
            }else if(qobj.subScope == 'TMLevelServiceRM'){
                userSameLevelList = Database.query('SELECT Id,Name,Profile.Name FROM User WHERE IsActive=true AND (UserRole.ParentRoleId =\''+roleIdQueryString+'\')');
            }else{
                userSameLevelList = Database.query('SELECT Id,Name,Profile.Name FROM User WHERE IsActive=true AND (UserRoleId '+' =\''+roleIdQueryString+'\' OR UserRole.ParentRoleId =\''+roleIdQueryString+'\')');
            }
            if(qobj.selfInclude==null)
                finalResult.addAll(userSameLevelList);

            if(qobj.extra!=null)
                resp.records.add(new ModelExtensions.PicklistByFilterKey('',Label.YearEnd_ShowAll,''));
            for(User eachUser : finalResult){
                resp.records.add(new ModelExtensions.PicklistByFilterKey(eachUser.Id+'',eachUser.Name+' ('+eachUser.Profile.Name+')'+'',eachUser.Profile.Name+''));
            }
        } catch (Exception e) {
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }

    @RemoteAction
    public static ModelExtensions.SavingResponse saveBulkAssignment(SME_BulkAssignment_Model.SavingRequest svobj) {
        ModelExtensions.SavingResponse resp = new ModelExtensions.SavingResponse();
        System.debug('saveBulkAssignment::svobj::'+svobj);
        User currentUser = checkMirrorUser();
        try {
            List<Bulk_Assignment__c> bulkAssignmentSelectedList = new List<Bulk_Assignment__c>();
            Boolean confirmValid = true;
            String bulkAssignmentUserId;
            String ownership;
            String portPool;
            String assignmentOwner;
            String currentOwner;
            String serviceRM;
            String temporaryRM;
            if(svobj.contx=='SAVE_BULK'){
                //referOut
                List<Bulk_Assignment__c> finalList = new List<Bulk_Assignment__c>();
                bulkAssignmentUserId = (svobj.selectName!=null && svobj.selectName.selectedByRMName!=null)?svobj.selectName.selectedByRMName:currentUser.Id;
                portPool = (svobj.selectName!=null && svobj.selectName.portPoolpanel!=null)?svobj.selectName.portPoolpanel:'Port';
                serviceRM = (svobj.selectName!=null && svobj.selectName.serviceRMpanel!=null)?svobj.selectName.serviceRMpanel:null;
                temporaryRM = (svobj.selectName!=null && svobj.selectName.temporaryRMpanel!=null)?svobj.selectName.temporaryRMpanel:null;
                User userData = Database.query('SELECT Id,Name,Profile.Name FROM User WHERE IsActive=true AND Id = \''+ bulkAssignmentUserId + '\'');

                if(userData!=null && bulkAssignmentUserId!=null && bulkAssignmentUserId != '' && portPool!=null && portPool != ''){
                    // Create Queue
                    Bulk_Assignment_Queue__c bulkAssignmentQueue = new Bulk_Assignment_Queue__c();
                    bulkAssignmentQueue.StartTime__c = System.now();
                    bulkAssignmentQueue.Status__c = 'Create';
                    insert bulkAssignmentQueue;

                    if(confirmValid){
                        currentOwner = bulkAssignmentUserId;
                        if(userData.Profile.Name == 'SME-RM' && svobj.gridName == 'reAssignPermanenceGrid'){
                            ownership = 'Permanent';
                            portPool = 'Port';
                            assignmentOwner = bulkAssignmentUserId;
                            currentOwner = bulkAssignmentUserId;
                            serviceRM = null;
                            temporaryRM = null;
                        }else if(svobj.gridName == 'reAssignTemporaryGrid'){
                            ownership = 'Temporary';
                            portPool = 'Pool';
                            assignmentOwner = bulkAssignmentUserId;
                            currentOwner = null;
                            serviceRM = null;
                            temporaryRM = null;
                        }else{
                            if(portPool == 'Port'){
                                ownership = 'Permanent';
                                assignmentOwner = bulkAssignmentUserId;
                            }else{
                                if(serviceRM != null){
                                    ownership = 'Permanent';
                                    assignmentOwner = bulkAssignmentUserId;
                                }else if(temporaryRM != null){
                                    ownership = 'Temporary';
                                    assignmentOwner = temporaryRM;
                                }else{
                                    ownership = 'Permanent';
                                    assignmentOwner = bulkAssignmentUserId;
                                }
                            }
                        }
                        for(String eachCISId : svobj.bulkCISlist){
                            Bulk_Assignment__c tempBulkAssignment = new Bulk_Assignment__c();
                            tempBulkAssignment.Ownership__c = ownership;
                            tempBulkAssignment.Port_Pool__c = portPool;
                            tempBulkAssignment.AssignmentOwner__c = assignmentOwner;
                            tempBulkAssignment.Permanent_Owner__c = currentOwner;
                            tempBulkAssignment.Service_RM__c = serviceRM;
                            tempBulkAssignment.CIS_ID__c = eachCISId;
                            tempBulkAssignment.Status__c = 'New';
                            tempBulkAssignment.BulkAssignmentQueue__c = bulkAssignmentQueue.Id;
                            finalList.add(tempBulkAssignment);
                        }
                        System.debug('finalList::'+finalList);
                        insert finalList;

                        Bulk_Assignment_Queue__c bulkAssignmentQueueUpdate = new Bulk_Assignment_Queue__c(Id=bulkAssignmentQueue.Id);
                        bulkAssignmentQueueUpdate.Status__c = 'Execute';
                        update bulkAssignmentQueueUpdate;
                    }
                }else{
                    confirmValid = false;
                }
            }
            if(!confirmValid){
                resp.success = false;
                resp.duplicate = true;
                resp.errorMessage = Label.Cannotprocessyourrequest;
            }
        } catch (Exception e) {
            resp.success = false;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }

    public static User checkMirrorUser(){
        User currentUser = [SELECT Id,Profile.Name,UserRoleId,RC_Code__c,Employee_ID__c,AH_RC_Code__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.debug('currentUser::'+currentUser);
        if(Account_Util.isProfile(GlobalConstants.SME_ADMIN,currentUser) || Account_Util.isProfile(GlobalConstants.SYSTEM_ADMIN,currentUser) || Account_Util.isProfile('Solar',currentUser)){
            String mirrorUserId = Label.BulkAssign_MirrorUser;
            System.debug('mirrorUserId::'+mirrorUserId);
            if(mirrorUserId != null && mirrorUserId != '' && mirrorUserId != '0'){
                User mirrorUser;
                try{
                    mirrorUser = [SELECT Id,Profile.Name,UserRoleId,RC_Code__c,Employee_ID__c,AH_RC_Code__c FROM User WHERE Id = :mirrorUserId LIMIT 1];
                }catch(Exception e){
                    System.debug('Exception::'+e.getMessage());
                }
                if(mirrorUser != null && mirrorUser.Id != null){
                    currentUser = mirrorUser;
                }
            }
        }
        return currentUser;
    }

    public String getSelectedResource(){
        User currentUser = checkMirrorUser();
        String subfix = '';
        if(Account_Util.isProfile(GlobalConstants.SME_TM,currentUser)){
            subfix = '_tm';
        }else if(Account_Util.isProfile(GlobalConstants.SME_AH,currentUser)){
            subfix = '_ah';
        }else if(Account_Util.isProfile(GlobalConstants.SME_NH,currentUser)){
            subfix = '_nh';
        }
        return staticPrefix + subfix;
    }
    public String getSelectedCountFields(){
        return 'Id,RM_Name__c,Team__c,Final_Team__c,TM_Name__c,Selected_By_Name__c,Selected_By_Team__c';
    }
    
    //Add more
    public String getReAssignPermanenceFields(){
        return 'Id,CIS__c,CIS_Number__c,Owner.Name,Name_Report__c,Credit_Flag__c,Primary_Segment_Code__c,(SELECT District__c,Province__c FROM Addresses__r ORDER BY Name DESC),High_Value__c,Port_Pool__c,Customer_Status__c,Ownership__c,Ownership_Text__c,Current_Owner__c,Current_Owner_Extension__r.Name,Current_Team_Name__r.Name,Permanent_Owner_Extension__r.Name,Permanent_Team_Name__r.Name,Previous_Owner__r.Name,Previous_Owner_Extension__c,Previous_Team_Name__r.Name,Service_RM__r.Name,Customer_s_Business_Code__c,Business_Code_Name_EN__c,Business_Code_Name_TH__c,Business_Details__c,Status__c,Income_To_Bank_Last_1_Month__c,Income_to_Bank_This_Year__c,Income_to_Bank_Last_Year__c,Total_SME_Limit__c,Total_SME_Out__c,Total_SME_Exposure__c,Wallet_Size_Exposure__c,SOW_Exposure__c,Last_Visited_Date__c,Number_of_Visited__c,Last_Visited_By__c,Last_Setup_Date__c,Last_Setup_By__c,Current_Activity__c,Current_Activity_By__c,Owner.RC_Code__c,Owner.AH_RC_Code__c,Owner.NH_RC_Code__c,Permanent_Team_Name__r.RC_Code__c,Permanent_Team_Name__r.AH_RC_Code__c,Permanent_Team_Name__r.NH_RC_Code__c,(SELECT CIS_ID__c,Status__c FROM Bulk_Assignments__r ORDER BY Name DESC LIMIT 1),(SELECT CIS__c,SME_Score__c,Name FROM Behaviour_Scores__r ORDER BY Name)';
    }
    public String getReAssignTemporaryFields(){
        return getReAssignPermanenceFields();
    }
    public String getReAssignOwnedByOtherFields(){
        return getReAssignPermanenceFields();
    }

    public String getReAssignPermanenceFieldsForDes() {
        return 'Id,CIS__c,CIS_Number__c,Name_Report__c,Primary_Segment_Code__c,Credit_Flag__c,High_Value__c,Port_Pool__c,Customer_Status__c,Ownership__c,Ownership_Text__c,Current_Owner__c,Current_Owner_Extension__c,Current_Team_Name__c,Permanent_Owner_Extension__c,Permanent_Team_Name__c,Previous_Owner__c,Previous_Owner_Extension__c,Previous_Team_Name__c,Service_RM__c,Customer_s_Business_Code__c,Business_Code_Name_EN__c,Business_Code_Name_TH__c,Business_Details__c,Status__c,Income_To_Bank_Last_1_Month__c,Income_to_Bank_This_Year__c,Income_to_Bank_Last_Year__c,Total_SME_Limit__c,Total_SME_Out__c,Total_SME_Exposure__c,Wallet_Size_Exposure__c,SOW_Exposure__c,Last_Visited_Date__c,Number_of_Visited__c,Last_Visited_By__c,Last_Setup_Date__c,Last_Setup_By__c,Current_Activity__c,Current_Activity_By__c';
    }
    public String getReAssignTemporaryFieldsForDes(){
        return getReAssignPermanenceFieldsForDes();
    }
    public String getReAssignOwnedByOtherFieldsForDes(){
        return getReAssignPermanenceFieldsForDes();
    }
}