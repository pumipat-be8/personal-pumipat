/**
* @author noppawit.h@beryl8.com
* @28/09/2015 created new
*/
public class ContactTriggerHandler extends TriggerHandler{
	public static String CLASS_NAME = 'ContactTriggerHandler';

	public override void allBefore() {
		checkContactPrimary();
	}

	public override void afterUpdate(){
		if(!Account_OwnerChange_Service.updateContactPrefOnce) {
			Account_OwnerChange_Service.updateContactPrefOnce = true;
			String contactJSON = SME_CIRestWebservice.contactPrefJSONGenerator(Trigger.new);
			if(!system.isBatch())// ContactTriggerHandler.updateContactPrefRequest(contactJSON);
				ContactTriggerHandler.futureUpdateContactPrefRequest(contactJSON);
		}
	}
	private static void updateContactPrefRequest(String contactJSON){
		String functionName = 'afterUpdate';
		String errorMessage;
		SME_UpdateContactPrefResultResponse responseValue;
		try{
			//Call WebService
			responseValue = SME_CIRestWebservice.updateContactPrefRequest(contactJSON);
			System.debug('responseValue :'+ responseValue);
			//responseValue = ContactTriggerHandler.futureUpdateContactPrefRequest(contactJSON);    
		}
		catch(Exception e){
			System.debug('Exception of SME_CIRestWebservice.updateContactPrefRequest :'+e.getMessage());
			errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+e.getMessage()+'Response:'+responseValue;
            GlobalUtility.logMessage('ERROR',CLASS_NAME,functionName,null,null,errorMessage,null,e,null);
		}
	}
	@future (callout=true)
	private static void futureUpdateContactPrefRequest(String contactJSON){
		ContactTriggerHandler.updateContactPrefRequest(contactJSON);
	}

	private void checkContactPrimary() {
		Set<Id> accountIds = new Set<Id>();
		for (Contact eachCon : ((List<Contact>) Trigger.new)) {
			if (eachCon.AccountId != null && eachCon.Primary_Contact__c != null && eachCon.Primary_Contact__c == true) {
				accountIds.add(eachCon.AccountId);
			}	
		}

		List<Contact> allContactList = new List<Contact>();
		allContactList = [SELECT Id, AccountId, Primary_Contact__c FROM Contact WHERE AccountId IN :accountIds AND Primary_Contact__c = true];
		Set<Id> hasPrimaryConAccount = new Set<Id>();
		for (Contact eachCon : allContactList) {
			hasPrimaryConAccount.add(eachCon.AccountId);	
		}

		for (Contact eachCon : ((List<Contact>) Trigger.new)) {
			if (hasPrimaryConAccount.contains(eachCon.AccountId)) {
				if (Trigger.oldMap != null && ((Contact)Trigger.oldMap.get(eachCon.Id)).Primary_Contact__c == eachCon.Primary_Contact__c) {
					// do nothing
				} else {
					eachCon.addError(System.Label.PrimaryContactErrorMessage);
				}
			}	
		}

	}
}