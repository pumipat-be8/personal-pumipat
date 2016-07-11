/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
07/27/2015  Charnun.T       First Create
------------------------------------------------------------*/
public class CustomSettingUtil {

	public static Map<String,String> endPointMap;
	public static Map<String,String> connAttributeMap;
	public static final String TIMEOUT_KEY = 'CITimeout';
	public static final String HTTP_USERNAME_KEY = 'httpUsername';
	public static final String HTTP_PASSWORD_KEY = 'httpPassword';

	public static void readEndpointCustomSettingMap() {
		Map<String,Kbank_Endpoint__c> customSettingMap = Kbank_Endpoint__c.getAll();
		endPointMap = new Map<String,String>();
		System.debug('customSettingMap:'+customSettingMap);
        for (Kbank_Endpoint__c eachEndpoint : customSettingMap.values()) {
       		endPointMap.put(eachEndpoint.Name__c,eachEndpoint.Endpoint__c);
        }
	}

	public static String getEndpointByName(String endPointName) {
		if (endPointMap == null){
			readEndpointCustomSettingMap();
		}
		return endPointMap.get(endPointName);
	}

	public static String getConnectionAttributeByName(String attrKey) {
		if (connAttributeMap == null){
			readConnectionAttributeValue();
		} 
		return connAttributeMap.get(attrKey);
	}


	public static Integer getTimeout() {
		Integer timeout = 5000;
		try{
			System.debug('ConnAttributeMap:'+connAttributeMap);
			timeout = Integer.valueOf(getConnectionAttributeByName(TIMEOUT_KEY));
		} catch(Exception e){
			System.debug(e.getStackTraceString());
		}

		return timeout;
	}

	public static String getHttpUsername() {
		return getConnectionAttributeByName(HTTP_USERNAME_KEY);
	}

	public static String getHttpPassword() {
		return getConnectionAttributeByName(HTTP_PASSWORD_KEY);
	}

	public static void readConnectionAttributeValue() {
		Map<String,ConnectionAttribute__c> customSettingMap = ConnectionAttribute__c.getAll();
		connAttributeMap = new Map<String,String>();
        for (ConnectionAttribute__c eachAttr : customSettingMap.values()) {
       		connAttributeMap.put(eachAttr.Name__c,eachAttr.AttributeValue__c);
		}
		System.debug(connAttributeMap);
	}

	public static String getPurgeTime() {
		return getCustomSettingPurgeDays();
	}

	public static String getCustomSettingPurgeDays() {
		String purgeDays = '30';
		System_Settings__c systemSetting = System_Settings__c.getInstance();
		if(systemSetting.Log_Purge_Days__c != null && systemSetting.Log_Purge_Days__c != 0){
			purgeDays = String.valueOf(Integer.valueOf(systemSetting.Log_Purge_Days__c));
		}

		return purgeDays;
	}

	public static Integer getSearchResults() {
		return getCustomSettingNumberOfSearchResults();
	}

	public static Integer getCustomSettingNumberOfSearchResults() {
		Integer numberOfSearchResults = 30;
		System_Settings__c systemSetting = System_Settings__c.getInstance();
		if(systemSetting.Search_Results__c != null && systemSetting.Search_Results__c != 0){
			numberOfSearchResults = Integer.valueOf(systemSetting.Search_Results__c);
		}

		return numberOfSearchResults;
	}
}