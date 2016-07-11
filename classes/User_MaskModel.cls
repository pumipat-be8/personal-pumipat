global class User_MaskModel {
	public User userObj;
	public User newUserObj;
	public User_Structure__c userStruc;
	public Boolean isChangeJobCode {
		get {
			return (this.newJobCode != this.previousJobCode);	
		}
	}
	public Boolean isChangeRCCode {
		get {
			return (this.newRCCode != this.previousRCCode);
		}
	}
	public Boolean isChangeArea {
		get {
			return (this.newAHRCCode != this.previousAHRCCode);	
		}
	}
	public Boolean isChangeNetwork {
		get {
			return (this.newNHRCCode != this.previousNHRCCode);	
		}
	}
	public String previousRCCode {
		get{
			return userObj.RC_Code__c;
		}
	}
	public String previousManagerRCCode {
		get{
			return userObj.Manager.RC_Code__c;
		}
	}
	public String previousManagerManagerRCCode {
		get{
			return userObj.Manager.Manager.RC_Code__c;
		}
	}
	public String previousManagerManagerManagerRCCode {
		get{
			return userObj.Manager.Manager.Manager.RC_Code__c;
		}
	}
	public String previousAHRCCode{
		get{
			return userObj.AH_RC_Code__c;
		}
	}
	public String previousNHRCCode{
		get{
			return userObj.NH_RC_Code__c;
		}
	}
	public String previousJobCode{
		get{
			return userObj.Job_Code__c;
		}
	}
	public String previousManagerJobCode{
		get{
			return userObj.Manager.Job_Code__c;
		}
	}
	public String previousManagerManagerJobCode{
		get{
			return userObj.Manager.Manager.Job_Code__c;
		}
	}
	public String previousManagerManagerManagerJobCode{
		get{
			return userObj.Manager.Manager.Manager.Job_Code__c;
		}
	}
	public String newRCCode{
		get{
			return userStruc == null ? newUserObj.RC_Code__c : userStruc.RC_Code__c;
		}
	}
	public String newAHRCCode{
		get{
			return userStruc == null ? newUserObj.AH_RC_Code__c : userStruc.AH_RC_Code__c;
		}
	}
	public String newNHRCCode{
		get{
			return userStruc == null ? newUserObj.NH_RC_Code__c : userStruc.NH_RC_Code__c;
		}
	}
	public String newJobCode{
		get{
			return userStruc == null ? newUserObj.Job_Code__c : userStruc.Job_Code__c;
		}
	}
	public User_MaskModel(User userObj) {
		this.userObj = userObj;
	}

	public User_MaskModel setUserStructure(User_Structure__c userStruc){
        this.userStruc = userStruc;
        return this;
    }

    public User_MaskModel setNewUser(User newUser){
        this.newUserObj = newUser;
        return this;
    }
}