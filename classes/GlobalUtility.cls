/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   A global utility class for common functions
Test Class:    GlobalUtility_Test
History : 
<Date>      <Authors Name>     <Brief Description of Change> 
05/28/2015  Charnun.T           First Create
------------------------------------------------------------*/
public with sharing class GlobalUtility {
    public static Boolean runOnce = false;
    public static Boolean accounFromYearend = false;
    public static Boolean initialMonthly = false;
    public static Boolean resetStatement = false;
    public static final String LEVEL_DEBUG = 'Debug';
    public static final String LEVEL_ERROR = 'Error';
    public static final String LEVEL_INFO = 'Info';
    public static final String LEVEL_WARNING = 'Warning';
    public static final String LOG_NAME_PREFIX = 'ALOG-';
    public static final Map<Integer, String> MONTH_STR_MAP = new Map<Integer, String>{1 =>'Jan', 2=>'Feb', 3=>'Mar',4 =>'Apr', 5=>'May', 6=>'Jun',7 =>'Jul', 8=>'Aug', 9=>'Sep',10 =>'Oct', 11=>'Nov', 12=>'Dec'};
    public static void logMessage(String logLevel, String sourceClass, String sourceFunction, String logMessage, String payLoad, Exception ex, long timeTaken) {           
        
        ApplicationLogWrapper msg = new ApplicationLogWrapper();
        
        msg.source = sourceClass;
        msg.logMessage = logMessage;
        msg.sourceFunction = sourceFunction;
        msg.referenceId = null;
        msg.referenceInfo = '';
        msg.payload = payLoad;
        msg.debugLevel = logLevel;
        msg.ex = ex;
        msg.Timer = timeTaken;

        logMessage( msg );
    }

    public static void logMessage(String logLevel, String sourceClass, String sourceFunction, String referenceId, String referenceInfo, String logMessage, String payLoad, Exception ex, long timeTaken) {
               
        ApplicationLogWrapper msg = new ApplicationLogWrapper();
        
        msg.source = sourceClass;
        msg.logMessage = logMessage;
        msg.sourceFunction = sourceFunction;
        msg.referenceId = referenceId;
        msg.referenceInfo = referenceInfo;
        msg.payload = payLoad;
        msg.debugLevel = logLevel;
        msg.ex = ex;
        msg.Timer = timeTaken;

        logMessage( msg );
        
    }

    public static void logMessage(ApplicationLogWrapper appLog) {   
        
        List<ApplicationLogWrapper> appLogs = new List<ApplicationLogWrapper>();

        appLogs.add ( appLog );
        logMessage ( appLogs );
    }

    public static void logMessage(List<ApplicationLogWrapper> appLogs) {
        
        List<Application_Log__c> insertAppLogs = new List<Application_Log__c>();
        
        for(ApplicationLogWrapper appLog : appLogs){
        
            Application_Log__c log = new Application_Log__c();
            Datetime dt = Datetime.now();
            String formattedDt = dt.format('ddMMyyyy\'T\'hhmmss\'Z\'SSS');
            log.Name = LOG_NAME_PREFIX+formattedDt;
            log.Source__c = appLog.source;
            log.Source_Function__c = appLog.sourceFunction;
            log.Reference_Id__c = appLog.referenceId;
            log.Reference_Information__c = appLog.referenceInfo;
            log.Message__c = appLog.logMessage;
            log.Integration_Payload__c = appLog.payload;
            
            if(appLog.ex != null){
                log.Stack_Trace__c = appLog.ex.getStackTraceString();
                log.Message__c = applog.ex.getMessage();
                //log.Exception_Type__c = applog.ex.getTypeName;
            }
            
            log.Debug_Level__c = appLog.debugLevel;
            log.Log_Code__c = appLog.logCode;
            log.Timer__c = appLog.timer;
            if (isValidInsert(appLog.debugLevel)){
                insertAppLogs.add(log);  
            }

        }

        if ( insertAppLogs.size() != 0){
            insert insertAppLogs;
        }
    }

    public static Boolean isValidInsert(String debugLevel){
        Boolean validInsert = false;
        //optimisation - move these to a global constant
        if(debugLevel == LEVEL_DEBUG && System_Settings__c.getInstance().Debug__c){
            validInsert = true;
        }

        System.Debug('Error Flag:' + System_Settings__c.getInstance().Error__c);
        if(debugLevel == LEVEL_ERROR && System_Settings__c.getInstance().Error__c){
            validInsert = true;
        }

        if(debugLevel == LEVEL_INFO&& System_Settings__c.getInstance().Info__c){
            validInsert = true;
        }
        System.Debug('Warning Flag: ' + System_Settings__c.getInstance().Warning__c);
        if(debugLevel == LEVEL_WARNING && System_Settings__c.getInstance().Warning__c){
            validInsert = true;
        }
        return validInsert;
    }
    public static Boolean isEmailValid(String email) {

        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
        Pattern emailPattern = Pattern.compile(emailRegex);
        Matcher resutlMatcher = emailPattern.matcher(email);

        return resutlMatcher.matches();
    }

    public static void sendTemplatedEmail(String[] toRecipients, String[] ccRecipients, String templateApiName, 
                                          ID targetObjId, Id whatId, ID orgWideEmailId, Boolean saveAsActivity, 
                                          Attachment[] attachList ) {

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Id templateId;

        try {
            templateId = [select id, name from EmailTemplate where developername = : templateApiName].id;
        } catch (Exception e) {
            e.setMessage('[U-03] Unable to locate EmailTemplate using name: ' + templateApiName + 
                                 ' refer to Setup | Communications Templates ' + templateApiName);
            throw e;
        }
        
        email.setToAddresses(toRecipients);
        email.setCcAddresses(ccRecipients);
        email.setTargetObjectId(targetObjId);
        email.setWhatId(whatId);
        email.setorgWideEmailAddressId(orgWideEmailId);
        email.setTemplateId(templateId);
        email.setSaveAsActivity(saveAsActivity);      // save email as activity on the targetObjId (i.e. Contact). Note activity can't be saved on Users

        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            return;
        } catch (EmailException e) {
            e.setMessage('[U-02] sendTemplatedEmail error. ' + e.getMessage());
            throw e;
        }
      
    }

    public static Map<String, Id> getRecordTypeMapByDevNameFromSObject(String sObjectName){
        Map<String, Id> resultsMap = new Map<String, Id>();
        List<RecordType> results = new List<RecordType>();
        results = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType =:sObjectName];
        if(!results.isEmpty()) {
            for(RecordType eachRecordType : results) {
                resultsMap.put(eachRecordType.DeveloperName, eachRecordType.Id);
            }
        }
        return resultsMap;
    }

    public static Id getRecordTypeIdFromSObjectByDevName(String sObjectName,String recordTypeDevName){
        return [SELECT Id FROM RecordType WHERE SObjectType =:sObjectName AND DeveloperName=:recordTypeDevName][0].Id;
    }
    
    public static Id getRecordTypeCallReportIdByName(String name){
        return (Schema.SObjectType.Call_Report__C.getRecordTypeInfosByName().get(name)!=null)?Schema.SObjectType.Call_Report__C.getRecordTypeInfosByName().get(name).getRecordTypeId():null;
    }
    public static Id getRecordTypeOpportunityIdByName(String name){
        return (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(name)!=null)?Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(name).getRecordTypeId():null;
    }
    public static Id getRecordTypeAccountIdByName(String name){
        return (Schema.SObjectType.Account.getRecordTypeInfosByName().get(name)!=null)?Schema.SObjectType.Account.getRecordTypeInfosByName().get(name).getRecordTypeId():null;
    }
    public static Id getRecordTypeCampaignIdByName(String name){
        return (Schema.SObjectType.Campaign.getRecordTypeInfosByName().get(name)!=null)?Schema.SObjectType.Campaign.getRecordTypeInfosByName().get(name).getRecordTypeId():null;
    }
    public static map<string, sObject> toMap(string field_name, List<sObject> objects){
        map<string, sObject> result = new map<string, sObject>();
        
        for(sObject obj:objects){
            result.put(string.valueOf(obj.get(field_name)), obj);
        }
        return result;
    }

    public static map<string, sObject> toMapLookup(String field_name, String lookup_name, List<sObject> objects){
        map<string, sObject> result = new map<string, sObject>();
        
        for(sObject obj:objects){
            result.put(string.valueOf(obj.getsObject(field_name).get(lookup_name)), obj);
        }
        return result;
    }

    // Encrypt Image path
    public static String getEncryptedData(String cryptoKey, String dataToEncrypt){                              
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', Blob.valueOf(cryptoKey), Blob.valueOf(dataToEncrypt));  
        return EncodingUtil.base64Encode(encryptedData);
    }

    public static String getEncryptedDataWithTransform(String cryptoKey, String dataToEncrypt){
        String encryptImgURL = getEncryptedData(cryptoKey,dataToEncrypt);
        String encodedHex = EncodingUtil.urlEncode(encryptImgURL, 'UTF-8');
        String transformEncodedHex = encodedHex.replace('%', '!');
        return transformEncodedHex;
    }

    public static Boolean isNumberAlphabet(String name){
        Boolean isNumberAlphabet = false;
        String nameRegEx = '(\\d+)';
        Pattern myPattern = Pattern.compile(nameRegEx);
        Matcher myMatcher = myPattern.matcher(name);
        myMatcher.region(0, myMatcher.regionEnd());
        isNumberAlphabet = myMatcher.matches();
        return isNumberAlphabet;
    }

    public static String toCurrency(Object currencyObj) {
        String currencyStr = String.valueOf(currencyObj);
        String s = (Decimal.valueOf(currencyStr==null||currencyStr.trim()==''?'0':currencyStr).setScale(2) + 0.001 ).format();
        return s.substring(0,s.length()-1);
    }

    public static String toAccountType(Object accountObj){
        String accountTypeStr = String.valueOf(accountObj);
        String s;
        if(accountTypeStr == '0' || accountTypeStr == '1' ){
            s = 'บัญชีร่วม';
        }else if(accountTypeStr == '2'){
            s = 'บัญชีเดี่ยว';
        }
        return s;
    }

    public static String toValue(Object val) {
        return val != null ? String.valueOf(val) : '';
    }


    //public static Decimal toDecimal(Object val) {
    //    return val != null ? Decimal.valueOf(val) : 0;
    //}

    public static Decimal toDecimal(String val) {
        return val != null && val != '' ? Decimal.valueOf(val) : 0;
    }

    public static Decimal toDecimal(Decimal val) {
        return val != null ? val : 0;
    }

    public static String toNumber(Object val) {
        String numberString;
        try {
            numberString = String.valueOf(Integer.valueOf(val));
        } catch (Exception ex) {
            System.debug(ex);
            numberString = '0';
        }
        return val != null ? numberString : '0';
    }

    public static String dropLeadingZero(String passedValue) {
        String return_string = null; //return string for passing back
        if (passedValue != null) { //if the passed value is not null
            return_string = passedValue.trim(); //trim the whitespace from the start and end of the value
            Pattern valid_characters = Pattern.compile('([0-9]+)'); //only numbers
            Matcher check_chars = valid_characters.matcher(return_string); //compare the string to the set of valid characters
            if (check_chars.matches()) { //if we have a somewhat valid number
                if (return_string.startsWith('0') && return_string.length() > 1) { //if the string begins with a 0 and the length is greater than 1
                    boolean keepChecking = true; //create a boolean variable
                    while (keepChecking) { //if boolean is true
                        if (return_string.startsWith('0') && return_string.length() > 1) { //if the string begins with 0 and there is more than 1 character
                            return_string = return_string.substring(1); //drop the first character
                        } else { //either the string doesn't begin with 0 or the length is less than or equal to 1
                            keepChecking = false; //stop the loop
                        }
                    }
                }
                if (return_string == '0') { //if the resulting string is now a single '0'
                    return_string = null; //set the string to null
                }
            } else { //otherwise the value passed was not valid
                return_string = null; //set the string to null
            }
        }
        return return_string; //pass back a value
    }

    public static String toDateFormat(String yearStr, String month, String day) {
        Integer year = Integer.valueOf(yearStr);
        if(year > 2400) year = year - 543;
        Date thisDate = Date.newInstance(year, Integer.valueOf(month), Integer.valueOf(day));
        String monthStr = (thisDate.month() < 10 ? '0' : '') + String.valueOf(thisDate.month());
        String dayStr = (thisDate.day() < 10 ? '0' : '') + String.valueOf(thisDate.day());
        return dayStr + '/' + monthStr + '/' + thisDate.year();
    }

    public static String toExportDateFormat(Date inputDate) {
        String returnDate;
        String tempYear = String.valueOf(inputDate.year());
        if(String.valueOf(UserInfo.getLocale()) == 'th_TH'){
            tempYear = String.valueOf(Integer.valueOf(inputDate.year())-543);
        }
        returnDate = String.valueOf(tempYear)+'-'+String.valueOf('0'+String.valueOf(inputDate.month())).right(2)+'-'+String.valueOf('0'+String.valueOf(inputDate.day())).right(2);

        return returnDate;
    }

    public static  Map<String, String> getLocaleDateMap() {
        Map<String, String> locale_map = new Map<String, String>(); //holds the locale to timedate formats
        locale_map.put('ar', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_AE', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_BH', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_JO', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_KW', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_LB', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_SA', 'dd/MM/yyyy hh:mm a');
        locale_map.put('bg_BG', 'yyyy-M-d H:mm');
        locale_map.put('ca', 'dd/MM/yyyy HH:mm');
        locale_map.put('ca_ES', 'dd/MM/yyyy HH:mm');
        locale_map.put('ca_ES_EURO', 'dd/MM/yyyy HH:mm');
        locale_map.put('cs', 'd.M.yyyy H:mm');
        locale_map.put('cs_CZ', 'd.M.yyyy H:mm');
        locale_map.put('da', 'dd-MM-yyyy HH:mm');
        locale_map.put('da_DK', 'dd-MM-yyyy HH:mm');
        locale_map.put('de', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_AT', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_AT_EURO', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_CH', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_DE', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_DE_EURO', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_LU', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_LU_EURO', 'dd.MM.yyyy HH:mm');
        locale_map.put('el_GR', 'd/M/yyyy h:mm a');
        locale_map.put('en_AU', 'd/MM/yyyy HH:mm');
        locale_map.put('en_B', 'M/d/yyyy h:mm a');
        locale_map.put('en_BM', 'M/d/yyyy h:mm a');
        locale_map.put('en_CA', 'dd/MM/yyyy h:mm a');
        locale_map.put('en_GB', 'dd/MM/yyyy HH:mm');
        locale_map.put('en_GH', 'M/d/yyyy h:mm a');
        locale_map.put('en_ID', 'M/d/yyyy h:mm a');
        locale_map.put('en_IE', 'dd/MM/yyyy HH:mm');
        locale_map.put('en_IE_EURO', 'dd/MM/yyyy HH:mm');
        locale_map.put('en_NZ', 'd/MM/yyyy HH:mm');
        locale_map.put('en_SG', 'M/d/yyyy h:mm a');
        locale_map.put('en_US', 'M/d/yyyy h:mm a');
        locale_map.put('en_ZA', 'yyyy/MM/dd hh:mm a');
        locale_map.put('es', 'd/MM/yyyy H:mm');
        locale_map.put('es_AR', 'dd/MM/yyyy HH:mm');
        locale_map.put('es_BO', 'dd-MM-yyyy hh:mm a');
        locale_map.put('es_CL', 'dd-MM-yyyy hh:mm a');
        locale_map.put('es_CO', 'd/MM/yyyy hh:mm a');
        locale_map.put('es_CR', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_EC', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_ES', 'd/MM/yyyy H:mm');
        locale_map.put('es_ES_EURO', 'd/MM/yyyy H:mm');
        locale_map.put('es_GT', 'd/MM/yyyy hh:mm a');
        locale_map.put('es_HN', 'MM-dd-yyyy hh:mm a');
        locale_map.put('es_MX', 'd/MM/yyyy hh:mm a');
        locale_map.put('es_PE', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_PR', 'MM-dd-yyyy hh:mm a');
        locale_map.put('es_PY', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_SV', 'MM-dd-yyyy hh:mm a');
        locale_map.put('es_UY', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_VE', 'dd/MM/yyyy hh:mm a');
        locale_map.put('et_EE', 'd.MM.yyyy H:mm');
        locale_map.put('fi', 'd.M.yyyy H:mm');
        locale_map.put('fi_FI', 'd.M.yyyy H:mm');
        locale_map.put('fi_FI_EURO', 'd.M.yyyy H:mm');
        locale_map.put('fr', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_BE', 'd/MM/yyyy H:mm');
        locale_map.put('fr_CA', 'yyyy-MM-dd HH:mm');
        locale_map.put('fr_CH', 'dd.MM.yyyy HH:mm');
        locale_map.put('fr_FR', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_FR_EURO', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_LU', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_MC', 'dd/MM/yyyy HH:mm');
        locale_map.put('hr_HR', 'yyyy.MM.dd HH:mm');
        locale_map.put('hu', 'yyyy.MM.dd. H:mm');
        locale_map.put('hy_AM', 'M/d/yyyy h:mm a');
        locale_map.put('is_IS', 'd.M.yyyy HH:mm');
        locale_map.put('it', 'dd/MM/yyyy H.mm');
        locale_map.put('it_CH', 'dd.MM.yyyy HH:mm');
        locale_map.put('it_IT', 'dd/MM/yyyy H.mm');
        locale_map.put('iw', 'HH:mm dd/MM/yyyy');
        locale_map.put('iw_IL', 'HH:mm dd/MM/yyyy');
        locale_map.put('ja', 'yyyy/MM/dd H:mm');
        locale_map.put('ja_JP', 'yyyy/MM/dd H:mm');
        locale_map.put('kk_KZ', 'M/d/yyyy h:mm a');
        locale_map.put('km_KH', 'M/d/yyyy h:mm a');
        locale_map.put('ko', 'yyyy. M. d a h:mm');
        locale_map.put('ko_KR', 'yyyy. M. d a h:mm');
        locale_map.put('lt_LT', 'yyyy.M.d HH.mm');
        locale_map.put('lv_LV', 'yyyy.d.M HH:mm');
        locale_map.put('ms_MY', 'dd/MM/yyyy h:mm a');
        locale_map.put('nl', 'd-M-yyyy H:mm');
        locale_map.put('nl_BE', 'd/MM/yyyy H:mm');
        locale_map.put('nl_NL', 'd-M-yyyy H:mm');
        locale_map.put('nl_SR', 'd-M-yyyy H:mm');
        locale_map.put('no', 'dd.MM.yyyy HH:mm');
        locale_map.put('no_NO', 'dd.MM.yyyy HH:mm');
        locale_map.put('pl', 'yyyy-MM-dd HH:mm');
        locale_map.put('pt', 'dd-MM-yyyy H:mm');
        locale_map.put('pt_AO', 'dd-MM-yyyy H:mm');
        locale_map.put('pt_BR', 'dd/MM/yyyy HH:mm');
        locale_map.put('pt_PT', 'dd-MM-yyyy H:mm');
        locale_map.put('ro_RO', 'dd.MM.yyyy HH:mm');
        locale_map.put('ru', 'dd.MM.yyyy H:mm');
        locale_map.put('sk_SK', 'd.M.yyyy H:mm');
        locale_map.put('sl_SI', 'd.M.y H:mm');
        locale_map.put('sv', 'yyyy-MM-dd HH:mm');
        locale_map.put('sv_SE', 'yyyy-MM-dd HH:mm');
        locale_map.put('th', 'M/d/yyyy h:mm a');
        locale_map.put('th_TH', 'd/M/yyyy, H:mm');
        locale_map.put('tr', 'dd.MM.yyyy HH:mm');
        locale_map.put('ur_PK', 'M/d/yyyy h:mm a');
        locale_map.put('vi_VN', 'HH:mm dd/MM/yyyy');
        locale_map.put('zh', 'yyyy-M-d ah:mm');
        locale_map.put('zh_CN', 'yyyy-M-d ah:mm');
        locale_map.put('zh_HK', 'yyyy-M-d ah:mm');
        locale_map.put('zh_TW', 'yyyy/M/d a h:mm');
        return locale_map; //return the map
    }

}