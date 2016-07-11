/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   Convert prospect callout with Async 

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
07/27/2015  Charnun.T           First Create
08/08/2015  Charnun.T           Add more logic about convert with CIS 
------------------------------------------------------------*/
global class SME_CIRestAsyncWebservice {

    public static String CONVERTPROSPECT_ENDPOINT = 'callout:CIConvertProspectEndpoint';
    public static String CONVERTPROSPECTWITHCIS_ENDPOINT = 'callout:CIConvertProspectEndpointWithCIS';
    public static String CLASS_NAME = 'SMECIRestAsyncWebservice';
    public static Integer CONVERT_PROSPECT_LIMIT_PER_ROUND = 30;

    private static String convertProspectJSONGenerator(List<sObject> convertListSpilt, Boolean isLasted){

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('convertProspect');
        gen.writeStartObject();
        gen.writeFieldName('jobrequest');
        gen.writeStartArray();
        if(convertListSpilt != null){
        //for each attendee create a JSON object
            for(sObject convertsObject:convertListSpilt){
                Date tempDate = Date.valueOf(convertsObject.get('Birthdate_Registration_Date__c'));
                String tempYear = String.valueOf(tempDate.year());
                if(String.valueOf(UserInfo.getLocale()) == 'th_TH'){
                    tempYear = String.valueOf(Integer.valueOf(tempDate.year())-543);
                }
                gen.writeStartObject();        
                gen.writeStringField('SFDC_ID', String.valueOf(convertsObject.get('Id')));
                gen.writeStringField('IDENT_NO', String.valueOf(convertsObject.get('Identification_No_Prospect__c')));
                gen.writeStringField('BRTH_ESTB_DT', String.valueOf(tempYear)+'-'+String.valueOf('0'+String.valueOf(tempDate.month())).right(2)+'-'+String.valueOf('0'+String.valueOf(tempDate.day())).right(2));
                gen.writeEndObject();
            }
        }
        gen.writeEndArray();
        gen.writeFieldName('LASTED');
        gen.writeString(String.valueOf(isLasted));
        gen.writeEndObject();
        gen.writeEndObject();

        System.debug('JSON string :'+ gen.getAsString());
        return gen.getAsString();
    }

    private static String convertProspectWithCISJSONGenerator(List<sObject> convertListSpilt, Boolean isLasted){

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('convertProspect');
        gen.writeStartObject();
        gen.writeFieldName('jobrequest');
        gen.writeStartArray();
        if(convertListSpilt != null){
            //for each attendee create a JSON object
            for(sObject convertsObject:convertListSpilt){
                gen.writeStartObject();        
                gen.writeStringField('SFDC_ID', String.valueOf(convertsObject.get('Id')));
                gen.writeStringField('IP_ID', String.valueOf(Integer.valueOf(convertsObject.get('Name'))));
                gen.writeEndObject();
            }
        }
        gen.writeEndArray();
        gen.writeFieldName('LASTED');
        gen.writeString(String.valueOf(isLasted));
        gen.writeEndObject();
        gen.writeEndObject();

        System.debug('JSON string :'+ gen.getAsString());
        return gen.getAsString();
    }

    public static void convertProspectRequest(List<sObject> convertList) {
        List<sObject> convertProspectList = new List<sObject>();
        List<sObject> convertProspectProblemList = new List<sObject>();
        List<Account> updateAccountConvertProspect = new List<Account>();

        for(sObject convert : convertList){
            Account tempAccount = new Account();
            tempAccount.Id = Id.valueOf(convert.Id);
            tempAccount.Convert_Prospect_Date__c = System.today();
            updateAccountConvertProspect.add(tempAccount);
        }

        for(sObject convert : convertList){
            if(convert.get('Birthdate_Registration_Date__c') != null && convert.get('Identification_No_Prospect__c') != null){
                convertProspectList.add(convert);
                if(convertProspectList.size() >= CONVERT_PROSPECT_LIMIT_PER_ROUND){
                    SME_CIRestWebservice.sendHTTPRequest(CONVERTPROSPECT_ENDPOINT,convertProspectJSONGenerator(convertProspectList,false));
                    convertProspectList.clear();
                }
            }else{
                convertProspectProblemList.add(convert);
            }
        }

        if(convertProspectList.size() > 0){
            SME_CIRestWebservice.sendHTTPRequest(CONVERTPROSPECT_ENDPOINT,convertProspectJSONGenerator(convertProspectList,false));
        }
        /*if(convertProspectList.size() == 0){
            SME_CIRestWebservice.sendHTTPRequest('https://rmtoolsweb.kasikornbank.com/SMEConvertProspectStatus','{"status":"Success","endtime":"'+String.valueOf(System.now())+'"}');
        }*/
        
        if(updateAccountConvertProspect.size()>0){
            update updateAccountConvertProspect;
            System.debug('Finish to update Convert Status');
        }
        if(convertProspectProblemList.size() > 0){
            GlobalUtility.logMessage('WARNING','SME_CIRestAsyncWebservice','convertProspectRequest',null,null,'Convert prospect error :'+convertProspectProblemList,null,null,null);
        }
    }

    public static void convertProspectRequestWithCIS(List<sObject> convertList) {
        List<sObject> convertProspectListWithCIS = new List<sObject>();
        List<sObject> convertProspectProblemList = new List<sObject>();
        List<Account> updateAccountConvertProspect = new List<Account>();

        for(sObject convert : convertList){
            Account tempAccount = new Account();
            tempAccount.Id = Id.valueOf(convert.Id);
            tempAccount.Convert_Prospect_Date__c = System.today();
            if(GlobalUtility.isNumberAlphabet(String.valueOf(convert.get('Name')))){
                tempAccount.Name = String.valueOf(Integer.valueOf(convert.get('Name')));
            }
            updateAccountConvertProspect.add(tempAccount);
        }

        for(sObject convert : convertList){
            if(GlobalUtility.isNumberAlphabet(String.valueOf(convert.get('Name')))){
                convertProspectListWithCIS.add(convert);
                if(convertProspectListWithCIS.size() >= CONVERT_PROSPECT_LIMIT_PER_ROUND){
                    SME_CIRestWebservice.sendHTTPRequest(CONVERTPROSPECTWITHCIS_ENDPOINT,convertProspectWithCISJSONGenerator(convertProspectListWithCIS,false));
                    convertProspectListWithCIS.clear();
                }
            }else{
                convertProspectProblemList.add(convert);
            }
        }

        if(convertProspectListWithCIS.size() > 0){
            SME_CIRestWebservice.sendHTTPRequest(CONVERTPROSPECTWITHCIS_ENDPOINT,convertProspectWithCISJSONGenerator(convertProspectListWithCIS,false));
        }
        /*if(convertProspectListWithCIS.size() == 0){
            SME_CIRestWebservice.sendHTTPRequest('https://rmtoolsweb.kasikornbank.com/SMEConvertProspectWithCISStatus','{"status":"Success","endtime":"'+String.valueOf(System.now())+'"}');
        }*/
        
        if(updateAccountConvertProspect.size()>0){
            update updateAccountConvertProspect;
            System.debug('Finish to update Convert with CIS Status');
        }
        if(convertProspectProblemList.size() > 0){
            GlobalUtility.logMessage('WARNING','SME_CIRestAsyncWebservice','convertProspectRequestWithCIS',null,null,'Convert prospect error :'+convertProspectProblemList,null,null,null);
        }
    }
    
    public static void convertProspectWithZeroRecord(String convertFunction){
        if(convertFunction == 'WithIdentification'){
            SME_CIRestWebservice.sendHTTPRequest('https://rmtoolsweb.kasikornbank.com/SMEConvertProspectStatus','{"status":"Success","endtime":"'+String.valueOf(System.now())+'"}');
        }else if(convertFunction == 'WithCIS'){
            SME_CIRestWebservice.sendHTTPRequest('https://rmtoolsweb.kasikornbank.com/SMEConvertProspectWithCISStatus','{"status":"Success","endtime":"'+String.valueOf(System.now())+'"}');
        }
    }
}