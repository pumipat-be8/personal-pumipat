function init(config){
   var yearColumn = [  
      {  
         "dataIndex":"CIS_ID_Unique__c",
         "text":"CIS ID",
         "align": "right",
         "sortable":true
      },
      {  
         "dataIndex":"Customer_Name__c",
         "text":"Customer Name",
         "sortable":false,
         
         "renderer": Ext.util.Format.htmlDecode
      },
      {  
         "dataIndex":"Segment_Original__c",
         "text":"Segment (Original)",
         "sortable":true
      },
      {
         "dataIndex":"Segment_Proposed__c",
         "text":"Segment (Proposed)",
         "sortable":true,
         "width":150
      },
      {  
         "dataIndex":"High_Value_Flag__c",
         "text":"High Value Flag",
         "sortable":true
      },
      {  
         "dataIndex":"Port_Pool__c",
         "text":"Port / Pool",
         "sortable":true
      },
      {  
         "dataIndex":"Credit_Status__c",
         "text":"Credit Status",
         "sortable":true
      },
      {
         "dataIndex":"RM_Name__c",
         "text":"RM Name",
         "sortable":true,
         "width":150
      },
      {  
         "dataIndex":"Team__c",
         "text":"Team",
         "sortable":true
      },
      {  
         "dataIndex":"TM_Name__c",
         "text":"TM Name",
         "sortable":true
      },
      {  
         "dataIndex":"Final_Team__c",
         "text":"Final Team",
         "sortable":true,
         "width":150
      },
      {  
         "dataIndex":"Final_Assigned_SelectedBy_Text__c",
         "text":"Final Assigned/SelectedBy",
         "sortable":true
      },
      {  
         "dataIndex":"Final_Port_Pool__c",
         "text":"Final Port/Pool",
         "sortable":true
      },
      {  
         "dataIndex":"Final_Refer_Out__c",
         "text":"Final Refer Out",
         "sortable":true,
         "xtype": "checkcolumn",
        "disabled": true,
        "disabledCls" : "x-item-enabled"
      },
      {
         "dataIndex":"Refer_Out_Reason__c",
         "text":"Refer Out Reason",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"Refer_Out_Detail__c",
         "text":"Refer Out Detail",
         "sortable":true,
         "width":150
      },
      {  
         "dataIndex":"Selected_Count__c",
         "text":"Selected Count",
         "format":"0,000",
         "align": "right",
         "sortable":true,
         "xtype":"numbercolumn",
      },
      {  
         "dataIndex":"AH_Name__c",
         "text":"AH Name",
         "sortable":true
      },
      {  
         "dataIndex":"NH_Name__c",
         "text":"NH Name",
         "sortable":true
      },
      {  
         "dataIndex":"Business_Code__c",
         "text":"Business Code",
         "sortable":true
      },
      {  
         "dataIndex":"Business_Desc__c",
         "text":"Business Desc",
         "sortable":true
      },
      {  
         "dataIndex":"Credit_Flag__c",
         "text":"Credit Flag",
         "sortable":true
      },
      {  
         "dataIndex":"Income_1M__c",
         "xtype": "numbercolumn",
         "format":"0,000",
         "align": "right",
         "text":"Income Last1Month",
         "sortable":true
      },
      {  
         "dataIndex":"Total_SME_Limit__c",
         "xtype": "numbercolumn",
         "format":"0,000",
         "align": "right",
         "text":"Total SME Limit",
         "sortable":true
      },
      {  
         "dataIndex":"SME_Limit_LI__c",
         "xtype": "numbercolumn",
         "format":"0,000",
         "align": "right",
         "text":"SME Limit - LI",
         "sortable":true
      },
      {  
         "dataIndex":"SME_Limit_TF__c",
         "xtype": "numbercolumn",
         "format":"0,000",
         "align": "right",
         "text":"SME Limit - TF",
         "sortable":true
      },
      {  
         "dataIndex":"Total_SME_Out__c",
         "xtype": "numbercolumn",
         "format":"0,000",
         "align": "right",
         "text":"Total SME Out",
         "sortable":true
      },
      {  
         "dataIndex":"Total_SME_Exposure__c",
         "xtype": "numbercolumn",
         "format":"0,000",
         "align": "right",
         "text":"Total SME Exposure",
         "sortable":true
      },
      {  
         "dataIndex":"SOW_SME_Exposure__c",
         "text":"%SOW (SME Exposure)",
         "sortable":true,
         "renderer": function(value) {
            return (value)?(value + "%"):"";
         }
      },
      {  
         "dataIndex":"SME_Wallet_Size__c",
         "xtype": "numbercolumn",
         "format":"0,000",
         "align": "right",
         "text":"SME Wallet Size",
         "sortable":true
      },
      {  
         "dataIndex":"DPD6M__c",
         "text":"DPD6M",
         "sortable":true
      },
      {  
         "dataIndex":"NPL12M__c",
         "text":"NPL12M",
         "sortable":true
      },
      {  
         "dataIndex":"Court_Case_12M__c",
         "text":"Court Case 12M",
         "sortable":true
      },
      {  
         "dataIndex":"SME_BSCORE_1M__c",
         "text":"SME BSCORE Last1Month",
         "sortable":true
      },
      {  
         "dataIndex":"SME_BSCORE_2M__c",
         "text":"SME BSCORE Last2Month",
         "sortable":true
      },
      {  
         "dataIndex":"SME_BSCORE_3M__c",
         "text":"SME BSCORE Last3Month",
         "sortable":true
      }
   ];
   var yearSelColumn = [
      {
         "dataIndex":"CIS_ID__c",
         "text":"CIS ID",
         "align": "right",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"Customer_Name__c",
         "text":"Customer Name",
         "sortable":false,
         "renderer": Ext.util.Format.htmlDecode
      },
      {
         "dataIndex":"Segment_Original__c",
         "text":"Segment (Original)",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"Segment_Proposed__c",
         "text":"Segment (Proposed)",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"High_Value_Flag__c",
         "text":"High Value Flag",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"Port_Pool__c",
         "text":"Port / Pool",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"Credit_Status__c",
         "text":"Credit Status",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"RM_Name__c",
         "text":"RM Name",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"Team__c",
         "text":"Team",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"TM_Name__c",
         "text":"TM Name",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"Selected_By_Name__c",
         "text":"Selected By Name",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"Selected_By_Team__c",
         "text":"Selected By Team",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"Refer_Out__c",
         "text":"Refer Out",
         "sortable":true,
         "xtype": "checkcolumn",
        "disabled": true,
        "disabledCls" : "x-item-enabled"
      },
      {
         "dataIndex":"Refer_Out_Reason__c",
         "text":"Refer Out Reason",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"Refer_Out_Detail__c",
         "text":"Refer Out Detail",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"Final_Assigned_RM__c",
         "text":"Final Assigned/SelectedBy",
         "sortable":true,
         "width":150
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
         "dataIndex":"Final_Refer_Out__c",
         "text":"Final Refer Out",
         "sortable":true,
         "xtype": "checkcolumn",
        "disabled": true,
        "disabledCls" : "x-item-enabled"
      },
      {
         "dataIndex":"Selected_Count__c",
         "text":"Selected Count",
         "format":"0,000",
         "align": "right",
         "sortable":true,
         
         "xtype":"numbercolumn"
      },
      {
         "dataIndex":"AH_Name__c",
         "text":"AH Name",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"NH_Name__c",
         "text":"NH Name",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"Business_Code__c",
         "text":"Business Code",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"Business_Desc__c",
         "text":"Business Desc",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"Credit_Flag__c",
         "text":"Credit Flag",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"Income_1M__c",
         "xtype": "numbercolumn",
         "format":"0,000",
         "align": "right",
         "text":"Income Last1Month",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"Total_SME_Limit__c",
         "xtype": "numbercolumn",
         "format":"0,000",
         "align": "right",
         "text":"Total SME Limit",
         "sortable":true,
         "width":150
      },
      {  
         "dataIndex":"SME_Limit_LI__c",
         "xtype": "numbercolumn",
         "format":"0,000",
         "align": "right",
         "text":"SME Limit - LI",
         "sortable":true
      },
      {  
         "dataIndex":"SME_Limit_TF__c",
         "xtype": "numbercolumn",
         "format":"0,000",
         "align": "right",
         "text":"SME Limit - TF",
         "sortable":true
      },
      {
         "dataIndex":"Total_SME_Out__c",
         "xtype": "numbercolumn",
         "format":"0,000",
         "align": "right",
         "text":"Total SME Out",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"Total_SME_Exposure__c",
         "xtype": "numbercolumn",
         "format":"0,000",
         "align": "right",
         "text":"Total SME Exposure",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"SOW_SME_Exposure__c",
         "text":"%SOW (SME Exposure)",
         "sortable":true,
         
         "renderer": function(value) {
            return (value)?(value + "%"):"";
         }
      },
      {
         "dataIndex":"SME_Wallet_Size__c",
         "xtype": "numbercolumn",
         "format":"0,000",
         "align": "right",
         "text":"SME Wallet Size",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"DPD6M__c",
         "text":"DPD6M",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"NPL12M__c",
         "text":"NPL12M",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"Court_Case_12M__c",
         "text":"Court Case 12M",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"SME_BSCORE_1M__c",
         "text":"SME BSCORE Last1Month",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"SME_BSCORE_2M__c",
         "text":"SME BSCORE Last2Month",
         "sortable":true,
         "width":150
      },
      {
         "dataIndex":"SME_BSCORE_3M__c",
         "text":"SME BSCORE Last3Month",
         "sortable":true,
         "width":150
      }
   ];

   var yearEndModelName = Ext.String.capitalize("Year_End_Assignment__c");
   var yearEndSelModelName = Ext.String.capitalize("Year_End_Assignment_Selection__c");

   createModel(yearEndModelName,'records','Id',
     '',YearEndAssignment_ListView_Controller.query,
     {sobjname: 'Year_End_Assignment__c', fields: config.fieldlist.join(',')}
   );

   createModel(yearEndSelModelName,'records','Id',
     '',YearEndAssignment_ListView_Controller.query,
     {sobjname: 'Year_End_Assignment_Selection__c', fields: config.fieldsellist.join(',')}
   );
   
   var yearEndStore = createStoreModel(yearEndModelName,config.pagesize,{
      filters: [{
         property: 'RM_Employee_ID__c',
         value: '#'+config.user_empid
      }],
      sorters:[{
         property: 'Team__c',
         direction: 'ASC'
      }]
   });
   var yearEndSelStore = createStoreModel(yearEndSelModelName,config.pagesize,{
      autoLoad:false,
      filters: [{
         property: 'Selected_By__c',
         value: config.user_id
      }],
      sorters:[{
         property: 'CIS_ID__c',
         direction: 'ASC'
      }]
   });
   var yearEndCheckbox = function(record){
      return record.Status__c=='New' && ((!record.Final_Assigned_RM__c || record.Final_Assigned_RM__c==null || typeof record.Final_Assigned_RM__c === "undefined" || record.Final_Assigned_RM__c=='') && (!record.Final_Refer_Out__c || record.Final_Refer_Out__c==null || typeof record.Final_Refer_Out__c === "undefined" || record.Final_Refer_Out__c=='') && (!record.Year_End_Assignment_Selections__r || record.Year_End_Assignment_Selections__r==null || typeof record.Year_End_Assignment_Selections__r === "undefined" || record.Year_End_Assignment_Selections__r.length == 0));
   };
   var yearEndSelCheckbox = function(record){
      return record.Year_End_Assignment__r.Status__c=='New' && (record.Selected_By__c == config.user_id) && (!record.Final_Assigned_RM__c || record.Final_Assigned_RM__c==null || typeof record.Final_Assigned_RM__c === "undefined" || record.Final_Assigned_RM__c=='');
   };

   var reasonStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryPicklist,{scope:'Refer_Out_Reason__c'},true);
   var segmentStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryPicklist,{scope:'Refer_Out_Segment__c'},true);

   var provinceStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryLocation,{scope:'Province'},true);
   var aumpurStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryLocation,{scope:'District'},false);
   var tumbonStore = createStorePicklistModel(YearEndAssignment_ListView_Controller.queryLocation,{scope:'Sub District'},false);

   var segmentCombobox = createComboxbox('Refer Out Segment','referoutSegment',true,segmentStore,'Select a Segment','pname','pvalue',false,true);
   var reasonCombobox = createComboxbox('Refer Out Reason','referoutReason',false,reasonStore,'Select a Reason','pname','pvalue',false,false);
   var provinceCombobox = createComboxbox('Refer Out Province','referoutProvince',true,provinceStore,'Select a Province','pname','pvalue',false,true);
   var aumpurCombobox = createComboxbox('Refer Out Aumpur','referoutAumpur',true,aumpurStore,'Select a Aumpur','pname','pvalue',false,true);
   var tumbonCombobox = createComboxbox('Refer Out Tumbon','referoutTumbon',true,tumbonStore,'Select a Tumbon','pname','pvalue',false,true);

   var referOutTeamText = new Ext.form.TextField({
      fieldLabel: 'Refer Out Team',
      name: 'referoutTeam',
      hidden:true
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

   provinceCombobox.on('select',function(cmb,record,index){
      aumpurCombobox.hide();
      aumpurCombobox.clearValue();

      tumbonCombobox.hide();
      tumbonCombobox.clearValue();

      if(record.get('pvalue') && record.get('pvalue')!=''){
         aumpurCombobox.show();
         aumpurStore.proxy.extraParams.extra = record.get('pvalue');
         aumpurStore.load();
      }
   });

   aumpurCombobox.on('select',function(cmb,record,index){
      tumbonCombobox.hide();
      tumbonCombobox.clearValue();

      if(record.get('pvalue') && record.get('pvalue')!=''){
         tumbonCombobox.show();
         tumbonStore.proxy.extraParams.extra = record.get('pvalue');
         tumbonStore.load();
      }
   });

   var referout_popup = Ext.create('Ext.form.Panel', {
      bodyPadding: 5,
      width: 330,
      id:'mainPanel',
      modal: true,
      closable : true,
      closeAction: 'hide',
      floating: true,
      title: 'Refer Out',
      listeners: {
         'beforerender': function(formPanel){
            //if (!field.allowBlank) field.labelSeparator += '<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>';
            var i, len, items, item;

            items = formPanel.query('[allowBlank=false]');

            for (i = 0, len = items.length; i < len; i++) {
               item = items[i];
               item.afterLabelTextTpl = (item.afterLabelTextTpl || "") + '<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>';
            }

            return true;
         }
      },
      items: [reasonCombobox, provinceCombobox, aumpurCombobox,tumbonCombobox, segmentCombobox, referOutTeamText],
      getInvalidFields: function() {
         var invalidFields = [];
         Ext.suspendLayouts();
         this.form.getFields().filterBy(function(field) {
           if (field.validate()) return;
           invalidFields.push(field);
         });
         Ext.resumeLayouts(true);
         return invalidFields;
      },    
      dockedItems: [
          {
              xtype: 'toolbar',
              dock: 'bottom',
              items : [
                  '->',
                  {
                      text: 'Save',
                      handler: function(){
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
                                             contx:'REFER_OUT',
                                             referOut:form.getFieldValues(),
                                             yearlist:_.pluck(final_selections,'id')
                                     })])
                                 .then(function (results) {
                                    
                                    if(results[0].success){

                                       grid.getView().getSelectionModel().deselectAll();

                                       yearEndStore.sync();
                                       yearEndStore.reload();
                                       yearEndSelStore.sync();
                                       yearEndSelStore.reload();

                                       grid.setLoading(false);
                                    }else{
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
                                     grid.setLoading(false);
                                 });
                              }else Ext.Msg.alert('Invalid Selection','No Yearend have been selected');
                             
                          } else {
                              var fieldNames = [];                
                              var fields = panel.getInvalidFields();
                              var field;
                              for(var i=0; i <  fields.length; i++){
                                  field = fields[i];
                                  fieldNames.push(field.getFieldLabel());
                               }
                              Ext.MessageBox.alert('Invalid Fields', 'The following fields are invalid: ' + fieldNames.join(', '));
                          }
                      }
                  }
              ]
          }
      ]
   });
   config.panel_items = [
      createGridObject('Customers List','yearEndGrid',yearEndStore,yearColumn,
        {//extra here
            dockedItems: [
            {
                xtype: 'toolbar',
                dock: 'bottom',
                items: [
                    {
                        text: 'Select Checked Customer',
                        handler: function(){
                            //rm selected here
                            var grid = this.up('grid');
                            var selections = grid.getView().getSelectionModel().getSelection();
                            var final_selections = _.filter(selections, function(record){ 
                                return yearEndCheckbox(record.data);
                            });
                            if(final_selections.length > 0){
                                Ext.MessageBox.confirm(
                                    'Please Confirm',
                                    'Are You Confirm to Select ?',
                                    function(btn, text) {
                                        if (btn=='yes') {
                                            var savingObj = sendRequest('saveYearEnd',{
                                                contx:'SELECTED',
                                                yearlist:_.pluck(final_selections,'id')
                                            });
                                          grid.setLoading(true);
                                            Ext.Deferred
                                            .all([savingObj])
                                            .then(function (results) {
                                                console.log(results);
                                                
                                                if(results[0].success){

                                                   grid.getView().getSelectionModel().deselectAll();

                                                   yearEndStore.sync();
                                                   yearEndStore.reload();
                                                   yearEndSelStore.sync();
                                                   yearEndSelStore.reload();

                                                }else {
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
                                                Ext.Msg.alert('Server error', errors[0].errorMessage);
                                                grid.setLoading(false);
                                            });
                                        }
                                    });
                            }else Ext.Msg.alert('Invalid Selection','No Yearend have been selected');
                        }
                    },
                    { xtype: 'tbspacer' },
                    {
                        text: 'Refer Out Checked Customer',
                        handler: function(){
                            //rm selected here
                            var grid = this.up('grid');
                            var selections = grid.getView().getSelectionModel().getSelection();
                            var final_selections = _.filter(selections, function(record){ 
                                return yearEndCheckbox(record.data);
                            });
                            if(final_selections.length > 0){
                              
                            
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
                           }else Ext.Msg.alert('Invalid Selection','No Yearend have been selected');
                        }
                    }
                ]
            },
            {
                xtype: 'toolbar',
                dock: 'top',
                items: [{
                    xtype: 'checkbox',
                    name: 'previous_me',
                    boxLabel: 'Previously owned by me',
                    checked: true,
                    handler: function(model,selected){
                        var grid = this.up('grid');
                        if(selected && config.user_empid && config.user_empid!=''){
                            grid.store.filter("RM_Employee_ID__c", '#'+config.user_empid);
                        }else {
                           grid.store.removeFilter("RM_Employee_ID__c");
                        }
                        grid.getView().getSelectionModel().deselectAll();
                    }
                }]
            }],
            selModel: new Ext.selection.CheckboxModel( {
                checkOnly:true,
                mode: 'SIMPLE',
                renderer : function(val, meta, record, rowIndex, colIndex, store,view){
                    if(yearEndCheckbox(record.data)){
                        meta.tdCls = Ext.baseCSSPrefix + 'grid-cell-special '
                        return '<div class="' + Ext.baseCSSPrefix + 'grid-row-checker">&#160;</div>';  
                    }else{
                        return '';
                    }
                }
            })
        }
         ),createGridObject('Selected List','yearEndSelGrid',yearEndSelStore,yearSelColumn,{
            dockedItems: [{xtype:'tbspacer'},{
                xtype: 'toolbar',
                dock: 'bottom',
                items: [
                    {
                        text: 'Remove Selection',
                        handler: function(){
                            var grid = this.up('grid');
                            var selections = grid.getView().getSelectionModel().getSelection();
                            var final_selections = _.filter(selections, function(record){ 
                                return yearEndSelCheckbox(record.data);
                            });
                            if(final_selections.length > 0){

                                Ext.MessageBox.confirm(
                                    'Please Confirm',
                                    'Are You Confirm to Remove ?',
                                    function(btn, text) {
                                        if (btn=='yes') {
                                            var savingObj = sendRequest('deleteYearEndSel',{
                                                yearlist:_.pluck(final_selections,'id')
                                            });
                                            grid.setLoading(true);
                                            Ext.Deferred
                                            .all([savingObj])
                                            .then(function (results) {

                                                if(results[0].success){
                                                   grid.getView().getSelectionModel().deselectAll();

                                                   yearEndStore.sync();
                                                   yearEndStore.reload();
                                                   yearEndSelStore.sync();
                                                   yearEndSelStore.reload();

                                                }else{
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
                                                grid.setLoading(false);
                                            });

                                        }
                                });

                                
                            }else Ext.Msg.alert('Invalid Selection','No Yearend have been selected');
                            
                        }
                    }]
               },{
                xtype: 'toolbar',
                dock: 'top',
                items: [{xtype:'tbspacer'},{
                    xtype: 'combobox',
                    name: 'selected_dropdown',
                    labelWidth: 110,
                    fieldLabel: 'Selected/Refer Out',
                    triggerAction: 'all',
                    editable: false,
                    lazyRender:true,
                    mode: 'local',
                    //emptyText: 'All',
                    store: new Ext.data.ArrayStore({
                        id: 0,
                        fields: [
                            'property',
                            'value'
                        ],
                        data: [['All', ''],['Selected', 'false'], ['Refer Out', 'true']]
                    }),
                    value:'',
                    valueField: 'value',
                    displayField: 'property',
                    listeners: {
                        select: function(combox,selected,index) {
                            var grid = this.up('grid');
                            if(selected.data.value!=''){
                                grid.store.filter("Refer_Out__c", selected.data.value);
                            }
                            else {
                              grid.store.removeFilter("Refer_Out__c");
                           }
                           grid.getView().getSelectionModel().deselectAll();
                        }
                    }
                },{xtype:'tbspacer'},{
                    xtype: 'checkbox',
                    name: 'selected_by_me',
                    boxLabel: 'Selected By Me',
                    checked: true,
                    handler: function(model,selected){
                        var grid = this.up('grid');
                        if(selected){
                            grid.store.filter("Selected_By__c", config.user_id);
                            grid.store.sort("CIS_ID__c", 'ASC');
                        }else {
                           grid.store.removeFilter("Selected_By__c");
                        }
                        grid.getView().getSelectionModel().deselectAll();
                        //grid.store.load()
                    }
                }]
            }],
            listeners:{
                'afterrender': function(grid) {
                    yearEndSelStore.sync();
                    yearEndSelStore.reload();        
                }
            },
            selModel: new Ext.selection.CheckboxModel( {
                checkOnly:true,
                mode: 'SIMPLE',
                renderer : function(val, meta, record, rowIndex, colIndex, store,view){
                    if(yearEndSelCheckbox(record.data)){
                        meta.tdCls = Ext.baseCSSPrefix + 'grid-cell-special '
                        return '<div class="' + Ext.baseCSSPrefix + 'grid-row-checker">&#160;</div>';
                    }else{
                        return '';
                    }
                }
         })
        })
   ];
   config.container_items = [referout_popup];
};