@isTest
    public class FinancialInformation_Controller_Test {

    	public static Account createAccount() {
    		Account account = new Account();
    		account.Name = 'AccountName';
    		account.CIS__c = '7749454';
    		return account;
    	}

        @isTest static void testValidateResponse() {
            Account account = new Account();
            account.CIS__c = '123';
            account.Name = 'AccountName';
            insert account;

            ApexPages.currentPage().getParameters().put('id', account.Id);
            FinancialInformation_Controller ctrl = new FinancialInformation_Controller(new ApexPages.StandardController(account));
            HttpResponse response404 = new HttpResponse();
            response404.setStatusCode(404);
            System.assertEquals(false, ctrl.validateResponse('123', response404));
            System.assertEquals('Adapter is not available', (String)((Map<String, Object>)ctrl.responseMap.get('123')).get('error'));

            HttpResponse response503 = new HttpResponse();
            response503.setStatusCode(503);
            System.assertEquals(false, ctrl.validateResponse('123', response503));
            System.assertEquals('Host is not available', (String)((Map<String, Object>)ctrl.responseMap.get('123')).get('error'));

            HttpResponse responseError = new HttpResponse();
            responseError.setStatusCode(200);
            responseError.setHeader('Content-Type', 'application/json');
            responseError.setBody('{"error":{"message":"error message"}}');
            System.assertEquals(false, ctrl.validateResponse('123', responseError));
            System.assertEquals('error message', (String)((Map<String, Object>)ctrl.responseMap.get('123')).get('error'));
        }

    	public static FinancialInformation_Controller processNonCreditDetailDataContinuation(String productName) {
    		Account account = FinancialInformation_Controller_Test.createAccount();
            insert account;

            ApexPages.StandardController stdController = new ApexPages.StandardController(account);
            ApexPages.currentPage().getParameters().put('id',account.Id);
            ApexPages.currentPage().getParameters().put('cis','444');
            ApexPages.currentPage().getParameters().put('productName',productName);
            FinancialInformation_Controller ctrl = new FinancialInformation_Controller(stdController);
            Continuation continuation = (Continuation)ctrl.requestNonCreditDetailData();
            Map<String, HttpRequest> requests = continuation.getRequests();
            System.assertEquals(1, requests.size());
            System.assert(requests.get(ctrl.requestLabelMap.get(productName)) != null);
            Test.setContinuationResponse(ctrl.requestLabelMap.get(productName), MockHttpResponseGenerator.getNonCreditDetailDataResponse(productName));
            Object result = Test.invokeContinuationMethod(ctrl, continuation);
            System.assertEquals(null, result);
            return ctrl;
    	}

       @isTest static void testRequestMutualFundNonCreditDetailData() {
            FinancialInformation_Controller ctrl = FinancialInformation_Controller_Test.processNonCreditDetailDataContinuation('Mutual_Fund');
            System.assert(ctrl.responseMap.get('Mutual_Fund') != null);
            List<List<String>> dataList = (List<List<String>>)ctrl.responseMap.get('Mutual_Fund');
            System.assertEquals('0011004482', dataList.get(0).get(0));
            System.assertEquals('0011004482-2', dataList.get(0).get(1));
            System.assertEquals('10.00', dataList.get(0).get(5));
    	}
     
    	@isTest static void testRequestTaweesupNonCreditDetailData() {
            FinancialInformation_Controller ctrl = FinancialInformation_Controller_Test.processNonCreditDetailDataContinuation('Taweesup');
            System.assert(ctrl.responseMap.get('Taweesup') != null);
            List<List<String>> dataList = (List<List<String>>)ctrl.responseMap.get('Taweesup');
            System.assertEquals('XXX-2-0033-X', dataList.get(0).get(0));
            System.assertEquals('4,138,436.96', dataList.get(0).get(3));
    	}

    	@isTest static void testRequestFixedNonCreditDetailData() {
            FinancialInformation_Controller ctrl = FinancialInformation_Controller_Test.processNonCreditDetailDataContinuation('Fixed_Deposit');
            System.assert(ctrl.responseMap.get('Fixed_Deposit') != null);
            List<List<String>> dataList = (List<List<String>>)ctrl.responseMap.get('Fixed_Deposit');
            System.assertEquals('0011004482', dataList.get(0).get(0));
            System.assertEquals('0011004482-2', dataList.get(0).get(1));
            System.assertEquals('10.00', dataList.get(0).get(3));
    	}

    	@isTest static void testRequestSavingNonCreditDetailData() {
            FinancialInformation_Controller ctrl = FinancialInformation_Controller_Test.processNonCreditDetailDataContinuation('Saving');
            System.assert(ctrl.responseMap.get('Saving') != null);
            List<List<String>> dataList = (List<List<String>>)ctrl.responseMap.get('Saving');
            System.assertEquals('XXX-2-0033-X', dataList.get(0).get(0));
            System.assertEquals('4,138,436.96', dataList.get(0).get(2));
            System.assertEquals('XXX-2-9459-X', dataList.get(1).get(0));
            System.assertEquals('2,664,630.23', dataList.get(1).get(2));
    	}

    	@isTest static void testRequestCurrentNonCreditDetailData() {
            FinancialInformation_Controller ctrl = FinancialInformation_Controller_Test.processNonCreditDetailDataContinuation('Current');
            System.assert(ctrl.responseMap.get('Current') != null);
            List<List<String>> dataList = (List<List<String>>)ctrl.responseMap.get('Current');
            System.assertEquals('0011004482', dataList.get(0).get(0));
            System.assertEquals('10,000.00', dataList.get(0).get(2));
        }
    	
    	@isTest static void testSetupKBankStmData() {
    		Account account = FinancialInformation_Controller_Test.createAccount();
    		insert account;

    		KBANK_STM__c stm01 = new KBANK_STM__c();
    		stm01.Name = '01';
    		stm01.Amount_Inflow__c = 10;
    		stm01.Amount_Outflow__c = 20;
    		stm01.CIS_ID__c = account.Id;
    		insert stm01;
    		
    		KBANK_STM__c stm02 = new KBANK_STM__c();
    		stm02.Name = '02';
    		stm02.Amount_Inflow__c = 20;
    		stm02.Amount_Outflow__c = 10;
    		stm02.CIS_ID__c = account.Id;
    		insert stm02;

            ApexPages.StandardController stdController = new ApexPages.StandardController(account);
            ApexPages.currentPage().getParameters().put('id',account.Id);
            FinancialInformation_Controller ctrl = new FinancialInformation_Controller(stdController);
            ctrl.setupKBankStmData();

            System.assertEquals(14, ctrl.kbankSTMHeader.size());
            System.assertEquals('Statement', ctrl.kbankSTMHeader.get(0));
            System.assertEquals('Summary 12 Months', ctrl.kbankSTMHeader.get(1));

            System.assertEquals(9, ctrl.kbankSTMData.size());
            System.assertEquals('Amount Inflow', ctrl.kbankSTMData.get(0).get(0));
            System.assertEquals('30.00', ctrl.kbankSTMData.get(0).get(1));
            System.assertEquals('10.00', ctrl.kbankSTMData.get(0).get(2));
            System.assertEquals('20.00', ctrl.kbankSTMData.get(0).get(3));

            System.assertEquals('Amount Outflow', ctrl.kbankSTMData.get(1).get(0));
            System.assertEquals('30.00', ctrl.kbankSTMData.get(1).get(1));
            System.assertEquals('20.00', ctrl.kbankSTMData.get(1).get(2));
            System.assertEquals('10.00', ctrl.kbankSTMData.get(1).get(3));

            System.assertEquals('CASA Avg. Balance', ctrl.kbankSTMData.get(2).get(0));
            System.assertEquals('Cheque (Items)', ctrl.kbankSTMData.get(3).get(0));
            System.assertEquals('Cheque Amount', ctrl.kbankSTMData.get(4).get(0));
            System.assertEquals('Cheque Return (Items)', ctrl.kbankSTMData.get(5).get(0));
            System.assertEquals('Cheque Return Amount', ctrl.kbankSTMData.get(6).get(0));
            System.assertEquals('TXN Inflow', ctrl.kbankSTMData.get(7).get(0));
            System.assertEquals('TXN Outflow', ctrl.kbankSTMData.get(8).get(0));
    	}
    	

    	@isTest static void testSetupUtilizationData() {
    		Account account = new Account();
    		account.Name = 'AccountName';
    		account.CIS__c = '7749454';
    		insert account;

    		Utilization__c utilization1 = new Utilization__c();
    		utilization1.CIS_ID__c = account.Id;
    		utilization1.Name = '01';
    		utilization1.OD_Limit__c = 1;
    		utilization1.OD_AVG_OUT__c = 2;
    		utilization1.OD_Utilization__c = 3;
    		utilization1.PN_Limit__c = 4;
    		utilization1.PN_AVG_OUT__c = 5;
    		utilization1.PN_Utilization__c = 6;
    		utilization1.TF_Limit__c = 7;
    		utilization1.TF_AVG_OUT__c = 8;
    		utilization1.TF_Utilization__c = 9;
    		insert utilization1;

    		Utilization__c utilization2 = new Utilization__c();
    		utilization2.CIS_ID__c = account.Id;
    		utilization2.Name = '02';
    		utilization2.OD_Limit__c = 1;
    		utilization2.OD_AVG_OUT__c = 2;
    		utilization2.OD_Utilization__c = 3;
    		utilization2.PN_Limit__c = 4;
    		utilization2.PN_AVG_OUT__c = 5;
    		utilization2.PN_Utilization__c = 6;
    		utilization2.TF_Limit__c = 7;
    		utilization2.TF_AVG_OUT__c = 8;
    		utilization2.TF_Utilization__c = 9;
    		insert utilization2;

    		Utilization__c utilization3 = new Utilization__c();
    		utilization3.CIS_ID__c = account.Id;
    		utilization3.Name = '03';
    		utilization3.OD_Limit__c = 1;
    		utilization3.OD_AVG_OUT__c = 2;
    		utilization3.OD_Utilization__c = 3;
    		utilization3.PN_Limit__c = 4;
    		utilization3.PN_AVG_OUT__c = 5;
    		utilization3.PN_Utilization__c = 6;
    		utilization3.TF_Limit__c = 7;
    		utilization3.TF_AVG_OUT__c = 8;
    		utilization3.TF_Utilization__c = 9;
    		insert utilization3;

            ApexPages.StandardController stdController = new ApexPages.StandardController(account);
            ApexPages.currentPage().getParameters().put('id',account.Id);
            FinancialInformation_Controller ctrl = new FinancialInformation_Controller(stdController);
            ctrl.setupUtilizationData();
            System.assertEquals(12, ctrl.utilizationData.headerList.size());
            System.assertEquals(3, ctrl.utilizationData.utilizationMap.size());
            System.assertEquals('OD', ctrl.utilizationData.utilizationMap.get('OD').productName);
            System.assertEquals(12, ctrl.utilizationData.utilizationMap.get('OD').limitList.size());
            System.assertEquals(12, ctrl.utilizationData.utilizationMap.get('OD').limitValueList.size());
            System.assertEquals(12, ctrl.utilizationData.utilizationMap.get('OD').outstandingList.size());
            System.assertEquals(12, ctrl.utilizationData.utilizationMap.get('OD').utilizationList.size());

            System.debug('utilizationData :'+ctrl.utilizationData);
    	}

    	@isTest static void testRequestFinancialInformation() {
    		Account account = FinancialInformation_Controller_Test.createAccount();
            insert account;

            ApexPages.StandardController stdController = new ApexPages.StandardController(account);
            ApexPages.currentPage().getParameters().put('id',account.Id);
            ApexPages.currentPage().getParameters().put('cis','444');
            FinancialInformation_Controller ctrl = new FinancialInformation_Controller(stdController);
            Continuation continuation = (Continuation)ctrl.requestFinancialInformation();
            Map<String, HttpRequest> requests = continuation.getRequests();
            System.assertEquals(2, requests.size());
            System.assert(requests.get(ctrl.requestLabelMap.get('creditData')) != null);
            System.assert(requests.get(ctrl.requestLabelMap.get('nonCreditData')) != null);
            Test.setContinuationResponse(ctrl.requestLabelMap.get('creditData'), MockHttpResponseGenerator.getCreditResponse());
            Test.setContinuationResponse(ctrl.requestLabelMap.get('nonCreditData'), MockHttpResponseGenerator.getNonCreditResponse());
            Object result = Test.invokeContinuationMethod(ctrl, continuation);
            System.assertEquals(null, result);

          	Map<String, Object> nonCreditDataMap = (Map<String, Object>)ctrl.responseMap.get('nonCreditData');
          	System.assertEquals('12,395,320.34', (String)nonCreditDataMap.get('Saving_Outstanding'));
          	System.assertEquals('20,000.00', (String)nonCreditDataMap.get('Current_Outstanding'));

          	Map<String, String> creditDataMap = (Map<String, String>)ctrl.responseMap.get('creditData');
          	System.assertEquals('12,395,320.34', creditDataMap.get('LN_Outstanding'));
          	System.assertEquals('20,000.00', creditDataMap.get('TP_Outstanding'));
    	}

    	@isTest static void testSetupFinancialData() {
    		Account account = new Account();
    		account.Name = 'AccountName';
    		account.CIS__c = '7749454';
    		insert account;

    		Financial_Information__c financialInfo1 = new Financial_Information__c();
    		financialInfo1.CC_Limit__c = 10;
    		financialInfo1.HL_Limit__c = 20;
    		financialInfo1.LI_Limit__c = 30;
    		financialInfo1.LN_Limit__c = 35;
    		financialInfo1.OD_Limit__c = 40;
    		financialInfo1.PN_Limit__c = 50;
    		financialInfo1.POD_Limit__c = 60;
    		financialInfo1.TF_Limit__c = 70;
    		financialInfo1.CIS_ID__c = account.Id;
    		insert financialInfo1;

            ApexPages.StandardController stdController = new ApexPages.StandardController(account);
            ApexPages.currentPage().getParameters().put('id',account.Id);
            FinancialInformation_Controller ctrl = new FinancialInformation_Controller(stdController);
            ctrl.setupFinancialData();

            System.assertEquals('35.00', ctrl.financialInformationData.creditData.get('LN').get(0));
            System.assertEquals('40.00', ctrl.financialInformationData.creditData.get('OD').get(0));
            System.assertEquals('50.00', ctrl.financialInformationData.creditData.get('PN').get(0));
            System.assertEquals('70.00', ctrl.financialInformationData.creditData.get('TF').get(0));
            System.assertEquals('30.00', ctrl.financialInformationData.creditData.get('LI').get(0));
            System.assertEquals('20.00', ctrl.financialInformationData.creditData.get('HL').get(0));
            System.assertEquals('60.00', ctrl.financialInformationData.creditData.get('POD').get(0));
            System.assertEquals('10.00', ctrl.financialInformationData.creditData.get('CC').get(0));
    	}

    	// This this class just do the code coverage / other test already assert 
    	@isTest static void testInitData() {
    		Account account = new Account();
    		account.Name = 'AccountName';
    		account.CIS__c = '7749454';
    		insert account;

            ApexPages.StandardController stdController = new ApexPages.StandardController(account);
            ApexPages.currentPage().getParameters().put('id',account.Id);
            FinancialInformation_Controller ctrl = new FinancialInformation_Controller(stdController);
            ctrl.initData();
    	}
    }