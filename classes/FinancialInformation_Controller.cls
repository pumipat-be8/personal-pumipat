/*------------------------------------------------------------
Author: Komsan Wi
Company : Beryl8
Description:

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
21/07/2015  Komsan.wi           First Create
------------------------------------------------------------*/
public with sharing class FinancialInformation_Controller {
    public String currentCis;
    public Map<String, Object> responseMap {get; private set;}
    public String responseMapJson {get; private set;}
    public Map<String, String> requestLabelMap {get; private set;}

    public String AMOUNT_INFLOW = 'Amount Inflow';
    public String AMOUNT_OUTFLOW = 'Amount Outflow';
    public String CASA_AVG = 'CASA Avg. Balance';
    public String CHEQUE = 'Cheque (Items)';
    public String CHEQUE_AMOUNT = 'Cheque Amount';
    public String CHEQUE_RETURN = 'Cheque Return (Items)';
    public String CHEQUE_RETURN_AMOUNT = 'Cheque Return Amount';
    public String TXN_INFLOW = 'TXN Inflow';
    public String TXN_OUTFLOW = 'TXN Outflow';

    public List<KBANK_STM__c> kbankSTMList{get;set;}

    public String cis {get;set;}

    public Account accountObj{get;set;}

    //public List<String> utilizationHeader {get; private set;}
    //public Map<String, Map<String, List<String>>> utilizationData {get; private set;}

    public List<String> kbankSTMHeader {get; private set;}
    public List<List<String>> kbankSTMData {get; private set;}
    public Id accountId;
    private Map<Integer, String> monthStrMap;

    public List<String> utilizationProductList {get; private set; }
    //public InteractionHistory_Model interactionHistoryData {get; private set;}
    public FinancialInformation_Model financialInformationData {get; private set;}
    public Utilization_Model utilizationData {get; private set;}
    public List<String> statementList {get; private set;}

    public FinancialInformation_Controller(ApexPages.StandardController controller){
        monthStrMap = new Map<Integer, String>{1 =>'Jan', 2=>'Feb', 3=>'Mar',4 =>'Apr', 5=>'May', 6=>'Jun',7 =>'Jul', 8=>'Aug', 9=>'Sep',10 =>'Oct', 11=>'Nov', 12=>'Dec'};
        utilizationProductList = new List<String> {'OD', 'PN', 'TF'};
        statementList = new List<String>{AMOUNT_INFLOW, AMOUNT_OUTFLOW, CASA_AVG, CHEQUE, CHEQUE_AMOUNT, CHEQUE_RETURN, CHEQUE_RETURN_AMOUNT, TXN_INFLOW, TXN_OUTFLOW};

        accountId = ApexPages.currentPage().getParameters().get('id');
        accountObj = [SELECT Id, CIS__c FROM Account WHERE Id=:accountId];
        cis = accountObj.CIS__c;

        kbankSTMList = new List<KBANK_STM__c>();
        kbankSTMList = [SELECT Id FROM KBANK_STM__c WHERE CIS_ID__c =:accountId];


        this.requestLabelMap = new Map<String, String>();
        this.responseMap = new Map<String, Object>();
    }

    public Object requestNonCreditDetailData() {
      this.responseMap.clear();
      currentCis = Apexpages.currentPage().getParameters().get('cis');
      String productName = Apexpages.currentPage().getParameters().get('productName');
      Continuation con = new Continuation(120);
      con.continuationMethod = 'handleResponseNonCreditDetail';
      HttpRequest req;
      productName = productName.replace(' ', '_');
      if(productName == 'Current') {
          req = SME_CIRestWebservice.createCurrentDataRequest(currentCis);
      } else if(productName == 'Fixed_Deposit') {
          req = SME_CIRestWebservice.createFixedDataRequest(currentCis);
      } else if(productName == 'Saving') {
          req = SME_CIRestWebservice.createSavingDataRequest(currentCis);
      } else if(productName == 'Taweesup') {
          req = SME_CIRestWebservice.createTaweesupDataRequest(currentCis);
      } else if(productName == 'Mutual_Fund') {
          req = SME_CIRestWebservice.createMutualFundDataRequest(currentCis);
      }
      this.requestLabelMap.put(productName, con.addHttpRequest(req));
      return con;
    }


    public Object requestFinancialInformation() {
      this.responseMap.clear();
      currentCis = Apexpages.currentPage().getParameters().get('cis');
      Continuation con = new Continuation(120);
      con.continuationMethod = 'handleResponseFinancialInformation';
      //this.requestLabelMap.put('interactionHistory', con.addHttpRequest(SME_CIRestWebservice.createTransactBPRequest(currentCis)));
      this.requestLabelMap.put('creditData', con.addHttpRequest(SME_CIRestWebservice.createCreditOutstandingRequest(currentCis)));
      this.requestLabelMap.put('nonCreditData', con.addHttpRequest(SME_CIRestWebservice.createNonCreditOutstandingRequest(currentCis)));
      return con;
    }

    public Object handleResponseNonCreditDetail() {
      for(String productName : requestLabelMap.keySet()) {
        HttpResponse response = Continuation.getResponse(this.requestLabelMap.get(productName));
        System.debug('handleResponseNonCreditDetail response :'+response);
        if(response == null) continue;
        if(productName == 'Current') {
            handleCurrentResponse(response);
        } else if(productName == 'Fixed_Deposit') {
            handleFixedResponse(response);
        } else if(productName == 'Saving') {
            handleSavingResponse(response);
        } else if(productName == 'Taweesup') {
            handleTaweesupResponse(response);
        } else if(productName == 'Mutual_Fund') {
            handleMutualFundResponse(response);
        }

        this.requestLabelMap.remove(productName);
      }

      this.responseMapJson = JSON.serializePretty(responseMap);
      return null;
    }

    public Object handleResponseFinancialInformation() {
      for(String key : requestLabelMap.keySet()) {
          HttpResponse response = Continuation.getResponse(this.requestLabelMap.get(key));
          //if(key == 'interactionHistory') {
            //handleInteractionHistoryResponse(response);
          //} else 
          if(key == 'creditData') {
            handleCreditData(response);
          } else if(key == 'nonCreditData') {
            handleNonCreditData(response);
          }
        this.requestLabelMap.remove(key);
      }
      this.responseMapJson = JSON.serializePretty(responseMap);
      return null;
    }

    public Boolean validateResponse(String key, HttpResponse response) {
      String responseStr = response.getBody();

      if(response.getStatusCode() == 404) {
          Map<String, String> errorMap = new Map<String, String>();
          errorMap.put('error', 'Adapter is not available');
          this.responseMap.put(key, errorMap);
          return false;

      } else if(response.getStatusCode() == 503) {
          Map<String, String> errorMap = new Map<String, String>();
          errorMap.put('error', 'Host is not available');
          this.responseMap.put(key, errorMap);
          return false;
      }

      Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
      if(responseMap.containsKey('error')) {
          String error = (String)((Map<String,Object>)responseMap.get('error')).get('message');
          String errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+error+'Response:'+responseStr;
          GlobalUtility.logMessage('ERROR',key,key,null,null,errorMessage,null,null,null);
          //throw new CIWebserviceException(errorMessage);
          Map<String, String> errorMap = new Map<String, String>();
          errorMap.put('error', error);
          this.responseMap.put(key, errorMap);
          return false;
      } 
      return true;
    }

    public void handleCurrentResponse(HttpResponse response) {
      if(!validateResponse('Current', response)) return;
      String responseStr = response.getBody();

      List<List<String>> dataList = new List<List<String>>();
      SME_CurrentResultResponse responseModel = SME_CurrentResultResponse.parse(responseStr);
        if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse.current != null) {
          for(SME_CurrentResultResponse.current_model dataModel : responseModel.returnResponse.current) {
              List<String> colsList = new List<String>();
              colsList.add(toValue(dataModel.AR_ID));
              colsList.add(toValue(dataModel.AR_NM_TH));
              colsList.add(GlobalUtility.toCurrency(toValue(dataModel.CRN_BAL)));
              colsList.add(GlobalUtility.toCurrency(toValue(dataModel.HOLD_BAL_AMT)));
              dataList.add(colsList);
          }
        }
      this.responseMap.put('Current', dataList);
      
    }
    public void handleFixedResponse(HttpResponse response) {
      if(!validateResponse('Fixed_Deposit', response)) return;
      String responseStr = response.getBody();

      List<List<String>> dataList = new List<List<String>>();

      SME_FixedResultResponse responseModel = SME_FixedResultResponse.parse(responseStr);
      if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse != null) {
        for(SME_FixedResultResponse.fixed_model dataModel : responseModel.returnResponse.fixed) {
            List<String> colsList = new List<String>();
            colsList.add(toValue(dataModel.AR_ID));
            colsList.add(toValue(dataModel.SUB_AR));
            colsList.add(toValue(dataModel.AR_NM_TH));
            colsList.add(GlobalUtility.toCurrency(toValue(dataModel.CRN_BAL)));
            colsList.add(toValue(dataModel.OPN_DT));
            colsList.add(toValue(dataModel.EFF_RATE_PCT));
            colsList.add(toValue(dataModel.AR_TERM));
            colsList.add(GlobalUtility.toCurrency(toValue(dataModel.HOLD_BAL_AMT)));
            dataList.add(colsList);
        }
      }
      responseMap.put('Fixed_Deposit',dataList);
    }

    public void handleSavingResponse(HttpResponse response) {
      if(!validateResponse('Saving', response)) return;
      String responseStr = response.getBody();

      List<List<String>> dataList = new List<List<String>>();
      SME_SavingResultResponse responseModel = SME_SavingResultResponse.parse(responseStr);
      if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse.saving != null) {
        for(SME_SavingResultResponse.saving_model dataModel : responseModel.returnResponse.saving) {
            List<String> colsList = new List<String>();
            colsList.add(toValue(dataModel.AR_ID));
            colsList.add(toValue(dataModel.AR_NM_TH));
            colsList.add(GlobalUtility.toCurrency(toValue(dataModel.CRN_BAL)));
            colsList.add(GlobalUtility.toCurrency(toValue(dataModel.HOLD_BAL_AMT)));
            dataList.add(colsList);
        }
      }
      responseMap.put('Saving',dataList);
      
    }
    public void handleTaweesupResponse(HttpResponse response) {
      if(!validateResponse('Taweesup', response)) return;
      String responseStr = response.getBody();

      List<List<String>> dataList = new List<List<String>>();
      SME_TaweesupResultResponse responseModel = SME_TaweesupResultResponse.parse(responseStr);
      if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse.taweesup != null) {
        for(SME_TaweesupResultResponse.taweesup_model dataModel : responseModel.returnResponse.taweesup) {
            List<String> colList = new List<String>();
            colList.add(toValue(dataModel.AR_ID));
            colList.add(toValue(null));
            colList.add(toValue(null));
            colList.add(GlobalUtility.toCurrency(toValue(dataModel.CRN_BAL)));
            colList.add(toValue(dataModel.OPN_DT));
            colList.add(toValue(dataModel.EFF_RATE_PCT));
            colList.add(toValue(null));
            colList.add(GlobalUtility.toCurrency(toValue(dataModel.HLD_BAL_AMT)));
            dataList.add(colList);
        }
      }
      responseMap.put('Taweesup',dataList);
    }

    public void handleMutualFundResponse(HttpResponse response) {
      if(!validateResponse('Mutual_Fund', response)) return;
      String responseStr = response.getBody();
      List<List<String>> dataList = new List<List<String>>();

      SME_MutualFundResultResponse responseModel = SME_MutualFundResultResponse.parse(responseStr);
      if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse != null) {
        for(SME_MutualFundResultResponse.mutualfund_model dataModel : responseModel.returnResponse.mutualfund) {
            List<String> colsList = new List<String>();
            colsList.add(toValue(dataModel.AR_ID));
            colsList.add(toValue(dataModel.SUB_AR));
            colsList.add(toValue(dataModel.AR_NM_TH));

            colsList.add(toValue(dataModel.FND_CD));
            colsList.add(toValue(dataModel.FND_DSC_TH));
            colsList.add(GlobalUtility.toCurrency(toValue(dataModel.UNIT_BAL)));
            colsList.add(toValue(dataModel.NAV_DT));
            colsList.add(toValue(dataModel.NAV));

            Decimal bal;
            if(dataModel.NAV != null && dataModel.UNIT_BAL != null) {
              bal = Decimal.valueOf(dataModel.NAV) * Decimal.valueOf(dataModel.UNIT_BAL);
            } 
            colsList.add(toValue(bal));
            colsList.add(toValue(dataModel.FND_TP_CD));
            colsList.add(toValue(dataModel.AR_OWN_TP_CD));
            dataList.add(colsList);
        }
      }
      responseMap.put('Mutual_Fund',dataList);
    }

    public void handleNonCreditData(HttpResponse response) {
      if(!validateResponse('nonCreditData', response)) return;
      String responseStr = response.getBody();
      Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseStr);

      Map<String, Object> dataMap = new Map<String, Object>();
      SME_NonCreditOutStandingResultResponse responseModel = SME_NonCreditOutStandingResultResponse.parse(responseStr);
      if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse.outstanding != null) {
            for(SME_NonCreditOutStandingResultResponse.nonCreditOutStandingResponse_model dataModel : responseModel.returnResponse.outstanding) {
                String arType = '';
                if(dataModel.AR_TYPE == 'SA')   arType = 'Saving_Outstanding';
                else if(dataModel.AR_TYPE == 'CA')  arType = 'Current_Outstanding';
                else if(dataModel.AR_TYPE == 'KA')  arType = 'Mutual_Fund_Outstanding';
                else if(dataModel.AR_TYPE == 'FD')  arType = 'Fixed_Deposit_Outstanding';
                else if(dataModel.AR_TYPE == 'TW')  arType = 'Taweesup_Outstanding';
                else arType = dataModel.AR_TYPE;
                dataMap.put(arType, GlobalUtility.toCurrency(dataModel.OST));
            }
        }
      this.responseMap.put('nonCreditData', dataMap);
    }

    public void handleCreditData(HttpResponse response) {
      if(!validateResponse('creditData', response)) return;
      String responseStr = response.getBody();
      Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseStr);

      FinancialInformation_Model financialModel = new FinancialInformation_Model(currentCis);
      Map<String, String> dataMap = financialModel.getCreditLimitDataMap();

      SME_CreditOutStandingResultResponse responseModel = SME_CreditOutStandingResultResponse.parse(responseStr);
      if(responseModel != null && responseModel.returnResponse != null && responseModel.returnResponse.outstanding != null) {
        for(SME_CreditOutStandingResultResponse.creditOutStandingResponse_model dataModel : responseModel.returnResponse.outstanding) {
            dataMap.put(dataModel.AR_TYPE +'_Outstanding', GlobalUtility.toCurrency(dataModel.OST));
        }
      }
      this.responseMap.put('creditData', dataMap);
    }

    //public void handleInteractionHistoryResponse(HttpResponse response) {
    //  if(!validateResponse('interactionHistory', response)) return;
    //  String responseOfTransactBP = response.getBody();
    //  //Blob returnBase64Response = EncodingUtil.base64Decode(responseOfTransactBP);
    //  //String responseOfTransactBPEncode = returnBase64Response.toString();
    //  //System.debug('responseOfTransactBP :'+responseOfTransactBP);
    //  Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(responseOfTransactBP);

    //  if(dataMap.containsKey('error')) {
    //      String error = (String)((Map<String,Object>)dataMap.get('error')).get('message');
    //      String errorMessage = ExceptionMessage.PARSE_FAILED+'ErrorMsg:'+error+'Response:'+responseOfTransactBP;
    //      GlobalUtility.logMessage('ERROR','InteractionHistory_Model','InteractionHistory_Model',null,null,errorMessage,null,null,null);
    //      //throw new CIWebserviceException(errorMessage);
    //      Map<String, String> errorMap = new Map<String, String>();
    //      errorMap.put('error', error);
    //      this.responseMap.put('interactionHistory', errorMap);
    //      return;
    //  } 
      
    //  InteractionHistory_Model interactionHistoryData = new InteractionHistory_Model(currentCis, responseOfTransactBP);
    //  this.responseMap.put('interactionHistory', interactionHistoryData.getDataMap());
    //}

    public void initData() {
        setupUtilizationData();
        setupKBankStmData();
        setupFinancialData();
    }

    public void setupFinancialData() {
        financialInformationData = new FinancialInformation_Model(this.cis);
    }

    public void setupUtilizationData() {
        utilizationData = new Utilization_Model(this.cis);
    }

    public void setupKBankStmData() {
        List<KBANK_STM__c> stmList = [SELECT Id, Name, Amount_Inflow__c, Amount_Outflow__c, CASA_Average_Balance__c, Cheque_Paid_Items__c, Cheque_Paid_Amount__c, Cheque_Return_Items__c, Cheque_Return_Amount__c, TXN_Inflow__c, TXN_Outflow__c FROM KBANK_STM__c WHERE CIS_ID__c = :accountId ORDER BY Name];
        Date todayDate = System.today();
        kbankSTMHeader = new List<String>();
        kbankSTMHeader.add('Statement');
        kbankSTMHeader.add('Summary 12 Months');

        Map<String, List<String>> dataMap = new Map<String, List<String>>();
        Map<String, Decimal> summaryMap = new Map<String, Decimal>();
        for(String statement : statementList) {
            dataMap.put(statement, new List<String>{statement});
            summaryMap.put(statement, 0);
        }

        Decimal inflowSummary = 0;
        Decimal outflowSummary = 0;

        Map<String, sObject> stmMapByMonth = GlobalUtility.toMap('Name', stmList);

        for(Integer i=1; i<=12; i++) {
            KBANK_STM__c stm;
            String key = i > 9 ? String.valueOf(i) : '0'+String.valueOf(i);
            if(stmMapByMonth.containsKey(key))      stm = (KBANK_STM__c)stmMapByMonth.get(key);
            else                                    stm = new KBANK_STM__c();

            Date thisDate = date.newinstance(todayDate.year(), todayDate.month() - i , 1);
            Integer year = thisDate.year() > 2400 ? thisDate.year() - 543 : thisDate.year();
            String yearStr = String.valueOf(year).substring(2);
            kbankSTMHeader.add(monthStrMap.get(thisDate.month())+'-'+yearStr);

            summaryMap.put(AMOUNT_INFLOW, summaryMap.get(AMOUNT_INFLOW) + GlobalUtility.toDecimal(stm.Amount_Inflow__c));
            dataMap.get(AMOUNT_INFLOW).add(stm.Amount_Inflow__c == null ? '' : GlobalUtility.toCurrency(stm.Amount_Inflow__c));

            summaryMap.put(AMOUNT_OUTFLOW, summaryMap.get(AMOUNT_OUTFLOW) + GlobalUtility.toDecimal(stm.Amount_Outflow__c));
            dataMap.get(AMOUNT_OUTFLOW).add(stm.Amount_Outflow__c == null ? '' : GlobalUtility.toCurrency(stm.Amount_Outflow__c));

            summaryMap.put(CASA_AVG, summaryMap.get(CASA_AVG) + GlobalUtility.toDecimal(stm.CASA_Average_Balance__c));
            dataMap.get(CASA_AVG).add(stm.CASA_Average_Balance__c == null ? '' : GlobalUtility.toCurrency(stm.CASA_Average_Balance__c));

            summaryMap.put(CHEQUE, summaryMap.get(CHEQUE) + GlobalUtility.toDecimal(stm.Cheque_Paid_Items__c));
            dataMap.get(CHEQUE).add(stm.Cheque_Paid_Items__c == null ? '' : stm.Cheque_Paid_Items__c);

            summaryMap.put(CHEQUE_AMOUNT, summaryMap.get(CHEQUE_AMOUNT) + GlobalUtility.toDecimal(stm.Cheque_Paid_Amount__c));
            dataMap.get(CHEQUE_AMOUNT).add(stm.Cheque_Paid_Amount__c == null ? '' : GlobalUtility.toCurrency(stm.Cheque_Paid_Amount__c));

            summaryMap.put(CHEQUE_RETURN, summaryMap.get(CHEQUE_RETURN) + GlobalUtility.toDecimal(stm.Cheque_Return_Items__c));
            dataMap.get(CHEQUE_RETURN).add(stm.Cheque_Return_Items__c == null ? '' : GlobalUtility.toValue(stm.Cheque_Return_Items__c));

            summaryMap.put(CHEQUE_RETURN_AMOUNT, summaryMap.get(CHEQUE_RETURN_AMOUNT) + GlobalUtility.toDecimal(stm.Cheque_Return_Amount__c));
            dataMap.get(CHEQUE_RETURN_AMOUNT).add(stm.Cheque_Return_Amount__c == null ? '' : GlobalUtility.toCurrency(stm.Cheque_Return_Amount__c));

            summaryMap.put(TXN_INFLOW, summaryMap.get(TXN_INFLOW) + GlobalUtility.toDecimal(stm.TXN_Inflow__c));
            dataMap.get(TXN_INFLOW).add(stm.TXN_Inflow__c == null ? '' : stm.TXN_Inflow__c);

            summaryMap.put(TXN_OUTFLOW, summaryMap.get(TXN_OUTFLOW) + GlobalUtility.toDecimal(stm.TXN_Outflow__c));
            dataMap.get(TXN_OUTFLOW).add(stm.TXN_Outflow__c == null ? '' : stm.TXN_Outflow__c);
        }

        for(String statement : summaryMap.keySet()) {
            if(dataMap.get(statement).size() > 1) {
                dataMap.get(statement).add(1, GlobalUtility.toCurrency(summaryMap.get(statement)));
            }
        }

        kbankSTMData = new List<List<String>>();
        for(String statement : statementList) {
            kbankSTMData.add(dataMap.get(statement));
        }
    }

    public String getValue(Object val) {
        return val != null ? String.valueOf(val) : '';
    }

    public String toValue(Object val) {
        return val != null ? String.valueOf(val) : '';
    }


    //@ReadOnly
   // @RemoteAction
   // public static Map<String, String> retrieveInteractionHistory(String cis) {
   //   Map<String, String> dataMap;
   //     try{
            //InteractionHistory_Model interactionHistoryData = new InteractionHistory_Model(cis);
            //dataMap = interactionHistoryData.getDataMap();
      //  } catch(Exception e) {
      //    dataMap = new Map<String, String>();
      //    dataMap.put('error', e.getMessage());
      //    System.debug(e);
      //  }
      //  return dataMap;
   // }
}