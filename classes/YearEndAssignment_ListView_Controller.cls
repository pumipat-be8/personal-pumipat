/**
* @author komsan.wi@beryl8.com
* @21/07/2015 create new
* @08/09/2015 move model to new class, remove description field
* @02/12/2015 split query due to offset limitation remove comment
*/
public with sharing class YearEndAssignment_ListView_Controller {
    public Boolean hasError{get;set;}
    public Integer rows{get{return Integer.valueOf(Year_End_Config__c.getOrgDefaults().Page_Size__c);}}
    public String rcCode{get{return [SELECT RC_Code__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].RC_Code__c;}}
    public String empId{get{return [SELECT Employee_ID__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Employee_ID__c;}}
    public String userLowerSet {get{
        List<User> userList = new List<User>();
        userList = [SELECT Id FROM User WHERE ManagerId = :UserInfo.getUserId()];
        Map<String,User> userMap = new Map<String,User>(userList);
        return JSON.serialize(userMap.keySet());
    }}

    @TestVisible
    private String staticPrefix = 'extjs_data';
    public YearEndAssignment_ListView_Controller() {
        hasError = false;
    }
    @RemoteAction
    public static List<YearEndModel.FieldInfo> describeFields(String objName, List<String> fieldNames) {
        Map<String, Schema.SObjectType> objTypeMap = Schema.getGlobalDescribe();
        if (!objTypeMap.containsKey(objName)) {
            throw new YearEndModel.DescribeException('No SObject named ' + objName + ' found');
        }
        Schema.SObjectType sobj = objTypeMap.get(objName);
        Map<String, Schema.SObjectField> fieldMap = sobj.getDescribe().fields.getMap();

        List<YearEndModel.FieldInfo> result = new List<YearEndModel.FieldInfo>();
        for (String field : fieldNames) {
            if (!fieldMap.containsKey(field)) {
                throw new YearEndModel.DescribeException('No field named ' + field + ' found in SObject ' + objName);
            }
            Schema.DescribeFieldResult dfr = fieldMap.get(field).getDescribe();
            YearEndModel.FieldInfo fi = new YearEndModel.FieldInfo();
            fi.name = field;
            fi.modifiable = dfr.isCreateable() | dfr.isUpdateable();
            fi.sortable = dfr.isSortable();
            fi.nillable = dfr.isNillable();
            fi.fieldType = String.valueOf(dfr.getType()).toLowerCase();
            fi.locked = false;
            fi.label = dfr.getLabel();
            if (dfr.getType() == Schema.DisplayType.Picklist) {
                fi.picklistValues = new List<List<String> >();
                for (Schema.PicklistEntry plv : dfr.getPicklistValues()) {
                    if (plv.isActive()) {
                        fi.picklistValues.add(new String[]{plv.getLabel(), plv.getValue()});
                    }
                }
                if (dfr.isNillable()) {
                    fi.picklistValues.add(new String[]{'', null});
                }
            }
            result.add(fi);
        }
        return result;
    }
    @RemoteAction
    public static Map<String,String> describeMapFields(String objName, List<String> fieldNames) {
        Map<String, Schema.SObjectType> objTypeMap = Schema.getGlobalDescribe();
        if (!objTypeMap.containsKey(objName)) {
            throw new YearEndModel.DescribeException('No SObject named ' + objName + ' found');
        }
        Schema.SObjectType sobj = objTypeMap.get(objName);
        Map<String, Schema.SObjectField> fieldMap = sobj.getDescribe().fields.getMap();
        Map<String,String> result = new Map<String,String>();
        for (String field : fieldNames) {
            if (!fieldMap.containsKey(field)) {
                throw new YearEndModel.DescribeException('No field named ' + field + ' found in SObject ' + objName);
            }
            Schema.DescribeFieldResult dfr = fieldMap.get(field).getDescribe();
            result.put(field,dfr.getLabel());
        }
        return result;
    }

    @RemoteAction
    public static YearEndModel.CRUDResponse query(YearEndModel.QueryObj qobj) {
        YearEndModel.CRUDResponse resp = new YearEndModel.CRUDResponse();
        String operate = ' = ';
        String countstr = 'SELECT COUNT() FROM ' + qobj.sobjname;
        if (qobj.filter != null) {
            List<Map<String, String>> filter = qobj.filter;
            countstr += ' WHERE ';
            countstr += filter[0].get('property') + ((filter[0].get('value')=='@')?' > 1 ':('= ' + YearEndAssignment_ListView_Controller.condition(filter[0])));
            for (Integer i = 1; i < filter.size(); i++) {
                countstr += ' AND ' + filter[i].get('property') + ((filter[i].get('value')=='@')?' > 1 ':('= ' + YearEndAssignment_ListView_Controller.condition(filter[i])));
            }
            if (qobj.extraquery != null) {
                countstr += ' AND '+ qobj.extraquery;
            }
        }else if (qobj.extraquery != null) {
            countstr += ' WHERE ' + qobj.extraquery;
        }
        resp.total = Database.countQuery(countstr);
        if(qobj.start >= resp.total){
            qobj.start -= qobj.recordCount;
        }
        String qstr = 'SELECT Id FROM ' + qobj.sobjname;
        if (qobj.filter != null) {
            List<Map<String, String>> filter = qobj.filter;
            qstr += ' WHERE ';
            qstr += filter[0].get('property') + ((filter[0].get('value')=='@')?' > 1 ':('= ' + YearEndAssignment_ListView_Controller.condition(filter[0])));
            for (Integer i = 1; i < filter.size(); i++) {
                qstr += ' AND ' + filter[i].get('property') + ((filter[i].get('value')=='@')?' > 1 ':('= ' + YearEndAssignment_ListView_Controller.condition(filter[i])));
            }
            if (qobj.extraquery != null) {
                qstr += ' AND '+ qobj.extraquery;
            }
        }else if (qobj.extraquery != null) {
            qstr += ' WHERE ' + qobj.extraquery;
        }
        if (qobj.sortParams != null) {
            qstr += ' ORDER BY ';
            qstr += qobj.sortParams[0].get('property');
            for (Integer i = 1; i < qobj.sortParams.size(); i++) {
                qstr += ',' + qobj.sortParams[i].get('property');
            }
            qstr += ' ' + qobj.sortParams[0].get('direction');
            qstr += ',Id ASC';
        }else qstr += ' ORDER BY Id ASC';

        Integer reclimit = qobj.start + qobj.recordCount;
        qstr += ' LIMIT ' + String.valueOf(reclimit);
        //qstr = String.escapeSingleQuotes(qstr);   // sanitize for SOQL injection
        Integer current_result = 0;        // initialize with the true offset
        List<String> temporaryId = new List<String>();
        try {
            for (List<SObject> rlit : Database.query(qstr)) {
                for (SObject rit : rlit) {
                    if ((current_result >= qobj.start) && (current_result < (qobj.start + qobj.recordCount))) {
                        temporaryId.add(rit.get('Id')+'');
                    }
                    current_result++;
                }
            }
            if(temporaryId!=null && temporaryId.size() > 0){
                qstr = 'SELECT ' + qobj.fields.replace('"','\'') + ' FROM ' + qobj.sobjname + ' WHERE Id IN :temporaryId';
                if (qobj.sortParams != null) {
                    qstr += ' ORDER BY ';
                    qstr += qobj.sortParams[0].get('property');
                    for (Integer i = 1; i < qobj.sortParams.size(); i++) {
                        qstr += ',' + qobj.sortParams[i].get('property');
                    }
                    qstr += ' ' + qobj.sortParams[0].get('direction');
                    qstr += ',Id ASC';
                }else qstr += ' ORDER BY Id ASC';
                
                for (List<SObject> rlit : Database.query(qstr)) {
                    for (SObject rit : rlit) {
                        resp.records.add(rit);
                    }
                }
            }
        } catch (Exception e) {
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }
    public static String condition(Map<String, String> filter){
        return ((filter.get('value').isNumeric())?(Decimal.valueOf(filter.get('value'))+''):(filter.get('value').indexOf('true')!=-1 || filter.get('value').indexOf('false')!=-1 || filter.get('value').indexOf('null')!=-1)?filter.get('value'):('\''+filter.get('value').replace('#','')+'\' '));
    }
    @RemoteAction
    public static YearEndModel.PicklistResponse queryLocation(YearEndModel.QueryPickListObj qobj) {
        YearEndModel.PicklistResponse resp = new YearEndModel.PicklistResponse();
        try {
            for (List<SObject> rlit : Database.query('SELECT Id,Area_Name__c FROM Master_Map__c WHERE Type__c=\''+qobj.scope+'\' '+((qobj.extra!=null)?(' AND Depend_On_Object__r.Area_Name__c=\''+qobj.extra+'\''):'')+' ORDER BY Area_Name__c')) {
                for (SObject rit : rlit) {
                    resp.records.add(new YearEndModel.Picklist(rit.get('Area_Name__c')+'',rit.get('Area_Name__c')+''));
                }
            }
        } catch (Exception e) {
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }
    @RemoteAction
    public static YearEndModel.PicklistResponse querySelectedByTeam(YearEndModel.QueryPickListObj qobj) {
        YearEndModel.PicklistResponse resp = new YearEndModel.PicklistResponse();
        try {
            List<UserRole> userRoleList = [SELECT Id,Name,DeveloperName FROM UserRole WHERE ParentRoleId = :UserInfo.getUserRoleId()];
            if(qobj.extra!=null)
                resp.records.add(new YearEndModel.Picklist('',Label.YearEnd_ShowAll));
            for(UserRole eachUserRole : userRoleList){
                resp.records.add(new YearEndModel.Picklist(eachUserRole.DeveloperName.replace('RC','')+'',eachUserRole.Name+''));
            }
        } catch (Exception e) {
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }
    @RemoteAction
    public static YearEndModel.PicklistResponse querySelectedBy(YearEndModel.QueryPickListObj qobj) {
        YearEndModel.PicklistResponse resp = new YearEndModel.PicklistResponse();
        try {
            List<User> finalResult = new List<User>();
            User thisUser = [SELECT UserRoleId,UserRole.ParentRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            //get current level
            String roleIdQueryString = (qobj.isAH!=null)?thisUser.UserRoleId:thisUser.UserRole.ParentRoleId;
            String queryString = (qobj.isAH!=null)?'UserRoleId':'UserRole.ParentRoleId';
            //got ah level or all tm level
            List<User> userSameLevelList = Database.query('SELECT Id,Name FROM User WHERE IsActive=true AND '+queryString+' =\''+roleIdQueryString +'\'' +((qobj.scope!=null)?(' AND RC_Code__c=\''+qobj.scope+'\''):''));
            if(qobj.selfInclude==null)
                finalResult.addAll(userSameLevelList);
            Map<Id,User> mapSameLevel = new Map<Id,User>(userSameLevelList);
            //second level tm level or rm level
            Map<Id,User> userSecondLevel = new Map<Id,User>([SELECT Id,Name FROM User WHERE IsActive=true AND ManagerId in :mapSameLevel.keySet()]);
            finalResult.addAll(userSecondLevel.values());
            if(qobj.isAH!=null){
                //ah case
                Map<Id,User> userThirdLevel = new Map<Id,User>([SELECT Id,Name FROM User WHERE IsActive=true AND ManagerId in :userSecondLevel.keySet()]);
                finalResult.addAll(userThirdLevel.values());
            }

            if(qobj.extra!=null)
                resp.records.add(new YearEndModel.Picklist('',qobj.extra));
            for(User eachUser : finalResult){
                resp.records.add(new YearEndModel.Picklist(eachUser.Id+'',eachUser.Name+''));
            }
        } catch (Exception e) {
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }
    @RemoteAction
    public static YearEndModel.PicklistResponse querySelectedByAH(YearEndModel.QueryPickListObj qobj) {
        YearEndModel.PicklistResponse resp = new YearEndModel.PicklistResponse();
        try {
            List<User> finalResult = new List<User>();
            User thisUser = [SELECT UserRoleId,UserRole.ParentRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            //get current level
            String roleIdQueryString = (qobj.isAH!=null)?thisUser.UserRoleId:thisUser.UserRole.ParentRoleId;
            String queryString = (qobj.isAH!=null)?'UserRoleId':'UserRole.ParentRoleId';
            //got ah level or all tm level
            List<User> userSameLevelList = Database.query('SELECT Id,Name FROM User WHERE IsActive=true AND '+queryString+' =\''+roleIdQueryString +'\'' +((qobj.scope!=null)?(' AND RC_Code__c=\''+qobj.scope+'\''):''));
            if(qobj.selfInclude==null)
                finalResult.addAll(userSameLevelList);
            Map<Id,User> mapSameLevel = new Map<Id,User>(userSameLevelList);
            //second level tm level or rm level
            Set<String> subScope = new Set<String>();
            if(qobj.subScope!=null)
                subScope.add(qobj.subScope);
            Set<Id> sameLevelSet = mapSameLevel.keySet();
            List<User> secondLevelList = [SELECT Id,Name FROM User WHERE IsActive=true AND ManagerId in :sameLevelSet AND RC_Code__c IN :subScope];
            Map<Id,User> userSecondLevel = new Map<Id,User>(secondLevelList);
            finalResult.addAll(userSecondLevel.values());
            if(qobj.isAH!=null){
                //ah case
                Set<Id> secondLevelSet = userSecondLevel.keySet();
                List<User> thirdLevelList = [SELECT Id,Name FROM User WHERE IsActive=true AND ManagerId in :secondLevelSet AND RC_Code__c IN :subScope];
                Map<Id,User> userThirdLevel = new Map<Id,User>(thirdLevelList);
                finalResult.addAll(userThirdLevel.values());
            }

            if(qobj.extra!=null)
                resp.records.add(new YearEndModel.Picklist('',qobj.extra));
            for(User eachUser : finalResult){
                resp.records.add(new YearEndModel.Picklist(eachUser.Id+'',eachUser.Name+''));
            }
        } catch (Exception e) {
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }
    @RemoteAction
    public static YearEndModel.PicklistResponse querySelectedByOnlyRM(YearEndModel.QueryPickListObj qobj) {
        YearEndModel.PicklistResponse resp = new YearEndModel.PicklistResponse();
        try {
            String additionString = '';
            if(qobj.selfInclude!=null) additionString += '(';
            additionString += 'ManagerId =\''+((qobj.extra!=null)?qobj.extra:UserInfo.getUserId())+'\'';
            if(qobj.selfInclude!=null) additionString += ' OR Id = \''+UserInfo.getUserId()+'\')';

            List<User> userList = Database.query('SELECT Id,Name FROM User WHERE IsActive=true AND '+ additionString +((qobj.isAH==null && qobj.scope!=null)?(' AND RC_Code__c=\''+qobj.scope+'\''):''));
            Map<Id,User> thisUserAndSameLevel = new Map<Id,User>(userList);

            if(qobj.selfInclude!=null)
                resp.records.add(new YearEndModel.Picklist('','All'));
            else resp.records.add(new YearEndModel.Picklist('','None'));
            for(User eachUser : userList){
                resp.records.add(new YearEndModel.Picklist(eachUser.Id+'',eachUser.Name+''));
            }
        } catch (Exception e) {
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }
    @RemoteAction
    public static YearEndModel.PicklistResponse queryPicklist(YearEndModel.QueryPickListObj qobj) {
        YearEndModel.PicklistResponse resp = new YearEndModel.PicklistResponse();
        try {
            for (Schema.PicklistEntry rit : Schema.getGlobalDescribe().get('Year_End_Assignment__c').newSObject().getSObjectType().getDescribe().fields.getMap().get(qobj.scope).getDescribe().getPicklistValues()) {
                resp.records.add(new YearEndModel.Picklist(rit.getValue(),rit.getLabel()));
            }
        } catch (Exception e) {
            resp.success = false;
            resp.records = null;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }
    @RemoteAction
    public static YearEndModel.SavingResponse saveYearEnd(YearEndModel.SavingRequest svobj) {
        YearEndModel.SavingResponse resp = new YearEndModel.SavingResponse();
        try {
            List<Year_End_Assignment__c> checkYearList = new List<Year_End_Assignment__c>();
            List<Year_End_Assignment_Selection__c> checkYearSelList = new List<Year_End_Assignment_Selection__c>();
            Boolean confirmValid = true;
            String selNameId;
            if(svobj.contx=='REFER_OUT'){
                //referOut
                List<Year_End_Assignment_Selection__c> finalList = new List<Year_End_Assignment_Selection__c>();
                selNameId = (svobj.selectName!=null && svobj.selectName.selectedbyNamepanel!=null)?svobj.selectName.selectedbyNamepanel:UserInfo.getUserId();

                checkYearSelList = [SELECT Id FROM Year_End_Assignment_Selection__c WHERE Year_End_Assignment__c IN :svobj.yearlist AND Selected_By__c = :selNameId];
                checkYearList = [SELECT Id FROM Year_End_Assignment__c WHERE Final_Assigned_RM__c = null AND Id IN :svobj.yearlist];
                if(checkYearList!=null && checkYearList.size() == svobj.yearlist.size() && (checkYearSelList==null || (checkYearSelList!=null && checkYearSelList.size()==0))){

                    if(confirmValid){
                        for(String eachYearEndId : svobj.yearlist){
                            finalList.add(new Year_End_Assignment_Selection__c(
                                Year_End_Assignment__c = eachYearEndId,
                                Refer_Out_Reason__c = svobj.referOut.referoutReason,
                                Refer_Out_Segment__c = svobj.referOut.referoutSegment,
                                Refer_Out_Amphur__c = svobj.referOut.referoutAumpur,
                                Refer_Out_Province__c = svobj.referOut.referoutProvince,
                                Refer_Out_Tumbon__c = svobj.referOut.referoutTumbon,
                                Refer_Out_Team__c = svobj.referOut.referoutTeam,
                                Refer_Out__c = true,
                                Selected_By__c = (svobj.selectName!=null && svobj.selectName.selectedbyNamepanel!=null)?svobj.selectName.selectedbyNamepanel:UserInfo.getUserId()
                            ));
                        }
                        insert finalList;
                    }
                }else{
                    confirmValid = false;
                }
                //yearlist
            }else if(svobj.contx=='SELECTED'){
                List<Year_End_Assignment_Selection__c> selectedList = new List<Year_End_Assignment_Selection__c>();
                selNameId = (svobj.selectName!=null && svobj.selectName.selectedbyNamepanel!=null)?svobj.selectName.selectedbyNamepanel:UserInfo.getUserId();

                checkYearSelList = [SELECT Id FROM Year_End_Assignment_Selection__c WHERE Year_End_Assignment__c IN :svobj.yearlist AND Selected_By__c = :selNameId];
                checkYearList = [SELECT Id FROM Year_End_Assignment__c WHERE Final_Assigned_RM__c = null AND Id IN :svobj.yearlist];

                if(checkYearList!=null && checkYearList.size() == svobj.yearlist.size() && (checkYearSelList==null || (checkYearSelList!=null && checkYearSelList.size()==0))){

                    if(confirmValid){
                        for(String eachYearEndId : svobj.yearlist){
                            selectedList.add(new Year_End_Assignment_Selection__c(
                                Year_End_Assignment__c = eachYearEndId,
                                Refer_Out__c = false,
                                Selected_By__c = (svobj.selectName!=null && svobj.selectName.selectedbyNamepanel!=null)?svobj.selectName.selectedbyNamepanel:UserInfo.getUserId(),
                                                                Selected_Service_RM_Name__c = (svobj.selectName!=null && svobj.selectName.serviceRMpanel!=null && svobj.selectName.serviceRMpanel!='')?svobj.selectName.serviceRMpanel:null,
                                Selected_Port_Pool__c = (svobj.selectName!=null && svobj.selectName.portPoolpanel!=null && svobj.selectName.portPoolpanel!='')?svobj.selectName.portPoolpanel:'Port'
                            ));
                        }
                        insert selectedList;
                    }
                }else{
                    confirmValid = false;
                }
            }else if(svobj.contx=='CONFIRM'){
                List<Year_End_Assignment__c> confirmList = new List<Year_End_Assignment__c>();
                List<Year_End_Assignment_Selection__c> selConfirmList = new List<Year_End_Assignment_Selection__c>();
                selConfirmList = [SELECT Id,Selected_By__c,Year_End_Assignment__c,Refer_Out_Reason__c,Refer_Out_Segment__c,Refer_Out_Team__c,Refer_Out_Amphur__c,Refer_Out_Province__c,Refer_Out_Tumbon__c,Refer_Out__c,Selected_Count__c,Year_End_Assignment__r.Final_Assigned_RM__c,Selected_Port_Pool__c,Selected_Service_RM_Name__c FROM Year_End_Assignment_Selection__c WHERE Id in :svobj.yearlist];

                if(selConfirmList!=null && svobj.yearlist.size()==selConfirmList.size()){
                    for(Year_End_Assignment_Selection__c eachYearEndSel : selConfirmList){

                        if(eachYearEndSel.Selected_Count__c!=1 || eachYearEndSel.Year_End_Assignment__r.Final_Assigned_RM__c!=null){
                            confirmValid = false;
                            break;
                        }
                        confirmList.add(new Year_End_Assignment__c(
                            Id = eachYearEndSel.Year_End_Assignment__c,
                            Final_Assigned_RM__c = eachYearEndSel.Selected_By__c,
                            Refer_Out_Reason__c = eachYearEndSel.Refer_Out_Reason__c,
                            Refer_Out_Segment__c = eachYearEndSel.Refer_Out_Segment__c,
                            Refer_Out_Team__c = eachYearEndSel.Refer_Out_Team__c,
                            Refer_Out_Amphur__c = eachYearEndSel.Refer_Out_Amphur__c,
                            Refer_Out_Province__c = eachYearEndSel.Refer_Out_Province__c,
                            Refer_Out_Tumbon__c = eachYearEndSel.Refer_Out_Tumbon__c,
                            Final_Refer_Out__c = eachYearEndSel.Refer_Out__c,
                                                        Final_Service_RM__c = eachYearEndSel.Selected_Service_RM_Name__c,
                            Final_Port_Pool__c = eachYearEndSel.Selected_Port_Pool__c
                        ));
                    }
                    if(confirmValid)
                        update confirmList;
                }else confirmValid = false;

            }else if(svobj.contx=='SELECTEDCONFIRM'){
                List<Year_End_Assignment_Selection__c> selectedConfirmList = new List<Year_End_Assignment_Selection__c>();

                selNameId = (svobj.selectName!=null && svobj.selectName.selectedbyNamepanel!=null)?svobj.selectName.selectedbyNamepanel:UserInfo.getUserId();

                checkYearSelList = [SELECT Id FROM Year_End_Assignment_Selection__c WHERE Year_End_Assignment__c IN :svobj.yearlist];
                checkYearList = [SELECT Id FROM Year_End_Assignment__c WHERE Final_Assigned_RM__c = null AND Id IN :svobj.yearlist];
                if(checkYearList!=null && checkYearList.size() == svobj.yearlist.size() && (checkYearSelList==null || (checkYearSelList!=null && checkYearSelList.size()==0))){
                    if(confirmValid){
                        for(String eachYearEndId : svobj.yearlist){
                            selectedConfirmList.add(new Year_End_Assignment_Selection__c(
                                Year_End_Assignment__c = eachYearEndId,
                                Refer_Out__c = false,
                                Selected_By__c = (svobj.selectName!=null && svobj.selectName.selectedbyNamepanel!=null)?svobj.selectName.selectedbyNamepanel:UserInfo.getUserId(),
                                                                Selected_Service_RM_Name__c = (svobj.selectName!=null && svobj.selectName.serviceRMpanel!=null && svobj.selectName.serviceRMpanel!='')?svobj.selectName.serviceRMpanel:null,
                                Selected_Port_Pool__c = (svobj.selectName!=null && svobj.selectName.portPoolpanel!=null && svobj.selectName.portPoolpanel!='')?svobj.selectName.portPoolpanel:'Port'
                            ));
                        }
                        insert selectedConfirmList;
                        List<Year_End_Assignment__c> confirmConfirmList = new List<Year_End_Assignment__c>();
                        for(Year_End_Assignment_Selection__c eachYearEndSel : selectedConfirmList){
                            confirmConfirmList.add(new Year_End_Assignment__c(
                                Id = eachYearEndSel.Year_End_Assignment__c,
                                Final_Assigned_RM__c = eachYearEndSel.Selected_By__c,
                                Final_Service_RM__c = (svobj.selectName!=null && svobj.selectName.serviceRMpanel!=null && svobj.selectName.serviceRMpanel!='')?svobj.selectName.serviceRMpanel:null,
                                Final_Port_Pool__c = (svobj.selectName!=null && svobj.selectName.portPoolpanel!=null && svobj.selectName.portPoolpanel!='')?svobj.selectName.portPoolpanel:'Port'
                            ));
                        }
                        update confirmConfirmList;
                    }
                }else{
                    confirmValid = false;
                }
            }else if(svobj.contx=='REFER_OUTCONFIRM'){
                //referOut
                List<Year_End_Assignment_Selection__c> referoutConfirmSelList = new List<Year_End_Assignment_Selection__c>();
                selNameId = (svobj.selectName!=null && svobj.selectName.selectedbyNamepanel!=null && svobj.selectName.selectedbyNamepanel!='')?svobj.selectName.selectedbyNamepanel:UserInfo.getUserId();

                checkYearSelList = [SELECT Id FROM Year_End_Assignment_Selection__c WHERE Year_End_Assignment__c IN :svobj.yearlist];
                checkYearList = [SELECT Id FROM Year_End_Assignment__c WHERE Final_Assigned_RM__c = null AND Id IN :svobj.yearlist];

                if(checkYearList!=null && checkYearList.size() == svobj.yearlist.size() && (checkYearSelList==null || (checkYearSelList!=null && checkYearSelList.size()==0))){

                    for(Year_End_Assignment__c eachYearEndSel : checkYearList){
                        if(eachYearEndSel.Year_End_Assignment_Selections__r!=null && eachYearEndSel.Year_End_Assignment_Selections__r.size()!=0){
                            confirmValid = false;
                            break;
                        }
                    }
                    if(confirmValid){
                        for(String eachYearEndId : svobj.yearlist){
                            referoutConfirmSelList.add(new Year_End_Assignment_Selection__c(
                                Year_End_Assignment__c = eachYearEndId,
                                Refer_Out_Reason__c = svobj.referOut.referoutReason,
                                Refer_Out_Segment__c = svobj.referOut.referoutSegment,
                                Refer_Out_Amphur__c = svobj.referOut.referoutAumpur,
                                Refer_Out_Province__c = svobj.referOut.referoutProvince,
                                Refer_Out_Tumbon__c = svobj.referOut.referoutTumbon,
                                Refer_Out_Team__c = svobj.referOut.referoutTeam,
                                Refer_Out__c = true,
                                Selected_By__c = (svobj.selectName!=null && svobj.selectName.selectedbyNamepanel!=null && svobj.selectName.selectedbyNamepanel!='')?svobj.selectName.selectedbyNamepanel:UserInfo.getUserId()
                            ));
                        }
                        insert referoutConfirmSelList;
                        //yearlist
                        List<Year_End_Assignment__c> referoutConfirmList = new List<Year_End_Assignment__c>();
                        for(Year_End_Assignment_Selection__c eachYearEndSel : referoutConfirmSelList){
                            referoutConfirmList.add(new Year_End_Assignment__c(
                                Id = eachYearEndSel.Year_End_Assignment__c,
                                Final_Assigned_RM__c = eachYearEndSel.Selected_By__c,
                                Refer_Out_Reason__c = eachYearEndSel.Refer_Out_Reason__c,
                                Refer_Out_Segment__c = eachYearEndSel.Refer_Out_Segment__c,
                                Refer_Out_Team__c = eachYearEndSel.Refer_Out_Team__c,
                                Refer_Out_Amphur__c = eachYearEndSel.Refer_Out_Amphur__c,
                                Refer_Out_Province__c = eachYearEndSel.Refer_Out_Province__c,
                                Refer_Out_Tumbon__c = eachYearEndSel.Refer_Out_Tumbon__c,
                                Final_Refer_Out__c = eachYearEndSel.Refer_Out__c
                            ));
                        }
                        update referoutConfirmList;
                    }
                }else{
                    confirmValid = false;
                }
            }else if(svobj.contx=='SUBMITTED'){
                List<Year_End_Assignment__c> yearEndSelectionToSubmitted = new List<Year_End_Assignment__c>();
                Integer countPossible = [SELECT count() FROM Year_End_Assignment__c WHERE Selected_Count__c!=1 OR Final_Assigned_RM__c=null];
                if(countPossible==0){
                    yearEndSelectionToSubmitted = [SELECT Id,Status__c FROM Year_End_Assignment__c];
                    for(Year_End_Assignment__c eachSelection : yearEndSelectionToSubmitted){
                        eachSelection.Status__c = GlobalConstants.SUBMITTED;
                    }
                    if(yearEndSelectionToSubmitted!=null && yearEndSelectionToSubmitted.size() > 0) update yearEndSelectionToSubmitted;
                }else{
                    resp.success = false;
                    resp.errorMessage = Label.YearEnd_TheListisnotcompleted_cannotsubmit;
                    return resp;
                }
            }
            if(!confirmValid){
                resp.success = false;
                resp.duplicate = true;
                resp.errorMessage = Label.Cannotprocessyourrequest;
            }
        } catch (Exception e) {
            resp.success = false;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }
    @RemoteAction
    public static YearEndModel.SavingResponse deleteYearEndSel(YearEndModel.SavingRequest svobj) {
        YearEndModel.SavingResponse resp = new YearEndModel.SavingResponse();
        try {
            List<Year_End_Assignment_Selection__c> yearSelList = [SELECT Id,Year_End_Assignment__c,Year_End_Assignment__r.Final_Assigned_RM__c FROM Year_End_Assignment_Selection__c WHERE Id in :svobj.yearlist];

            if(svobj.deleteFinalAssign!=null && svobj.deleteFinalAssign){
                List<Year_End_Assignment__c> updateList = new List<Year_End_Assignment__c>();
                for(Year_End_Assignment_Selection__c eachYearSel : yearSelList){
                    updateList.add(new Year_End_Assignment__c(
                        Id = eachYearSel.Year_End_Assignment__c,
                        Final_Refer_Out__c = false,
                        Status__c = GlobalConstants.STATUS_NEW,
                        Final_Assigned_RM__c = null,
                        Refer_Out_Reason__c = null,
                        Refer_Out_Segment__c = null,
                        Refer_Out_Team__c = null,
                        Refer_Out_Amphur__c = null,
                        Refer_Out_Province__c = null,
                        Refer_Out_Tumbon__c = null,
                        Final_Service_RM__c = null,
                        Final_Port_Pool__c = null
                    ));
                }
                update updateList;
            }else {
                Boolean deleteValid = true;
                if(yearSelList.size() != svobj.yearlist.size()){
                    deleteValid = false;
                    resp.success = false;
                    resp.duplicate = false;
                    resp.errorMessage = Label.Cannotprocessyourrequest;
                }else{
                    for(Year_End_Assignment_Selection__c eachSel : yearSelList){
                        if(eachSel.Year_End_Assignment__r.Final_Assigned_RM__c!=null){
                            deleteValid = false;
                            resp.success = false;
                            resp.duplicate = false;
                            resp.errorMessage = Label.Cannotprocessyourrequest;
                            break;
                        }
                    }
                }

                if(deleteValid){
                    delete yearSelList;
                }
            }

        } catch (Exception e) {
            resp.success = false;
            resp.errorMessage = e.getMessage();
            return resp;
        }
        return resp;
    }
    public String getSelectedResource(){
        User currentUser = [SELECT Id,Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        String subfix = '';
        if(Account_Util.isProfile(GlobalConstants.SME_RM,currentUser)){
            subfix = '_rmnew';
        }else if(Account_Util.isProfile(GlobalConstants.SME_TM,currentUser)){
            subfix = '_tmnewer';
        }else if(Account_Util.isProfile(GlobalConstants.SME_AH,currentUser)){
            subfix = '_ahnew';
        }
        return staticPrefix + subfix;
    }
    public String getSelectedCountFields(){
        return 'Id,RM_Name__c,Team__c,Final_Team__c,TM_Name__c,Selected_By_Name__c,Selected_By_Team__c';
    }
    public String getCustomerOwnerRequestFields(){
        return 'Id,Name,CIS_ID_Text__c,CIS_ID__r.CIS__c,Customer_Name__c,Segment_Original__c,High_Value_Flag__c,Port_Pool_YearEnd__c,Credit_Status__c,Owner.Name,Team__c,TM_Name__c,AH_Name__c,NH_Name__c,RM_Name__c,Approval_Status__c,Assigned_Port_Pool__c,Port_Pool__c, Service_RM_User__r.Name, Year_End_Assignment__r.Selected_Count__c';
    }
    public String getYearEndFields(){
        return 'Id,CIS_ID__c,CIS_ID_Unique__c,Court_Case_Current_Year__c,Final_Service_RM__c,Final_Service_RM__r.Name,Final_Service_RM_Text__c,SME_Limit_LI__c,SME_Limit_TF__c,Customer_Name__c,Segment_Original__c,Final_Team__c,toLabel(Refer_Out_Reason__c),Refer_Out_Detail__c,RM_Name__c,Segment_Proposed__c,Final_Port_Pool__c,High_Value_Flag__c,Port_Pool__c,Credit_Status__c,Team__c,TM_Name__c,Final_Assigned_RM__c,Final_Refer_Out__c,Final_Assigned_SelectedBy_Text__c,Selected_Count__c,AH_Name__c,NH_Name__c,Business_Code__c,Business_Desc__c,Status__c,Credit_Flag__c,Income_1M__c,Total_Income__c,Total_SME_Limit__c,Total_SME_Out__c,Total_SME_Exposure__c,SOW_SME_Exposure__c,SME_Wallet_Size__c,DPD6M__c,NPL12M__c,Court_Case_12M__c,SME_BSCORE_1M__c,SME_BSCORE_2M__c,SME_BSCORE_3M__c,Relationship_Affiliate__c,Relationship_Authorized_Director__c,Relationship_Joint_Obligor__c,Relationship_Spouse__c,Relationship_Stockholder__c,Group__c,UW_Color_Group__c,Visited_Count__c,RM_Last_Visited__c,Additional_or_Refer_out__c,Refer_Out_By_Team__c,Refer_Out_Reason_fr_other__c,Refer_To_Team__c,Refer_Sub_District__c,Refer_District__c,Refer_Province__c,(SELECT Id FROM Year_End_Assignment_Selections__r WHERE Selected_By__c="'+UserInfo.getUserId()+'")';
    }
    public String getYearEndSelFields(){
        return 'Id,CIS_ID__c,RM_Name__c,Final_Team__c,Customer_Name__c,Final_Service_RM__c,Court_Case_Current_Year__c,Year_End_Assignment__r.Status__c,Segment_Original__c,Segment_Proposed__c,Final_Port_Pool__c,High_Value_Flag__c,Credit_Status__c,Team__c,TM_Name__c,TM_EmpID__c,Selected_By_Name__c,Selected_By_Team__c,Port_Pool__c,Refer_Out__c,toLabel(Refer_Out_Reason__c),Refer_Out_Team__c,Refer_Out_Detail__c,SME_Limit_LI__c,SME_Limit_TF__c,Service_RM_Name__c,Final_Assigned_RM__c,Final_Refer_Out__c,Selected_Count__c,AH_Name__c,NH_Name__c,Business_Code__c,Business_Desc__c,Credit_Flag__c,Income_1M__c,Total_Income__c,Total_SME_Limit__c,Total_SME_Out__c,Total_SME_Exposure__c,SOW_SME_Exposure__c,SME_Wallet_Size__c,DPD6M__c,NPL12M__c,Court_Case_12M__c,SME_BSCORE_1M__c,SME_BSCORE_2M__c,SME_BSCORE_3M__c,Selected_By__c,Selected_By__r.RC_Code__c,Year_End_Assignment__c,Final_Refer_Out_Reason__c,Final_Refer_Out_Reason_Detail__c,Selected_Port_Pool__c,Selected_Service_RM_Name__c,Selected_Service_RM_Name_Text__c,Relationship_Affiliate__c,Relationship_Authorized_Director__c,Relationship_Joint_Obligor__c,Relationship_Spouse__c,Relationship_Stockholder__c,Group__c,UW_Color_Group__c,Visited_Count__c,RM_Last_Visited__c,Additional_or_Refer_out__c,Refer_Out_By_Team__c,Refer_Out_Reason_fr_other__c,Refer_To_Team__c,Refer_Sub_District__c,Refer_District__c,Refer_Province__c';
    }
    public String getCustomerOwnerRequestFieldsForDes(){
        return 'Id,Name,CIS_ID_Text__c,Customer_Name__c,Segment_Original__c,High_Value_Flag__c,Port_Pool_YearEnd__c,Credit_Status__c,Team__c,TM_Name__c,AH_Name__c,NH_Name__c,RM_Name__c,Approval_Status__c,Assigned_Port_Pool__c,Port_Pool__c';
    }
    public String getYearEndFieldsForDes(){
        return 'Id,CIS_ID__c,CIS_ID_Unique__c,Court_Case_Current_Year__c,Final_Service_RM__c,Final_Service_RM_Text__c,SME_Limit_LI__c,SME_Limit_TF__c,Customer_Name__c,Segment_Original__c,Final_Team__c,Refer_Out_Reason__c,Refer_Out_Detail__c,RM_Name__c,Segment_Proposed__c,Final_Port_Pool__c,High_Value_Flag__c,Port_Pool__c,Credit_Status__c,Team__c,TM_Name__c,Final_Assigned_RM__c,Final_Refer_Out__c,Final_Assigned_SelectedBy_Text__c,Selected_Count__c,AH_Name__c,NH_Name__c,Business_Code__c,Business_Desc__c,Status__c,Credit_Flag__c,Income_1M__c,Total_Income__c,Total_SME_Limit__c,Total_SME_Out__c,Total_SME_Exposure__c,SOW_SME_Exposure__c,SME_Wallet_Size__c,DPD6M__c,NPL12M__c,Court_Case_12M__c,SME_BSCORE_1M__c,SME_BSCORE_2M__c,SME_BSCORE_3M__c,Relationship_Affiliate__c,Relationship_Authorized_Director__c,Relationship_Joint_Obligor__c,Relationship_Spouse__c,Relationship_Stockholder__c,Group__c,UW_Color_Group__c,Visited_Count__c,RM_Last_Visited__c,Additional_or_Refer_out__c,Refer_Out_By_Team__c,Refer_Out_Reason_fr_other__c,Refer_To_Team__c,Refer_Sub_District__c,Refer_District__c,Refer_Province__c';
    }
    public String getYearEndSelFieldsForDes(){
        return 'Id,CIS_ID__c,Customer_Name__c,Final_Service_RM__c,Court_Case_Current_Year__c,Segment_Original__c,Segment_Proposed__c,Final_Port_Pool__c,High_Value_Flag__c,Credit_Status__c,RM_Name__c,Team__c,TM_Name__c,TM_EmpID__c,Selected_By_Name__c,Selected_By_Team__c,Port_Pool__c,Final_Team__c,Refer_Out__c,Refer_Out_Reason__c,Refer_Out_Team__c,Refer_Out_Detail__c,SME_Limit_LI__c,SME_Limit_TF__c,Service_RM_Name__c,Final_Assigned_RM__c,Final_Refer_Out__c,Selected_Count__c,AH_Name__c,NH_Name__c,Business_Code__c,Business_Desc__c,Credit_Flag__c,Income_1M__c,Total_Income__c,Total_SME_Limit__c,Total_SME_Out__c,Total_SME_Exposure__c,SOW_SME_Exposure__c,SME_Wallet_Size__c,DPD6M__c,NPL12M__c,Court_Case_12M__c,SME_BSCORE_1M__c,SME_BSCORE_2M__c,SME_BSCORE_3M__c,Selected_By__c,Year_End_Assignment__c,Final_Refer_Out_Reason__c,Final_Refer_Out_Reason_Detail__c,Selected_Port_Pool__c,Selected_Service_RM_Name__c,Selected_Service_RM_Name_Text__c,Relationship_Affiliate__c,Relationship_Authorized_Director__c,Relationship_Joint_Obligor__c,Relationship_Spouse__c,Relationship_Stockholder__c,Group__c,UW_Color_Group__c,Visited_Count__c,RM_Last_Visited__c,Additional_or_Refer_out__c,Refer_Out_By_Team__c,Refer_Out_Reason_fr_other__c,Refer_To_Team__c,Refer_Sub_District__c,Refer_District__c,Refer_Province__c';
    }
}