function init(config) {
    var yearColumn = [{
        "dataIndex": "CIS_ID_Unique__c",
        "text": "CIS ID",
        "sortable": true,
        "align": "right",
        "width": 70
    }, {
        "dataIndex": "Customer_Name__c",
        "text": "Customer Name",
        "sortable": false,
        "renderer": Ext.util.Format.htmlDecode
    }, {
        "dataIndex": "Segment_Original__c",
        "text": "Segment (Original)",
        "sortable": true
    }, {
        "dataIndex": "Segment_Proposed__c",
        "text": "Segment (Proposed)",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "High_Value_Flag__c",
        "text": "High Value Flag",
        "sortable": true
    }, {
        "dataIndex": "Port_Pool__c",
        "text": "Port / Pool",
        "sortable": true
    }, {
        "dataIndex": "Credit_Status__c",
        "text": "Credit Status",
        "sortable": true
    }, {
        "dataIndex": "RM_Name__c",
        "text": "RM Name",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "Team__c",
        "text": "Team",
        "sortable": true
    }, {
        "dataIndex": "TM_Name__c",
        "text": "TM Name",
        "sortable": true
    }, {
        "dataIndex": "Final_Assigned_SelectedBy_Text__c",
        "text": "Final Assigned/SelectedBy",
        "align": "right",
        "sortable": true
    },
    {  
        "dataIndex":"Final_Service_RM_Text__c",
        "text":"Final Servicing RM",
        "sortable":true
    },
    {  
        "dataIndex":"Final_Port_Pool__c",
        "text":"Final Port/Pool",
        "sortable":true
    },
    {
        "dataIndex": "Final_Team__c",
        "text": "Final Team",
        "sortable": true,
        "width": 150
    },{
        "dataIndex": "Final_Refer_Out__c",
        "text": "Final Refer Out",
        "sortable": true,
        "xtype": "checkcolumn",
        "disabled": true,
        "disabledCls" : "x-item-enabled"
    }, {
        "dataIndex": "Refer_Out_Reason__c",
        "text": "Refer Out Reason",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "Refer_Out_Detail__c",
        "text": "Refer Out Detail",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "Selected_Count__c",
        "text": "Selected Count",
        "align": "right",
        "format": "0,000",
        "sortable": true,
        "xtype": "numbercolumn",
        "listeners":{
            "click": function(gridtable,gridtable_html,index,col,record){
                var record_data = record.record.data;
                if(record_data.Selected_Count__c > 1){
                    selectedCountStore.filter("Year_End_Assignment__c", record_data.Year_End_Assignment__c);
                    selectedcount_popup.show();
                }
            }
        }
    }, {
        "dataIndex": "AH_Name__c",
        "text": "AH Name",
        "sortable": true
    }, {
        "dataIndex": "NH_Name__c",
        "text": "NH Name",
        "sortable": true
    }, {
        "dataIndex": "Business_Code__c",
        "text": "Business Code",
        "sortable": true
    }, {
        "dataIndex": "Business_Desc__c",
        "text": "Business Desc",
        "sortable": true
    }, {
        "dataIndex": "Credit_Flag__c",
        "text": "Credit Flag",
        "sortable": true
    }, {
        "dataIndex": "Income_1M__c",
        "xtype": "numbercolumn",
        "format": "0,000",
        "align": "right",
        "text": "Income Last1Month",
        "sortable": true
    }, {
        "dataIndex": "Total_SME_Limit__c",
        "xtype": "numbercolumn",
        "format": "0,000",
        "align": "right",
        "text": "Total SME Limit",
        "sortable": true
    }, {  
        "dataIndex":"SME_Limit_LI__c",
        "xtype": "numbercolumn",
        "format":"0,000",
        "align": "right",
        "text":"SME Limit - LI",
        "sortable":true
    }, {  
        "dataIndex":"SME_Limit_TF__c",
        "xtype": "numbercolumn",
        "format":"0,000",
        "align": "right",
        "text":"SME Limit - TF",
        "sortable":true
    }, {
        "dataIndex": "Total_SME_Out__c",
        "xtype": "numbercolumn",
        "format": "0,000",
        "align": "right",
        "text": "Total SME Out",
        "sortable": true
    }, {
        "dataIndex": "Total_SME_Exposure__c",
        "xtype": "numbercolumn",
        "format": "0,000",
        "align": "right",
        "text": "Total SME Exposure",
        "sortable": true
    }, {
        "dataIndex": "SOW_SME_Exposure__c",
        "text": "%SOW (SME Exposure)",
        "sortable": true,
        "renderer": function(value) {
            return (value) ? (value + "%") : "";
        }
    }, {
        "dataIndex": "SME_Wallet_Size__c",
        "xtype": "numbercolumn",
        "format": "0,000",
        "align": "right",
        "text": "SME Wallet Size",
        "sortable": true
    }, {
        "dataIndex": "DPD6M__c",
        "text": "DPD6M",
        "sortable": true
    }, {
        "dataIndex": "NPL12M__c",
        "text": "NPL12M",
        "sortable": true
    }, {
        "dataIndex": "Court_Case_12M__c",
        "text": "Court Case 12M",
        "sortable": true
    },{
        "dataIndex": "Court_Case_Current_Year__c",
        "text": "Court Case Current Year",
        "sortable": true
    }, {
        "dataIndex": "SME_BSCORE_1M__c",
        "text": "SME BSCORE Last1Month",
        "sortable": true
    }, {
        "dataIndex": "SME_BSCORE_2M__c",
        "text": "SME BSCORE Last2Month",
        "sortable": true
    }, {
        "dataIndex": "SME_BSCORE_3M__c",
        "text": "SME BSCORE Last3Month",
        "sortable": true
    }];
    var selectedCountColumn = [
        {
            "dataIndex": "RM_Name__c",
            "text": "RM Name",
            "flex": 1
        }, {
            "dataIndex": "Team__c",
            "text": "Team",
            "flex": 1
        }, {
            "dataIndex": "TM_Name__c",
            "text": "TM Name",
            "flex": 1
        }, {
            "dataIndex": "Selected_By_Name__c",
            "text": "Selected By Name",
            "flex": 1
        }, {
            "dataIndex": "Selected_By_Team__c",
            "text": "Selected By Team",
            "flex": 1
        }
    ];
    var yearSelColumn = [{
        "dataIndex": "CIS_ID__c",
        "text": "CIS ID",
        "sortable": true,
        "align": "right",
        "width": 70
    }, {
        "dataIndex": "Customer_Name__c",
        "text": "Customer Name",
        "sortable": false,
        "renderer": Ext.util.Format.htmlDecode
    }, {
        "dataIndex": "Segment_Original__c",
        "text": "Segment (Original)",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "Segment_Proposed__c",
        "text": "Segment (Proposed)",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "High_Value_Flag__c",
        "text": "High Value Flag",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "Credit_Status__c",
        "text": "Credit Status",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "RM_Name__c",
        "text": "RM Name",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "Team__c",
        "text": "Team",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "TM_Name__c",
        "text": "TM Name",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "Selected_By_Name__c",
        "text": "Selected By Name",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "Selected_By_Team__c",
        "text": "Selected By Team",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "Port_Pool__c",
        "text": "Port / Pool",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "Refer_Out__c",
        "text": "Refer Out",
        "sortable": true,
        "xtype": "checkcolumn",
        "disabled": true,
        "disabledCls" : "x-item-enabled"
    }, {
        "dataIndex": "Refer_Out_Reason__c",
        "text": "Refer Out Reason",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "Refer_Out_Detail__c",
        "text": "Refer Out Detail",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "Final_Assigned_RM__c",
        "text": "Final Assigned/SelectedBy",
        "sortable": true,
        "width": 150
    },
    {  
        "dataIndex":"Final_Service_RM__c",
        "text":"Final Servicing RM",
        "sortable":true
    },
    {  
        "dataIndex":"Final_Port_Pool__c",
        "text":"Final Port/Pool",
        "sortable":true
    },
     {
        "dataIndex": "Final_Refer_Out__c",
        "text": "Final Refer Out",
        "sortable": true,
        "xtype": "checkcolumn",
        "disabled": true,
        "disabledCls" : "x-item-enabled"
    }, {
        "dataIndex": "Selected_Count__c",
        "text": "Selected Count",
        "align": "right",
        "format": "0,000",
        "sortable": true,
        "xtype": "numbercolumn"
    }, {
        "dataIndex": "AH_Name__c",
        "text": "AH Name",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "NH_Name__c",
        "text": "NH Name",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "Business_Code__c",
        "text": "Business Code",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "Business_Desc__c",
        "text": "Business Desc",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "Credit_Flag__c",
        "text": "Credit Flag",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "Income_1M__c",
        "xtype": "numbercolumn",
        "format": "0,000",
        "align": "right",
        "text": "Income Last1Month",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "Total_SME_Limit__c",
        "xtype": "numbercolumn",
        "format": "0,000",
        "align": "right",
        "text": "Total SME Limit",
        "sortable": true,
        "width": 150
    }, {  
        "dataIndex":"SME_Limit_LI__c",
        "xtype": "numbercolumn",
        "format":"0,000",
        "align": "right",
        "text":"SME Limit - LI",
        "sortable":true
      }, {  
        "dataIndex":"SME_Limit_TF__c",
        "xtype": "numbercolumn",
        "format":"0,000",
        "align": "right",
        "text":"SME Limit - TF",
        "sortable":true
      }, {
        "dataIndex": "Total_SME_Out__c",
        "xtype": "numbercolumn",
        "format": "0,000",
        "align": "right",
        "text": "Total SME Out",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "Total_SME_Exposure__c",
        "xtype": "numbercolumn",
        "align": "right",
        "format": "0,000",
        "text": "Total SME Exposure",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "SOW_SME_Exposure__c",
        "text": "%SOW (SME Exposure)",
        "sortable": true,

        "renderer": function(value) {
            return (value) ? (value + "%") : "";
        }
    }, {
        "dataIndex": "SME_Wallet_Size__c",
        "xtype": "numbercolumn",
        "align": "right",
        "format": "0,000",
        "text": "SME Wallet Size",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "DPD6M__c",
        "text": "DPD6M",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "NPL12M__c",
        "text": "NPL12M",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "Court_Case_12M__c",
        "text": "Court Case 12M",
        "sortable": true,
        "width": 150
    },{
        "dataIndex": "Court_Case_Current_Year__c",
        "text": "Court Case Current Year",
        "sortable": true
    }, {
        "dataIndex": "SME_BSCORE_1M__c",
        "text": "SME BSCORE Last1Month",
        "sortable": true,
        "width": 150
    }, {
        "dataIndex": "SME_BSCORE_2M__c",
        "text": "SME BSCORE Last2Month",
        "sortable": true,
        "width": 150
    },{
        "dataIndex":"SME_BSCORE_3M__c",
        "text":"SME BSCORE Last3Month",
        "sortable":true,
        "width":150
      }];
    var yearEndModelName = Ext.String.capitalize("Year_End_Assignment__c");
    var yearEndSelModelName = Ext.String.capitalize("Year_End_Assignment_Selection__c");

    createModel(yearEndModelName, 'records', 'Id',
        '', YearEndAssignment_ListView_Controller.query, {
            sobjname: 'Year_End_Assignment__c',
            fields: config.fieldlist.join(',')
        }
    );

    createModel(yearEndSelModelName, 'records', 'Id',
        '', YearEndAssignment_ListView_Controller.query, {
            sobjname: 'Year_End_Assignment_Selection__c',
            fields: config.fieldsellist.join(',')
        }
    );
    createModel('selectedCount', 'records', 'Id',
        '', YearEndAssignment_ListView_Controller.query, {
            sobjname: 'Year_End_Assignment_Selection__c',
            fields: config.fieldselcountlist.join(',')
        }
    );
    var yearEndStore = createStoreModel(yearEndModelName, config.pagesize, {
         autoLoad:false,
        sorters: [{
            property: 'Team__c',
            direction: 'ASC'
        }]
    });
    var yearEndSelStore = createStoreModel(yearEndSelModelName, config.pagesize, {
         filters: [{
            property: 'Year_End_Assignment__r.Final_Assigned_RM__c',
            value: 'null'
         },{
            property: 'Selected_Count__c',
            value: '1'
         }],
        sorters:[{
            property: 'CIS_ID__c',
            direction: 'ASC'
        }]
    });
    var selectedCountStore = createStoreModel('selectedCount', 200, {
        autoLoad: false
    });
    var is_confirmlist = false;
    var request_id;
    var yearEndCheckbox = function(record){
        return record.Status__c=='New' && ((!record.Final_Assigned_RM__c || record.Final_Assigned_RM__c==null || typeof record.Final_Assigned_RM__c === "undefined") && (!record.Final_Refer_Out__c || record.Final_Refer_Out__c==null || typeof record.Final_Refer_Out__c === "undefined") && (!record.Year_End_Assignment_Selections__r || record.Year_End_Assignment_Selections__r==null || typeof record.Year_End_Assignment_Selections__r === "undefined") && record.Selected_Count__c==0);
   };
   var yearEndSelCheckbox = function(record){
      return record.Year_End_Assignment__r.Status__c=='New' && (!is_confirmlist || 
            (is_confirmlist && record.Final_Assigned_RM__c && record.Final_Assigned_RM__c!=null && typeof record.Final_Assigned_RM__c !== "undefined"
            ));
   };

    var selectByStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedBy,{extra:'All',isAH:true,selfInclude:false},true);
    var selectByPanelStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedBy,{scope:config.user_rc_code,isAH:true,selfInclude:false},true);
    var servicePanelStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.querySelectedByOnlyRM,{scope:config.user_rc_code,isAH:true},true);
    var reasonStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryPicklist,{scope:'Refer_Out_Reason__c'},true);
    var segmentStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryPicklist,{scope:'Refer_Out_Segment__c'},true);

    var provinceStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryLocation,{scope:'Province'},true);
    var aumpurStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryLocation,{scope:'District'},false);
    var tumbonStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryLocation,{scope:'Sub District'},false);

    var selectByCombobox = createComboxbox('Customer Selected by Name (RM/TM)','selectedbyname',false,selectByStore,'Select (RM/TM)','pname','pvalue',false,true,{
      labelWidth:210,
      listeners: {
         select: function(combox,selected,index) {
            var grid = this.up('grid');
            if(selected.get('pvalue') && selected.get('pvalue')!=''){
               grid.store.filter("Selected_By__c", selected.get('pvalue'));
            }else grid.store.removeFilter("Selected_By__c");
         }
      }
   });
   var selectByPanelCombobox = createComboxbox('Select RM/TM','selectedbyNamepanel',false,selectByPanelStore,'Select (RM/TM)','pname','pvalue',false,false,{
      listeners: {
         select: function(combox,selected,index) {
            var grid = this.up('grid');
            servicePanelCombobox.hide();
            servicePanelCombobox.clearValue();
            if(selected.get('pvalue') && config.lowerLevelSet.indexOf(selected.get('pvalue'))!=-1 && portPoolPanelCombobox.getValue()=='Pool'){
               servicePanelStore.proxy.extraParams.extra = selected.get('pvalue');
               servicePanelStore.load();
               servicePanelCombobox.show();
            }
            if(selected.get('pvalue') && config.lowerLevelSet.indexOf(selected.get('pvalue'))==-1){
                portPoolPanelCombobox.setValue('Port');
                portPoolPanelCombobox.setReadOnly(true);
            }else portPoolPanelCombobox.setReadOnly(false);
         }
      }
   });

   var portPoolPanelCombobox = createComboxbox('Select Port/Pool','portPoolpanel',false,
         new Ext.data.ArrayStore({
                           id: 0,
                           fields: [
                           'property',
                           'value'
                           ],
                           data: [['Port', 'Port'], ['Pool', 'Pool']]
                        }),'Port Pool','pname','pvalue',false,false,{
         value:'',
         valueField: 'value',
         displayField: 'property',
         listeners: {
            select: function(combox,selected,index) {
               var grid = this.up('grid');
               servicePanelCombobox.hide();
               servicePanelCombobox.clearValue();
               if(selected.data && selected.data.value=='Pool' && config.lowerLevelSet.indexOf(selectByPanelCombobox.getValue())!=-1){
                  servicePanelStore.proxy.extraParams.extra = selectByPanelCombobox.getValue();
                  servicePanelStore.load();
                  servicePanelCombobox.show();
               }
            }
         }
   });
    var servicePanelCombobox = createComboxbox('Select Servicing RM', 'serviceRMpanel', true, servicePanelStore, 'Servicing RM', 'pname', 'pvalue', false, true, {
        value: ''
    });

    var segmentCombobox = createComboxbox('Refer Out Segment', 'referoutSegment', true, segmentStore, 'Select a Segment', 'pname', 'pvalue', false, true);
    var reasonCombobox = createComboxbox('Refer Out Reason', 'referoutReason', false, reasonStore, 'Select a Reason', 'pname', 'pvalue', false, false);
    var provinceCombobox = createComboxbox('Refer Out Province', 'referoutProvince', true, provinceStore, 'Select a Province', 'pname', 'pvalue', false, true);
    var aumpurCombobox = createComboxbox('Refer Out Aumpur', 'referoutAumpur', true, aumpurStore, 'Select a Aumpur', 'pname', 'pvalue', false, true);
    var tumbonCombobox = createComboxbox('Refer Out Tumbon', 'referoutTumbon', true, tumbonStore, 'Select a Tumbon', 'pname', 'pvalue', false, true);

    var referOutTeamText = new Ext.form.TextField({
        fieldLabel: 'Refer Out Team',
        name: 'referoutTeam',
        hidden: true
    });
    var cisText = new Ext.form.TextField({
        fieldLabel: 'CIS ID',
        name: 'search_box'
    });

    reasonCombobox.on('select', function(cmb, record, index) {

        provinceCombobox.hide();
        aumpurCombobox.hide();
        tumbonCombobox.hide();
        referOutTeamText.hide();
        segmentCombobox.hide();

        provinceCombobox.clearValue();
        aumpurCombobox.clearValue();
        tumbonCombobox.clearValue();
        referOutTeamText.setValue('');
        segmentCombobox.clearValue();

        provinceCombobox.labelEl.update('Select a Province:');
        aumpurCombobox.labelEl.update('Select a Aumpur:');
        tumbonCombobox.labelEl.update('Select a Tumbon:');
        referOutTeamText.labelEl.update('Refer Out Team:');
        segmentCombobox.labelEl.update('Refer Out Segment:');

        provinceCombobox.allowBlank = true;
        aumpurCombobox.allowBlank = true;
        tumbonCombobox.allowBlank = true;
        referOutTeamText.allowBlank = true;
        segmentCombobox.allowBlank = true;

        if (record.get('pvalue') && record.get('pvalue') != '' && record.get('pvalue') == 'Wrong Area') {
            provinceCombobox.labelEl.update('Select a Province:<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
            aumpurCombobox.labelEl.update('Select a Aumpur:<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
            tumbonCombobox.labelEl.update('Select a Tumbon:<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');

            provinceCombobox.allowBlank = false;
            aumpurCombobox.allowBlank = false;
            tumbonCombobox.allowBlank = false;

            provinceCombobox.show();
        } else if (record.get('pvalue') && record.get('pvalue') != '' && record.get('pvalue') == 'Other Team') {
            referOutTeamText.allowBlank = false;
            referOutTeamText.labelEl.update('Refer Out Team:<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
            referOutTeamText.show();
        } else if (record.get('pvalue') && record.get('pvalue') != '' && record.get('pvalue') == 'Other Segment') {
            segmentCombobox.allowBlank = false;
            segmentCombobox.labelEl.update('Refer Out Segment:<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>');
            segmentCombobox.show();
        }

        provinceCombobox.clearInvalid();
        aumpurCombobox.clearInvalid();
        tumbonCombobox.clearInvalid();
        referOutTeamText.clearInvalid();
        segmentCombobox.clearInvalid();
    });

    provinceCombobox.on('select', function(cmb, record, index) {
        aumpurCombobox.hide();
        aumpurCombobox.clearValue();

        tumbonCombobox.hide();
        tumbonCombobox.clearValue();

        if (record.get('pvalue') && record.get('pvalue') != '') {
            aumpurCombobox.show();
            aumpurStore.proxy.extraParams.extra = record.get('pvalue');
            aumpurStore.load();
        }
    });

    aumpurCombobox.on('select', function(cmb, record, index) {
        tumbonCombobox.hide();
        tumbonCombobox.clearValue();

        if (record.get('pvalue') && record.get('pvalue') != '') {
            tumbonCombobox.show();
            tumbonStore.proxy.extraParams.extra = record.get('pvalue');
            tumbonStore.load();
        }
    });
    var selectedcount_popup = createPanel({
        id: 'selectedcountPanel',
        title: 'Selected User in this Records',
        width: 550,
        items: [{
            xtype: 'grid',
            id: 'selectedcountgrid',
            loadMask: true,
            store: selectedCountStore,
            columns: selectedCountColumn,
            enableLocking: false,
            collapsed: false,
            collapsible: false,
            //width: 1,
            height: 200,
            width: '100%'
        }]
    });
    var selectconfirm_popup = createPanel({
        id: 'selectedPanel',
        title: 'Select RM/TM',
        items: [selectByPanelCombobox, portPoolPanelCombobox, servicePanelCombobox],
        dockedItems: [{
            xtype: 'toolbar',
            dock: 'bottom',
            items: [
                '->', {
                    text: 'Save',
                    handler: function() {
                        var panel = this.up('form');
                        var form = panel.getForm();
                        if (form.isValid()) {
                            var grid = Ext.getCmp('yearEndGrid');
                            var selections = grid.getView().getSelectionModel().getSelection();
                            var final_selections = _.filter(selections, function(record) {
                                return yearEndCheckbox(record.data);
                            });
                            if (final_selections.length > 0) {
                                grid.setLoading(true);
                                selectconfirm_popup.hide();
                                Ext.Deferred
                                    .all([sendRequest('saveYearEnd', {
                                        contx: 'SELECTEDCONFIRM',
                                        selectName: form.getFieldValues(),
                                        yearlist: _.pluck(final_selections, 'id')
                                    })])
                                    .then(function(results) {
                                        
                                        if (results[0].success) {
                                            grid.getView().getSelectionModel().deselectAll();
                                            
                                            yearEndStore.sync();
                                            yearEndStore.reload();
                                            yearEndSelStore.sync();
                                            yearEndSelStore.reload();
                                            
                                        } else {
                                            if(results[0].duplicate){
                                              Ext.MessageBox.confirm(
                                                 'Please Confirm to Refresh List',
                                                 results[0].errorMessage,
                                                 function(btn, text) {
                                                    if (btn=='yes') {

                                                       grid.getView().getSelectionModel().deselectAll();

                                                       yearEndStore.sync();
                                                       yearEndStore.reload();
                                                       yearEndSelStore.sync();
                                                       yearEndSelStore.reload();
                                                    }
                                                 grid.setLoading(false);
                                              });
                                           }else Ext.Msg.alert('Server error', results[0].errorMessage);
                                        }
                                        grid.setLoading(false);
                                    }, function(errors) {
                                        Ext.Msg.alert('Server error', errors[0]);
                                    });
                            } else Ext.Msg.alert('Invalid Selection', 'No records have been selected');

                        } else {
                            var fieldNames = [];
                            var fields = panel.getInvalidFields();
                            var field;
                            for (var i = 0; i < fields.length; i++) {
                                field = fields[i];
                                fieldNames.push(field.getFieldLabel());
                            }
                            Ext.MessageBox.alert('Invalid Fields', 'The following fields are invalid: ' + fieldNames.join(', '));
                        }
                    }
                }
            ]
        }]
    });
    
    var referout_popup = createPanel({
        id: 'referoutPanel',
        title: 'Refer Out',
        items: [reasonCombobox, provinceCombobox, aumpurCombobox, tumbonCombobox, segmentCombobox, referOutTeamText],
        dockedItems: [{
            xtype: 'toolbar',
            dock: 'bottom',
            items: [
                '->', {
                    text: 'Save',
                    handler: function() {
                        var panel = this.up('form');
                        var form = panel.getForm();
                        if (form.isValid()) {
                            var grid = Ext.getCmp('yearEndGrid');
                              var selections = grid.getView().getSelectionModel().getSelection();
                              var final_selections = _.filter(selections, function(record){ 
                                 return yearEndCheckbox(record.data);
                              });
                              if(final_selections.length > 0){
                                grid.setLoading(true);
                                referout_popup.hide();
                                Ext.Deferred
                                .all([sendRequest('saveYearEnd',{
                                          contx:'REFER_OUTCONFIRM',
                                          referOut:form.getFieldValues(),
                                          yearlist:_.pluck(final_selections,'id')
                                  })])
                                .then(function (results) {
                                    
                                    if (results[0].success) {
                                        grid.getView().getSelectionModel().deselectAll();
                                        
                                        yearEndStore.sync();
                                        yearEndStore.reload();
                                        yearEndSelStore.sync();
                                        yearEndSelStore.reload();
                                        
                                    } else {
                                        if(results[0].duplicate){
                                          Ext.MessageBox.confirm(
                                             'Please Confirm to Refresh List',
                                             results[0].errorMessage,
                                             function(btn, text) {
                                                if (btn=='yes') {

                                                   grid.getView().getSelectionModel().deselectAll();

                                                   yearEndStore.sync();
                                                   yearEndStore.reload();
                                                   yearEndSelStore.sync();
                                                   yearEndSelStore.reload();
                                                }
                                             grid.setLoading(false);
                                          });
                                       }else Ext.Msg.alert('Server error', results[0].errorMessage);
                                    }
                                    grid.setLoading(false);
                                },function (errors) {
                                    Ext.Msg.alert('Server error', errors[0]);
                                });
                            }else Ext.Msg.alert('Invalid Selection','No Yearend have been selected');

                        } else {
                            var fieldNames = [];
                            var fields = panel.getInvalidFields();
                            var field;
                            for (var i = 0; i < fields.length; i++) {
                                field = fields[i];
                                fieldNames.push(field.getFieldLabel());
                            }
                            Ext.MessageBox.alert('Invalid Fields', 'The following fields are invalid: ' + fieldNames.join(', '));
                        }
                    }
                }
            ]
        }]
    });

    config.panel_items = [
        createGridObject('Selected List', 'yearEndSelGrid', yearEndSelStore, yearSelColumn, {
            dockedItems: [{
                xtype: 'tbspacer'
            }, {
                xtype: 'toolbar',
                dock: 'bottom',
                items: [{
                    id: 'confirm_final',
                    text: 'Confirm Final RM/TM & Refer Out',
                    handler: function() {
                        var grid = this.up('grid');
                        var selections = grid.getView().getSelectionModel().getSelection();
                        var before_final_selections = _.filter(selections, function(record) {
                            return yearEndSelCheckbox(record.data);
                        });
                        var final_selections = _.filter(before_final_selections, function(record) {
                            return record.data.Selected_Count__c == 1;
                        });
                        if (final_selections.length > 0) {
                            Ext.MessageBox.confirm(
                                'Please Confirm',
                                'Are You Confirm to Confirmation ?',
                                function(btn, text) {
                                    if (btn == 'yes') {
                                        grid.setLoading(true);
                                        Ext.Deferred
                                            .all([sendRequest('saveYearEnd', {
                                                contx: 'CONFIRM',
                                                yearlist: _.pluck(final_selections, 'id')
                                            })])
                                            .then(function(results) {
                                                if (results[0].success) {
                                                    grid.getView().getSelectionModel().deselectAll();
                                                    yearEndStore.sync();
                                                    yearEndStore.reload();
                                                    yearEndSelStore.sync();
                                                    yearEndSelStore.reload();
                                                    
                                                } else {
                                                    if(results[0].duplicate){
                                                      Ext.MessageBox.confirm(
                                                         'Please Confirm to Refresh List',
                                                         results[0].errorMessage,
                                                         function(btn, text) {
                                                            if (btn=='yes') {

                                                               grid.getView().getSelectionModel().deselectAll();

                                                               yearEndStore.sync();
                                                               yearEndStore.reload();
                                                               yearEndSelStore.sync();
                                                               yearEndSelStore.reload();
                                                            }
                                                         grid.setLoading(false);
                                                      });
                                                   }else Ext.Msg.alert('Server error', results[0].errorMessage);
                                                }
                                                grid.setLoading(false);
                                            }, function(errors) {
                                                Ext.Msg.alert('Server error', errors[0]);
                                            });
                                    }
                                });
                        } else Ext.Msg.alert('Invalid Selection', 'No records have been selected OR some records have Selected Count > 1');
                    }
                }, {
                    id: 'remove_selection',
                    text: 'Remove RM Selection',
                    handler: function() {
                        var grid = this.up('grid');
                        var selections = grid.getView().getSelectionModel().getSelection();
                        /*var final_selections = _.filter(selections, function(record) {
                            return yearEndSelCheckbox(record.data);
                        });*/
                        if (selections.length > 0) {

                            Ext.MessageBox.confirm(
                                'Please Confirm',
                                'Are You Confirm to Remove selected ?',
                                function(btn, text) {
                                    if (btn == 'yes') {
                                        var savingObj = sendRequest('deleteYearEndSel', {
                                            yearlist: _.pluck(selections, 'id')
                                        });
                                        grid.setLoading(true);
                                        Ext.Deferred
                                            .all([savingObj])
                                            .then(function(results) {
                                                if (results[0].success) {
                                                    grid.getView().getSelectionModel().deselectAll();

                                                    yearEndStore.sync();
                                                    yearEndStore.reload();
                                                    yearEndSelStore.sync();
                                                    yearEndSelStore.reload();
                                                    
                                                } else {
                                                    if(results[0].duplicate){
                                                      Ext.MessageBox.confirm(
                                                         'Please Confirm to Refresh List',
                                                         results[0].errorMessage,
                                                         function(btn, text) {
                                                            if (btn=='yes') {

                                                               grid.getView().getSelectionModel().deselectAll();

                                                               yearEndStore.sync();
                                                               yearEndStore.reload();
                                                               yearEndSelStore.sync();
                                                               yearEndSelStore.reload();
                                                            }
                                                         grid.setLoading(false);
                                                      });
                                                   }else Ext.Msg.alert('Server error', results[0].errorMessage);
                                                }
                                                grid.setLoading(false);
                                            }, function(errors) {
                                                Ext.Msg.alert('Server error', errors[0]);
                                            });

                                    }
                                });


                        } else Ext.Msg.alert('Invalid Selection', 'No records have been selected');

                    }
                }, {
                    id: 'remove_confirm',
                    text: 'Remove Confirmation',
                    handler: function() {
                        var grid = this.up('grid');
                        var selections = grid.getView().getSelectionModel().getSelection();
                        var final_selections = _.filter(selections, function(record) {
                            return yearEndSelCheckbox(record.data);
                        });
                        if (final_selections.length > 0) {

                            Ext.MessageBox.confirm(
                                'Please Confirm',
                                'Are You Confirm to Remove Confirmation ?',
                                function(btn, text) {
                                    if (btn == 'yes') {
                                        var savingObj = sendRequest('deleteYearEndSel', {
                                            deleteFinalAssign: true,
                                            yearlist: _.pluck(final_selections, 'id')
                                        });
                                        grid.setLoading(true);
                                        Ext.Deferred
                                            .all([savingObj])
                                            .then(function(results) {
                                                if (results[0].success) {
                                                    grid.getView().getSelectionModel().deselectAll();

                                                    yearEndStore.sync();
                                                    yearEndStore.reload();
                                                    yearEndSelStore.sync();
                                                    yearEndSelStore.reload();
                                                    
                                                } else {
                                                    if(results[0].duplicate){
                                                      Ext.MessageBox.confirm(
                                                         'Please Confirm to Refresh List',
                                                         results[0].errorMessage,
                                                         function(btn, text) {
                                                            if (btn=='yes') {

                                                               grid.getView().getSelectionModel().deselectAll();

                                                               yearEndStore.sync();
                                                               yearEndStore.reload();
                                                               yearEndSelStore.sync();
                                                               yearEndSelStore.reload();
                                                            }
                                                         grid.setLoading(false);
                                                      });
                                                   }else Ext.Msg.alert('Server error', results[0].errorMessage);
                                                }
                                                grid.setLoading(false);
                                            }, function(errors) {
                                                Ext.Msg.alert('Server error', errors[0]);
                                            });

                                    }
                                });


                        } else Ext.Msg.alert('Invalid Selection', 'No records have been selected');
                    },
                    hidden: true
                },{
                    xtype: 'container',
                    flex: 1
                },
                {
                    id: 'submit_final',
                    text: 'Submitted All Selection',
                    handler: function() {
                        var grid = this.up('grid');
                        Ext.MessageBox.confirm(
                                'Please Confirm',
                                '<span style="color:red;">Warning!</span> This button will change status of YearEnd records to \"Submitted\" , RM/TM will lose ability to select or refer out for those \"Submitted\" records.<br /><br />Are you sure to confirm?',
                            function(btn, text) {
                                if (btn == 'yes') {
                                    grid.setLoading(true);
                                    Ext.Deferred
                                        .all([sendRequest('saveYearEnd', {
                                            contx: 'SUBMITTED'
                                        })])
                                        .then(function(results) {
                                            if (results[0].success) {
                                                grid.getView().getSelectionModel().deselectAll();
                                                yearEndStore.sync();
                                                yearEndStore.reload();
                                                yearEndSelStore.sync();
                                                yearEndSelStore.reload();
                                                
                                            } else {
                                                if(results[0].duplicate){
                                                  Ext.MessageBox.confirm(
                                                     'Please Confirm to Refresh List',
                                                     results[0].errorMessage,
                                                     function(btn, text) {
                                                        if (btn=='yes') {

                                                           grid.getView().getSelectionModel().deselectAll();

                                                           yearEndStore.sync();
                                                           yearEndStore.reload();
                                                           yearEndSelStore.sync();
                                                           yearEndSelStore.reload();
                                                        }
                                                     grid.setLoading(false);
                                                  });
                                               }else Ext.Msg.alert('Server error', results[0].errorMessage);
                                            }
                                            grid.setLoading(false);
                                        }, function(errors) {
                                            Ext.Msg.alert('Server error', errors[0]);
                                        });
                                }
                            });
                    }
                }]
            }, {
                xtype: 'toolbar',
                dock: 'top',
                items: [{
                        xtype: 'tbspacer'
                    },
                    selectByCombobox, {
                        xtype: 'tbspacer'
                    }, {
                        xtype: 'combobox',
                        name: 'selected_dropdown',
                        labelWidth: 110,
                        fieldLabel: 'Selected/Refer Out',
                        triggerAction: 'all',
                        editable: false,
                        lazyRender: true,
                        mode: 'local',
                        //emptyText: 'All',
                        store: new Ext.data.ArrayStore({
                            id: 0,
                            fields: [
                                'property',
                                'value'
                            ],
                            data: [
                                ['All', ''],
                                ['Selected', 'false'],
                                ['Refer Out', 'true']
                            ]
                        }),
                        value: '',
                        valueField: 'value',
                        displayField: 'property',
                        listeners: {
                            select: function(combox, selected, index) {
                                var grid = this.up('grid');
                                if (selected.data.value != '')
                                    grid.store.filter("Refer_Out__c", selected.data.value);
                                else grid.store.removeFilter("Refer_Out__c");
                                grid.getView().getSelectionModel().deselectAll();
                            }
                        }
                    }, {
                        xtype: 'container',
                        flex: 1
                    }, {
                        xtype: 'checkbox',
                        name: 'selected_count',
                        boxLabel: 'Selected Count > 1',
                        handler: function(model, selected) {
                            var grid = this.up('grid');
                            if (selected) {
                                grid.store.filter("Selected_Count__c", '@');
                                Ext.getCmp("confirm_final").disable();
                            } else {
                                grid.store.filter("Selected_Count__c", '1');
                                Ext.getCmp("confirm_final").enable();
                            }
                            //grid.store.removeFilter("Selected_Count__c");
                            grid.getView().getSelectionModel().deselectAll();
                        }
                    }, {
                        xtype: 'tbspacer'
                    }, {
                        xtype: 'checkbox',
                        name: 'confirm_list',
                        boxLabel: 'Confirmed List',
                        handler: function(model, selected) {
                            var grid = this.up('grid');
                            if (selected) {
                                //grid.store.filter("Selected_By__r.RC_Code__c", '#'+config.user_rc_code);
                                is_confirmlist = true;
                                Ext.getCmp("remove_confirm").show();
                                Ext.getCmp("confirm_final").hide();
                                Ext.getCmp("remove_selection").hide();
                                grid.store.removeFilter("Year_End_Assignment__r.Final_Assigned_RM__c");
                                grid.store.filter("Year_End_Assignment__r.Final_Assigned_RM__c !", 'null');
                            } else {
                                is_confirmlist = false;
                                Ext.getCmp("remove_confirm").hide();
                                Ext.getCmp("confirm_final").show();
                                Ext.getCmp("remove_selection").show();
                                //grid.store.removeFilter("Year_End_Assignment__r.Status__c");
                                grid.store.removeFilter("Year_End_Assignment__r.Final_Assigned_RM__c !");
                                grid.store.filter("Year_End_Assignment__r.Final_Assigned_RM__c", 'null');
                            }
                            grid.getView().getSelectionModel().deselectAll();
                        }
                    },
                ]
            }],
            selModel: new Ext.selection.CheckboxModel({
                checkOnly: true,
                mode: 'SIMPLE',
                renderer: function(val, meta, record, rowIndex, colIndex, store, view) {
                    if (yearEndSelCheckbox(record.data)) {
                        meta.tdCls = Ext.baseCSSPrefix + 'grid-cell-special '
                        return '<div class="' + Ext.baseCSSPrefix + 'grid-row-checker">&#160;</div>';
                    } else {
                        return '';
                    }
                }
            })
        }),
        createGridObject('Customers List', 'yearEndGrid', yearEndStore, yearColumn, { //extra here

            dockedItems: [{
                xtype: 'toolbar',
                dock: 'bottom',
                items: [{
                    text: 'Select & Confirm',
                    handler: function() {
                        //rm selected here
                        var grid = this.up('grid');
                        var selections = grid.getView().getSelectionModel().getSelection();
                        
                        var before_final_selections = _.filter(selections, function(record) {
                            return yearEndCheckbox(record.data);
                        });
                        var final_selections = _.filter(before_final_selections, function(record) {
                            return record.data.Selected_Count__c == 0;
                        });
                        if (final_selections.length > 0) {

                            selectByPanelCombobox.clearValue();
                            portPoolPanelCombobox.clearValue();
                            servicePanelCombobox.clearValue();

                            selectByPanelCombobox.clearInvalid();
                            portPoolPanelCombobox.clearInvalid();
                            servicePanelCombobox.clearInvalid();

                            servicePanelCombobox.hide();
                            selectconfirm_popup.show();
                        } else Ext.Msg.alert('Invalid Selection', 'No records have been selected');
                    }
                }, {
                    xtype: 'tbspacer'
                }, {
                    text: 'Refer Out & Confirm',
                    handler: function() {
                        //rm selected here
                        var grid = this.up('grid');
                        var selections = grid.getView().getSelectionModel().getSelection();
                        var final_selections = _.filter(selections, function(record) {
                            return yearEndCheckbox(record.data);
                        });
                        if (final_selections.length > 0) {
                            
                            reasonCombobox.clearValue();
                            provinceCombobox.clearValue();
                            aumpurCombobox.clearValue();
                            tumbonCombobox.clearValue();
                            segmentCombobox.clearValue();
                            referOutTeamText.setValue('');

                            reasonCombobox.clearInvalid();
                            provinceCombobox.clearInvalid();
                            aumpurCombobox.clearInvalid();
                            tumbonCombobox.clearInvalid();
                            segmentCombobox.clearInvalid();
                            referOutTeamText.clearInvalid();

                            provinceCombobox.hide();
                            aumpurCombobox.hide();
                            tumbonCombobox.hide();
                            referOutTeamText.hide();
                            segmentCombobox.hide();
                            referout_popup.show();
                        } else Ext.Msg.alert('Invalid Selection', 'No records have been selected');
                    }
                }]
            }],
            listeners:{
                'afterrender': function(grid) {
                    yearEndStore.sync();
                    yearEndStore.reload();        
                }
            },
            selModel: new Ext.selection.CheckboxModel({
                checkOnly: true,
                mode: 'SIMPLE',
                renderer: function(val, meta, record, rowIndex, colIndex, store, view) {
                    if (yearEndCheckbox(record.data)) {
                        meta.tdCls = Ext.baseCSSPrefix + 'grid-cell-special '
                        return '<div class="' + Ext.baseCSSPrefix + 'grid-row-checker">&#160;</div>';
                    } else {
                        return '';
                    }
                }
            })
        })
    ];
    config.container_items = [referout_popup, selectconfirm_popup,selectedcount_popup];
};