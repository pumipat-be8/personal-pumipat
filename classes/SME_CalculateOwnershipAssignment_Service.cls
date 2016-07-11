public without sharing class SME_CalculateOwnershipAssignment_Service {
    private static final String ROLE_PREFIX = 'RC';
    private static final Integer LIMIT_SIZE = 2000;
    private static User_Admin__c userAdmin;
    private static Map<String,String> poolVisibilityRoleMap;
    private static Map<String,Set<String>> poolVisibilityGroupMap;
    
    public static Map<Id, User> oldUserMap;

    public static void executeBulkAssignmentBatch() {
        List<Bulk_Assignment_Queue__c> bulkQueue = new List<Bulk_Assignment_Queue__c>();
        bulkQueue = [SELECT Id FROM Bulk_Assignment_Queue__c WHERE Status__c = 'Execute' ORDER BY Name ASC];
        
        List<Bulk_Assignment__c> bulkAssignList = new List<Bulk_Assignment__c>();
        if(bulkQueue.size() > 0)
            bulkAssignList = [SELECT Id, BulkAssignmentQueue__c, CIS_ID__c, Permanent_Owner__c, AssignmentOwner__c, CurrentOwner__c, Port_Pool__c, Ownership__c, Service_RM__c FROM Bulk_Assignment__c WHERE BulkAssignmentQueue__r.Status__c = 'Execute' AND BulkAssignmentQueue__c = :bulkQueue.get(0).Id];

        List<Bulk_Assignment__c> expectedBulkAssign = new List<Bulk_Assignment__c>();
        if(!bulkAssignList.isEmpty()) {
            if(bulkAssignList.size() > LIMIT_SIZE) {
                for(Bulk_Assignment__c eachBulkAssign : bulkAssignList) {
                    expectedBulkAssign.add(eachBulkAssign);
                    if(expectedBulkAssign.size() >= LIMIT_SIZE) {
                        System.enqueueJob(new CalculateOwnershipAssignment_Queue(expectedBulkAssign));
                        expectedBulkAssign.clear();
                    }
                }
                if(expectedBulkAssign.size() > 0) {
                    System.enqueueJob(new CalculateOwnershipAssignment_Queue(expectedBulkAssign));
                    expectedBulkAssign.clear();
                }
            } else {
                System.enqueueJob(new CalculateOwnershipAssignment_Queue(bulkAssignList));
                bulkAssignList.clear();
            }
        }
    }

    public static void assignUserRelatedObject(Map<String, User> userMapByNewRoleRC, Map<String, User_MaskModel> userMaskMapByEmpId, List<Id> queryOwnerIds) {
        userAdmin = User_Admin__c.getOrgDefaults();
        Map<Id, User> newUserMap = new Map<Id, User>([SELECT Id, IsActive, Employee_Id__c, Job_Code__c, Profile.Name, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, 
                    ManagerId, 
                    Manager.ManagerId, 
                    Manager.Manager.ManagerId,
                    Manager.RC_Code__c, 
                    Manager.IsActive, 
                    Manager.Manager.IsActive, 
                    Manager.Manager.Manager.IsActive,
                    Manager.Manager.RC_Code__c, 
                    Manager.Manager.Manager.RC_Code__c,
                    Manager.Job_Code__c, 
                    Manager.Manager.Job_Code__c, 
                    Manager.Manager.Manager.Job_Code__c FROM User WHERE Id IN :queryOwnerIds]);
        
        Map<Id, Bulk_Assignment__c> assignMapByCurrentUser = new Map<Id, Bulk_Assignment__c>();
        User_MaskModel eachMask;
        Bulk_Assignment__c assignObj;

        for(User eachUser : newUserMap.values()) {
            assignObj = new Bulk_Assignment__c();
            eachMask = userMaskMapByEmpId.get(eachUser.Employee_Id__c);
            assignObj.AssignmentOwner__c = SME_CalculateOwnershipAssignment_Service.getAssignOwner(newUserMap, eachMask, userMapByNewRoleRC);
            assignMapByCurrentUser.put(eachUser.Id, assignObj);
        }

        if(!assignMapByCurrentUser.isEmpty()) {
            System.enqueueJob(new CalculateRelatedObject_Queue(assignMapByCurrentUser, newUserMap));
            assignMapByCurrentUser.clear();
        }
    }

    public static List<Account> createBulkAssignment(List<Account> accountList, Map<String, User> userMapByNewRoleRC, Map<String, User_MaskModel> userMaskMapByEmpId, Set<Id> hrisDiffIds , Set<Id> hrisInActiveIds) {
        userAdmin = User_Admin__c.getOrgDefaults();
        Map<Id, Account> updateAccount = new Map<Id, Account>();
        Set<Id> queryOwnerIds = new Set<Id>();
        queryOwnerIds.addAll(hrisDiffIds);
        queryOwnerIds.addAll(hrisInActiveIds);

        System.debug('userMapByNewRoleRC:' + userMapByNewRoleRC);
        getPoolVisibilityMap();

        Map<Id, Bulk_Assignment__c> assignMapByCurrentUser = new Map<Id, Bulk_Assignment__c>();
        User_MaskModel eachMask;
        Bulk_Assignment__c assignObj;

        Map<Id, User> newUserMap = new Map<Id, User>([SELECT Id, Employee_Id__c, Job_Code__c, Profile.Name, RC_Code__c, AH_RC_Code__c, NH_RC_Code__c, 
                    ManagerId, 
                    Manager.ManagerId, 
                    Manager.Manager.ManagerId,
                    Manager.RC_Code__c, 
                    Manager.IsActive, 
                    Manager.Manager.IsActive, 
                    Manager.Manager.Manager.IsActive,
                    Manager.Manager.RC_Code__c, 
                    Manager.Manager.Manager.RC_Code__c,
                    Manager.Job_Code__c, 
                    Manager.Manager.Job_Code__c, 
                    Manager.Manager.Manager.Job_Code__c FROM User WHERE Id IN :queryOwnerIds]);

        for(User eachUser : newUserMap.values()) {
            assignObj = new Bulk_Assignment__c();
            eachMask = userMaskMapByEmpId.get(eachUser.Employee_Id__c);
            assignObj.AssignmentOwner__c = SME_CalculateOwnershipAssignment_Service.getAssignOwner(newUserMap, eachMask, userMapByNewRoleRC);
            assignMapByCurrentUser.put(eachUser.Id, assignObj);
        }

        if(UserExtension_Service.allUserExtMapByUser == null)
            UserExtension_Service.allUserExtMapByUser = UserExtension_Service.getUserExtensionMapByUser();
        if(UserExtension_Service.allTeamMapByRc == null)
            UserExtension_Service.allTeamMapByRc = UserExtension_Service.getAllTeamStructureMapByRC();

        List<Bulk_Assignment__c> bulkAssignList = new List<Bulk_Assignment__c>();
        Boolean needUpdateAccount;
        for(Account eachAccount : accountList) {
            needUpdateAccount = false;
            // Manage Account Related Object
            // ---- Exist Permanent User ----
            if(eachAccount.Permanent_Owner_Extension__r.User__c != eachAccount.OwnerId && queryOwnerIds.contains(eachAccount.Permanent_Owner_Extension__r.User__c)) {
                Id assignUserId = assignMapByCurrentUser.get(eachAccount.Permanent_Owner_Extension__r.User__c).AssignmentOwner__c;
                if(UserExtension_Service.allUserExtMapByUser.containsKey(assignUserId)) {
                    eachAccount.Permanent_Owner_Extension__c = UserExtension_Service.allUserExtMapByUser.get(assignUserId);
                    needUpdateAccount = true;
                }
            }

            // ---- Exist Service RM ----
            if(eachAccount.OwnerId != eachAccount.Service_RM__c && queryOwnerIds.contains(eachAccount.Service_RM__c)) {
                eachAccount.Service_RM__c = null;
                needUpdateAccount = true;
            }

            if(needUpdateAccount)
                updateAccount.put(eachAccount.Id, eachAccount);

            // ---- Exist Owner ----
            if(queryOwnerIds.contains(eachAccount.OwnerId)) {
                // Manage Bulk Assign
                eachMask = userMaskMapByEmpId.get(eachAccount.Owner.Employee_Id__c);

                assignObj = new Bulk_Assignment__c();
                assignObj.CIS_ID__c = eachAccount.Id;
                assignObj.CurrentOwner__c = eachAccount.OwnerId;
                assignObj.Port_Pool__c = eachAccount.Port_Pool__c;
                assignObj.Ownership__c = '';
                assignObj.Service_RM__c = eachAccount.Service_RM__c;

                if(hrisInActiveIds.contains(eachAccount.OwnerId)) {
                    // Case InActive
                    assignObj.AssignmentOwner__c = SME_CalculateOwnershipAssignment_Service.getAssignOwner(newUserMap, eachMask, userMapByNewRoleRC);
                    assignObj.Ownership__c = eachAccount.Ownership_Text__c;
                } else {
                    // Case Move Team
                    if(eachAccount.Ownership_Text__c == GlobalConstants.OWNERSHIP_TEMPORARY) {
                        if(eachMask.userObj.Profile.Name == GlobalConstants.SME_RM) {
                            // Check Visibility
                            String currentGroup;
                            if(eachMask.isChangeRCCode || eachMask.isChangeArea) {
                                if (poolVisibilityRoleMap.containsKey(ROLE_PREFIX + eachMask.previousNHRCCode)) {
                                    currentGroup = poolVisibilityRoleMap.get(ROLE_PREFIX + eachMask.previousNHRCCode);
                                } else if (poolVisibilityRoleMap.containsKey(ROLE_PREFIX + eachMask.previousAHRCCode)) {
                                    currentGroup = poolVisibilityRoleMap.get(ROLE_PREFIX + eachMask.previousAHRCCode);
                                } else if(poolVisibilityRoleMap.containsKey(ROLE_PREFIX + eachMask.previousRCCode)) {
                                    currentGroup = poolVisibilityRoleMap.get(ROLE_PREFIX + eachMask.previousRCCode);
                                }
                            }
                            if(currentGroup!= null) {
                                Set<String> roleSet = poolVisibilityGroupMap.get(currentGroup);
                                if(roleSet.contains(ROLE_PREFIX + eachMask.newRCCode) || roleSet.contains(ROLE_PREFIX + eachMask.newAHRCCode) || roleSet.contains(ROLE_PREFIX + eachMask.newNHRCCode)) {
                                    //Same Group
                                    if(UserExtension_Service.allTeamMapByRc.containsKey(eachMask.newRCCode)) {
                                        eachAccount.Current_Team_Name__c = UserExtension_Service.allTeamMapByRc.get(eachMask.newRCCode);
                                        updateAccount.put(eachAccount.Id, eachAccount);
                                    }
                                    continue;
                                } else {
                                    // Change visibility
                                    assignObj.AssignmentOwner__c = SME_CalculateOwnershipAssignment_Service.getAssignOwner(newUserMap, eachMask, userMapByNewRoleRC);
                                }
                            } else {
                                continue;
                            }
                        } else {
                            assignObj.AssignmentOwner__c = SME_CalculateOwnershipAssignment_Service.getAssignOwner(newUserMap, eachMask, userMapByNewRoleRC);
                        }
                            
                    } else if (eachAccount.Ownership_Text__c == GlobalConstants.OWNERSHIP_PERMANENT) {
                        if(eachMask.isChangeJobCode && !eachMask.isChangeRCCode || 
                        (eachMask.isChangeJobCode && eachMask.isChangeRCCode && !eachMask.isChangeArea) || 
                        (eachMask.isChangeJobCode && eachMask.isChangeRCCode && !eachMask.isChangeNetwork)) {
                            // Promote
                            continue;
                        }
                        assignObj.Ownership__c = eachAccount.Ownership_Text__c;
                        assignObj.AssignmentOwner__c = SME_CalculateOwnershipAssignment_Service.getAssignOwner(newUserMap, eachMask, userMapByNewRoleRC);
                    } else {
                        assignObj.AssignmentOwner__c = userAdmin.User_Record_ID__c;
                    }
                }
                bulkAssignList.add(assignObj);
            }
        }

        System.debug('bulkAssignList:' + bulkAssignList);
        if(!bulkAssignList.isEmpty()) {
            System.enqueueJob(new CalculateOwnershipAssignment_Queue(bulkAssignList,true));
            bulkAssignList.clear();
        }

        return updateAccount.values();
    }

    public static String getAssignOwner(Map<Id, User> newUserMap, User_MaskModel userMask, Map<String, User> userMapByNewRoleRC) {
        if(userMapByNewRoleRC.containsKey(userMask.previousJobCode + '-' + userMask.previousRCCode) && userMapByNewRoleRC.get(userMask.previousJobCode + '-' + userMask.previousRCCode).Status__c != 'I') {
            // Check if have Replace
            return userMapByNewRoleRC.get(userMask.previousJobCode + '-' + userMask.previousRCCode).Id;
        }else {
            // One level up
            User beforeUpdateUser = userMask.userObj;
            User afterUpdateUser = newUserMap.get(beforeUpdateUser.Id);

            if(afterUpdateUser.Manager != null && beforeUpdateUser.Manager != null) {
                // New and Old Manager
                if(userMapByNewRoleRC.containsKey(userMask.previousManagerJobCode + '-' + userMask.previousManagerRCCode)) {
                    return userMapByNewRoleRC.get(userMask.previousManagerJobCode + '-' + userMask.previousManagerRCCode).Id;
                } else if(afterUpdateUser.ManagerId == beforeUpdateUser.ManagerId) {
                    if(afterUpdateUser.Manager.IsActive) {
                        return afterUpdateUser.ManagerId;
                    }
                } else if(beforeUpdateUser.Manager.IsActive) {
                    return beforeUpdateUser.ManagerId;
                }
            }
            if(afterUpdateUser.Manager.Manager != null && beforeUpdateUser.Manager.Manager != null) {
                if(userMapByNewRoleRC.containsKey(userMask.previousManagerManagerJobCode + '-' + userMask.previousManagerManagerRCCode)) {
                    return userMapByNewRoleRC.get(userMask.previousManagerManagerJobCode + '-' + userMask.previousManagerManagerRCCode).Id;
                } else if(afterUpdateUser.Manager.ManagerId == beforeUpdateUser.Manager.ManagerId) {
                    if(afterUpdateUser.Manager.Manager.IsActive) {
                        return afterUpdateUser.Manager.ManagerId;
                    }
                } else if(beforeUpdateUser.Manager.Manager.IsActive) {
                    return beforeUpdateUser.Manager.ManagerId;
                }
            }
            if(afterUpdateUser.Manager.Manager.Manager != null && beforeUpdateUser.Manager.Manager.Manager != null) {
                if(userMapByNewRoleRC.containsKey(userMask.previousManagerManagerManagerJobCode + '-' + userMask.previousManagerManagerManagerRCCode)) {
                    return userMapByNewRoleRC.get(userMask.previousManagerManagerManagerJobCode + '-' + userMask.previousManagerManagerManagerRCCode).Id;
                } else if(afterUpdateUser.Manager.Manager.ManagerId == beforeUpdateUser.Manager.Manager.ManagerId) {
                    if(afterUpdateUser.Manager.Manager.Manager.IsActive) {
                        return afterUpdateUser.Manager.Manager.ManagerId;
                    }
                } else if(beforeUpdateUser.Manager.Manager.Manager.IsActive) {
                    return beforeUpdateUser.Manager.Manager.ManagerId;
                }
            }
            return userAdmin.User_Record_ID__c;
        }
    }

    public static void getPoolVisibilityMap() {
        poolVisibilityRoleMap = new Map<String,String>();
        poolVisibilityGroupMap = new Map<String,Set<String>>();
        List<Pool_Visibility__c> poolVisibilityList =[SELECT Group_Indicate__c,Name FROM Pool_Visibility__c];
        for(Pool_Visibility__c eachPoolVisibility : poolVisibilityList){
            poolVisibilityRoleMap.put(eachPoolVisibility.Name, eachPoolVisibility.Group_Indicate__c);
            if(poolVisibilityGroupMap.containsKey(eachPoolVisibility.Group_Indicate__c)){
                poolVisibilityGroupMap.get(eachPoolVisibility.Group_Indicate__c).add(eachPoolVisibility.Name);
            }else{
                Set<String> roleSet = new Set<String>();
                roleSet.add(eachPoolVisibility.Name);
                poolVisibilityGroupMap.put(eachPoolVisibility.Group_Indicate__c,roleSet);
            }
        }
    }
}