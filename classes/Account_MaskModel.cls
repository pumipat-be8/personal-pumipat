/**
* @author komsan.wi@beryl8.com
* @12/07/2015 createddate
*/
public class Account_MaskModel {
    public Account accObj;
    public User ownerUser;
    //public User ownerUser;
    public Id temporaryNewOwnerUserId;
    public Id temporaryPreviousOwnerUserId;
    public User previousOwnerUser;
    //private Id finalOwnerId;
    public Id previousOwnerId{
        get{
            return accObj.OwnerId;
        }
    }
    public Boolean ownerInActive{
        get{
            return !ownerUser.IsActive;
        }
    }
    public Boolean managerOfOwnerActive{
        get{
            return ownerUser.ManagerId!=null && ownerUser.Manager.IsActive;
        }
    }
    public Boolean managerOfManagerOfOwnerActive{
        get{
            return ownerUser.ManagerId!=null && ownerUser.Manager.ManagerId!=null && ownerUser.Manager.Manager.IsActive;
        }
    }
    public Boolean isPoolAccount{
        get{
            return accObj.Port_Pool__c == GlobalConstants.POOL;
        }
    }
    public Boolean isPortAccount{
        get{
            return accObj.Port_Pool__c == GlobalConstants.PORT;
        }
    }
    public Boolean haveToDeletedSharingRule{
        get{
            return Account_Util.isProfile(GlobalConstants.SME_RM,ownerUser) || Account_Util.isProfile(GlobalConstants.SME_TM,ownerUser) ||
                Account_Util.isProfile(GlobalConstants.SME_NH,ownerUser) ||
                Account_Util.isProfile(GlobalConstants.SME_AH,ownerUser);
        }
    }
    public Boolean profileIsNHAndAH{
        get{
            return ownerUser.ProfileId!=null && (ownerUser.Profile.Name==GlobalConstants.SME_NH || ownerUser.Profile.Name==GlobalConstants.SME_AH);
        }
    }
    public Boolean haveToDeletedManualSharing{
        get{
            return profileIsNHAndAH;
        }
    }
    public Boolean haveToUpdateRelatedObject{
        get{
            return accObj.Port_Pool__c == GlobalConstants.PORT || accObj.Port_Pool__c == GlobalConstants.POOL || Account_Util.isProfile(GlobalConstants.SME_ADMIN,ownerUser);
        }
    }
    public Boolean haveReleaseFlag {
        get{
            return accObj.Customer_Owner_Release_Flag__c;
        }
}
    public Account_MaskModel(Account accObj){
        this.accObj = accObj;
    }
    public Account_MaskModel setOwner(User ownerUser){
        this.ownerUser = ownerUser;
        return this;
    }
    public Account_MaskModel setPreviousOwner(User previousOwnerUser){
        this.previousOwnerUser = previousOwnerUser;
        return this;
    }
}