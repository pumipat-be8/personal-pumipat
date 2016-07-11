/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:    Customer Search Controller

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
05/28/2015  Charnun.T           First Create
07/06/2015  Komsan.wi           Renovated
------------------------------------------------------------*/
public without sharing class CustomerSearch_Controller extends CustomerSearch_Management{
    transient Boolean hasError;
    transient Boolean hasInfo;
    public String errorMessage{get;set;}
    
    public String requestLabel;

    public String id {get;set;}
    public String cis {get;set;}
    public String firstname {get;set;}
    public String lastname {get;set;}

    public String prospect_id;
    public String prospect_cis;
    public String prospect_firstname;
    public String prospect_lastname;

    public String sortDirection = 'ASC';
    public String sortExp = 'name';
    public Boolean isEnglishInput_FN = null;
    public Boolean isEnglishInput_LN = null;

    public List<Customer> customerList {get;set;}
    public List<Customer> finalCustomerList {get;set;}
    public List<String> displayedCisList {get;set;}
    public String requestOwnershipValue {get;set;}
    public String lang {get;set;}
    public static final String PROSPECT = 'SME-Prospect';
    public static final String FIRSTNAME_TH = 'TH_FRST_NM';
    public static final String FIRSTNAME_EN = 'EN_FRST_NM';
    public static final String SURNAME_TH = 'TH_SURNM';
    public static final String SURNAME_EN = 'EN_SURNM';
    public static final String FULL_NAME = 'FULL_NAME';
    public static final String IDENT_NO = 'IDENT_NO';
    public static final String CIS_ID = 'IP_ID';
    public static final String LIMIT_VAR = 'LIMIT';
    public static final String CIS_LIST = 'IP_ID';
    public static final String SORT_TYPE = 'SORT_TYPE';
    public static final String SORT_COLUMN = 'SORT_COLUMN';

    private static final String PROS_NAME_TH = 'Name_TH_Prospect__c';
    private static final String PROS_NAME_EN = 'Name_EN_Prospect__c';
    private static final String PROS_SUR_TH = 'Surname_TH_Prospect__c';
    private static final String PROS_SUR_EN = 'Surname_EN_Prospect__c';
    private static final String PROS_IDENT_NO = 'Identification_No_Prospect__c';
    
    private static final Integer PAGE_SIZE = CustomSettingUtil.getSearchResults();
    private static final String TIME_OUT_CASE = 'Read timed out';
    private static final String SERVICE_UNAVAILABLE_CASE = '503';
    private static final String DATABASE_UNAVAILABLE_CASE = '504';//1906503
    private static final String INCORRECT_USER_PASS_CASE = '401';
    private static final String URI_UNAVAILABLE_CASE = '404';
    private static final String EN_LANGUAGE = 'en_US';
    private static final String TH_LANGUAGE = 'th';
 
    public String ownerShipId{get;set;}
    public Integer page{get;set;}
    public Integer totalRecords{get;set;}
    public Integer totalPages{get;set;}
    public Integer startIdx{get;set;}
    public Integer endIdx{get;set;}

    public Boolean showProspectButton{get;set;}

    public static String prospectRecordTypeId = String.valueOf(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(PROSPECT).GetRecordTypeId());
    public String prospectRecordTypeIdString {get{return CustomerSearch_Controller.prospectRecordTypeId;}}
    
    private Map<String,String> errorMap = new Map<String,String>();

    private User ownerUser;
    public class Customer{
        public Account accountObj{get;set;}
        public String firstNameTH{get;set;}
        public String firstNameEN{get;set;}
        public String surNameTH{get;set;}
        public String surNameEN{get;set;}
        public String fullName{get;set;}
        public String province{get;set;}
        public String district{get;set;}
        public String identificationNo{get;set;}
        public String documentType{get;set;}
        public String birthdateRegistrationDate{get;set;}
        public Boolean isProspect{get;set;}
        public Boolean showRequestOwnershipButton{get;set;}
        public String mashupEndPoint;
        public String getURLStringFromCISAndFieldName(String cis,String fieldName,Boolean isEnglishInput_FN,Boolean isEnglishInput_LN){
            String imgURL = '';
            String functionName = 'getURLStringFromCISAndFieldName';
            if (mashupEndpoint == null){
                // read mashup endpoint from customsetting
                mashupEndPoint = CustomSettingUtil.getEndpointByName('MashupEndpoint');
                //writeDebugMessage(functionName,'Mashup Endpoint:'+mashupEndPoint);
            }
            System.debug('isEnglishInput_FN:'+isEnglishInput_FN);
            System.debug('isEnglishInput_LN:'+isEnglishInput_LN);
            if(isEnglishInput_FN == true || isEnglishInput_LN == true){
                if(isEnglishInput_FN == false || isEnglishInput_LN == false){
                    imgURL = 'customer/th/'+cis+'/'+fieldName+'.gif';
                }else{
                    imgURL = 'customer/en/'+cis+'/'+fieldName+'.gif';
                }
            }else{
                imgURL = 'customer/th/'+cis+'/'+fieldName+'.gif'; 
            }

            String encryptImgURL = GlobalUtility.getEncryptedDataWithTransform('Test1234 Exameod',imgURL);
            String fullPathEncryptImgURL = mashupEndPoint+'encrypt/'+encryptImgURL;
            String fullPatheImgURL = mashupEndPoint+imgURL;
            return fullPathEncryptImgURL;
        }

        public Customer(Account accountObj, Map<String,sObject> mapAddress, Boolean isEnglishInput_FN, Boolean isEnglishInput_LN){
            this.accountObj = accountObj;
            if(accountObj.RecordTypeId == prospectRecordTypeId){
                this.firstNameTH =  accountObj.Name;
                this.firstNameEN = accountObj.Name_EN_Prospect__c;
                this.surNameTH = accountObj.Surname_TH_Prospect__c;
                this.surNameEN = accountObj.Surname_EN_Prospect__c;
                this.identificationNo = accountObj.Identification_No_Prospect__c;
                this.documentType = accountObj.Document_Type_Prospect__c;
                //this.showRequestOwnershipButton = False;
                this.showRequestOwnershipButton = True; // Phase 2 Change requirement
                this.district = '-';
                this.province = '-';
                this.isProspect = True;
            }else{
                sObject tempObj = null;
                if(mapAddress != null){
                    tempObj = mapAddress.get(accountObj.CIS__c);
                }
                this.fullName =  getURLStringFromCISAndFieldName(accountObj.CIS__c,FULL_NAME,isEnglishInput_FN,isEnglishInput_LN);
                this.identificationNo =  getURLStringFromCISAndFieldName(accountObj.CIS__c,IDENT_NO,isEnglishInput_FN,isEnglishInput_LN);
                if(tempObj != null){
                    this.district = String.valueOf(tempObj.get('District__c'));
                    this.province = String.valueOf(tempObj.get('Province__c'));
                }else{
                    this.district = '-';
                    this.province = '-';
                }
                
                //if(accountObj.Primary_Segment_Code__c == 'SM' || accountObj.Primary_Segment_Code__c == 'SR'  || accountObj.Primary_Segment_Code__c == 'LM'  || accountObj.Primary_Segment_Code__c == 'LR'  || accountObj.Primary_Segment_Code__c == 'UM'  || accountObj.Primary_Segment_Code__c == 'UR')
                //{
                //    this.showRequestOwnershipButton = True;
                //}else{
                //    this.showRequestOwnershipButton = False;
                //}
                this.showRequestOwnershipButton = True; // Phase 2 Change requirement
                this.isProspect = False;
            }
            if(accountObj.Birthdate_Registration_Date__c != null){
                Datetime tempDate = accountObj.Birthdate_Registration_Date__c;
                this.birthdateRegistrationDate = String.valueOf('0'+String.valueOf(tempDate.day())).right(2)+'/'+String.valueOf('0'+String.valueOf(tempDate.month())).right(2)+'/'+String.valueOf(tempDate.year());
            }
            if(String.valueOf(accountObj.OwnerId) == String.valueOf(UserInfo.getUserId())){
                this.showRequestOwnershipButton = False;
            }
        }

        public Customer(String cisNumber, Boolean isEnglishInput_FN, Boolean isEnglishInput_LN){
            this.fullName =  getURLStringFromCISAndFieldName(cisNumber,FULL_NAME,isEnglishInput_FN,isEnglishInput_LN);
            this.identificationNo =  getURLStringFromCISAndFieldName(cisNumber,IDENT_NO,isEnglishInput_FN,isEnglishInput_LN);
            //this.documentType = accountObj.Document_Type__c;
            this.showRequestOwnershipButton = False;
            this.isProspect = False;

        }
    }

    public CustomerSearch_Controller(){
        hasError = false;
        hasInfo = false;
        customerList = new List<Customer>();
        finalCustomerList = new List<Customer>();
        showProspectButton = false;
        this.sortDirection = 'ASC';
        ownerUser = getUserFromId(UserInfo.getUserId());
    }

    public void doNext(){
        if(getHasNext()){
            this.page++;
            getCustomersFinal();
        }
    }

    public void doPrevious(){
        if(getHasPrevious()){
            this.page--;
            getCustomersFinal();
        }      
    }

    public Boolean getHasPrevious(){
        if(this.page>1){
            return true;
        }
        else{
            return false;
        }
    }

    public Boolean getHasNext(){
        if(this.page<this.totalPages){
            return true;
        }
        else{
            return false;
        }
    }

    public void getCustomersFinal(){
        String functionName = 'getCustomersFinal';
        finalCustomerList.clear();
        this.startIdx = (this.page-1)*PAGE_SIZE;
        this.endIdx = this.page*PAGE_SIZE;
        this.totalRecords = 0;
        for(Customer each : customerList){
            if(this.totalRecords>=this.startIdx && this.totalRecords<this.endIdx){   
                this.finalCustomerList.add(each);
            } else{
                System.debug('==>totalRecords'+totalRecords+'this.startIdx:'+this.startIdx+'this.endIdx:'+this.endIdx);
            }
            this.totalRecords++;
        }
        Decimal pages = Decimal.valueOf(this.totalRecords);
        pages = pages.divide(Decimal.valueOf(PAGE_SIZE), 2);
        this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);
        this.startIdx++;
        if(this.endIdx>this.totalRecords){
            this.endIdx = this.totalRecords;
        }
        if(this.firstname != '' || this.lastname != '' || finalCustomerList.size() == 0){
            showProspectButton = true;
        }
        if (this.id.trim() != '' && finalCustomerList.size() > 0) {
            showProspectButton = false;
        }
        if(this.totalRecords >= 100){
            showInfoMessageOnPage(System.Label.Search_More100Records);
        }
        writeDebugMessage(functionName,'finalCustomerList.size = '+finalCustomerList.size());
    }

    public String sortExpression{
        get
        {
            return sortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp){
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            }else{
                sortDirection = 'ASC';
            }
            sortExp = value;
        }
    }

    public String getSortDirection(){
        //if not column is selected 
        if (sortExpression == null || sortExpression == ''){
            return 'ASC';
        }else{
            return sortDirection;
        }
    }

    public void setSortDirection(String value){  
        sortDirection = value;
    }

    public Boolean getRequestOwnerShipId() {
        Account requestAccount = getAccountFromId(requestOwnershipValue);
        String functionName = 'canRequestOwnerShip';
        ownerShipId = '';
        try{
            if(requestAccount != null && ownerUser != null){
                List<Customer_Ownership_Request__c> currentRecord = new List<Customer_Ownership_Request__c>();
                currentRecord = [SELECT Id,Approval_Status__c FROM Customer_Ownership_Request__c WHERE CIS_ID__c=:requestAccount.Id AND OwnerID=:ownerUser.Id AND (Approval_Status__c='Approval In Progress' OR Approval_Status__c='Open') ORDER BY CreatedDate DESC LIMIT 1];
                
                if(ownerUser.Profile.Name != GlobalConstants.SME_RM){
                    showErrorMessageOnPage(System.Label.Search_Not_SME_RM);
                    return false;
                }

                if(currentRecord!=null && currentRecord.size() > 0){
                    showErrorMessageOnPage(ExceptionMessage.ALREADY_SUBMMITTED);
                    return false;
                } else {
                    Customer_Ownership_Request__c ownerObj;
                    ownerObj = Ownership_Service.createOwnerShip(requestAccount,ownerUser);

                    if (ownerObj != null && ownerObj.Id != null) {
                        ownerShipId = ownerObj.Id;
                    }
                } 
            } else {
                showErrorMessageOnPage('Request customer or owner user is null!!');
                return false;
            }

            return true;
        } catch (Exception e){
            writeExceptionMessage(functionName,e.getMessage(),e);
            return true;
        }
    }

    public PageReference requestOwnership(){
        PageReference redirectPage;
        Boolean isNotError = false;
        isNotError = getRequestOwnerShipId();

        if(isNotError && ownerShipId != null && ownerShipId.length() > 0) {
            redirectPage = new PageReference('/'+ownerShipId+'/e?retURL=%2F'+ownerShipId+'&saveURL=%2F'+ownerShipId);
            redirectPage.setRedirect(true);
        }
        
        return redirectPage;
    }

    public void requestOwnershipAsync(){
        getRequestOwnerShipId();
    }

    public void searchDataSyncronous(){
        isEnglishInput_FN = null;
        isEnglishInput_LN = null;
        String displayedErrorMsg;
        String functionName = 'searchDataSyncronous';
        showProspectButton = false;
        List<Customer> backendCustomerList = new List<Customer>();
        CustomerSearchRequestModel requestModel = getCustomerSearchRequestModel();
        // check if map is null or empty before calling ws
        clearOldResult();
        try {
            if(!requestModel.requestMap.isEmpty()){
                CustomerResponseModel responseModel;
                responseModel = getResponseFromWebservice(requestModel);   

                // query prospect and add to customer list
                if(responseModel != null){
                    if(responseModel.errorMsg != null && responseModel.errorMsg != ''){
                        showInfoMessageOnPage(ExceptionMessage.BACKEND_ERROR);
                    }else if(responseModel.cisList != null && responseModel.cisList.size() != 0){
                        backendCustomerList = getCustomerListByCISList(responseModel.cisList);
                        customerList.addAll(backendCustomerList);
                    }else{
                        writeDebugMessage(functionName,'No data from backend');
                    }
                }
                queryProspectFromSFDC();
                getCustomersFinal();
                if(this.finalCustomerList == null || this.finalCustomerList.isEmpty()){
                    showErrorMessageOnPage(System.Label.Search_NoMatch);
                }
            } else {
                showInfoMessageOnPage(System.Label.Search_MinField);
            }
            
             System.debug('sortDirection='+sortDirection);
        }catch(CIWebserviceException e){
            System.debug('CIWebserviceException:'+e);
            if(e.getMessage().containsIgnoreCase(SERVICE_UNAVAILABLE_CASE)){
                showErrorMessageOnPage(ExceptionMessage.ADAPTER_NOT_AVAILABLE);
            }else if(e.getMessage().containsIgnoreCase(DATABASE_UNAVAILABLE_CASE)){
                showErrorMessageOnPage(ExceptionMessage.HOST_NOT_AVAILABLE);
            }else if(e.getMessage().containsIgnoreCase(INCORRECT_USER_PASS_CASE)){
                showErrorMessageOnPage(ExceptionMessage.HOST_EXCEPTION);
            }else if(e.getMessage().containsIgnoreCase(TIME_OUT_CASE)){
                showErrorMessageOnPage(System.Label.Search_TimeOut);
            }else{
                showErrorMessageOnPage(ExceptionMessage.SEARCH_FAILED);
            }

            writeExceptionMessage(functionName,e.getMessage(),e);
        } catch (Exception e){
            System.debug('Exception:'+e);
            writeExceptionMessage(functionName,e.getMessage(),e);
            showErrorMessageOnPage(ExceptionMessage.SEARCH_FAILED);
        }

        // set default direction
        sortDirection = 'ASC';
    }

    public Object searchData(){
        isEnglishInput_FN = null;
        isEnglishInput_LN = null;
        String displayedErrorMsg;
        String functionName = 'searchData';
        String requestStr = null;
        showProspectButton = false;
        List<Customer> backendCustomerList = new List<Customer>();
        CustomerSearchRequestModel requestModel = getCustomerSearchRequestModel();
        // check if map is null or empty before calling ws
        clearOldResult();

        Continuation con = new Continuation(120);
        String requestNumber;
        String endpoint = SME_CIRestWebservice.SEARCH_ENDPOINT;

        try {
            if(!requestModel.requestMap.isEmpty()){
                requestStr = SME_CIRestWebservice.getRequestStringFromMap(requestModel.requestMap);

                // Set callback method
                con.continuationMethod='handleResponseCustomerSearch';

                // Create callout request
                HttpRequest req = new HttpRequest();

                req.setHeader('Authorization', SME_HTTPCallUtil.getAuthorizationHeader());
                req.setEndpoint(endpoint);
                req.setMethod('POST');
                req.setbody(requestStr);

                // Add callout request to continuation
                this.requestLabel = con.addHttpRequest(req);
            } else {
                showInfoMessageOnPage(System.Label.Search_MinField);
            }
            
        }catch(CIWebserviceException e){
            System.debug('CIWebserviceException:'+e);
            if(e.getMessage().containsIgnoreCase(SERVICE_UNAVAILABLE_CASE)){
                showErrorMessageOnPage(ExceptionMessage.ADAPTER_NOT_AVAILABLE);
            }else if(e.getMessage().containsIgnoreCase(DATABASE_UNAVAILABLE_CASE)){
                showErrorMessageOnPage(ExceptionMessage.HOST_NOT_AVAILABLE);
            }else if(e.getMessage().containsIgnoreCase(INCORRECT_USER_PASS_CASE)){
                showErrorMessageOnPage(ExceptionMessage.HOST_EXCEPTION);
            }else if(e.getMessage().containsIgnoreCase(TIME_OUT_CASE)){
                showErrorMessageOnPage(System.Label.Search_TimeOut);
            }else if(e.getMessage().containsIgnoreCase(URI_UNAVAILABLE_CASE)){
                showErrorMessageOnPage(ExceptionMessage.ADAPTER_NOT_AVAILABLE);
            }else{
                showErrorMessageOnPage(ExceptionMessage.SEARCH_FAILED);
            }

            writeExceptionMessage(functionName,e.getMessage(),e);
        } catch (Exception e){
            System.debug('Exception:'+e);
            writeExceptionMessage(functionName,e.getMessage(),e);
            showErrorMessageOnPage(ExceptionMessage.SEARCH_FAILED);
        }

        // set default direction
        this.sortDirection = 'ASC';

        // Return the continuation
        return con;
    }

    public Object handleResponseCustomerSearch() {
        isEnglishInput_FN = null;
        isEnglishInput_LN = null;
        String displayedErrorMsg;
        String functionName = 'handleResponseCustomerSearch';
        HttpResponse response;
        showProspectButton = false;
        List<Customer> backendCustomerList = new List<Customer>();
        
        try {
            CustomerResponseModel responseModel;

            if(this.requestLabel != null){
                HttpResponse continuationResponse = Continuation.getResponse(this.requestLabel);

                response = SME_CIRestWebservice.handleReturnException(continuationResponse);
                System.debug('[response]'+response);
                responseModel = SME_CIRestWebservice.getResponseModelFromSearchResultStr(response.getBody());
            }

            // query prospect and add to customer list
            if(responseModel != null){
                if(responseModel.errorMsg != null && responseModel.errorMsg != ''){
                    showInfoMessageOnPage(ExceptionMessage.BACKEND_ERROR);
                }else if(responseModel.cisList != null && responseModel.cisList.size() != 0){
                    backendCustomerList = getCustomerListByCISList(responseModel.cisList);
                    customerList.addAll(backendCustomerList);
                }else{
                    writeDebugMessage(functionName,'No data from backend');
                }
            }
            queryProspectFromSFDC();
            getCustomersFinal();
            if(this.finalCustomerList == null || this.finalCustomerList.isEmpty()){
                showErrorMessageOnPage(System.Label.Search_NoMatch);
            }
            System.debug('sortDirection='+sortDirection);
        }catch(CIWebserviceException e){
            System.debug('CIWebserviceException:'+e);
            if(e.getMessage().containsIgnoreCase(SERVICE_UNAVAILABLE_CASE)){
                showErrorMessageOnPage(ExceptionMessage.ADAPTER_NOT_AVAILABLE);
            }else if(e.getMessage().containsIgnoreCase(DATABASE_UNAVAILABLE_CASE)){
                showErrorMessageOnPage(ExceptionMessage.HOST_NOT_AVAILABLE);
            }else if(e.getMessage().containsIgnoreCase(INCORRECT_USER_PASS_CASE)){
                showErrorMessageOnPage(ExceptionMessage.HOST_EXCEPTION);
            }else if(e.getMessage().containsIgnoreCase(TIME_OUT_CASE)){
                showErrorMessageOnPage(System.Label.Search_TimeOut);
            }else if(e.getMessage().containsIgnoreCase(URI_UNAVAILABLE_CASE)){
                showErrorMessageOnPage(ExceptionMessage.ADAPTER_NOT_AVAILABLE);
            }else{
                showErrorMessageOnPage(ExceptionMessage.SEARCH_FAILED);
            }

            writeExceptionMessage(functionName,e.getMessage(),e);
        } catch (Exception e){
            System.debug('Exception:'+e);
            writeExceptionMessage(functionName,e.getMessage(),e);
            showErrorMessageOnPage(ExceptionMessage.SEARCH_FAILED);
        }

        // set default direction
        this.sortDirection = 'ASC';
        return null;
    }

    public void clearOldResult(){
        this.finalCustomerList  = new List<Customer>();
        this.customerList = new List<Customer>();
        this.displayedCisList = new List<String>();
        this.requestLabel = null;
        ApexPages.getMessages().clear();
        this.page = 1;
    }

    public void queryProspectFromSFDC(){
        List<List<sObject>> soslResultSet = null;
        //CustomerSearch_Management customerSearchManangement = new CustomerSearch_Management();
        if(this.cis == ''){
            Map<String,sObject> mapAddress = null;
            soslResultSet = searchAllValue(this.id, '', this.firstname, this.lastname);
            if(soslResultSet!= null && soslResultSet.size() != 0){
                Account[] accountLists = ((List<Account>)soslResultSet[0]);
                for(Account tempAccount:accountLists){
                    if(tempAccount.RecordTypeId == prospectRecordTypeId){
                        showProspectButton = true;
                        customerList.add(new Customer(tempAccount,mapAddress,this.isEnglishInput_FN,this.isEnglishInput_LN));

                    }
                }
            }

        }          
    }

    public void sortData(){
        String functionName = 'sortData';
        try{
            System.debug('sortData sortDirection='+sortDirection);
            showProspectButton = false;
            List<Customer> backendCustomerList = sortBackendData(this.sortDirection);
            List<Customer> prospectCustomerList = sortProspectData(this.sortDirection);
            this.customerList.clear();
            this.customerList.addAll(backendCustomerList);
            this.customerList.addAll(prospectCustomerList);
            this.page = 1;
            this.getCustomersFinal();
        }catch(CIWebserviceException e){
            System.debug('CIWebserviceException:'+e);
            if(e.getMessage().containsIgnoreCase(SERVICE_UNAVAILABLE_CASE)){
                showErrorMessageOnPage(ExceptionMessage.ADAPTER_NOT_AVAILABLE);
            }else if(e.getMessage().containsIgnoreCase(DATABASE_UNAVAILABLE_CASE)){
                showErrorMessageOnPage(ExceptionMessage.HOST_NOT_AVAILABLE);
            }else if(e.getMessage().containsIgnoreCase(INCORRECT_USER_PASS_CASE)){
                showErrorMessageOnPage(ExceptionMessage.HOST_EXCEPTION);
            }else if(e.getMessage().containsIgnoreCase(TIME_OUT_CASE)){
                showErrorMessageOnPage(System.Label.Search_TimeOut);
            }else{
                showErrorMessageOnPage(ExceptionMessage.SORT_FAILED);
            }

            writeExceptionMessage(functionName,e.getMessage(),e);
        }catch (Exception e){
            writeExceptionMessage(functionName,e.getMessage(),e);
            showErrorMessageOnPage(ExceptionMessage.SORT_FAILED);
        }
    }


    public List<Customer> sortBackendData(String direction){
        List<Customer> backendCustomerList = new List<Customer>();
        String functionName = 'sortBackendData';
        showProspectButton = false;
        // if no displayed list , do nothing
        if(this.displayedCisList != null && !this.displayedCisList.isEmpty()){
            CustomerSearchRequestModel requestModel = getCustomerRequestForSorting();
            // the result must not be null before sorting
            CustomerResponseModel responseModel = getResponseFromWebservice(requestModel);
            writeDebugMessage(functionName,'responseSortCISList:='+responseModel.cisList);
            
            if(responseModel.errorMsg != null && responseModel.errorMsg != ''){
                showInfoMessageOnPage(ExceptionMessage.BACKEND_ERROR);
            }else if(responseModel.cisList != null && responseModel.cisList.size() != 0){
                backendCustomerList = getCustomerListByCISList(responseModel.cisList);
            }else{
                writeDebugMessage(functionName,'No data from backend');
            }
        }
        return backendCustomerList;
    }

    public List<Customer> sortProspectData(String direction){
        List<Customer> prospectCustomerList = new List<Customer>();
        List<List<sObject>> soslResultSet = null;
        //CustomerSearch_Management customerSearchManangement = new CustomerSearch_Management();
        if(this.cis == ''){

            Map<String,sObject> mapAddress = null;
            soslResultSet = sortAllValue(this.prospect_id, '', this.prospect_firstname, this.prospect_lastname,direction);
            if(soslResultSet!= null && soslResultSet.size() != 0){
                Account[] accountLists = ((List<Account>)soslResultSet[0]);
                for(Account tempAccount:accountLists){
                    if(tempAccount.CIS__c == null){
                        showProspectButton = false;
                        prospectCustomerList.add(new Customer(tempAccount,mapAddress,this.isEnglishInput_FN,this.isEnglishInput_LN));
                        
                    }
                }
            }

        }
        return prospectCustomerList;         
    }

    public CustomerResponseModel getResponseFromWebservice(CustomerSearchRequestModel requestModel){
        CustomerResponseModel responseModel;
        String functionName = 'getResponseFromWebservice';

        if(requestModel.requestMap.containsKey(SORT_TYPE)){
            responseModel = SME_CIRestWebservice.sortCISListByCustomerSearchRequest(requestModel);
        } else {
            responseModel = SME_CIRestWebservice.searchCISListByCustomerSearchRequest(requestModel);
        }
        return responseModel;
    }

    public CustomerSearchRequestModel getCustomerSearchRequestModel(){       
        Map<String,String> requestCISMap = new Map<String,String>();
        CustomerSearchRequestModel reqModel = new CustomerSearchRequestModel();
        Boolean checkLastNameResult = True;
        Boolean checkFirstNameResult = True;
        Boolean hasFirstName = False;
        Boolean hasLastName = False;
        clearProspectParam();

        if(this.cis != null && this.cis.trim() != ''){
            this.cis = this.cis.trim();
            if(isValidParam(this.cis)){
                requestCISMap.put(CIS_ID, this.cis);
                this.prospect_id = this.cis;
            }
        } else if(this.id != null && this.id.trim() != ''){
            this.id = this.id.trim();
            if(isValidParam(this.id)){
                requestCISMap.put(IDENT_NO, this.id);
                this.prospect_id = this.id;
            }
        // check if it TH or EN
        } else if (this.firstname != null && this.firstname.trim() != '' || this.lastname != null && this.lastname.trim() != ''){
            if (this.firstname != null && this.firstname.trim() != ''){
                this.firstname = this.firstname.trim();
                this.prospect_firstname = this.firstname;
                if(isEnglishAlphabet(this.firstname)){
                    requestCISMap.put(FIRSTNAME_EN,this.firstname);
                    this.isEnglishInput_FN = true;
                }else{
                    requestCISMap.put(FIRSTNAME_TH,this.firstname);
                    this.isEnglishInput_FN = false;
                }
                hasFirstName = True;
            } 

            if (this.lastname != null && this.lastname.trim() != ''){
                this.lastname = this.lastname.trim();
                this.prospect_lastname = this.lastname;
                if(isEnglishAlphabet(this.lastname)){
                    requestCISMap.put(SURNAME_EN,this.lastname);
                    this.isEnglishInput_LN = true;
                }else{
                    requestCISMap.put(SURNAME_TH,this.lastname);
                    this.isEnglishInput_LN = false;
                }
                hasLastName = True;
            }

            if(hasFirstName == True && hasLastName == False){
                if(!isValidParam(this.firstname)){
                    reqModel = new CustomerSearchRequestModel();
                    requestCISMap.clear();
                    clearProspectParam();
                }
            } else if (hasFirstName == False && hasLastName == True){
                if(!isValidParam(this.lastname)){
                    reqModel = new CustomerSearchRequestModel();
                    requestCISMap.clear();
                    clearProspectParam();
                }
            }

        }

        reqModel.requestMap = requestCISMap;
        return reqModel;
    }

    public void clearProspectParam(){
        this.prospect_id = '';
        this.prospect_cis = '';
        this.prospect_lastname = '';
        this.prospect_firstname = '';

    }

    public Boolean isValidParam(String param){
        Boolean result = false;
        if(param != ''){
            // check length
            if (param.length()==1){
                showInfoMessageOnPage(System.Label.Search_MinChar);
            }else{
                result = true;
            }
        }
        return result;
    }

    public CustomerSearchRequestModel getCustomerRequestForSorting(){       
        Map<String,String> requestCISMap = new Map<String,String>();
        CustomerSearchRequestModel reqModel = new CustomerSearchRequestModel();

        // check if it TH or EN
        if(this.firstname != null && this.firstname.trim() != ''){
            if(isEnglishAlphabet(this.firstname.trim())){
                requestCISMap.put(SORT_COLUMN,FIRSTNAME_EN);
            }else{
                requestCISMap.put(SORT_COLUMN,FIRSTNAME_TH);
            }
        }else{
            requestCISMap.put(SORT_COLUMN,FIRSTNAME_TH);
        }

        requestCISMap.put(SORT_TYPE,this.sortDirection);
        requestCISMap.put(CIS_ID,convertListToCommaString(displayedCisList));
        reqModel.requestMap = requestCISMap;
        return reqModel;
    }

    public String convertListToCommaString(List<String> idList){
        String outputString = String.join(idList, ',');
        System.debug(outputString);
        return outputString;
    }

    public Boolean isEnglishAlphabet(String name){
        Boolean isEnglishAlphabet = false;
        String nameRegEx = '[a-zA-Z0-9\\-]+';
        Pattern myPattern = Pattern.compile(nameRegEx);
        Matcher myMatcher = myPattern.matcher(name);
        myMatcher.region(0, myMatcher.regionEnd());
        isEnglishAlphabet = MyMatcher.matches();
        return isEnglishAlphabet;
    }

    public List<Customer> getCustomerListByCISList(List<String> cisIdList){
        List<Customer> backendCustomerList = new List<Customer>();
        //CustomerSearch_Management customerSearchManagement = new CustomerSearch_Management();
        String functionName = 'setCustomerListByCISList';
        // Query when match CIS with backend
        Map<String,sObject> accountMap = GlobalUtility.toMap('CIS__c', [SELECT Id,CIS__c,Customer_360__c,Title__c,Primary_Segment_Code__c,
                                    Dual_Segment_Code__c,Customer_Status__c,Status__c,RecordtypeId,OwnerId,Owner.Name,Name,Document_Type__c,
                                    Birthdate_Registration_Date__c,Port_Pool__c,
                                    Name_EN_Prospect__c,
                                    Surname_TH_Prospect__c,Surname_EN_Prospect__c,Identification_No_Prospect__c,Document_Type_Prospect__c
                                    FROM Account WHERE CIS__c IN :cisIdList]);
        
        Map<String,sObject> mapAddress = queryMapAddress(cisIdList);

        for (String cis:cisIdList){
            try {
                if (accountMap.get(cis) != null){
                    Account acc = (Account)accountMap.get(cis);
                    if (acc != null){
                        showProspectButton = false;
                        backendCustomerList.add(new Customer(acc,mapAddress,this.isEnglishInput_FN,this.isEnglishInput_LN));   
                    }
                } else {
                    showProspectButton = true;
                    backendCustomerList.add(new Customer(cis,this.isEnglishInput_FN,this.isEnglishInput_LN));   
                }

            }catch(Exception ex){
                writeExceptionMessage(functionName,ex.getMessage(),ex);
            }
        }
        writeDebugMessage(functionName,'backend customerList size:'+backendCustomerList.size());
        displayedCisList = cisIdList;
        return backendCustomerList;
    }

    public Boolean getHasError(){
        return hasError;
    }

    public Boolean getHasInfo(){
        return hasInfo;
    }
    
    public void showInfoMessageOnPage(String errorMsg){
        if (!ApexPages.hasMessages(ApexPages.Severity.ERROR) && !ApexPages.hasMessages(ApexPages.Severity.INFO)){
            apexpages.addmessage(new ApexPages.message(ApexPages.severity.INFO,errorMsg));
            errorMessage = errorMsg;
            hasInfo = true;
        }       
    }

    public void showErrorMessageOnPage(String errorMsg){
        System.debug('showErrorMessageOnPage:'+errorMsg);
        if (errorMsg != null && !ApexPages.hasMessages(ApexPages.Severity.ERROR) && !ApexPages.hasMessages(ApexPages.Severity.INFO)){
            apexpages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMsg));
            errorMessage = errorMsg;
            hasError = true;
        }
    }

    public static void writeDebugMessage(String sourceFunction,String logMessage){
        String sourceClass = 'CustomerSearch_Controller';
        String referenceId = null;
        String referenceInfo = null;
        String payload = null;

        Exception ex = null;
        Long timeTaken = null;
        String severity = 'DEBUG';

        GlobalUtility.logMessage(severity,sourceClass,sourceFunction,referenceId,referenceInfo,logMessage,payLoad,ex,timeTaken);
    }

    public static void writeExceptionMessage(String sourceFunction,String logMessage,Exception ex){
        String sourceClass = 'CustomerSearch_Controller';
        String referenceId = null;
        String referenceInfo = null;
        String payload = null;

        Long timeTaken = null;
        String severity = 'ERROR';

        GlobalUtility.logMessage(severity,sourceClass,sourceFunction,referenceId,referenceInfo,logMessage,payLoad,ex,timeTaken);
    }
}