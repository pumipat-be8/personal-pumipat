function requestApex(method,mdata) {
    var deferred = new Ext.Deferred();
    var response = sforce.apex.execute("YearEndAssignment_Webservice", method, mdata);

    if (response && response[0].success) {
        deferred.resolve(response[0]);
    } else deferred.reject(response[0].errorMessage);

    return deferred.promise;
};
function savingBulk(requestObj) {
    var deferred = new Ext.Deferred();
    SME_BulkAssignment_ListView_Controller.saveBulk(requestObj, function(results, e) {
        console.log(results, e);
        if (!e.status) {
            deferred.reject(e.message);
        } else {
            deferred.resolve(results);
        }
    });
    return deferred.promise;
};
function sendRequest(operate, requestObj) {
    var deferred = new Ext.Deferred();
    SME_BulkAssignment_ListView_Controller[operate](requestObj, function(results, e) {
        console.log(results, e);
        if (!e.status) {
            deferred.reject(e.message);
        } else {
            deferred.resolve(results);
        }
    });
    return deferred.promise;
};
var fields_base = {
    "CIS__c":{
        "dataIndex": "CIS__c",
        "sortable": true,
        "header": "CIS",
        "align": "right",
        "width": 70,
        "locked": true,
        "customSort": "CIS_Number__c",
        "filter": {
            "type": "numstring",
            "updateBuffer": 1000,
            "itemDefaults": {
                "emptyText": "Search CIS Number..."
            }
        }
    },
    "CIS_Number__c":{
        "dataIndex": "CIS__c",
        "sortable": true,
        "header": "CIS",
        "align": "right",
        "width": 70,
        "locked": true,
        "customSort": "CIS_Number__c",
        "filter": {
            "type": "numstring",
            "operator": "=",
            "updateBuffer": 1000,
            "itemDefaults": {
                "emptyText": "Search CIS Number..."
            }
        }
    },
    "Name_Report__c":{
        "dataIndex": "Name_Report__c",
        "sortable": false,
        "header": "Name",
        "renderer": Ext.util.Format.htmlDecode,
        "locked": true,
        "width": 150
    },
    "Primary_Segment_Code__c":{
        "dataIndex": "Primary_Segment_Code__c",
        "header": "Segment",
        "sortable": false,
        "locked": true,
        "width": 70
    },
    "Current_Owner_Extension__c":{
        "dataIndex": "Current_Owner_Extension__r.Name",
        "width": 150/*,
        "renderer": function(userExtensionArray){
            //console.log(userExtensionArray);
            if(Ext.isDefined(userExtensionArray)){
                return userExtensionArray.Name;
            }
        }*/
    },
    "Current_Team_Name__c":{
        "dataIndex": "Current_Team_Name__r.Name",
        "width": 150/*,
        "renderer": function(teamStructureArray){
            //console.log(teamStructureArray);
            if(Ext.isDefined(teamStructureArray)){
                return teamStructureArray.Name;
            }
        }*/
    },
    "Permanent_Owner_Extension__c":{
        "dataIndex": "Permanent_Owner_Extension__r.Name",
        "width": 150/*,
        "renderer": function(userExtensionArray){
            //console.log(userExtensionArray);
            if(Ext.isDefined(userExtensionArray)){
                return userExtensionArray.Name;
            }
        }*/
    },
    "Permanent_Team_Name__c":{
        "dataIndex": "Permanent_Team_Name__r.Name",
        "width": 200/*,
        "renderer": function(teamStructureArray){
            //console.log(teamStructureArray);
            if(Ext.isDefined(teamStructureArray)){
                return teamStructureArray.Name;
            }
        }*/
    },
    "Previous_Owner__c":{
        "dataIndex": "Previous_Owner__r.Name",
        "width": 150/*,
        "renderer": function(userArray){
            //console.log(userArray);
            if(Ext.isDefined(userArray)){
                return userArray.Name;
            }
        }*/
    },
    "Previous_Team_Name__c":{
        "dataIndex": "Previous_Team_Name__r.Name",
        "width": 200/*,
        "renderer": function(teamStructureArray){
            //console.log(teamStructureArray);
            if(Ext.isDefined(teamStructureArray)){
                return teamStructureArray.Name;
            }
        }*/
    },
    "Service_RM__c":{
        "dataIndex": "Service_RM__r.Name",
        "width": 150/*,
        "renderer": function(userArray){
            //console.log(userArray);
            if(Ext.isDefined(userArray)){
                return userArray.Name;
            }
        }*/
    },
    "Last_Visited_Date__c":{
        "dataIndex": "Last_Visited_Date__c",
        "width": 150,
        "renderer": function(dateArray){
            if ((dateArray == null) || (dateArray == ''))
                return null;
            date_as_sent = new Date(parseInt(dateArray));
            //console.log(date_as_sent);
            return new Date(date_as_sent.getUTCFullYear(),
                            date_as_sent.getUTCMonth(),
                            date_as_sent.getUTCDate()).toDateString();
        }
    },
    "Last_Setup_Date__c":{
        "dataIndex": "Last_Setup_Date__c",
        "width": 150,
        "renderer": function(dateArray){
            if ((dateArray == null) || (dateArray == ''))
                return null;
            date_as_sent = new Date(parseInt(dateArray));
            //console.log(date_as_sent);
            return new Date(date_as_sent.getUTCFullYear(),
                            date_as_sent.getUTCMonth(),
                            date_as_sent.getUTCDate()).toDateString();
        }
    },
    "District__c":{
        "dataIndex": "Addresses__r",
        "sortable": false,
        "width": 100,
        "text": 'District',
        "renderer": function(addressesArray){
            if(Ext.isDefined(addressesArray) && addressesArray.length > 0){
            	return addressesArray[0].District__c;
            }
        }
    },
    "Province__c":{
        "dataIndex": "Addresses__r",
        "sortable": false,
        "width": 100,
        "text": 'Province',
        "renderer": function(addressesArray){
            if(Ext.isDefined(addressesArray) && addressesArray.length > 0){
            	return addressesArray[0].Province__c;
            }
        }
    },
    "Total_SME_Limit__c":{
        "dataIndex": "Total_SME_Limit__c",
        "xtype": "numbercolumn",
        "format": "0,000.00",
        "align": "right",
        "sortable":false,
        "width": 150
    },
    "Total_SME_Out__c":{
        "dataIndex": "Total_SME_Out__c",
        "xtype": "numbercolumn",
        "format": "0,000.00",
        "align": "right",
        "sortable":false,
        "width": 150
    },
    "Total_SME_Exposure__c":{
        "dataIndex": "Total_SME_Exposure__c",
        "xtype": "numbercolumn",
        "format": "0,000.00",
        "align": "right",
        "sortable":false,
        "width": 150
    },
    "Income_To_Bank_Last_1_Month__c":{
        "dataIndex": "Income_To_Bank_Last_1_Month__c",
        "xtype": "numbercolumn",
        "format": "0,000.00",
        "align": "right",
        "sortable":false,
        "width": 150
    },
    "Income_to_Bank_This_Year__c":{
        "dataIndex": "Income_to_Bank_This_Year__c",
        "xtype": "numbercolumn",
        "format": "0,000.00",
        "align": "right",
        "sortable":false,
        "width": 150
    },
    "Income_to_Bank_Last_Year__c":{
        "dataIndex": "Income_to_Bank_Last_Year__c",
        "xtype": "numbercolumn",
        "format": "0,000.00",
        "align": "right",
        "sortable":false,
        "width": 150
    },
    "Wallet_Size_Exposure__c":{
        "dataIndex": "Wallet_Size_Exposure__c",
        "xtype": "numbercolumn",
        "format": "0,000.00",
        "align": "right",
        "sortable":false,
        "width": 150
    },
    "Bscore_1M":{
        "dataIndex": "Behaviour_Scores__r",
        "sortable": false,
        "width": 100,
        "text": 'SME Bscore 1M',
        "renderer": function(bscoreArray){
            //console.log(bscoreArray);
            if(Ext.isDefined(bscoreArray) && bscoreArray.length > 0){
                for (var i = 0; i < bscoreArray.length; i++) {
                    if(bscoreArray[i].Name == '01'){
                        return bscoreArray[i].SME_Score__c;
                    }
                }
            }
        }
    },
    "Bscore_2M":{
        "dataIndex": "Behaviour_Scores__r",
        "sortable": false,
        "width": 100,
        "text": 'SME Bscore 2M',
        "renderer": function(bscoreArray){
            //console.log(bscoreArray);
            if(Ext.isDefined(bscoreArray) && bscoreArray.length > 0){
                for (var i = 0; i < bscoreArray.length; i++) {
                    if(bscoreArray[i].Name == '02'){
                        return bscoreArray[i].SME_Score__c;
                    }
                }
            }
        }
    },
    "Bscore_3M":{
        "dataIndex": "Behaviour_Scores__r",
        "sortable": false,
        "width": 100,
        "text": 'SME Bscore 3M',
        "renderer": function(bscoreArray){
            //console.log(bscoreArray);
            if(Ext.isDefined(bscoreArray) && bscoreArray.length > 0){
                for (var i = 0; i < bscoreArray.length; i++) {
                    if(bscoreArray[i].Name == '03'){
                        return bscoreArray[i].SME_Score__c;
                    }
                }
            }
        }
    }
};