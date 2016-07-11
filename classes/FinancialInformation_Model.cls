public class FinancialInformation_Model {
	public final String SAVING = 'Saving';
	public final String CURRENT = 'Current';
	public final String FIXED = 'Fixed Deposit';
	public final String TAWEESUP = 'Taweesup';
	public final String MUTUALFUND = 'Mutual Fund';

    public Map<String, List<String>> creditData {get; private set;}
    public Map<String, List<String>> nonCreditData {get; private set;}
    public List<String> creditProductList {get; private set;}
    public List<String> nonCreditProductList {get; private set;}
    public String cis;

    public Map<String, List<String>> creditDetailHeader {get; private set;}
    public Map<String, List<List<String>>> creditDetailData {get; private set;}

    public Map<String, List<String>> nonCreditDetailHeader {get; private set; }
    public Map<String, List<List<String>>> nonCreditDetailData {get; private set;}

	public FinancialInformation_Model(String cis) {
		this.cis = cis;
		creditProductList = new List<String>{'LN', 'OD', 'PN', 'TF', 'LI', 'HL', 'POD', 'CC'};
		nonCreditProductList = new List<String> {SAVING, 'Current', FIXED, TAWEESUP, MUTUALFUND};

		setupCreditData();
		setupNonCreditData();
	}

	public void setupCreditData() {
    	creditData = new Map<String, List<String>>();
    	creditDetailHeader = new Map<String, List<String>>();
    	creditDetailData = new Map<String, List<List<String>>>();
    	for(String creditProduct : creditProductList) {
	    	creditData.put(creditProduct, new List<String>());
    		creditDetailHeader.put(creditProduct, new List<String>());
    		creditDetailData.put(creditProduct, new List<List<String>>());
    	}

    	List<Financial_Information__c> financialList = [SELECT Id, CC_Limit__c, HL_Limit__c, LI_Limit__c, LN_Limit__c, OD_Limit__c, PN_Limit__c, POD_Limit__c, TF_Limit__c FROM Financial_Information__c WHERE CIS_ID__r.CIS__c=:cis];
    	for(Financial_Information__c financial : financialList) {
    		for(String creditProduct : creditProductList) {
    			String limitField = creditProduct+'_Limit__c';
    			creditData.get(creditProduct).add(GlobalUtility.toCurrency(financial.get(limitField)));
    		}
    	}

    	setupLNData();
    }

    public Map<String, String> getCreditLimitDataMap() {
        Map<String, String> dataMap = new Map<String, String>();
        List<Financial_Information__c> financialList = [SELECT Id, CC_Limit__c, HL_Limit__c, LI_Limit__c, LN_Limit__c, OD_Limit__c, PN_Limit__c, POD_Limit__c, TF_Limit__c FROM Financial_Information__c WHERE CIS_ID__r.CIS__c=:cis LIMIT 1];
        if(!financialList.isEmpty()) {
            Financial_Information__c financial = financialList.get(0);
            for(String creditProduct : creditProductList) {
                String limitField = creditProduct+'_Limit__c';
                dataMap.put(creditProduct+'_Limit', GlobalUtility.toCurrency(financial.get(limitField)));
            }
        }
        return dataMap;
    }

    public void setupLNData() {
    	creditDetailHeader.get('LN').add('Type of Product');
    	creditDetailHeader.get('LN').add('Account Number / Sub');
    	creditDetailHeader.get('LN').add('Limit (บาท)');
    	creditDetailHeader.get('LN').add('Outstanding (บาท)');
    	creditDetailHeader.get('LN').add('อัตราดอกเบี้ย');
    	creditDetailHeader.get('LN').add('วันเปิดบัญชี');
    	creditDetailHeader.get('LN').add('วันครบกำหนด');
    	creditDetailHeader.get('LN').add('จำนวนงวด (เดือน)');
    	creditDetailHeader.get('LN').add('ผ่อนต่องวด (บาท)');
    	creditDetailHeader.get('LN').add('Status');
    }

    public void setupNonCreditData() {
    	nonCreditDetailHeader = new Map<String, List<String>>();
    	nonCreditData = new Map<String, List<String>>();
    	nonCreditDetailData = new Map<String, List<List<String>>>();
    	for(String nonCreditProduct : nonCreditProductList) {
	    	nonCreditData.put(nonCreditProduct, new List<String>());
	    	nonCreditDetailHeader.put(nonCreditProduct, new List<String>());
	    	nonCreditDetailData.put(nonCreditProduct, new List<List<String>>());
    	}

    	setupSavingDetailData();
    	setupCurrentDetailData();
    	setupFixDetailData();
    	setupTaweesupDetailData();
    	setupMutualFundDetailData();

    }

    public void setupMutualFundDetailData() {
    	nonCreditDetailHeader.get(MUTUALFUND).add('เลขที่บัญชี  /เลขที่อ้างอิง');
    	nonCreditDetailHeader.get(MUTUALFUND).add('Sub Account');
    	nonCreditDetailHeader.get(MUTUALFUND).add('ชื่อบัญชี');
    	nonCreditDetailHeader.get(MUTUALFUND).add('ชื่อย่อกองทุน');
    	nonCreditDetailHeader.get(MUTUALFUND).add('ชิ่อกองทุน');
    	nonCreditDetailHeader.get(MUTUALFUND).add('จำนวนหน่วยคงเหลือ (Outstanding Unit)');
    	nonCreditDetailHeader.get(MUTUALFUND).add('วันที่ NAV');
    	nonCreditDetailHeader.get(MUTUALFUND).add('NAV Rate');
    	nonCreditDetailHeader.get(MUTUALFUND).add('มูลค่าคงเหลือ');
    	nonCreditDetailHeader.get(MUTUALFUND).add('รหัสประเภทบัญชี');
    	nonCreditDetailHeader.get(MUTUALFUND).add('บัญชีหลัก / ร่วม');
    }

    public void setupTaweesupDetailData() {
    	nonCreditDetailHeader.get(TAWEESUP).add('เลขที่บัญชี');
    	nonCreditDetailHeader.get(TAWEESUP).add('sub');
    	nonCreditDetailHeader.get(TAWEESUP).add('ชื่อบัญชี');
    	nonCreditDetailHeader.get(TAWEESUP).add('ยอดคงเหลือ (Outstanding)');
    	nonCreditDetailHeader.get(TAWEESUP).add('วันเปิดบัญชี');
    	nonCreditDetailHeader.get(TAWEESUP).add('อัตราดอกเบี้ย');
    	nonCreditDetailHeader.get(TAWEESUP).add('ระยะเวลาฝาก (เดือน)');
    	nonCreditDetailHeader.get(TAWEESUP).add('Hold Amount');
    	//SME_TaweesupResultResponse response = SME_CIRestWebservice.getTaweesupRequest('27702');
    	//if(response != null && response.returnResponse != null && response.returnResponse.taweesup != null) {
    	//	for(SME_TaweesupResultResponse.taweesup_model dataModel : response.returnResponse.taweesup) {
    	//		List<String> colList = new List<String>();
    	//		colList.add(getValue(dataModel.AR_ID));
    			
    	//		//colList.add(getValue(dataModel.SUB_AR));
    	//		colList.add(getValue(null));

    	//		//colList.add(getValue(dataModel.AR_MN_TH));
    	//		colList.add(getValue(null));

    	//		colList.add(getValue(dataModel.CRN_BAL));
    	//		colList.add(getValue(dataModel.OPN_DT));
    	//		colList.add(getValue(dataModel.EFF_RATE_PCT));
    	//		colList.add(getValue(null));
    	//		colList.add(getValue(dataModel.HLD_BAL_AMT));
    	//	}
    	//}
    }


    public void setupSavingDetailData() {
    	nonCreditDetailHeader.get(SAVING).add('เลขที่บัญชี');
    	nonCreditDetailHeader.get(SAVING).add('ชื่อบัญชี');
    	nonCreditDetailHeader.get(SAVING).add('ยอดคงเหลือ (Outstanding)');
    	nonCreditDetailHeader.get(SAVING).add('Hold Amount');
    	//SME_SavingResultResponse savingResponse = SME_CIRestWebservice.getSavingRequest('28862');
    	//if(savingResponse != null && savingResponse.returnResponse != null && savingResponse.returnResponse.saving != null) {
    	//	for(SME_SavingResultResponse.saving_model savingModel : savingResponse.returnResponse.saving) {
    	//		List<String> savingData = new List<String>();
    	//		savingData.add(getValue(savingModel.AR_ID));
    	//		savingData.add(getValue(savingModel.AR_MN_TH));
    	//		savingData.add(getValue(savingModel.CRN_BAL));
    	//		savingData.add(getValue(savingModel.HOLD_BAL_AMT));
    	//		nonCreditDetailData.get(SAVING).add(savingData);
    	//	}
    	//}
    }

    public void setupCurrentDetailData() {
    	nonCreditDetailHeader.get('Current').add('เลขที่บัญชี');
    	nonCreditDetailHeader.get('Current').add('ชื่อบัญชี');
    	nonCreditDetailHeader.get('Current').add('ยอดคงเหลือ (Outstanding)');
    	nonCreditDetailHeader.get('Current').add('Hold Amount');

    	//SME_CurrentResultResponse currentResponse = SME_CIRestWebservice.getCurrentRequest('28862');
    	//if(currentResponse != null && currentResponse.returnResponse != null && currentResponse.returnResponse.current != null) {
    	//	for(SME_CurrentResultResponse.current_model currentModel : currentResponse.returnResponse.current) {
    	//		List<String> currentData = new List<String>();
    	//		currentData.add(getValue(currentModel.AR_ID));
    	//		currentData.add(getValue(currentModel.AR_MN_TH));
    	//		currentData.add(getValue(currentModel.CRN_BAL));
    	//		currentData.add(getValue(currentModel.HOLD_BAL_AMT));
    	//		nonCreditDetailData.get('Current').add(currentData);
    	//	}
    	//}
    }

    public void setupFixDetailData() {
    	nonCreditDetailHeader.get(FIXED).add('เลขที่บัญชี');
    	nonCreditDetailHeader.get(FIXED).add('sub');
    	nonCreditDetailHeader.get(FIXED).add('ชื่อบัญชี');
    	nonCreditDetailHeader.get(FIXED).add('ยอดคงเหลือ (Outstanding)');
    	nonCreditDetailHeader.get(FIXED).add('วันเปิดบัญชี');
    	nonCreditDetailHeader.get(FIXED).add('อัตราดอกเบี้ย');
    	nonCreditDetailHeader.get(FIXED).add('ระยะเวลาฝาก (เดือน)');
    	nonCreditDetailHeader.get(FIXED).add('Hold Amount');

    	//SME_FixedResultResponse response = SME_CIRestWebservice.getFixedRequest('27702');
    	//if(response != null && response.returnResponse != null && response.returnResponse != null) {
    	//	for(SME_FixedResultResponse.fixed_model dataModel : response.returnResponse.fixed) {
    	//		List<String> currentData = new List<String>();
    	//		currentData.add(getValue(dataModel.AR_ID));
    	//		currentData.add(getValue(dataModel.SUB_AR));
    	//		currentData.add(getValue(dataModel.AR_MN_TH));
    	//		currentData.add(getValue(dataModel.CRN_BAL));
    	//		currentData.add(getValue(dataModel.OPN_DT));
    	//		currentData.add(getValue(dataModel.EFF_RATE_PCT));
    	//		currentData.add(getValue(dataModel.AR_TERM));
    	//		currentData.add(getValue(dataModel.HOLD_BAL_AMT));
    	//		nonCreditDetailData.get(FIXED).add(currentData);
    	//	}
    	//}
    }

    public static List<List<String>> getColListOfTaweesup(String cis) {
        List<List<String>> dataList = new List<List<String>>();

        SME_TaweesupResultResponse response = SME_CIRestWebservice.getTaweesupRequest(cis);
        if(response != null && response.returnResponse != null && response.returnResponse.taweesup != null) {
          for(SME_TaweesupResultResponse.taweesup_model dataModel : response.returnResponse.taweesup) {
              List<String> colList = new List<String>();
              colList.add(toValue(dataModel.AR_ID));
                
              //colList.add(toValue(dataModel.SUB_AR));
              colList.add(toValue(null));

              //colList.add(toValue(dataModel.AR_MN_TH));
              colList.add(toValue(null));

              colList.add(GlobalUtility.toCurrency(toValue(dataModel.CRN_BAL)));
              colList.add(toValue(dataModel.OPN_DT));
              colList.add(toValue(dataModel.EFF_RATE_PCT));
              colList.add(toValue(null));
              colList.add(GlobalUtility.toCurrency(toValue(dataModel.HLD_BAL_AMT)));

              dataList.add(colList);
          }
        }

        return dataList;
    }

    public static List<List<String>> getColListOfCurrent(String cis) {
        List<List<String>> dataList = new List<List<String>>();
        SME_CurrentResultResponse response = SME_CIRestWebservice.getCurrentRequest(cis);
        if(response != null && response.returnResponse != null && response.returnResponse.current != null) {
          for(SME_CurrentResultResponse.current_model dataModel : response.returnResponse.current) {
              List<String> colsList = new List<String>();
              colsList.add(toValue(dataModel.AR_ID));
              colsList.add(toValue(dataModel.AR_NM_TH));
              colsList.add(GlobalUtility.toCurrency(toValue(dataModel.CRN_BAL)));
              colsList.add(GlobalUtility.toCurrency(toValue(dataModel.HOLD_BAL_AMT)));
              dataList.add(colsList);
          }
        }
        return dataList;
    }

    public static List<List<String>> getColListOfSaving(String cis) {
        List<List<String>> dataList = new List<List<String>>();
        SME_SavingResultResponse response = SME_CIRestWebservice.getSavingRequest(cis);
        if(response != null && response.returnResponse != null && response.returnResponse.saving != null) {
          for(SME_SavingResultResponse.saving_model dataModel : response.returnResponse.saving) {
              List<String> colsList = new List<String>();
              colsList.add(toValue(dataModel.AR_ID));
              colsList.add(toValue(dataModel.AR_NM_TH));
              colsList.add(GlobalUtility.toCurrency(toValue(dataModel.CRN_BAL)));
              colsList.add(GlobalUtility.toCurrency(toValue(dataModel.HOLD_BAL_AMT)));
              dataList.add(colsList);
          }
        }

        return dataList;
    }


    public static List<List<String>> getColListOfFixed(String cis) {
        List<List<String>> dataList = new List<List<String>>();

        SME_FixedResultResponse response = SME_CIRestWebservice.getFixedRequest(cis);
        if(response != null && response.returnResponse != null && response.returnResponse != null) {
          for(SME_FixedResultResponse.fixed_model dataModel : response.returnResponse.fixed) {
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

        return dataList;
    }


    public static List<List<String>> getColListOfMutualFund(String cis) {
        List<List<String>> dataList = new List<List<String>>();

        SME_MutualFundResultResponse response = SME_CIRestWebservice.getMutualFundRequest(cis);
        if(response != null && response.returnResponse != null && response.returnResponse != null) {
          for(SME_MutualFundResultResponse.mutualfund_model dataModel : response.returnResponse.mutualfund) {
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

        return dataList;
    }


    public String getValue(Object val) {
        return val != null ? String.valueOf(val) : '';
    }

    public static String toValue(Object val) {
        return val != null ? String.valueOf(val) : '';
    }


}