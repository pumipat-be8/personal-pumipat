public virtual class CustomerSearch_Management {
    //public String CIS;
    //public List<Account> accounts{get; set;}
    //public List<Call_Report__c> report{get; set;}
    //public List<List<SObject>> result {get; set;}

    protected Account getAccountFromId(String accountID){
        Account tempAccount = [Select Id, OwnerId, Port_Pool__c, RC_Code__c, Primary_Segment_Code__c, Permanent_Owner_Extension__c From Account Where Id =: accountID];
        return tempAccount;
    }

    protected User getUserFromId(Id userID){
        User tempUser = [Select Id, RC_Code__c, ManagerId,Profile.Name From User Where Id =: userID];
        return tempUser;
    }
    @TestVisible
    protected List<List<sObject>> searchAllValue(String inputID, String inputCIS, String inputFirstName, String inputLastName){
        String inputValue = '';
        if(inputID != null && inputID.trim() != ''){
            inputValue = inputID.trim();
            return queryAllSOSLValue(inputValue);
        }
        if(inputFirstName != null && inputFirstName.trim() != '' && inputValue != ''){
            inputValue = inputValue + ' or ' + inputFirstName.trim()+'*';
        }else if(inputFirstName != null && inputFirstName.trim() != ''){
            inputValue = inputFirstName.trim()+'*';
        }
        if(inputLastName != null && inputLastName.trim() != '' && inputValue != ''){
            inputValue = inputValue + ' or ' + inputLastName.trim()+'*';
        }else if(inputLastName != null && inputLastName.trim() != ''){
            inputValue = inputLastName.trim()+'*';
        }
        
        if(inputValue != ''){
            return queryAllSOSLValue(inputValue);
        }
        return null;
    }
  protected List<List<sObject>> sortAllValue(String inputID, String inputCIS, String inputFirstName, String inputLastName,String direction){
        String inputValue = '';
        List<List<sObject>> result = new List<List<SObject>>();
        //if(inputCIS != ''){
        //    inputValue = inputCIS;
        //    result = sortSOSLValueByName(inputValue,direction);
        //}
        if(inputID != null && inputID.trim() != ''){
            inputValue = inputID.trim();
            result = sortSOSLValueByName(inputValue,direction);
            return result;
        }
        if(inputFirstName != null && inputFirstName.trim() != '' && inputValue != ''){
            inputValue = inputValue + ' or ' + inputFirstName.trim()+'*';
        }else if(inputFirstName != null && inputFirstName.trim() != ''){
            inputValue = inputFirstName.trim()+'*';
        }
        if(inputLastName != null && inputLastName.trim() != '' && inputValue != ''){
            inputValue = inputValue + ' or ' + inputLastName.trim()+'*';
        }else if(inputLastName != null && inputLastName.trim() != ''){
            inputValue = inputLastName.trim()+'*';
        }
        
        if(inputValue != ''){
            result = sortSOSLValueByName(inputValue,direction);
        }
        return result;
    }
    @TestVisible
    protected List<List<sObject>> queryAllSOSLValue(String inputValue){

        List<List<SObject>> returnResult = new List<List<sObject>>();
        String searchQuery = 'FIND \'' + inputValue + '\' IN ALL FIELDS RETURNING Account(Id,CIS__c,Customer_360__c,Title__c,Primary_Segment_Code__c,'+
                                    'Document_Type__c,Dual_Segment_Code__c,Customer_Status__c,Status__c,RecordtypeId,OwnerId,Owner.Name,Name,'+
                                    'Name_EN_Prospect__c,Birthdate_Registration_Date__c,Port_Pool__c,'+
                                    'Surname_TH_Prospect__c,Surname_EN_Prospect__c,Identification_No_Prospect__c,Document_Type_Prospect__c order by Name ASC) LIMIT 100';
        returnResult = search.query(searchQuery);
        return returnResult;
    }
    @TestVisible
    protected List<List<sObject>> sortSOSLValueByName(String inputValue,String direction){

        List<List<SObject>> returnResult = new List<List<sObject>>();
        String searchQuery = 'FIND \'' + inputValue + '\' IN ALL FIELDS RETURNING Account(Id,CIS__c,Customer_360__c,Title__c,Primary_Segment_Code__c,'+
                                    'Document_Type__c,Dual_Segment_Code__c,Customer_Status__c,Status__c,RecordtypeId,OwnerId,Owner.Name,Name,'+
                                    'Name_EN_Prospect__c,Birthdate_Registration_Date__c,Port_Pool__c,'+
                                    'Surname_TH_Prospect__c,Surname_EN_Prospect__c,Identification_No_Prospect__c,Document_Type_Prospect__c order by Name '+direction+') LIMIT 100';
        returnResult = search.query(searchQuery);
        return returnResult;
    }

    protected Map<String,sObject> queryMapAddress(List<String> cisIdList){
        
        Map<String,sObject> mapAddress = new Map<String,sObject>();
        mapAddress = GlobalUtility.toMapLookup('CIS_ID__r','CIS__c', [SELECT Id,CIS_ID__c,CIS_ID__r.CIS__c,District__c,Province__c
                                    FROM Address__c WHERE CIS_ID__r.CIS__c IN :cisIdList AND Address_Type__c = 'Contact']);
        return mapAddress;
    }

    //public void set(){
    //    result= [find :CIS in ALL FIELDS RETURNING Account(cis__c,name, Phone),Call_Report__c(name,Contact__c)];
    //    accounts=result.remove(0);
    //    report=result.remove(0);
    //}
    /*public List<Account> SearchAccount(){
        return accounts;
    }*/
    /*public List<Call_Report__c> SearchCall(){
        return report;
    }*/
}