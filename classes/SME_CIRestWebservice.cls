/*------------------------------------------------------------
Author: Sasitorn Saisuttichai
Company : Beryl8
Description:   A webservice class for CI connecting.

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015  Sasitorn.S          First Create
------------------------------------------------------------*/
global class SME_CIRestWebservice {
    
    public static final String CALLOUT_URL = CustomSettingUtil.getEndpointByName('KbankURL');
    public static final String TRANSACTBP_ENDPOINT = CALLOUT_URL + 'SMETransactBPInformation';
    public static final String DEPOSIT_ENDPOINT = CALLOUT_URL + '';
    public static final String SAVING_ENDPOINT = CALLOUT_URL + 'SMESavingDepositInformation';
    public static final String FIXED_ENDPOINT = CALLOUT_URL + 'SMEFixedDepositInformation';
    public static final String CURRENT_ENDPOINT = CALLOUT_URL + 'SMECurrentDepositInformation';
    public static final String MUTUALFUND_ENDPOINT = CALLOUT_URL + 'SMEMutualFundInformation';
    public static final String TAWEESUP_ENDPOINT = CALLOUT_URL + 'SMETaweesupDepositInformation';
    public static final String NON_CREDIT_OUTSTANDING_ENDPOINT = CALLOUT_URL + 'SMEOutstandingNoneCreditInformation';
    public static final String CREDIT_OUTSTANDING_ENDPOINT = CALLOUT_URL + 'SMEOutstandingCreditInformation';
    public static final String SEARCH_ENDPOINT = CALLOUT_URL + 'SMECustomSearch';
    public static final String SORT_ENDPOINT = CALLOUT_URL + 'SMECustomSort';
    public static final String UPDATE_CAMPAIGN_LEAD_ENDPOINT = 'SMEUpdateTargetList';
    public static final String UPDATE_CONTACT_PREF_ENDPOINT = 'SMEUpdateContactPreference';
    public static String CLASS_NAME = 'SME_CIRestWebservice';

    public static HTTPResponse continuationResponse {get;set;}
    public static Object continuationObject;

    //public static String TRANSACTBP_ENDPOINT = 'callout:CITransactBPEndpoint';
    //public static String DEPOSIT_ENDPOINT = 'callout:CIDepositEndpoint';
    //public static String SAVING_ENDPOINT = 'callout:CISavingEndpoint';
    //public static String FIXED_ENDPOINT = 'callout:CIFixedEndpoint';
    //public static String CURRENT_ENDPOINT = 'callout:CICurrentEndpoint';
    //public static String MUTUALFUND_ENDPOINT = 'callout:CIMutualFundEndpoint';
    //public static String TAWEESUP_ENDPOINT = 'callout:CITaweesupEndpoint';
    //public static String NON_CREDIT_OUTSTANDING_ENDPOINT = 'callout:CINonCreditOutStandingEndpoint';
    //public static String CREDIT_OUTSTANDING_ENDPOINT = 'callout:CICreditOutStandingEndpoint';
    //public static String SEARCH_ENDPOINT = 'callout:CISearchEndpoint';
    //public static String SORT_ENDPOINT = 'callout:CISortEndpoint';

    //public static String UPDATE_CAMPAIGN_LEAD_ENDPOINT = 'callout:CIUpdateCampaignLeadEndpoint';
    //public static String UPDATE_CONTACT_PREF_ENDPOINT = 'callout:CIUpdateContactPrefEndpoint';

    public static HttpRequest createTransactBPRequest(String cis) {
        String requestStr = 'IP_ID=' + cis;
        return SME_HTTPCallUtil.createHttpRequest(TRANSACTBP_ENDPOINT, requestStr, 120);
    }

    public static HttpRequest createCreditOutstandingRequest(String cis) {
        String requestStr = 'IP_ID='+cis;
        return SME_HTTPCallUtil.createHttpRequest(CREDIT_OUTSTANDING_ENDPOINT, requestStr, 120);
    }
    
    public static HttpRequest createNonCreditOutstandingRequest(String cis) {
        String requestStr = 'IP_ID='+cis;
        return SME_HTTPCallUtil.createHttpRequest(NON_CREDIT_OUTSTANDING_ENDPOINT, requestStr, 120);
    }

    public static HttpRequest createCurrentDataRequest(String cis) {
        String requestStr = 'IP_ID='+cis;
        return SME_HTTPCallUtil.createHttpRequest(CURRENT_ENDPOINT, requestStr, 120);
    }

    public static HttpRequest createSavingDataRequest(String cis) {
        String requestStr = 'IP_ID='+cis;
        return SME_HTTPCallUtil.createHttpRequest(SAVING_ENDPOINT, requestStr, 120);
    }

    public static HttpRequest createFixedDataRequest(String cis) {
        String requestStr = 'IP_ID='+cis;
        return SME_HTTPCallUtil.createHttpRequest(FIXED_ENDPOINT, requestStr, 120);
    }

    public static HttpRequest createMutualFundDataRequest(String cis) {
        String requestStr = 'IP_ID='+cis;
        return SME_HTTPCallUtil.createHttpRequest(MUTUALFUND_ENDPOINT, requestStr, 120);
    }

    public static HttpRequest createTaweesupDataRequest(String cis) {
        String requestStr = 'IP_ID='+cis;
        return SME_HTTPCallUtil.createHttpRequest(TAWEESUP_ENDPOINT, requestStr, 120);
    }

    webservice static CustomerResponseModel searchCISListByCustomerSearchRequest(CustomerSearchRequestModel searchRequest){
        CustomerResponseModel responseModel = new CustomerResponseModel();
        List<String> cisList = new List<String>();
        String requestStr = null;
        String errorMessage;
        String jsonResponseStr;
        String functionName = 'searchCISListByCustomerSearchRequest';
        // prepare JSON object
        if (searchRequest.requestMap != null) {
            requestStr = getRequestStringFromMap(searchRequest.requestMap);
        }

        HTTPResponse resp = sendHTTPRequest(SEARCH_ENDPOINT,requestStr);

        // handle error 
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        responseModel = getResponseModelFromSearchResultStr(resp.getBody());
        //responseModel = getResponseModelFromSearchResultStr('{"searchResponse":{"cis_id":["1234"]}}');
        return responseModel;
    }

    public static HTTPResponse handleReturnException(HttpResponse returnResp){
        HTTPResponse resp;
        String errorMessage;
        resp = returnResp;
        System.debug('StatusCode = '+resp.getStatusCode());
        if(resp.getStatusCode() != 200) { // 500 = fail
            if(resp.getStatusCode() == 503){
                errorMessage = ExceptionMessage.APPLICATION_SERVER_NOT_AVAILABLE+' Trace: StatusCode:'+resp.getStatusCode()+resp;
            }else if(resp.getStatusCode() == 504){
                errorMessage = ExceptionMessage.APPLICATION_TIMEOUT+' Trace: StatusCode:'+resp.getStatusCode()+resp;
            }else if(resp.getStatusCode() == 401){
                errorMessage = ExceptionMessage.AUTHENTICATION_FAILED+' Trace: StatusCode:'+resp.getStatusCode()+resp;
            }else{
                errorMessage = ExceptionMessage.HTTP_CONNECTION_FAILED+' Trace: StatusCode:'+resp.getStatusCode()+resp;
            }
            throw new CIWebserviceException(errorMessage);
        }
        return resp;
    }
    
    public static HTTPResponse sendHTTPRequest(String endpoint,String requestStr){
        // send request to endpoint
        HTTPResponse resp;
        String errorMessage;
        try {
            resp = SME_HTTPCallUtil.sendHttpCallout(endpoint,requestStr);
        } catch(CalloutException e){
            errorMessage = ExceptionMessage.HTTP_CONNECTION_FAILED+'Endpoint:'+endpoint+' Message:'+e.getMessage()+' Trace:'+e.getStackTraceString();
            throw new CIWebserviceException(errorMessage);
        } catch(Exception e){
            errorMessage = ExceptionMessage.HTTP_CONNECTION_FAILED+'Endpoint:'+endpoint+' Message:'+e.getMessage()+' Trace:'+e.getStackTraceString();
            throw new CIWebserviceException(errorMessage);
        }
        System.debug('StatusCode = '+resp.getStatusCode());
        if(resp.getStatusCode() != 200) { // 500 = fail
            if(resp.getStatusCode() == 503){
                errorMessage = ExceptionMessage.APPLICATION_SERVER_NOT_AVAILABLE+' Endpoint:'+endpoint+' Trace: StatusCode:'+resp.getStatusCode()+resp;
            }else if(resp.getStatusCode() == 504){
                errorMessage = ExceptionMessage.APPLICATION_TIMEOUT+' Endpoint:'+endpoint+' Trace: StatusCode:'+resp.getStatusCode()+resp;
            }else if(resp.getStatusCode() == 401){
                errorMessage = ExceptionMessage.AUTHENTICATION_FAILED+' Endpoint:'+endpoint+' Trace: StatusCode:'+resp.getStatusCode()+resp;
            }else{
                errorMessage = ExceptionMessage.HTTP_CONNECTION_FAILED+' Endpoint:'+endpoint+' Trace: StatusCode:'+resp.getStatusCode()+resp;
            }
            throw new CIWebserviceException(errorMessage);
        }
        return resp;
    }

    public static CustomerResponseModel getResponseModelFromSearchResultStr(String jsonResponseStr){
        CustomerResponseModel responseModel = new CustomerResponseModel();
        String functionName = 'getResponseModelFromSearchResultStr';
        SearchResultResponse searchResult;
        String errorMessage;

        try{
            searchResult = SearchResultResponse.parse(jsonResponseStr);
        }catch(Exception e){
            errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+e.getMessage()+'Response:'+jsonResponseStr;
            throw new CIWebserviceException(errorMessage);
        } 
        if (searchResult != null && searchResult.searchResponse != null){
            if(searchResult.searchResponse.errorMessage != null){
                errorMessage = ExceptionMessage.CI_RESPONSE_ERROR+searchResult.searchResponse.errorMessage;
                throw new CIWebserviceException(errorMessage);
            }else if(searchResult.searchResponse.cis_id != null){
                responseModel.cisList = searchResult.searchResponse.cis_id;
            }else{
                writeDebugMessage(functionName,'Empty Response');
            }
        }
        return responseModel;
    }

    public static CustomerResponseModel getResponseModelFromSortResultStr(String jsonResponseStr){
        CustomerResponseModel responseModel = new CustomerResponseModel();
        String functionName = 'getResponseModelFromSortResultStr';
        String errorMessage;
        SortResultResponse sortResult;

        try{
            sortResult = SortResultResponse.parse(jsonResponseStr);
        }catch(Exception e){
            errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+e.getMessage()+'Response:'+jsonResponseStr;
            throw new CIWebserviceException(errorMessage);
        } 

        if (sortResult != null && sortResult.sortResponse != null){
            if(sortResult.sortResponse.errorMessage != null){
                errorMessage = ExceptionMessage.CI_RESPONSE_ERROR+sortResult.sortResponse.errorMessage;
                throw new CIWebserviceException(errorMessage);
            }else if(sortResult.sortResponse.cis_id != null){
                responseModel.cisList = sortResult.sortResponse.cis_id;
            }else{
                writeDebugMessage(functionName,'Empty Response');
            }
        }
        return responseModel;
    }

    public static String getRequestStringFromMap(Map<String,String> requestMap){
        String resultStr='';
        for(String key:requestMap.keySet()){
            String val = requestMap.get(key);
            if (resultStr != ''){
                resultStr = resultStr+'&&';
            }
            resultStr = resultStr+key+'='+val;
        }

        return resultStr;
    }

    webservice static CustomerResponseModel sortCISListByCustomerSearchRequest(CustomerSearchRequestModel searchRequest){
        CustomerResponseModel responseModel = new CustomerResponseModel();
        List<String> cisList = new List<String>();
        String requestStr;
        String functionName = 'sortCISListByCustomerSearchRequest';
        // prepare JSON object
        if (searchRequest.requestMap != null) {
            requestStr = getRequestStringFromMap(searchRequest.requestMap);
        }

        HTTPResponse resp = sendHTTPRequest(SORT_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        // handle error 
        responseModel = getResponseModelFromSortResultStr(resp.getBody());
        
        return responseModel;
    }

    public static void writeDebugMessage(String sourceFunction,String logMessage){
        String sourceClass = CLASS_NAME;
        String referenceId = null;
        String referenceInfo = null;
        String payload = null;
        Exception ex = null;
        Long timeTaken = null;
        String severity = 'DEBUG';

        GlobalUtility.logMessage(severity,sourceClass,sourceFunction,referenceId,referenceInfo,logMessage,payLoad,ex,timeTaken);
    }

    webservice static SME_TransactBPResultResponse getTransactBPRequest(String cisID){
        SME_TransactBPResultResponse responseModel = new SME_TransactBPResultResponse();
        String requestStr = null;
        String errorMessage;
        String functionName = 'getTransactBPRequest';

        requestStr = 'IP_ID='+cisID;

        HTTPResponse resp = sendHTTPRequest(TRANSACTBP_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        try{
            responseModel = SME_TransactBPResultResponse.parse(jsonResponseStr);
        }catch(Exception e){
            errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+e.getMessage()+'Response:'+jsonResponseStr;
            GlobalUtility.logMessage('ERROR',CLASS_NAME,functionName,null,null,errorMessage,null,e,null);
            throw new CIWebserviceException(errorMessage);
        } 

        return responseModel;
    }
    
    webservice static SME_ProductHoldingResultResponse getDepositRequest(String cisID){
        SME_ProductHoldingResultResponse responseModel = new SME_ProductHoldingResultResponse();
        String requestStr = null;
        String errorMessage;
        String functionName = 'getDepositRequest';

        requestStr = 'IP_ID='+cisID;

        HTTPResponse resp = sendHTTPRequest(DEPOSIT_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        try{
            responseModel = SME_ProductHoldingResultResponse.parse(jsonResponseStr);
        }catch(Exception e){
            errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+e.getMessage()+'Response:'+jsonResponseStr;
            GlobalUtility.logMessage('ERROR',CLASS_NAME,functionName,null,null,errorMessage,null,e,null);
        } 

        return responseModel;
    }

    webservice static SME_SavingResultResponse getSavingRequest(String cisID){
        SME_SavingResultResponse responseModel = new SME_SavingResultResponse();
        String requestStr = null;
        String errorMessage;
        String functionName = 'getSavingRequest';

        requestStr = 'IP_ID='+cisID;

        HTTPResponse resp = sendHTTPRequest(SAVING_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        try{
            responseModel = SME_SavingResultResponse.parse(jsonResponseStr);
        }catch(Exception e){
            errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+e.getMessage()+'Response:'+jsonResponseStr;
            GlobalUtility.logMessage('ERROR',CLASS_NAME,functionName,null,null,errorMessage,null,e,null);
        } 

        return responseModel;
    }

    webservice static SME_FixedResultResponse getFixedRequest(String cisID){
        SME_FixedResultResponse responseModel = new SME_FixedResultResponse();
        String requestStr = null;
        String errorMessage;
        String functionName = 'getFixedRequest';

        requestStr = 'IP_ID='+cisID;

        HTTPResponse resp = sendHTTPRequest(FIXED_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        try{
            responseModel = SME_FixedResultResponse.parse(jsonResponseStr);
        }catch(Exception e){
            errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+e.getMessage()+'Response:'+jsonResponseStr;
            GlobalUtility.logMessage('ERROR',CLASS_NAME,functionName,null,null,errorMessage,null,e,null);
        } 

        return responseModel;
    }

    webservice static SME_CurrentResultResponse getCurrentRequest(String cisID){
        SME_CurrentResultResponse responseModel = new SME_CurrentResultResponse();
        String requestStr = null;
        String errorMessage;
        String functionName = 'getCurrentRequest';

        requestStr = 'IP_ID='+cisID;

        HTTPResponse resp = sendHTTPRequest(CURRENT_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        try{
            responseModel = SME_CurrentResultResponse.parse(jsonResponseStr);
        }catch(Exception e){
            errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+e.getMessage()+'Response:'+jsonResponseStr;
            GlobalUtility.logMessage('ERROR',CLASS_NAME,functionName,null,null,errorMessage,null,e,null);
        } 

        return responseModel;
    }

    webservice static SME_MutualFundResultResponse getMutualFundRequest(String cisID){
        SME_MutualFundResultResponse responseModel = new SME_MutualFundResultResponse();
        String requestStr = null;
        String errorMessage;
        String functionName = 'getMutualFundRequest';

        requestStr = 'IP_ID='+cisID;

        HTTPResponse resp = sendHTTPRequest(MUTUALFUND_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        try{
            responseModel = SME_MutualFundResultResponse.parse(jsonResponseStr);
        }catch(Exception e){
            errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+e.getMessage()+'Response:'+jsonResponseStr;
            GlobalUtility.logMessage('ERROR',CLASS_NAME,functionName,null,null,errorMessage,null,e,null);
        } 

        return responseModel;
    }

    webservice static SME_TaweesupResultResponse getTaweesupRequest(String cisID){
        SME_TaweesupResultResponse responseModel = new SME_TaweesupResultResponse();
        String requestStr = null;
        String errorMessage;
        String functionName = 'getTaweesupRequest';

        requestStr = 'IP_ID='+cisID;

        HTTPResponse resp = sendHTTPRequest(TAWEESUP_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        try{
            responseModel = SME_TaweesupResultResponse.parse(jsonResponseStr);
        }catch(Exception e){
            errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+e.getMessage()+'Response:'+jsonResponseStr;
            GlobalUtility.logMessage('ERROR',CLASS_NAME,functionName,null,null,errorMessage,null,e,null);
        } 

        return responseModel;
    }

    webservice static SME_NonCreditOutStandingResultResponse getNonCreditOutStandingRequest(String cisID){
        SME_NonCreditOutStandingResultResponse responseModel = new SME_NonCreditOutStandingResultResponse();
        String requestStr = null;
        String errorMessage;
        String functionName = 'getNonCreditOutStandingRequest';

        requestStr = 'IP_ID='+cisID;

        HTTPResponse resp = sendHTTPRequest(NON_CREDIT_OUTSTANDING_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        try{
            responseModel = SME_NonCreditOutStandingResultResponse.parse(jsonResponseStr);
        }catch(Exception e){
            errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+e.getMessage()+'Response:'+jsonResponseStr;
            GlobalUtility.logMessage('ERROR',CLASS_NAME,functionName,null,null,errorMessage,null,e,null);
        } 

        return responseModel;
    }

    webservice static SME_CreditOutStandingResultResponse getCreditOutStandingRequest(String cisID){
        SME_CreditOutStandingResultResponse responseModel = new SME_CreditOutStandingResultResponse();
        String requestStr = null;
        String errorMessage;
        String functionName = 'getCreditOutStandingRequest';

        requestStr = 'IP_ID='+cisID;

        HTTPResponse resp = sendHTTPRequest(CREDIT_OUTSTANDING_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        try{
            responseModel = SME_CreditOutStandingResultResponse.parse(jsonResponseStr);
        }catch(Exception e){
            errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+e.getMessage()+'Response:'+jsonResponseStr;
            GlobalUtility.logMessage('ERROR',CLASS_NAME,functionName,null,null,errorMessage,null,e,null);
        } 

        return responseModel;
    }

    webservice static SME_UpdateCampaignLeadResultResponse updateCampaignLeadRequest(List<Target_List__c> updateTargetList){
        SME_UpdateCampaignLeadResultResponse responseModel = new SME_UpdateCampaignLeadResultResponse();
        String requestStr = null;
        String errorMessage;
        String functionName = 'updateCampaignLeadRequest';

        List<Id> targetListId = new List<Id>();
        for(Target_List__c eachTargetList : updateTargetList){
            targetListId.add(eachTargetList.Id);
        }
        List<Target_List__c> matchUpdateTargetList = [SELECT Id, CIS_ID_Prospect_Name__c, CIS_ID_Prospect_Name__r.Name, Status__c, Lead_Campaign__r.Name FROM Target_List__c WHERE Id IN :targetListId];
        if(matchUpdateTargetList.size()>0){
            //requestStr = 'IP_ID='+cisID+'&SFDC_ID='+sfdcID+'&STATUS='+leadStatus;
            //Transform to JSON format
            /*
            {"updateLeadStatus": {"targetList":[
               {"SFDC_ID": "xxxxxxx",
               "IP_ID": "457397",
               "STATUS": "2"},
               
               {"SFDC_ID": "yyyyyyy",
               "IP_ID": "847393",
               "STATUS": "5"}
            ]}}
            */
            requestStr = leadStatusJSONGenerator(matchUpdateTargetList);
        }
        
        HTTPResponse resp = sendHTTPRequest(UPDATE_CAMPAIGN_LEAD_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        try{
            responseModel = SME_UpdateCampaignLeadResultResponse.parse(jsonResponseStr);
        }catch(Exception e){
            errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+e.getMessage()+'Response:'+jsonResponseStr;
            GlobalUtility.logMessage('ERROR',CLASS_NAME,functionName,null,null,errorMessage,null,e,null);
        } 

        return responseModel;
    }

    webservice static SME_UpdateContactPrefResultResponse updateContactPrefRequestList(List<Contact> updateContactPrefList){
        String requestStr = contactPrefJSONGenerator(updateContactPrefList);
        return updateContactPrefRequest(requestStr);
    }

    webservice static SME_UpdateContactPrefResultResponse updateContactPrefRequest(String requestStr){
        SME_UpdateContactPrefResultResponse responseModel = new SME_UpdateContactPrefResultResponse();
        String errorMessage;
        String functionName = 'updateContactPrefRequest';

        HTTPResponse resp = sendHTTPRequest(UPDATE_CONTACT_PREF_ENDPOINT,requestStr);
        writeDebugMessage(functionName,'RequestStr:'+requestStr);
        String jsonResponseStr = resp.getBody();
        writeDebugMessage(functionName,'jsonRespStr:'+jsonResponseStr);

        try{
            responseModel = SME_UpdateContactPrefResultResponse.parse(jsonResponseStr);
        }catch(Exception e){
            errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+e.getMessage()+'Response:'+jsonResponseStr;
            GlobalUtility.logMessage('ERROR',CLASS_NAME,functionName,null,null,errorMessage,null,e,null);
        } 

        return responseModel;
    }

    private static String leadStatusJSONGenerator(List<Target_List__c> updateLeadStatusSpilt){

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('updateLeadStatus');
        gen.writeStartObject();
        gen.writeFieldName('targetList');
        gen.writeStartArray();
        //for each attendee create a JSON object
        for(Target_List__c targetListObject : updateLeadStatusSpilt){
            gen.writeStartObject();        
            gen.writeStringField('SFDC_ID', String.valueOf(targetListObject.Id));
            gen.writeStringField('IP_ID', String.valueOf(targetListObject.CIS_ID_Prospect_Name__r.Name));
            gen.writeStringField('STATUS_ID', String.valueOf('0'));
            gen.writeStringField('LEAD_ID', String.valueOf(targetListObject.Lead_Campaign__r.Name));
            gen.writeStringField('UPDATE_DT', GlobalUtility.toExportDateFormat(System.today()));
            gen.writeStringField('UPDATE_USER', String.valueOf(UserInfo.getName()));
            //gen.writeStringField('STATUS_ID', String.valueOf(targetListObject.Status__c));
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        gen.writeEndObject();

        System.debug('JSON string :'+ gen.getAsString());
        return gen.getAsString();
    }

    public static String contactPrefJSONGenerator(List<Contact> updateContactPrefSpilt){

        /*
        {   "updateCustomerPref" : 
            {       "jobrequest" : 
                [{           "IP_ID" : "32354",
                            "CTC_PSN_ID" : "str12",             
                            "TH_TTL" : "str1234",           
                            "TH_FRST_NM" : "str1234",           
                            "TH_MDL_NM" : "str1234",  

                            "TH_SURNM" : "str1234",             
                            "EN_TTL" : "str1234",           
                            "EN_FRST_NM" : "str1234",           
                            "EN_MDL_NM" : "str1234",            
                            "EN_SURNM" : "str1234", 

                            "NCK" : "str1234",          
                            "POS" : "str1234",          
                            "PSN_EMAIL" : "str1234",            
                            "BSN_EMAIL" : "str1234",            
                            "MBL_NO" : "str1234",   

                            "LINE_ID" : "str1234",          
                            "FB_ID" : "str1234",            
                            "IG_ID" : "str1234",            
                            "PRIM_CTC_F" : "t",             
                            "DOB" : "",  

                            "CTC_RPRT_TP_CD" : "s1",            
                            "PREF_CTC_MTH" : "str1234",             
                            "ACTV_F" : "I",             
                            "FAV_FOOD_TP_CD" : "str1234",           
                            "ALG_FOOD_TP_CD" : "str1234", 

                            "LS_TP_CD" : "str1234",             
                            "LS_SUB_TP_CD" : "str1234",             
                            "FAV_BRND" : "str1234",             
                            "FAV_RSTRN" : "str1234",            
                            "FAV_SPORT" : "str1234",   

                            "MOST_INTD_TOPC" : "str1234",           
                            "SPK_LNG" : "str1234",          
                            "INT_IVSM_EV" : "str1234",          
                            "INT_GNL_EV" : "str1234",           
                            "FAV_MGZ" : "str1234",   

                            "COLL" : "str1234",             
                            "SOC_PSN_F" : "str1234",            
                            "OTHR_CHAR_INFO" : "str1234",           
                            "EFF_DT" : "",          
                            "END_DT" : "",    

                            "LAST_VRSN_F" : "2",            
                            "CRT_DT" : "",          
                            "CRT_USR" : "str1234",          
                            "UDT_DT" : "",          
                            "UDT_USR" : "str1234"       
                }]  
            } 
        }
        */
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('updateCustomerPref');
        gen.writeStartObject();
        gen.writeFieldName('jobrequest');
        gen.writeStartArray();
        //for each attendee create a JSON object
        for(Contact contactPrefsObject:updateContactPrefSpilt){
            gen.writeStartObject();        
            gen.writeStringField('IP_ID', toValue(contactPrefsObject.CIS_ID__c));
            gen.writeStringField('CTC_PSN_ID',toValue(contactPrefsObject.ID));
            gen.writeStringField('TH_TTL',toValue(contactPrefsObject.Salutation));
            gen.writeStringField('TH_FRST_NM',toValue(contactPrefsObject.Contact_Firstname__c));

            gen.writeStringField('TH_SURNM', toValue(contactPrefsObject.LastName));
            gen.writeStringField('NCK', toValue(contactPrefsObject.Nickname__c));
            gen.writeStringField('POS',toValue(contactPrefsObject.Contact_Position__c));
            gen.writeStringField('PSN_EMAIL',toValue(contactPrefsObject.Personal_Email__c));
            gen.writeStringField('BSN_EMAIL',toValue(contactPrefsObject.Business_Email__c));
            gen.writeStringField('MBL_NO',toValue(contactPrefsObject.Phone_Number__c));

            gen.writeStringField('LINE_ID', toValue(contactPrefsObject.Line_ID__c));
            gen.writeStringField('FB_ID',toValue(contactPrefsObject.Facebook_ID__c));
            gen.writeStringField('IG_ID',toValue(contactPrefsObject.Instagram_ID__c));
            gen.writeStringField('PRIM_CTC_F',toValue(contactPrefsObject.Primary_Contact__c));
            gen.writeStringField('DOB',toValue(contactPrefsObject.Birthdate__c));

            gen.writeStringField('CTC_RPRT_TP_CD', toValue(contactPrefsObject.Contact_Representative_Type__c));
            gen.writeStringField('PREF_CTC_MTH',toValue(contactPrefsObject.Contact_Preference_Communication__c));
            gen.writeStringField('ACTV_F',toValue(contactPrefsObject.Active_Contact__c));

            gen.writeStringField('LS_TP_CD', toValue(contactPrefsObject.Life_Style__c));
            gen.writeStringField('LS_SUB_TP_CD',toValue(contactPrefsObject.Life_Style_Details__c));
            gen.writeStringField('INT_GNL_EV',toValue(contactPrefsObject.Other_Life_Style_Detail__c));
            gen.writeStringField('SOC_PSN_F',toValue(contactPrefsObject.Character__c));
            gen.writeStringField('OTHR_CHAR_INFO',toValue(contactPrefsObject.Other_Info_about_Character__c));

            gen.writeStringField('CRT_DT',toValue(contactPrefsObject.CreatedDate));
            gen.writeStringField('CRT_USR',toValue(contactPrefsObject.CreatedBy.Employee_ID__c));
            gen.writeStringField('UDT_DT',toValue(contactPrefsObject.Contact_Preference_Last_Modified_Date__c));
            gen.writeStringField('UDT_USR',toValue(contactPrefsObject.Contact_Preference_Last_Modified_By__c));

            //gen.writeStringField('CRT_DT',toValue(contactPrefsObject.LastModifiedDate));
            //gen.writeStringField('CRT_USR',toValue(contactPrefsObject.LastModifiedBy.Employee_ID__c));
            //gen.writeStringField('UDT_DT',toValue(contactPrefsObject.LastModifiedDate));
            //gen.writeStringField('UDT_USR',toValue(contactPrefsObject.LastModifiedBy.Employee_ID__c));
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        gen.writeEndObject();

        System.debug('JSON string :'+ gen.getAsString());
        return gen.getAsString();
    }

    private static String toValue(String fieldValue) {
        return fieldValue != null ? fieldValue : '';
    }
    private static String toValue(Boolean fieldValue) {
        if(fieldValue != null) {
            return fieldValue ? 'Y' : 'N';
        }
        return '';
    }
    private static String toValue(Datetime fieldValue) {
        if(fieldValue != null){
            return fieldValue.format('YYYY-MM-dd');
        }
        else{
            return '';
        }      
    }
}