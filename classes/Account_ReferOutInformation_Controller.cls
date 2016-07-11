public without sharing class Account_ReferOutInformation_Controller {
	public Boolean isSF1 {
		get{
			if (String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
			String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
			ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
			(ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') )
			   ) {
				return true;
			} else{
				return false;
			}
		} set;
	}

	private String ON_GOING_RECORD_TYPE_ID;
	public Customer_Ownership_Request__c mysObject {get; set;}
	public List<SelectOption> provinceList = new List<SelectOption>();
	public List<SelectOption> teamList = new List<SelectOption>();
	public String selectedProvince {get; set;}
	public String selectedTeam {get; set;}
	public Boolean disabledFlag {get; set;}
	private ApexPages.StandardController stdController;

	private static final String SELECT_NONE = ' - ';

	public Account_ReferOutInformation_Controller(ApexPages.StandardController stdCtrl) {
		this.ON_GOING_RECORD_TYPE_ID = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Team_Province_Master_Data__c', 'On_Going');
		this.stdController = stdCtrl;
		this.mysObject = (Customer_Ownership_Request__c) stdCtrl.getRecord();

		if (this.mysObject != null && this.mysObject.Id != null){
			this.mysObject = [SELECT Id, Refer_Out_Reason__c, Request_Type__c, Requested_Date__c, Refer_Out_Team__c, Refer_Out_Province__c FROM Customer_Ownership_Request__c WHERE Id = :this.mysObject.Id];
		}
		init();

	}

	private void init() {
		this.mysObject.Request_Type__c = GlobalConstants.RELEASE_OWNERSHIP;
		this.mysObject.Requested_Date__c = System.today();
		if (this.mysObject.CIS_ID__c == null)
			this.mysObject.CIS_ID__c = ApexPages.currentPage().getParameters().get('cisID');
		this.mysObject.RecordTypeId = GlobalUtility.getRecordTypeIdFromSObjectByDevName('Customer_Ownership_Request__c', GlobalConstants.RELEASE_OWNERSHIP_DEVNAME);
		disabledFlag = true;
		getSelectedProvince();
		getSelectedTeam();
		checkSegmentCondition();	
	}
	
	public void checkReasonCondition(){
		Customer_Ownership_Request__c customerOwnerShip = (Customer_Ownership_Request__c) this.stdController.getRecord();
		String selectedReason = customerOwnerShip.Refer_Out_Reason__c;
		String selectedRefSegment = customerOwnerShip.Refer_Out_Segment__c;
		disabledFlag = true;
		if(selectedReason == GlobalConstants.REASON_OTHER_TEAM || selectedReason == GlobalConstants.REASON_WRONG_AREA){
			selectedProvince = SELECT_NONE;
			selectedTeam = SELECT_NONE;
			if(isSelectSegment(selectedRefSegment)){
				disabledFlag = false;
			}
		}else{
			customerOwnerShip.Refer_Out_Segment__c = '';
		}
	}

	public void checkSegmentCondition(){
		Customer_Ownership_Request__c customerOwnerShip = (Customer_Ownership_Request__c) this.stdController.getRecord();
		String selectedRefSegment = customerOwnerShip.Refer_Out_Segment__c;
		if(isSelectSegment(selectedRefSegment)){
			disabledFlag = false;
		}else{
			disabledFlag = true;
			selectedProvince = SELECT_NONE;
			selectedTeam = SELECT_NONE;
			getTeamList();
		}
	}

	public String getSelectedTeam() {
		if (selectedTeam == null && this.mysObject.Refer_Out_Team__c != null) {
			selectedTeam = this.mysObject.Refer_Out_Team__c;
		} else if (selectedTeam == null) {
			selectedTeam = SELECT_NONE;
		}
		return selectedTeam;
	}

	public String getSelectedProvince() {
		if (selectedProvince == null && this.mysObject.Refer_Out_Province__c != null) {
			selectedProvince = this.mysObject.Refer_Out_Province__c;
		} else if (selectedProvince == null) {
			selectedProvince = SELECT_NONE;
		}
		return selectedProvince;
	}

	public List<SelectOption> getProvinceList() {
		Set<String> provinceSet = new Set<String>();
		provinceList = new List<SelectOption>();
		teamList = new List<SelectOption>();
		List<Team_Province_Master_Data__c> provinceObjList = new List<Team_Province_Master_Data__c>();
		Customer_Ownership_Request__c customerOwnerShip = (Customer_Ownership_Request__c) this.stdController.getRecord();
		String selectedRefSegment = customerOwnerShip.Refer_Out_Segment__c;
		String selectReason = customerOwnerShip.Refer_Out_Reason__c;
		if(isSelectSegment(selectedRefSegment) && (selectReason == GlobalConstants.REASON_OTHER_TEAM || selectReason == GlobalConstants.REASON_WRONG_AREA)){
			provinceObjList = [SELECT Id, Province_Name__c, Team_Structure__c, Team_Structure__r.Name, Segment__c FROM Team_Province_Master_Data__c WHERE Team_Structure__c != null AND RecordTypeId = :ON_GOING_RECORD_TYPE_ID AND Segment__c = :selectedRefSegment ORDER BY Province_Name__c];
		}
		provinceList.add(new SelectOption(SELECT_NONE, SELECT_NONE));
		for (Team_Province_Master_Data__c eachProvince : provinceObjList) {
			if (!provinceSet.contains(eachProvince.Province_Name__c)) {
				provinceSet.add(eachProvince.Province_Name__c);
				provinceList.add(new SelectOption(eachProvince.Province_Name__c, eachProvince.Province_Name__c));
			}
			teamList.add(new SelectOption(eachProvince.Team_Structure__c, eachProvince.Team_Structure__r.Name));
		}
		return provinceList;
	}

	public List<SelectOption> getTeamList() {
		teamList = new List<SelectOption>();
		Set<String> teamSet = new Set<String>();
		List<Team_Province_Master_Data__c> provinceObjList = new List<Team_Province_Master_Data__c>();
		Customer_Ownership_Request__c customerOwnerShip = (Customer_Ownership_Request__c) this.stdController.getRecord();
		String selectedRefSegment = customerOwnerShip.Refer_Out_Segment__c;
		String selectReason = customerOwnerShip.Refer_Out_Reason__c;
		if(isSelectSegment(selectedRefSegment) && (selectReason == GlobalConstants.REASON_OTHER_TEAM || selectReason == GlobalConstants.REASON_WRONG_AREA)){
			if (selectedProvince == SELECT_NONE || selectedProvince == null) {
				if(selectedRefSegment == 'ME'){
					provinceObjList = [SELECT Id, Province_Name__c, Team_Structure__c, Team_Structure__r.Name, Segment__c FROM Team_Province_Master_Data__c WHERE Team_Structure__c != null AND RecordTypeId = :ON_GOING_RECORD_TYPE_ID AND Segment__c = :selectedRefSegment AND Team_Structure__r.External_id__c != '99999' AND Team_Structure__r.Name LIKE :(System.Label.Filter_ME_Team +'%') ORDER BY Team_Structure__r.Name];
				}else{
					provinceObjList = [SELECT Id, Province_Name__c, Team_Structure__c, Team_Structure__r.Name, Segment__c FROM Team_Province_Master_Data__c WHERE Team_Structure__c != null AND RecordTypeId = :ON_GOING_RECORD_TYPE_ID AND Segment__c = :selectedRefSegment AND Team_Structure__r.External_id__c != '99999' AND Team_Structure__r.Name LIKE :(System.Label.Filter_SE_Team +'%') ORDER BY Team_Structure__r.Name];
				}
			} else {
				provinceObjList = [SELECT Id, Province_Name__c, Team_Structure__c, Team_Structure__r.Name, Segment__c FROM Team_Province_Master_Data__c WHERE Province_Name__c = :selectedProvince AND Team_Structure__c != null AND RecordTypeId = :ON_GOING_RECORD_TYPE_ID AND Segment__c = :selectedRefSegment ORDER BY Team_Structure__r.Name];
			}
		}

		teamList.add(new SelectOption(SELECT_NONE, SELECT_NONE));
		for (Team_Province_Master_Data__c eachProvince : provinceObjList) {
			if (eachProvince.Team_Structure__c != null && !teamSet.contains(eachProvince.Team_Structure__r.Name)){
				teamSet.add(eachProvince.Team_Structure__r.Name);
				teamList.add(new SelectOption(eachProvince.Team_Structure__r.Name, eachProvince.Team_Structure__r.Name));
			}
		}
		return teamList;
	}

	public PageReference selectProvince() {
		getTeamList();

		return null;
	}

	public void showError (String errorMsg) {
		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
		ApexPages.addMessage(msg);
	}

	public PageReference save() {
		Customer_Ownership_Request__c updateCustomerOwnerShip = (Customer_Ownership_Request__c) this.stdController.getRecord();
		
		if (updateCustomerOwnerShip.Refer_Out_Reason__c == GlobalConstants.REASON_OTHER_TEAM || updateCustomerOwnerShip.Refer_Out_Reason__c == GlobalConstants.REASON_WRONG_AREA) {
			updateCustomerOwnerShip.Refer_Out_Province__c = selectedProvince == SELECT_NONE ? null : selectedProvince;
			updateCustomerOwnerShip.Refer_Out_Team__c = selectedTeam == SELECT_NONE ? null : selectedTeam;
		} else {
			updateCustomerOwnerShip.Refer_Out_Province__c = null;
			updateCustomerOwnerShip.Refer_Out_Team__c = null;
		}
		if(isBlockTeam(selectedTeam)){
			return null;
		}
		return this.stdController.save();
	}

	private Boolean isBlockTeam(String selectedTeam){
		Team_Structure__c listBlockTeam = [SELECT External_Id__C ,Name FROM Team_Structure__c WHERE External_Id__C = '99999'];
		if(listBlockTeam.Name == selectedTeam){
			showError (Schema.Customer_Ownership_Request__c.fields.Refer_Out_Team__c.getDescribe().getLabel() + ':' + System.Label.Cannot_Refer_Out_to_this_Province);
			return true;
		}
		return false;
	}

	private Boolean isSelectSegment(String selectedRefSegment){
		if(selectedRefSegment == 'ME' || selectedRefSegment == 'SE'){
			return true;
		}
		return false;
	}
}