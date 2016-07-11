/**
 * @author: komsan.wi@beryl8.com.com
 * @komsan.wi: 24/07/2015 create new
 */
global without sharing class Ownership_Service {
    global static Boolean fromTrigger = false;
    global static List<Customer_Ownership_Request__Share> shareRecordToUpdate;
    global static Map<Id, User_Extension__c>  userExtensionMap;

    global class Response{
        webservice String recordId{get;set;}
        webservice Boolean success{get;set;}
        webservice String msg{get;set;}
    }
    global class OwnershipException extends Exception{}

    public static Account releaseOwnership(Account accountObj) {
        if(Ownership_Service.userExtensionMap == null)
            Ownership_Service.userExtensionMap = new Map<Id, User_Extension__c>([SELECT Id, User__c FROM User_Extension__c]);

        User assignUser;
        if(Ownership_Service.userExtensionMap.containsKey(accountObj.Permanent_Owner_Extension__c)) {
            assignUser = [SELECT Id,IsActive,Profile.Name,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.IsActive,Manager.Manager.IsActive,Manager.Manager.Manager.IsActive FROM User WHERE Id=:Ownership_Service.userExtensionMap.get(accountObj.Permanent_Owner_Extension__c).User__c];
        }            

        String currentOwner;
        if(assignUser != null && assignUser.IsActive && assignUser.Profile.Name != GlobalConstants.SME_RM)
            currentOwner = assignUser.Id;
        else if(assignUser != null && assignUser.Manager != null && assignUser.Manager.IsActive)
            currentOwner = assignUser.ManagerId;
        else if(assignUser != null && assignUser.Manager.Manager != null && assignUser.Manager.Manager.IsActive)
            currentOwner = assignUser.Manager.ManagerId;
        else if(assignUser != null && assignUser.Manager.Manager.Manager != null && assignUser.Manager.Manager.Manager.IsActive)
            currentOwner = assignUser.Manager.Manager.ManagerId;
        else
            currentOwner = SME_Admin__c.getOrgDefaults().User_Record_ID__c;
        
        accountObj.OwnerId = currentOwner;
        accountObj.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
        Account_OwnerChange_Service.isChangeOwnership = true;

        return accountObj;
    }

    webservice static Response releaseTemporaryOwnership(String accountString,String adminUserId){
        Response res = new Response();
        try{
            Account accountObj = (Account)JSON.deserialize(accountString,Account.class);

            //accountObj.Customer_Owner_Release_Flag__c = true;
            accountObj.Temp_Owner_Changed_Date__c = System.today();
            accountObj.OwnerChangeExecutedByTrigger__c = true;
            
            List<User_Extension__c> userExtList = new List<User_Extension__c>();
            userExtList = [SELECT Id, User__c FROM User_Extension__c WHERE Id = :accountObj.Permanent_Owner_Extension__c];

            User assignUser;
            if(userExtList.size() > 0)
                assignUser = [SELECT Id,IsActive,Profile.Name,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,Manager.IsActive,Manager.Manager.IsActive,Manager.Manager.Manager.IsActive FROM User WHERE Id=:userExtList.get(0).User__c];
            /*if (accountObj.RecordTypeId == GlobalUtility.getRecordTypeAccountIdByName(GlobalConstants.SME_PROSPECT) || accountObj.Previous_Owner__c==null)
                accountObj.OwnerId = adminUserId;
            else */
            // Change Phase 2
            //if(accountObj.Previous_Owner__c!=null)
            //    accountObj.OwnerId = accountObj.Previous_Owner__c;
            String currentOwner;
            if(assignUser != null && assignUser.IsActive && assignUser.Profile.Name != GlobalConstants.SME_RM)
                currentOwner = assignUser.Id;
            else if(assignUser != null && assignUser.Manager != null && assignUser.Manager.IsActive)
                currentOwner = assignUser.ManagerId;
            else if(assignUser != null && assignUser.Manager.Manager != null && assignUser.Manager.Manager.IsActive)
                currentOwner = assignUser.Manager.ManagerId;
            else if(assignUser != null && assignUser.Manager.Manager.Manager != null && assignUser.Manager.Manager.Manager.IsActive)
                currentOwner = assignUser.Manager.Manager.ManagerId;
            else
                currentOwner = adminUserId;
            
            accountObj.OwnerId = currentOwner;
            accountObj.Ownership_Text__c = GlobalConstants.OWNERSHIP_PERMANENT;
            Account_OwnerChange_Service.isChangeOwnership = true;
            Account_OwnerChange_Service.callingFromYearEndBatch = false;
            update accountObj;

            res.recordId = accountObj.Id;
            res.success = true;
        }catch(Exception ex){
            res.success = false;
            res.msg = ex.getMessage();
        }
        return res;
    }
    global static Customer_Ownership_Request__c releaseOwnership(Account accountObj, User userObj){
        Customer_Ownership_Request__c ownerObj;
        User_Admin__c userAdmin;
        if(Ownership_Service.fromTrigger){
            ownerObj = (Customer_Ownership_Request__c)Trigger.new.get(0);
        }else ownerObj = new Customer_Ownership_Request__c();
        Savepoint sp = Database.setSavepoint();
        try{
            User requestorUser = [SELECT Id,
            ManagerId,
            Manager.Profile.Name,
            Manager.ManagerId,
            Manager.Manager.Profile.Name,
            Manager.IsActive,
            Manager.Manager.ManagerId,
            Manager.Manager.IsActive,
            Manager.Manager.Email,
            Manager.Manager.Manager.Email,
            Manager.Manager.Manager.Profile.Name,
            Manager.Manager.Manager.IsActive,
            Profile.Name,Email,AH_Employee_ID__c,NH_Employee_ID__c FROM User WHERE IsActive = true AND Id=:accountObj.OwnerId];
            
            String tmRequestor;
            String ahRequestor;
            String nhRequestor;
            String requestorManager;

            ownerObj.Request_Type__c = GlobalConstants.RELEASE_OWNERSHIP;
            if(requestorUser !=null){

                if(requestorUser.Profile.Name == GlobalConstants.SME_TM) {
                    tmRequestor = requestorUser.Id;
                } else if(requestorUser.Profile.Name == GlobalConstants.SME_AH) {
                    ahRequestor = requestorUser.Id;
                } else if(requestorUser.Profile.Name == GlobalConstants.SME_NH) {
                    nhRequestor = requestorUser.Id;
                }

                if(requestorUser.Manager!=null && requestorUser.Manager.IsActive) {
                    if(requestorUser.Manager.Profile.Name == GlobalConstants.SME_TM) {
                        tmRequestor = requestorUser.ManagerId;
                    } else if(requestorUser.Manager.Profile.Name == GlobalConstants.SME_AH) {
                        ahRequestor = requestorUser.ManagerId;
                    } else if(requestorUser.Manager.Profile.Name == GlobalConstants.SME_NH) {
                        nhRequestor = requestorUser.ManagerId;
                    }
                }

                if(requestorUser.Manager.Manager!=null && requestorUser.Manager.Manager.IsActive) {
                    if(requestorUser.Manager.Manager.Profile.Name == GlobalConstants.SME_AH) {
                        ahRequestor = requestorUser.Manager.ManagerId;
                    } else if(requestorUser.Manager.Manager.Profile.Name == GlobalConstants.SME_NH) {
                        nhRequestor = requestorUser.Manager.ManagerId;
                    }
                }

                if(requestorUser.Manager.Manager.Manager!=null && requestorUser.Manager.Manager.Manager.IsActive) {
                    if(requestorUser.Manager.Manager.Manager.Profile.Name == GlobalConstants.SME_NH) {
                        nhRequestor = requestorUser.Manager.Manager.ManagerId;
                    }
                }

                userAdmin = User_Admin__c.getOrgDefaults();
                ownerObj.CIS_ID__c = accountObj.Id;
                ownerObj.OwnerID = userObj.Id;
                ownerObj.Requestor_TM__c = tmRequestor;
                ownerObj.Requestor_AH__c = ahRequestor;
                ownerObj.Requestor_NH__c = nhRequestor;
                ownerObj.User_Admin__c = userAdmin.User_Record_ID__c;

                if(ownerObj.Refer_Out_Reason__c == 'Wrong Area' || ownerObj.Refer_Out_Reason__c == 'Other Team') {
                    List<User_Extension__c> userExtList = new List<User_Extension__c>();
                    if(ownerObj.Refer_Out_Team__c != null){
                        userExtList = [SELECT Id, User__c FROM User_Extension__c WHERE Team_Structure__r.Name = :ownerObj.Refer_Out_Team__c];
                    }

                    User assignUser;
                    if(userExtList.size() > 0)
                        assignUser = [SELECT Id,IsActive,
                        ManagerId,
                        Manager.Profile.Name,
                        Manager.ManagerId,
                        Manager.Manager.Profile.Name,
                        Manager.IsActive,
                        Manager.Manager.ManagerId,
                        Manager.Manager.IsActive,
                        Manager.Manager.Email,
                        Manager.Manager.Manager.Email,
                        Manager.Manager.Manager.Profile.Name,
                        Manager.Manager.Manager.IsActive,
                        Profile.Name,Email,AH_Employee_ID__c,NH_Employee_ID__c FROM User WHERE Id=:userExtList.get(0).User__c];

                    String tmTarget;
                    String ahTarget;
                    String nhTarget;
                    String userTarget;
                    
                    if(assignUser != null) {
                        if(assignUser.IsActive && assignUser.Profile.Name == GlobalConstants.SME_TM) {
                            tmTarget = assignUser.Id;
                        } else if(assignUser.Profile.Name == GlobalConstants.SME_AH) {
                            ahTarget = assignUser.Id;
                        } else if(assignUser.Profile.Name == GlobalConstants.SME_NH) {
                            nhTarget = assignUser.Id;
                        }

                        if(assignUser.Manager!=null && assignUser.Manager.IsActive) {
                            if(assignUser.Manager.Profile.Name == GlobalConstants.SME_TM) {
                                tmTarget = assignUser.ManagerId;
                            } else if(assignUser.Manager.Profile.Name == GlobalConstants.SME_AH) {
                                ahTarget = assignUser.ManagerId;
                            } else if(assignUser.Manager.Profile.Name == GlobalConstants.SME_NH) {
                                nhTarget = assignUser.ManagerId;
                            }
                        }

                        if(assignUser.Manager.Manager!=null && assignUser.Manager.Manager.IsActive) {
                            if(assignUser.Manager.Manager.Profile.Name == GlobalConstants.SME_AH) {
                                ahTarget = assignUser.Manager.ManagerId;
                            } else if(assignUser.Manager.Manager.Profile.Name == GlobalConstants.SME_NH) {
                                nhTarget = assignUser.Manager.ManagerId;
                            }
                        }

                        if(assignUser.Manager.Manager.Manager!=null && assignUser.Manager.Manager.Manager.IsActive) {
                            if(assignUser.Manager.Manager.Manager.Profile.Name == GlobalConstants.SME_NH) {
                                nhTarget = assignUser.Manager.Manager.ManagerId;
                            }
                        }

                        if(assignUser.Profile.Name != GlobalConstants.SME_RM && assignUser.IsActive)
                            userTarget = assignUser.Id;
                        else if(tmTarget!=null)
                            userTarget = tmTarget;
                        else if(ahTarget!=null)
                            userTarget = ahTarget;
                        else if(nhTarget!=null)
                            userTarget = nhTarget;
                    }

                    ownerObj.Current_Owner__c = userTarget;
                    ownerObj.Current_Owner_TM__c = tmTarget;
                    ownerObj.Current_Owner_AH__c = ahTarget;
                    ownerObj.Current_Owner_NH__c = nhTarget;
                } else {
                    if(tmRequestor!=null) 
                        requestorManager = tmRequestor;
                    else if(ahRequestor!=null) 
                        requestorManager = ahRequestor;
                    else if(nhRequestor!=null) 
                        requestorManager = nhRequestor;
                    
                    ownerObj.Current_Owner_TM__c = tmRequestor;
                    ownerObj.Current_Owner_AH__c = ahRequestor;
                    ownerObj.Current_Owner_NH__c = nhRequestor;

                    if(ownerObj.Refer_Out_Reason__c == 'TM Pool') {
                        ownerObj.Current_Owner__c = requestorManager;
                    } else {
                        ownerObj.Current_Owner__c = accountObj.OwnerId;    
                    }
                }
            }
            if(!Ownership_Service.fromTrigger)
                insert ownerObj;

            if(tmRequestor!=null) 
                requestorManager = tmRequestor;
            else if(ahRequestor!=null) 
                requestorManager = ahRequestor;
            else if(nhRequestor!=null) 
                requestorManager = nhRequestor;

            if(!Ownership_Service.fromTrigger){
                List<Customer_Ownership_Request__Share> ownershipShareList = new List<Customer_Ownership_Request__Share>();
                Customer_Ownership_Request__Share ownerShareObj;

                if(ownerObj.Current_Owner__c != ownerObj.OwnerID){
                    ownerShareObj = new Customer_Ownership_Request__Share();
                    ownerShareObj.ParentId = ownerObj.Id;
                    ownerShareObj.UserOrGroupId = ownerObj.Current_Owner__c;
                    ownerShareObj.AccessLevel = 'Read';
                    ownerShareObj.RowCause = 'Manual';
                    ownershipShareList.add(ownerShareObj);
                }

                if(requestorManager != ownerObj.OwnerID){
                    ownerShareObj = new Customer_Ownership_Request__Share();
                    ownerShareObj.ParentId = ownerObj.Id;
                    ownerShareObj.UserOrGroupId = requestorManager;
                    ownerShareObj.AccessLevel = 'Read';
                    ownerShareObj.RowCause = 'Manual';
                    ownershipShareList.add(ownerShareObj);
                }
                
                insert ownershipShareList;
            }else {
                Ownership_Service.shareRecordToUpdate = new List<Customer_Ownership_Request__Share>();
                Customer_Ownership_Request__Share ownerShareObj;
                
                if(ownerObj.Current_Owner__c != ownerObj.OwnerID){
                    ownerShareObj = new Customer_Ownership_Request__Share();
                    ownerShareObj.UserOrGroupId = ownerObj.Current_Owner__c;
                    ownerShareObj.AccessLevel = 'Read';
                    ownerShareObj.RowCause = 'Manual';
                    Ownership_Service.shareRecordToUpdate.add(ownerShareObj);
                }

                if(requestorManager != ownerObj.OwnerID){
                    ownerShareObj = new Customer_Ownership_Request__Share();
                    ownerShareObj.UserOrGroupId = requestorManager;
                    ownerShareObj.AccessLevel = 'Read';
                    ownerShareObj.RowCause = 'Manual';
                    Ownership_Service.shareRecordToUpdate.add(ownerShareObj);
                }

            }
        }catch(Exception ex){
            Database.rollback(sp);
            throw new Ownership_Service.OwnershipException(ex.getMessage());
        }
        return ownerObj;
    }
    webservice static Response releaseOwnership(String accountString,String userString){
        Response res = new Response();
        try{
            Account accountObj = (Account)JSON.deserialize(accountString,Account.class);
            User userObj = (User)JSON.deserialize(userString,User.class);
            Customer_Ownership_Request__c resultObj = Ownership_Service.releaseOwnership(accountObj, userObj);

            res.recordId = resultObj.Id;
            res.success = true;
        }catch(Exception ex){
            res.success = false;
            res.msg = ex.getMessage();
        }
        return res;
    }
    global static Customer_Ownership_Request__c createOwnerShip(Account accountObj, User userObj){
        Customer_Ownership_Request__c ownerObj;
        User_Admin__c userAdmin;
        if(Ownership_Service.fromTrigger){
            ownerObj = (Customer_Ownership_Request__c)Trigger.new.get(0);
        }else ownerObj = new Customer_Ownership_Request__c();
        Savepoint sp = Database.setSavepoint();
        try{
            Set<String> recordTypeSet = new Set<String>{
                GlobalConstants.OWNERSHIP_REQUEST_POOL_DEVNAME,
                GlobalConstants.OWNERSHIP_REQUEST_PORT_DEVNAME
            };
            List<RecordType> recordTypeList = [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType ='Customer_Ownership_Request__c' AND DeveloperName IN :recordTypeSet];
            
            String poolRecordTypeId;
            String portRecordTypeId;
            for(RecordType eachRecordType : recordTypeList){
                if(eachRecordType.DeveloperName == GlobalConstants.OWNERSHIP_REQUEST_POOL_DEVNAME) 
                    poolRecordTypeId = eachRecordType.Id;
                if(eachRecordType.DeveloperName == GlobalConstants.OWNERSHIP_REQUEST_PORT_DEVNAME) 
                    portRecordTypeId = eachRecordType.Id;
            }

            if(accountObj.Primary_Segment_Code__c=='SM' || accountObj.Primary_Segment_Code__c=='SR' || accountObj.Primary_Segment_Code__c=='LM' || accountObj.Primary_Segment_Code__c=='LR' || accountObj.Primary_Segment_Code__c=='UM' || accountObj.Primary_Segment_Code__c=='UR') {
                ownerObj.RecordTypeId = portRecordTypeId;
            } else {
                ownerObj.RecordTypeId = poolRecordTypeId;
            }

            User additionUserObj = [SELECT Id,
            ManagerId,
            Manager.Profile.Name,
            Manager.ManagerId,
            Manager.Manager.Profile.Name,
            Manager.IsActive,
            Manager.Manager.ManagerId,
            Manager.Manager.IsActive,
            Manager.Manager.Email,
            Manager.Manager.Manager.Email,
            Manager.Manager.Manager.Profile.Name,
            Manager.Manager.Manager.IsActive,
            Profile.Name,Email,AH_Employee_ID__c,NH_Employee_ID__c FROM User WHERE Id=:userObj.Id];

            String tmRequest;
            String ahRequest;
            String nhRequest;

            //User accountUserRecord = [SELECT Id,
            //ManagerId,
            //Manager.Profile.Name,
            //Manager.ManagerId,
            //Manager.Manager.Profile.Name,
            //Manager.IsActive,
            //Manager.Manager.ManagerId,
            //Manager.Manager.IsActive,
            //Manager.Manager.Email,
            //Manager.Manager.Manager.Email,
            //Manager.Manager.Manager.Profile.Name,
            //Manager.Manager.Manager.IsActive,
            //Profile.Name,Email,AH_Employee_ID__c,NH_Employee_ID__c FROM User WHERE Id=:accountObj.OwnerId];

            //User_Extension__c permanentUserExt;
            //List<User_Extension__c> perUserExtList = new List<User_Extension__c>();
            //if(Ownership_Service.fromTrigger) {
            //    perUserExtList = [SELECT Id,User__c FROM User_Extension__c WHERE Id=:accountObj.Permanent_Owner_Extension__c];
            //}
            //else
            //    perUserExtList = [SELECT Id,User__c FROM User_Extension__c WHERE Name=:accountObj.Permanent_Owner_Extension__c];
            //if(perUserExtList.size() > 0)
            //    permanentUserExt = perUserExtList.get(0);
            ////else 
            ////    throw new Ownership_Service.OwnershipException('Cannot find Permanent Owner User Extension');

            //User permanentUserRecord;
            //List<User> perUserList = new List<User>();
            //if(permanentUserExt!=null)
            //    perUserList = [SELECT Id,
            //    ManagerId,
            //    Manager.Profile.Name,
            //    Manager.ManagerId,
            //    Manager.Manager.Profile.Name,
            //    Manager.IsActive,
            //    Manager.Manager.ManagerId,
            //    Manager.Manager.IsActive,
            //    Manager.Manager.Email,
            //    Manager.Manager.Manager.Email,
            //    Manager.Manager.Manager.Profile.Name,
            //    Manager.Manager.Manager.IsActive,
            //    Profile.Name,Email,AH_Employee_ID__c,NH_Employee_ID__c FROM User WHERE Id = :permanentUserExt.User__c];
            //if(perUserList.size() > 0) {
            //    permanentUserRecord = perUserList.get(0);
            //} 
            


            //String tmCurrentOwner;
            //String ahCurrentOwner;
            //String nhCurrentOwner;
            //String ownerManager;

            if(additionUserObj != null) {
                if(additionUserObj.Profile.Name == GlobalConstants.SME_TM) {
                    tmRequest = additionUserObj.Id;
                } else if(additionUserObj.Profile.Name == GlobalConstants.SME_AH) {
                    ahRequest = additionUserObj.Id;
                } else if(additionUserObj.Profile.Name == GlobalConstants.SME_NH) {
                    nhRequest = additionUserObj.Id;
                }

                if(additionUserObj.Manager!=null && additionUserObj.Manager.IsActive) {
                    if(additionUserObj.Manager.Profile.Name == GlobalConstants.SME_TM) {
                        tmRequest = additionUserObj.ManagerId;
                    } else if(additionUserObj.Manager.Profile.Name == GlobalConstants.SME_AH) {
                        ahRequest = additionUserObj.ManagerId;
                    } else if(additionUserObj.Manager.Profile.Name == GlobalConstants.SME_NH) {
                        nhRequest = additionUserObj.ManagerId;
                    }
                }

                if(additionUserObj.Manager.Manager!=null && additionUserObj.Manager.Manager.IsActive) {
                    if(additionUserObj.Manager.Manager.Profile.Name == GlobalConstants.SME_AH) {
                        ahRequest = additionUserObj.Manager.ManagerId;
                    } else if(additionUserObj.Manager.Manager.Profile.Name == GlobalConstants.SME_NH) {
                        nhRequest = additionUserObj.Manager.ManagerId;
                    }
                }
                if(additionUserObj.Manager.Manager.Manager!=null && additionUserObj.Manager.Manager.Manager.IsActive) {
                    if(additionUserObj.Manager.Manager.Manager.Profile.Name == GlobalConstants.SME_NH) {
                        nhRequest = additionUserObj.Manager.Manager.ManagerId;
                    }
                }
            }

            //User currentAccountOwner;
            //if(ownerObj.Request_Ownership_Type__c == GlobalConstants.POOL_TEMPORARY || ownerObj.RecordTypeId == poolRecordTypeId){
            //    currentAccountOwner = accountUserRecord;
            //} else if(ownerObj.Request_Ownership_Type__c == GlobalConstants.PORT || ownerObj.RecordTypeId == portRecordTypeId) {
            //    currentAccountOwner = permanentUserRecord;
            //}

            //if(currentAccountOwner != null) {
            //    if(currentAccountOwner.Profile.Name == GlobalConstants.SME_TM) {
            //        tmCurrentOwner = currentAccountOwner.Id;
            //    } else if(currentAccountOwner.Profile.Name == GlobalConstants.SME_AH) {
            //        ahCurrentOwner = currentAccountOwner.Id;
            //    } else if(currentAccountOwner.Profile.Name == GlobalConstants.SME_NH) {
            //        nhCurrentOwner = currentAccountOwner.Id;
            //    }

            //    if(currentAccountOwner.Manager!=null && currentAccountOwner.Manager.IsActive) {
            //        if(currentAccountOwner.Manager.Profile.Name == GlobalConstants.SME_TM) {
            //            tmCurrentOwner = currentAccountOwner.ManagerId;
            //        } else if(currentAccountOwner.Manager.Profile.Name == GlobalConstants.SME_AH) {
            //            ahCurrentOwner = currentAccountOwner.ManagerId;
            //        } else if(currentAccountOwner.Manager.Profile.Name == GlobalConstants.SME_NH) {
            //            nhCurrentOwner = currentAccountOwner.ManagerId;
            //        }
            //    }

            //    if(currentAccountOwner.Manager.Manager!=null && currentAccountOwner.Manager.Manager.IsActive) {
            //        if(currentAccountOwner.Manager.Manager.Profile.Name == GlobalConstants.SME_AH) {
            //            ahCurrentOwner = currentAccountOwner.Manager.ManagerId;
            //        } else if(currentAccountOwner.Manager.Manager.Profile.Name == GlobalConstants.SME_NH) {
            //            nhCurrentOwner = currentAccountOwner.Manager.ManagerId;
            //        }
            //    }

            //    if(currentAccountOwner.Manager.Manager.Manager!=null && currentAccountOwner.Manager.Manager.Manager.IsActive) {
            //        if(currentAccountOwner.Manager.Manager.Manager.Profile.Name == GlobalConstants.SME_NH) {
            //            nhCurrentOwner = currentAccountOwner.Manager.Manager.ManagerId;
            //        }
            //    }
            //}

            //if(tmCurrentOwner!=null)
            //    ownerManager = tmCurrentOwner;
            //else if(ahCurrentOwner!=null)
            //    ownerManager = ahCurrentOwner;
            //else if(nhCurrentOwner!=null)
            //    ownerManager = nhCurrentOwner;
            
            ownerObj.Request_Type__c = GlobalConstants.REQUEST_OWNERSHIP;
            ownerObj.CIS_ID__c = accountObj.Id;
            ownerObj.OwnerID = userObj.Id;
            ownerObj.Requestor_TM__c = tmRequest;
            ownerObj.Requestor_AH__c = ahRequest;
            ownerObj.Requestor_NH__c = nhRequest;
            ownerObj.Current_Owner__c = accountObj.OwnerId;
            //ownerObj.Current_Owner_TM__c = tmCurrentOwner;
            //ownerObj.Current_Owner_AH__c = ahCurrentOwner;
            //ownerObj.Current_Owner_NH__c = nhCurrentOwner;
            //ownerObj.Current_Owner_Email_Same_Team__c = (accountObj.OwnerId != userObj.Id && accountObj.RC_Code__c == userObj.RC_Code__c && accountUserRecord.Profile!=null && accountUserRecord.Profile.Name == GlobalConstants.SME_RM)?accountUserRecord.Email:null;
            //ownerObj.Current_Owner_Email_Other_Team__c = (accountObj.OwnerId != userObj.Id && accountObj.RC_Code__c != userObj.RC_Code__c && accountUserRecord.Profile!=null && accountUserRecord.Profile.Name == GlobalConstants.SME_RM)?accountUserRecord.Email:null;
            //ownerObj.Other_Team_NH_Email__c = (additionUserObj.NH_Employee_ID__c != additionUserObj.NH_Employee_ID__c && additionUserObj.Manager!=null && additionUserObj.Manager.Manager!=null && additionUserObj.Manager.Manager.Manager!=null)?additionUserObj.Manager.Manager.Manager.Email:null;
            //ownerObj.Other_Team_AH_Email__c = (additionUserObj.Manager!=null && additionUserObj.Manager.Manager!=null && ((additionUserObj.NH_Employee_ID__c != additionUserObj.NH_Employee_ID__c) || ((additionUserObj.NH_Employee_ID__c == additionUserObj.NH_Employee_ID__c) && (additionUserObj.AH_Employee_ID__c != additionUserObj.AH_Employee_ID__c))))?additionUserObj.Manager.Manager.Email:null;
            
            userAdmin = User_Admin__c.getOrgDefaults();
            ownerObj.User_Admin__c = userAdmin.User_Record_ID__c;

            if(!Ownership_Service.fromTrigger)
                insert ownerObj;
            //UserRecordAccess userRecList = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId =: UserInfo.getUserId() AND RecordId =:ownerObj.Id LIMIT 1];
            
            /*if(userRecList.HasReadAccess){
                throw new Ownership_Service.OwnershipException('You are already have permission to view this customer');
            }*/
            // && !userRecList.HasReadAccess
            //if(ownerObj.Current_Owner__c!=ownerObj.OwnerID && ownerObj.Current_Owner__c!=ownerObj.Requestor_TM__c && ownerObj.Current_Owner__c!=ownerObj.Requestor_AH__c && ownerObj.Current_Owner__c!=ownerObj.Requestor_NH__c && accountUserRecord.Profile.Name != GlobalConstants.SME_ADMIN){
            //    if(!Ownership_Service.fromTrigger){
            //        List<Customer_Ownership_Request__Share> ownershipShareList = new List<Customer_Ownership_Request__Share>();
            //        Customer_Ownership_Request__Share ownerShareObj = new Customer_Ownership_Request__Share();
            //        ownerShareObj.ParentId = ownerObj.Id;
            //        ownerShareObj.UserOrGroupId = accountObj.OwnerId;
            //        ownerShareObj.AccessLevel = 'Read';
            //        ownershipShareList.add(ownerShareObj);

                    //if(ownerManager != null) {
                    //    Customer_Ownership_Request__Share ownerTMShareObj = new Customer_Ownership_Request__Share();
                    //    ownerTMShareObj.ParentId = ownerObj.Id;
                    //    ownerTMShareObj.UserOrGroupId = ownerManager;
                    //    ownerTMShareObj.AccessLevel = 'Read';
                    //    ownershipShareList.add(ownerTMShareObj);
                    //}
                        
                //    insert ownershipShareList;
                //}
                //else {
                //    Ownership_Service.shareRecordToUpdate = new List<Customer_Ownership_Request__Share>();
                //    //ownerShareObj.ParentId = ownerObj.Id;
                //    Customer_Ownership_Request__Share ownerShareObj = new Customer_Ownership_Request__Share();
                //    ownerShareObj.UserOrGroupId = accountObj.OwnerId;
                //    ownerShareObj.AccessLevel = 'Read';
                //    Ownership_Service.shareRecordToUpdate.add(ownerShareObj);

                //    if(ownerManager != null) {
                //        Customer_Ownership_Request__Share ownerTMShareObj = new Customer_Ownership_Request__Share();
                //        ownerTMShareObj.UserOrGroupId = ownerManager;
                //        ownerTMShareObj.AccessLevel = 'Read';
                //        Ownership_Service.shareRecordToUpdate.add(ownerTMShareObj);
                //    }
                //}
            //}
        }catch(Exception ex){
            Database.rollback(sp);
            throw new Ownership_Service.OwnershipException(ex.getMessage());
        }
        return ownerObj;
    }

    global static void updateRequestOwnership(Map<Id,Account> accountMap, User userObj, List<Customer_Ownership_Request__c> ownerRequestList){
        Map<Id,User> allUserMap = new Map<Id, User>([SELECT Id,
                ManagerId,
                Manager.Profile.Name,
                Manager.ManagerId,
                Manager.Manager.Profile.Name,
                Manager.IsActive,
                Manager.Manager.ManagerId,
                Manager.Manager.IsActive,
                Manager.Manager.Email,
                Manager.Manager.Manager.Email,
                Manager.Manager.Manager.Profile.Name,
                Manager.Manager.Manager.IsActive,
                Profile.Name,Email,AH_Employee_ID__c,NH_Employee_ID__c,RC_Code__c FROM User]);
        if(Ownership_Service.userExtensionMap == null)
            Ownership_Service.userExtensionMap = new Map<Id, User_Extension__c>([SELECT Id, User__c FROM User_Extension__c]);

        Account accountObj;
        User currentAccountOwner;
        User_Extension__c permanentUserExt;
        String tmCurrentOwner;
        String ahCurrentOwner;
        String nhCurrentOwner;
        String ownerManager;

        userObj = allUserMap.get(userObj.Id);

        for(Customer_Ownership_Request__c ownerObj : ownerRequestList) {
            if(ownerObj.Request_Type__c != GlobalConstants.REQUEST_OWNERSHIP)
                continue;

            accountObj = accountMap.get(ownerObj.CIS_ID__c);
            currentAccountOwner = allUserMap.get(accountObj.OwnerId);
            //if(ownerObj.Request_Ownership_Type__c == GlobalConstants.POOL_TEMPORARY){
            //    currentAccountOwner = allUserMap.get(accountObj.OwnerId);
            //} else 
            if(ownerObj.Request_Ownership_Type__c == GlobalConstants.PORT) {
                permanentUserExt = Ownership_Service.userExtensionMap.get(accountObj.Permanent_Owner_Extension__c);
                if(permanentUserExt != null)
                    currentAccountOwner = allUserMap.get(permanentUserExt.User__c);
            }

            if(currentAccountOwner != null) {
                if(currentAccountOwner.Profile.Name == GlobalConstants.SME_TM) {
                    tmCurrentOwner = currentAccountOwner.Id;
                } else if(currentAccountOwner.Profile.Name == GlobalConstants.SME_AH) {
                    ahCurrentOwner = currentAccountOwner.Id;
                } else if(currentAccountOwner.Profile.Name == GlobalConstants.SME_NH) {
                    nhCurrentOwner = currentAccountOwner.Id;
                }

                if(currentAccountOwner.Manager!=null && currentAccountOwner.Manager.IsActive) {
                    if(currentAccountOwner.Manager.Profile.Name == GlobalConstants.SME_TM) {
                        tmCurrentOwner = currentAccountOwner.ManagerId;
                    } else if(currentAccountOwner.Manager.Profile.Name == GlobalConstants.SME_AH) {
                        ahCurrentOwner = currentAccountOwner.ManagerId;
                    } else if(currentAccountOwner.Manager.Profile.Name == GlobalConstants.SME_NH) {
                        nhCurrentOwner = currentAccountOwner.ManagerId;
                    }
                }

                if(currentAccountOwner.Manager.Manager!=null && currentAccountOwner.Manager.Manager.IsActive) {
                    if(currentAccountOwner.Manager.Manager.Profile.Name == GlobalConstants.SME_AH) {
                        ahCurrentOwner = currentAccountOwner.Manager.ManagerId;
                    } else if(currentAccountOwner.Manager.Manager.Profile.Name == GlobalConstants.SME_NH) {
                        nhCurrentOwner = currentAccountOwner.Manager.ManagerId;
                    }
                }

                if(currentAccountOwner.Manager.Manager.Manager!=null && currentAccountOwner.Manager.Manager.Manager.IsActive) {
                    if(currentAccountOwner.Manager.Manager.Manager.Profile.Name == GlobalConstants.SME_NH) {
                        nhCurrentOwner = currentAccountOwner.Manager.Manager.ManagerId;
                    }
                }
            }

            if(tmCurrentOwner!=null)
                ownerManager = tmCurrentOwner;
            else if(ahCurrentOwner!=null)
                ownerManager = ahCurrentOwner;
            else if(nhCurrentOwner!=null)
                ownerManager = nhCurrentOwner;
            
            ownerObj.CIS_ID__c = accountObj.Id;
            ownerObj.Current_Owner__c = accountObj.OwnerId;
            ownerObj.Current_Owner_TM__c = tmCurrentOwner;
            ownerObj.Current_Owner_AH__c = ahCurrentOwner;
            ownerObj.Current_Owner_NH__c = nhCurrentOwner;
            ownerObj.Current_Owner_Email_Same_Team__c = (accountObj.OwnerId != userObj.Id && accountObj.RC_Code__c == userObj.RC_Code__c && currentAccountOwner.Profile!=null && currentAccountOwner.Profile.Name == GlobalConstants.SME_RM)?currentAccountOwner.Email:null;
            ownerObj.Current_Owner_Email_Other_Team__c = (accountObj.OwnerId != userObj.Id && accountObj.RC_Code__c != userObj.RC_Code__c && currentAccountOwner.Profile!=null && currentAccountOwner.Profile.Name == GlobalConstants.SME_RM)?currentAccountOwner.Email:null;
            ownerObj.Other_Team_NH_Email__c = (userObj.NH_Employee_ID__c != userObj.NH_Employee_ID__c && userObj.Manager!=null && userObj.Manager.Manager!=null && userObj.Manager.Manager.Manager!=null)?userObj.Manager.Manager.Manager.Email:null;
            ownerObj.Other_Team_AH_Email__c = (userObj.Manager!=null && userObj.Manager.Manager!=null && ((userObj.NH_Employee_ID__c != userObj.NH_Employee_ID__c) || ((userObj.NH_Employee_ID__c == userObj.NH_Employee_ID__c) && (userObj.AH_Employee_ID__c != userObj.AH_Employee_ID__c))))?userObj.Manager.Manager.Email:null;
            
            if(ownerObj.Current_Owner__c != ownerObj.OwnerID && currentAccountOwner.Profile.Name != GlobalConstants.SME_ADMIN){
                Ownership_Service.shareRecordToUpdate = new List<Customer_Ownership_Request__Share>();
                Customer_Ownership_Request__Share ownerShareObj = new Customer_Ownership_Request__Share();
                ownerShareObj.ParentId = ownerObj.Id;
                ownerShareObj.UserOrGroupId = ownerObj.Current_Owner__c;
                ownerShareObj.AccessLevel = 'Read';
                ownerShareObj.RowCause = 'Manual';
                Ownership_Service.shareRecordToUpdate.add(ownerShareObj);

                if(ownerManager != null) {
                    Customer_Ownership_Request__Share ownerTMShareObj = new Customer_Ownership_Request__Share();
                    ownerTMShareObj.ParentId = ownerObj.Id;
                    ownerTMShareObj.UserOrGroupId = ownerManager;
                    ownerTMShareObj.AccessLevel = 'Read';
                    ownerShareObj.RowCause = 'Manual';
                    Ownership_Service.shareRecordToUpdate.add(ownerTMShareObj);
                }
                
            }
        }

        if(Ownership_Service.shareRecordToUpdate != null) {
            insert Ownership_Service.shareRecordToUpdate;
            Ownership_Service.shareRecordToUpdate = null;
        }
        
    }

    webservice static Response createOwnerShip(String accountString,String userString){
        Response res = new Response();
        try{
            Account accountObj = (Account)JSON.deserialize(accountString,Account.class);
            User userObj = (User)JSON.deserialize(userString,User.class);

            Customer_Ownership_Request__c resultObj = Ownership_Service.createOwnerShip(accountObj, userObj);
            res.recordId = resultObj.Id;
            res.success = true;

        }catch(Exception ex){
            res.success = false;
            res.msg = ex.getMessage();
        }
        return res;
    }
}