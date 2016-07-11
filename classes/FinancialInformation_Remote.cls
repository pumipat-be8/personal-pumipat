global class FinancialInformation_Remote {

    global FinancialInformation_Remote(ApexPages.StandardController stdController) { 

    }

    @RemoteAction
    global static Map<String, List<String>> retrieveTotalDebt(String cis) {
        Map<String, List<String>>  dataMap = new Map<String, List<String>>();
        dataMap.put('total_limit', new List<String>{'0.00'});
        dataMap.put('pn_limit', new List<String>{'0'});
        dataMap.put('od_limit', new List<String>{'0'});
        dataMap.put('tf_limit', new List<String>{'0'});
        for(Financial_Information__c ficancialInfo : [SELECT Id, PN_Limit__c, OD_Limit__c, TF_Limit__c FROM Financial_Information__c WHERE CIS_ID__r.CIS__c = :cis]) {
            Decimal pnLimit = ficancialInfo.PN_Limit__c != null ? ficancialInfo.PN_Limit__c : 0;
            Decimal odLimit = ficancialInfo.OD_Limit__c != null ? ficancialInfo.OD_Limit__c : 0;
            //Decimal liLimit = ficancialInfo.LI_Limit__c != null ? ficancialInfo.LI_Limit__c : 0;
            Decimal tfLimit = ficancialInfo.TF_Limit__c != null ? ficancialInfo.TF_Limit__c : 0;
            dataMap.put('pn_limit', new List<String>{String.valueOf(pnLimit)});
            dataMap.put('od_limit', new List<String>{String.valueOf(odLimit)});
            //dataMap.put('li_limit', new List<String>{String.valueOf(liLimit)});
            dataMap.put('tf_limit', new List<String>{String.valueOf(tfLimit)});

            Decimal totalLimit = pnLimit + odLimit + tfLimit;
            dataMap.put('total_limit', new List<String>{GlobalUtility.toCurrency(totalLimit)});
        }

        Utilization_Model utilizationModel = new Utilization_Model(cis);
        for(String product : utilizationModel.utilizationNameList) {
            dataMap.put(product.toLowerCase()+'_header_list', utilizationModel.headerList);
            dataMap.put(product.toLowerCase()+'_limit_list', utilizationModel.getLimitList(product));
            dataMap.put(product.toLowerCase()+'_outstanding_list', utilizationModel.getOutstandingList(product));
            dataMap.put(product.toLowerCase()+'_limit_value_list', utilizationModel.getLimitValueList(product));
            dataMap.put(product.toLowerCase()+'_outstanding_value_list', utilizationModel.getOutstandingValueList(product));
        }

        SME_CreditOutStandingResultResponse response = SME_CIRestWebservice.getCreditOutStandingRequest(cis);
        if(response != null && response.returnResponse != null && response.returnResponse.outstanding != null) {
            Decimal pnOutstanding = 0;
            Decimal odOutstanding = 0;
            Decimal tfOutstanding = 0;
            Decimal totalOutstanding = 0;
            
            for(SME_CreditOutStandingResultResponse.creditOutStandingResponse_model dataModel : response.returnResponse.outstanding) {
                if(dataModel.AR_TYPE == 'PN') {
                    pnOutstanding = Decimal.valueOf(dataModel.OST);
                } else if(dataModel.AR_TYPE == 'OD') {
                    odOutstanding = Decimal.valueOf(dataModel.OST);
                } else if(dataModel.AR_TYPE == 'TF') {
                    tfOutstanding = Decimal.valueOf(dataModel.OST);
                }
            }

            totalOutstanding = pnOutstanding + odOutstanding + tfOutstanding; 
            dataMap.put('total_outstanding', new List<String>{GlobalUtility.toCurrency(totalOutstanding)});
            dataMap.put('pn_outstanding', new List<String>{String.valueOf(pnOutstanding)});
            dataMap.put('od_outstanding', new List<String>{String.valueOf(odOutstanding)});
            dataMap.put('tf_outstanding', new List<String>{String.valueOf(tfOutstanding)});
        }

        return dataMap;
    }

    @RemoteAction
    global static Map<String, String> retrieveInteractionHistory(String cis) {
        Map<String, String> dataMap;
        InteractionHistory_Model interactionHistoryData;
        interactionHistoryData = new InteractionHistory_Model(cis);
        dataMap = interactionHistoryData.getDataMap();
        return dataMap;
    }

    @RemoteAction
    global static Map<String, String> retrieveCreditData(String cis) {
        FinancialInformation_Model financialModel = new FinancialInformation_Model(cis);
        Map<String, String> dataMap = financialModel.getCreditLimitDataMap();
        SME_CreditOutStandingResultResponse response = SME_CIRestWebservice.getCreditOutStandingRequest(cis);
        if(response != null && response.returnResponse != null && response.returnResponse.outstanding != null) {
            for(SME_CreditOutStandingResultResponse.creditOutStandingResponse_model dataModel : response.returnResponse.outstanding) {
                dataMap.put(dataModel.AR_TYPE +'_Outstanding', GlobalUtility.toCurrency(dataModel.OST));
            }
        }
        return dataMap;
    }

    @RemoteAction
    global static Map<String, String> retrieveNonCreditData(String cis) {
        Map<String ,String> dataMap = new Map<String, String>();
        SME_NonCreditOutStandingResultResponse response;
        response = SME_CIRestWebservice.getNonCreditOutStandingRequest(cis);
        if(response != null && response.returnResponse != null && response.returnResponse.outstanding != null) {
            for(SME_NonCreditOutStandingResultResponse.nonCreditOutStandingResponse_model dataModel : response.returnResponse.outstanding) {
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
        return dataMap;
    }

    @RemoteAction
    global static Map<String, List<List<String>>> retrieveNonCreditDetailData(String cis, String product) {
        Map<String, List<List<String>>> dataListMap = new Map<String, List<List<String>>>();
        List<List<String>> dataList = new List<List<String>>();
        product = product.replace(' ', '_');
        if(product == 'Current') {
            dataList = FinancialInformation_Model.getColListOfCurrent(cis);
        } else if(product == 'Fixed_Deposit') {
            dataList = FinancialInformation_Model.getColListOfFixed(cis);
        } else if(product == 'Saving') {
            dataList = FinancialInformation_Model.getColListOfSaving(cis);
        } else if(product == 'Taweesup') {
            dataList = FinancialInformation_Model.getColListOfTaweesup(cis);
        } else if(product == 'Mutual_Fund') {
            dataList = FinancialInformation_Model.getColListOfMutualFund(cis);
        }

        dataListMap.put(product, dataList);

        //product = product.replace(' ', '_');
        //dataList.add(new List<String>{'1','2'});
        //dataListMap.put(product, dataList);

        return dataListMap;
    }
}