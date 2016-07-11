/*------------------------------------------------------------
Author: Sasitorn Saisuttichai
Company : Beryl8
Description:   A test class for CustomerSearch_Controller

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
03/08/2015  Sasitorn.S          First Create
------------------------------------------------------------*/
@isTest
public class CustomerSearch_Controller_Test {
	public CustomerSearch_Controller_Test() {

	}
    public static final String PROSPECT = 'SME-Prospect';
    public static final String FIRSTNAME_TH = 'TH_FRST_NM';
    public static final String FIRSTNAME_EN = 'EN_FRST_NM';
    public static final String SURNAME_TH = 'TH_SURNM';
    public static final String SURNAME_EN = 'EN_SURNM';
    public static final String FULLNAME_TH = 'FULLNAME_TH';
    public static final String FULLNAME_EN = 'FULLNAME_EN';
    public static final String IDENT_NO = 'IDENT_NO';
    public static final String CIS_ID = 'IP_ID';
    public static final String LIMIT_VAR = 'LIMIT';
    public static final String CIS_LIST = 'IP_ID';
    public static final String SORT_TYPE = 'SORT_TYPE';
    public static final String SORT_COLUMN = 'SORT_COLUMN';

    public static final String SEARCH_POSITIVE = 'SEARCH_POSITIVE';
    public static final String SEARCH_ERROR_ONLY = 'SEARCH_ERROR_ONLY';
    public static final String SEARCH_PARTIAL_ERROR = 'SEARCH_PARTIAL_ERROR';
    public static final String SEARCH_STATUS_500 = 'SEARCH_STATUS_500';
    public static final String SORT_POSITIVE = 'SORT_POSITIVE';
    public static final String EMPTY_RESPONSE = 'EMPTY_RESPONSE';
    public static CustomerSearch_Controller testController = new CustomerSearch_Controller();
    private static String prospectRecordTypeId = String.valueOf(Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(PROSPECT).GetRecordTypeId());
 
    @isTest static void testSearchData_PositiveData_Mobile() {
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // input
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.cis = SEARCH_POSITIVE+'001O000000kfDTl1';
        tController.id = '001O000000kfDTl';
        tController.firstname = 'testFirst';
        tController.lastname = 'testLastName';

        List<String> expectedCISList = new List<String>();
        expectedCISList.add('001O000000kfDTl1');
        expectedCISList.add('001O000000kfDTm1');
        
        // execute httpcallout
        Test.startTest();
            tController.searchDataSyncronous();
        Test.stopTest();

       //System.assertEquals(expectedCISList.size(),tController.displayedCisList.size());
       // verifyCISList(expectedCISList,tController.displayedCisList);

    }

    @isTest static void testSearchData_PositiveData() {
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // input
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.cis = SEARCH_POSITIVE+'001O000000kfDTl1';
        tController.id = '001O000000kfDTl';
        tController.firstname = 'testFirst';
        tController.lastname = 'testLastName';

        List<String> expectedCISList = new List<String>();
        expectedCISList.add('001O000000kfDTl1');
        expectedCISList.add('001O000000kfDTm1');
        
        // execute httpcallout
        Test.startTest();
        tController.searchData();
        Test.stopTest();

       //System.assertEquals(expectedCISList.size(),tController.displayedCisList.size());
       //verifyCISList(expectedCISList,tController.displayedCisList);

    }
    @isTest static void testSortData_PositiveData() {
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // input
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        List<String> searchResultList = new List<String>();
        searchResultList.add('5137447');
        searchResultList.add('5137448');


        List<String> expectedResultList = new List<String>();
        expectedResultList.add('5137448');
        expectedResultList.add('5137447');


        tController.firstname = 'ENGLISH';
        tController.lastname = SORT_TYPE;
        tController.sortDirection = 'DESC';
        tController.displayedCisList = searchResultList;

        ///  {"cis_id":["5137448","5137447"]}}');
        

        // execute httpcallout
        Test.startTest();
            List<CustomerSearch_Controller.Customer> customerListResult = tController.sortBackendData(tController.sortDirection);
        Test.stopTest();
        System.debug(customerListResult);
        System.assertEquals(2,customerListResult.size());

        verifyCISList(expectedResultList,tController.displayedCisList);

    }


  @isTest static void testSearchData_ByNamePositiveData() {
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // input
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        //tController.cis = SEARCH_POSITIVE+'001O000000kfDTl1';
        //tController.id = '001O000000kfDTl';
        tController.firstname = 'SEARCH_POSITIVE+testFirst';
        tController.lastname = 'testLastName';

        List<String> expectedCISList = new List<String>();
        expectedCISList.add('001O000000kfDTl1');
        expectedCISList.add('001O000000kfDTm1');
        
        // execute httpcallout
        Test.startTest();
        //Account acc = new Account(name='accname');
        //acc.Name_EN_Prospect__c = 'SEARCH_POSITIVE+testFirst';
        ////acc.CIS__c = '001O000000kfDTl1';
        //acc.Identification_No_Prospect__c = '1111111111';
        //acc.RecordTypeId = prospectRecordTypeId;
        //insert acc;

        //acc = new Account(name='accname2');
        //acc.Name_EN_Prospect__c = 'SEARCH_POSITIVE+testFirst2';
        ////acc.CIS__c = '001O000000kfDTm1';
        //acc.Identification_No_Prospect__c = '1111111112';
        //acc.RecordTypeId = prospectRecordTypeId;
        //insert acc;
        tController.searchData();
        Test.stopTest();


        //System.assertEquals(expectedCISList.size(),tController.displayedCisList.size());
        //List<Customer> resultCustomerList = new List<Customer>();
       // verifyCISList(expectedCISList,tController.displayedCisList);

    }

    private static void verifyCISList(List<String> expectedCISList,List<String> actualCISList){
        for(Integer i=0; i<expectedCISList.size(); i++) {
            String expectedValue = expectedCISList.get(i);
            String actualValue = actualCISList.get(i);
            System.assertEquals(expectedValue,actualValue);
        }
    }


    @isTest static void testSearchData_SomeInvalidCIS() {
     
    }

    @isTest static void testSearchData_ErrorFromCIWebservice() {
             // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // input
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        // input
        //tController.cis = SEARCH_STATUS_500;
        //tController.id = '00001';
        tController.firstname = SEARCH_STATUS_500;
        tController.lastname = 'testLastName';


        // execute httpcallout
        Test.startTest();

        tController.searchData();

        Test.stopTest();

        System.assertEquals(0,tController.displayedCisList.size());
    }

    @isTest static void testSortData_PositiveDataFromCIWebservice() {
     // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // input
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.cis = SEARCH_POSITIVE;
        tController.id = '5137447';
        tController.firstname = 'testFirst';
        tController.lastname = 'testLastName';
        tController.sortDirection = 'ASC';
        List<String> cisList = new List<String>();
        cisList.add('5137447');
        cisList.add('5137448');
        tController.displayedCisList = cisList;

        List<String> expectedCisList = new List<String>();
        expectedCisList.add('5137447');
        expectedCisList.add('5137448');

        // execute httpcallout
        Test.startTest();
       
        Account acc = new Account(name='accname');
        acc.Name_EN_Prospect__c = 'testEnFirstName';
        acc.CIS__c = '5137447';
        acc.Identification_No_Prospect__c = '1111111111';
        acc.RecordTypeId = prospectRecordTypeId;
        insert acc;

        tController.sortData();
        Test.stopTest();

        System.assertEquals(expectedCISList.size(),tController.displayedCisList.size());
        verifyCISList(expectedCISList,tController.displayedCisList);

    }
    @isTest static void testSortData_ErrorFromCIWebservice() {
     // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // input
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.cis = SEARCH_POSITIVE;
        tController.id = '00001';
        tController.firstname = 'ตอง';
        tController.lastname = 'ตอง';
        tController.sortDirection = 'ASC';
        List<String> cisList = new List<String>();
        cisList.add('5137447');
        cisList.add('5137448');
        tController.displayedCisList = cisList;

        List<String> expectedCisList = new List<String>();
        expectedCisList.add('5137447');
        expectedCisList.add('5137448');

        // execute httpcallout
        Test.startTest();
       
        Account acc = new Account();
        tController.sortData();
        Test.stopTest();

        verifyCISList(expectedCISList,tController.displayedCisList);

    }
    @isTest static void testSortData_SomeInvalidCIS() {
     
    }


    @isTest static void testGetSearchModel_AllRequstFieldsAreNull() {
        CustomerSearchRequestModel expectedModel = new CustomerSearchRequestModel();
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
        System.assertEquals(True,actualModel.requestMap.isEmpty());

    }

    @isTest static void testGetSearchModel_Priority_InputAllFields_ExpectedCISOnly() {
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = 'testFirst';
        tController.lastname = 'testLastName';
        tController.cis = '4444';
        tController.id = '55555';

        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
        System.debug(actualModel.requestMap);
        System.assertEquals(True,actualModel.requestMap.containsKey(CIS_ID));
        System.assertEquals(False,actualModel.requestMap.containsKey(IDENT_NO));
        System.assertEquals(False,actualModel.requestMap.containsKey(FIRSTNAME_EN));
        System.assertEquals(False,actualModel.requestMap.containsKey(SURNAME_EN));
    }


    @isTest static void testGetSearchModel_Priority_InputTHNameFields_ExpectedTHName() {
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = 'หหหหหห';
        tController.lastname = 'กกกกกก';

        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
        System.debug(actualModel.requestMap);
        System.assertEquals(True,actualModel.requestMap.containsKey(FIRSTNAME_TH));
        System.assertEquals(True,actualModel.requestMap.containsKey(SURNAME_TH));
    }



    @isTest static void testGetSearchModel_Priority_InputIDENT_NAME_Fields_ExpectedIDENTOnly() {
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = 'testFirst';
        tController.lastname = 'testLastName';
        tController.id = '4444';

        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
        System.debug(actualModel.requestMap);
        System.assertEquals(False,actualModel.requestMap.containsKey(CIS_ID));
        System.assertEquals(True,actualModel.requestMap.containsKey(IDENT_NO));
        System.assertEquals(False,actualModel.requestMap.containsKey(FIRSTNAME_EN));
        System.assertEquals(False,actualModel.requestMap.containsKey(SURNAME_EN));
    }
    @isTest static void testGetSearchModel_Priority_InputFirstLast_ExpectedFirstLast() {
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = 'testFirst';
        tController.lastname = 'testLastName';

        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
        System.assertEquals(False,actualModel.requestMap.containsKey(CIS_ID));
        System.assertEquals(False,actualModel.requestMap.containsKey(IDENT_NO));
        System.assertEquals(True,actualModel.requestMap.containsKey(FIRSTNAME_EN));
        System.assertEquals(True,actualModel.requestMap.containsKey(SURNAME_EN));
        System.debug('actualModel'+actualModel);
    }

    @isTest static void testGetSearchModel_Validation_InputFirstName_ExpectedMinCharError() {
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = 'j';
        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
        System.assertEquals(False,actualModel.requestMap.containsKey(CIS_ID));
        System.assertEquals(False,actualModel.requestMap.containsKey(IDENT_NO));
        System.assertEquals(False,actualModel.requestMap.containsKey(FIRSTNAME_EN));
        System.assertEquals(False,actualModel.requestMap.containsKey(SURNAME_EN));
        System.assertEquals(True,ApexPages.hasMessages(ApexPages.Severity.INFO));

        System.debug('actualModel'+actualModel);
    }

    @isTest static void testGetSortModel_Name_ASC() {
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = 'testFirst';
        tController.lastname = 'testLastName';

        List<String> cisList = new List<String>();
        cisList.add('11');
        cisList.add('22');
        tController.displayedCisList = cisList;
        tController.searchData();
        CustomerSearchRequestModel actualModel = tController.getCustomerRequestForSorting(); 
        System.assertEquals('ASC', actualModel.requestMap.get(SORT_TYPE));

    }


    @isTest static void testGetSortModel_Name_DESC() {
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = 'testFirst';
        tController.lastname = 'testLastName';

        List<String> cisList = new List<String>();
        cisList.add('11');
        cisList.add('22');
        tController.displayedCisList = cisList;
        tController.SortData();
        tController.sortDirection = 'DESC';

        CustomerSearchRequestModel actualModel = tController.getCustomerRequestForSorting(); 
        System.assertEquals('DESC', actualModel.requestMap.get(SORT_TYPE));
    }


  
    @isTest static void testGetSortModel_InputOnlyLastname_NameTH() {
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.lastname = 'testLastName';

        List<String> cisList = new List<String>();
        cisList.add('11');
        cisList.add('22');
        tController.displayedCisList = cisList;
        tController.SortData();
        tController.sortDirection = 'DESC';

        CustomerSearchRequestModel actualModel = tController.getCustomerRequestForSorting(); 
        System.assertEquals('DESC', actualModel.requestMap.get(SORT_TYPE));
        System.assertEquals(FIRSTNAME_TH, actualModel.requestMap.get(SORT_COLUMN));
    }

    @isTest static void testGetSortModel_InputOnlyThaiFirstName_NameTH() {
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.firstname = 'กกกกกก';
        tController.lastname = 'testLastName';

        List<String> cisList = new List<String>();
        cisList.add('11');
        cisList.add('22');
        tController.displayedCisList = cisList;
        tController.SortData();
        tController.sortDirection = 'DESC';

        CustomerSearchRequestModel actualModel = tController.getCustomerRequestForSorting(); 
        System.assertEquals('DESC', actualModel.requestMap.get(SORT_TYPE));
        System.assertEquals(FIRSTNAME_TH, actualModel.requestMap.get(SORT_COLUMN));
    }


    @isTest static void testIsEnglishAlphabet_AllEn() {
    	String name = 'ABC445';
    	Boolean expectedResult = True;
    	Boolean actual = testController.isEnglishAlphabet(name);
    	 System.assertEquals(expectedResult,actual);
    }


    @isTest static void testIsEnglishAlphabet_AllTh() {
     	String name = 'กกกกกกก';
    	Boolean expectedResult = False;
    	Boolean actual = testController.isEnglishAlphabet(name);
    	System.assertEquals(expectedResult,actual);
    }

    @isTest static void testIsEnglishAlphabet_MixThEn() {
        String name = 'sกกกกกกกs';
    	Boolean expectedResult = False;
    	Boolean actual = testController.isEnglishAlphabet(name);
    	System.assertEquals(expectedResult,actual);
    }

    @isTest static void testIsEnglishAlphabet_MixEn_Dash() {
    	String name = 'ABC-445';
    	Boolean expectedResult = True;
    	Boolean actual = testController.isEnglishAlphabet(name);
    	System.assertEquals(expectedResult,actual);
     
    }

    @isTest static void testIsEnglishAlphabet_MixTh_Dash() {
        String name = 'แซ่-ตั้ง';
    	Boolean expectedResult = False;
    	Boolean actual = testController.isEnglishAlphabet(name);
    	System.assertEquals(expectedResult,actual);
     
    }

    @isTest static void testGetCustomerListByCISList() {
      // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // input
        CustomerSearch_Controller tController = new CustomerSearch_Controller();

        List<String> cisList = new List<String>();
        cisList.add('5137447');
        cisList.add('5137448');
        cisList.add('5137449');
        // execute httpcallout
        Test.startTest();
        Account acc = new Account(name='accname');
        acc.Name_EN_Prospect__c = 'testEnFirstName';
        acc.CIS__c = '5137447';
        acc.Identification_No_Prospect__c = '1111111111';
        acc.RecordTypeId = prospectRecordTypeId;
        insert acc;

        acc = new Account(name='accname2');
        acc.Name_EN_Prospect__c = 'testEnFirstName';
        acc.CIS__c = '5137448';
        acc.Identification_No_Prospect__c = '1111111111';
        acc.RecordTypeId = prospectRecordTypeId;
        insert acc;

        tController.getCustomerListByCISList(cisList);
        Test.stopTest();
        System.assertEquals(cisList.size(),tController.displayedCisList.size());
    }
 @isTest static void testQueryProspect() {
      // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // input
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        //tController.cis = SEARCH_POSITIVE;
        //tController.id = '5137447';
        tController.firstname = 'prospect1';
        tController.lastname = 'prospect2';
        tController.sortDirection = 'ASC';


        List<String> cisList = new List<String>();
        cisList.add('111');
        cisList.add('222');

        //'Surname_TH_Prospect__c,Surname_EN_Prospect__c
        // execute httpcallout
        Test.startTest();
        Account acc = new Account(name='prospect1');
        acc.Name_EN_Prospect__c = 'prospect1';
        acc.Surname_TH_Prospect__c = 'prospect1';
        acc.Surname_EN_Prospect__c = 'prospect1';
        acc.CIS__c = '1111';
        acc.Identification_No_Prospect__c = '1111111111';
        acc.RecordTypeId = prospectRecordTypeId;
        insert acc;

        acc = new Account(name='prospect2');
        acc.Name_EN_Prospect__c = 'prospect2';
        acc.Surname_TH_Prospect__c = 'prospect2';
        acc.Surname_EN_Prospect__c = 'prospect2';
        acc.CIS__c = '2222';
        acc.Identification_No_Prospect__c = '1111111111';
        acc.RecordTypeId = prospectRecordTypeId;
        insert acc;

        List<CustomerSearch_Controller.Customer> result = tController.sortProspectData('ASC');

        System.debug('result list:'+result.size());
        Test.stopTest();

       // System.assertEquals(cisList.size(),tController.displayedCisList.size());
       // System.assertEquals(cisList.size(), tController.customerList.size());
       
       // check customer list
        //System.assertEquals(tController.getCustomerListByCISList(cisList).size(),tController.customerList.size());
        }



  @isTest static void testSortProspect() {
      // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // input
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        //tController.cis = SEARCH_POSITIVE;
        tController.cis = '';
        tController.id = '111111';
        tController.firstname = 'prospect1';
        tController.lastname = 'prospect2';
        tController.sortDirection = 'ASC';

        tController.prospect_id = '111111';
        tController.prospect_firstname = 'prospect1';
        tController.prospect_lastname = 'prospect2';
        tController.sortDirection = 'ASC';

        //List<String> cisList = new List<String>();
        //cisList.add('001O000000kfDTl1');
        //cisList.add('001O000000kfDTm1');

        // execute httpcallout
        Test.startTest();
        //Account acc = new Account(name='prospect1');
        //acc.Name_EN_Prospect__c = 'prospect1';
        //acc.Surname_TH_Prospect__c = 'prospect1';
        //acc.Surname_EN_Prospect__c = 'prospect1';
        //acc.Identification_No_Prospect__c = '111111';
        //acc.RecordTypeId = prospectRecordTypeId;
        //insert acc;

        //acc = new Account(name='prospect2');
        //acc.Name_EN_Prospect__c = 'prospect2';
        //acc.Surname_TH_Prospect__c = 'prospect2';
        //acc.Surname_EN_Prospect__c = 'prospect2';
        //acc.Identification_No_Prospect__c = '1111111111';
        //acc.RecordTypeId = prospectRecordTypeId;
        //insert acc;

       // tController.searchData();
       // tController.sortData();
        List<CustomerSearch_Controller.Customer> result = tController.sortProspectData(tController.sortDirection);

        System.debug('result list:'+result.size());
        Test.stopTest();
       // System.assertEquals(cisList.size(),tController.displayedCisList.size());
       // System.assertEquals(cisList.size(), tController.customerList.size());
       // check customer list
        System.assertEquals(0,result.size());
        }

 @isTest static void testSearchProspect() {
      // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // input
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        //tController.cis = SEARCH_POSITIVE;
        tController.cis = '';
        tController.id = '111111';
        tController.firstname = 'prospect1';
        tController.lastname = 'prospect2';
        tController.sortDirection = 'ASC';

        tController.prospect_id = '111111';
        tController.prospect_firstname = 'prospect1';
        tController.prospect_lastname = 'prospect2';
        tController.sortDirection = 'ASC';

        //List<String> cisList = new List<String>();
        //cisList.add('001O000000kfDTl1');
        //cisList.add('001O000000kfDTm1');

        // execute httpcallout
        Test.startTest();
        //Account acc = new Account(name='prospect1');
        //acc.Name_EN_Prospect__c = 'prospect1';
        //acc.Surname_TH_Prospect__c = 'prospect1';
        //acc.Surname_EN_Prospect__c = 'prospect1';
        //acc.Identification_No_Prospect__c = '111111';
        //acc.RecordTypeId = prospectRecordTypeId;
        //insert acc;

        //acc = new Account(name='prospect2');
        //acc.Name_EN_Prospect__c = 'prospect2';
        //acc.Surname_TH_Prospect__c = 'prospect2';
        //acc.Surname_EN_Prospect__c = 'prospect2';
        //acc.Identification_No_Prospect__c = '1111111111';
        //acc.RecordTypeId = prospectRecordTypeId;
        //insert acc;

       // tController.searchData();
       // tController.sortData();
        tController.queryProspectFromSFDC();

       // System.debug('result list:'+result.size());
        Test.stopTest();
       // System.assertEquals(cisList.size(),tController.displayedCisList.size());
        //System.assertEquals(cisList.size(), tController.customerList.size());
       // check customer list
        System.assertEquals(0,tController.customerList.size());
        }


    @isTest static void testGetSearchModel_Priority_HasInvalidLastName() {
        CustomerSearch_Controller tController = new CustomerSearch_Controller();
        tController.lastname = '    l';
        CustomerSearchRequestModel actualModel = tController.getCustomerSearchRequestModel(); 
        System.debug(actualModel.requestMap);
        System.assertEquals(False,actualModel.requestMap.containsKey(FIRSTNAME_EN));
    }

    // Test Continuation method
    /*public static testmethod void testWebService() {
        CustomerSearch_Controller customSearchController = new CustomerSearch_Controller();
        // Invoke the continuation by calling the action method
        Continuation conti = (Continuation)customSearchController.searchData();
        
        // Verify that the continuation has the proper requests
        Map<String, HttpRequest> requests = conti.getRequests();
        System.debug(requests);
        //system.assert(requests.size() == 1);
        //system.assert(requests.get(customSearchController.requestLabel) != null);
        
        // Perform mock callout 
        // (i.e. skip the callout and call the callback method)
        HttpResponse response = new HttpResponse();
        response.setBody('Mock response body');   
        // Set the fake response for the continuation     
        Test.setContinuationResponse(customSearchController.requestLabel, response);
        // Invoke callback method
        Object result = Test.invokeContinuationMethod(customSearchController, conti);
        // result is the return value of the callback
        System.assertEquals(null, result);
        // Verify that the controller's result variable
        //   is set to the mock response.
        //System.assertEquals('Mock response body', customSearchController.result);
    }*/
}