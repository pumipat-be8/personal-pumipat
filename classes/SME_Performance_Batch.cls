/**
 * @author komsan.wi@beryl8.com
 * @04/04/2016 create new
 */
global class SME_Performance_Batch implements Database.Batchable<sObject>, Database.Stateful{
    private String query;

    private Boolean runMontly = false;
    private Boolean initialMonthly = false;
    private Boolean shouldRunMontly = true;
    private Boolean runSummaryAtTheEnd = false;
    private Boolean resetStatement = false;

    private Boolean resetValue = false;

    private Map<String,User_Extension__c> userExMap;
    private Map<String,Team_Structure__c> teamMap;

    //private List<User_Extension__c> userExUpdateList;
    //private List<Team_Structure__c> teamUpdateList;
    private Map<String,Monthly_Performance__c> monthlyMap;
    private String completeStatement;
    private String completeStatementMonthly;
    private Date monthlyStart;
    private Date monthlyEnd;
    private Map<String,List<String>> userExIdMapTeam;
    @TestVisible
    private Date todayDateFromNow;
    private Integer minusMonthly = 0;
    private List<String> monthList = new List<String>{
        'มกราคม',
        'กุมภาพันธ์',
        'มีนาคม',
        'เมษายน',
        'พฤษภาคม',
        'มิถุนายน',
        'กรกฎาคม',
        'สิงหาคม',
        'กันยายน',
        'ตุลาคม',
        'พฤศจิกายน',
        'ธันวาคม'
    };
    @TestVisible
    private Integer currentYear;
    global SME_Performance_Batch(Integer minusMonthly) {
        this.minusMonthly = minusMonthly;
        this.init();
    }
    global SME_Performance_Batch(){
        this.init();
    }
    global void init() {
        this.query = 'SELECT Id,CIS_ID__c,Current_Owner_Extension__c,Current_Owner_Extension__r.Team_Structure__c,Current_Team_Name__c,Ownership__c,Port_Pool__c,Visit_Objective__c,Contact_Channel__c,Completed__c,Current_Owner_Extension__r.User__r.isActive,Current_Owner_Extension__r.User__r.Employee_Id__c,Current_Owner_Extension__r.User__r.RC_Code__c,Actual_Visit_Date__c,Offer_Credit_Product__c,Collect_Documents__c,Negotiation__c,Pain__c,Servicing__c,Customer_Insight__c,Non_Credit__c,No_Change__c FROM Call_Report__c WHERE Status__c=\'Contacted\' AND Primary_Call_Report__c=true AND Actual_Visit_Date__c = THIS_YEAR';
        completeStatement = ' AND Completed__c=false';
        completeStatementMonthly = '';
        DateTime dT = System.now();
        todayDateFromNow = date.newinstance(dT.year(), dT.month()-minusMonthly, dT.day());
        currentYear = (todayDateFromNow.year()<2500)?todayDateFromNow.year()+543:todayDateFromNow.year();
        userExMap = new Map<String,User_Extension__c>([SELECT Id,Call_Report__c,Call_Report_Customer_Others__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Port__c,Call_Report_for_Relationship__c,Call_Report_for_Sales__c,Face_to_Face__c,Months__c,Phone_Call__c,Team_Structure__c,User__r.ProfileId,User__r.Profile.Name,User__r.Employee_Id__c,User__r.RC_Code__c,Number_of_RM_under_Team__c,Last_Month_Stamp__c,User__r.IsActive,Contacted_Customer_Other__c,Contacted_Customer_Pool__c,Contacted_Customer_Port__c,Customer_Other__c,Customer_Pool__c,Customer_Port__c,User__c,User__r.ManagerId,Total_visited_Customer__c,Contacted_Customer_Other_My_Penetrate__c,Contacted_Customer_Pool_My_Penetrate__c,Contacted_Customer_Port_My_Penetrate__c FROM User_Extension__c WHERE Team_Structure__c!=null]);

        teamMap = new Map<String,Team_Structure__c>([SELECT Id,Call_Report__c,Call_Report_Customer_Others__c,Call_Report_Customer_Pool__c,Call_Report_Customer_Port__c,Call_Report_for_Relationship__c,Call_Report_for_Sales__c,Face_to_Face__c,Months__c,Phone_Call__c,Name,AH_Name__c,NH_Name__c,RC_Code__c,Number_of_RM_under_Team__c,AH_RC_Code__c,NH_RC_Code__c,Contacted_Customer_Other__c,Contacted_Customer_Pool__c,Contacted_Customer_Port__c,Customer_Other__c,Customer_Pool__c,Customer_Port__c,Total_visited_Customer__c,Contacted_Customer_Other_My_Penetrate__c,Contacted_Customer_Pool_My_Penetrate__c,Contacted_Customer_Port_My_Penetrate__c FROM Team_Structure__c]);

        userExIdMapTeam = new Map<String,List<String>>();

        //reset
        for(User_Extension__c eachExt : userExMap.values()){
            eachExt.Number_of_RM_under_Team__c = 0;
            teamMap.get(eachExt.Team_Structure__c).Number_of_RM_under_Team__c = 0;
            
            if(teamMap.get(eachExt.Team_Structure__c).AH_Name__c!=null) 
                teamMap.get(teamMap.get(eachExt.Team_Structure__c).AH_Name__c).Number_of_RM_under_Team__c = 0;
            
            if(teamMap.get(eachExt.Team_Structure__c).NH_Name__c!=null) 
                teamMap.get(teamMap.get(eachExt.Team_Structure__c).NH_Name__c).Number_of_RM_under_Team__c = 0;

            if(!userExIdMapTeam.containsKey(eachExt.Team_Structure__c))
                userExIdMapTeam.put(eachExt.Team_Structure__c,new List<String>());
            userExIdMapTeam.get(eachExt.Team_Structure__c).add(eachExt.Id);
        }
        for(Team_Structure__c eachTeam : teamMap.values()){
            eachTeam.Months__c = todayDateFromNow.month();
        }
        for(User_Extension__c eachExt : userExMap.values()){
            eachExt.Months__c = todayDateFromNow.month();
        }
        //recount
        for(User_Extension__c eachExt : userExMap.values()){
            if(Account_Util.isProfile(GlobalConstants.SME_RM,eachExt) && eachExt.User__r.isActive){
                teamMap.get(eachExt.Team_Structure__c).Number_of_RM_under_Team__c++;
                //eachExt.Number_of_RM_under_Team__c++;

                for(String exId : userExIdMapTeam.get(eachExt.Team_Structure__c)){
                    userExMap.get(exId).Number_of_RM_under_Team__c++;
                }

                if(teamMap.get(eachExt.Team_Structure__c).AH_Name__c!=null){
                    teamMap.get(teamMap.get(eachExt.Team_Structure__c).AH_Name__c).Number_of_RM_under_Team__c++;
                    if(userExIdMapTeam.containsKey(teamMap.get(eachExt.Team_Structure__c).AH_Name__c))
                        for(String exId : userExIdMapTeam.get(teamMap.get(eachExt.Team_Structure__c).AH_Name__c)){
                            userExMap.get(exId).Number_of_RM_under_Team__c++;
                        }
                }
                if(teamMap.get(eachExt.Team_Structure__c).NH_Name__c!=null){
                    teamMap.get(teamMap.get(eachExt.Team_Structure__c).NH_Name__c).Number_of_RM_under_Team__c++;
                    if(userExIdMapTeam.containsKey(teamMap.get(eachExt.Team_Structure__c).NH_Name__c))
                        for(String exId : userExIdMapTeam.get(teamMap.get(eachExt.Team_Structure__c).NH_Name__c)){
                            userExMap.get(exId).Number_of_RM_under_Team__c++;
                        }
                }
            }
        }
        
    }
    global SME_Performance_Batch noFlag(){
        //set everything to zero;
        completeStatement = '';
        for(User_Extension__c eachExt : userExMap.values()){
            eachExt.Call_Report__c = 0;
            eachExt.Call_Report_Customer_Port__c = 0;
            eachExt.Call_Report_Customer_Pool__c = 0;
            eachExt.Call_Report_Customer_Others__c = 0;
            eachExt.Call_Report_for_Sales__c = 0;
            eachExt.Call_Report_for_Relationship__c = 0;
            eachExt.Face_to_Face__c = 0;
            eachExt.Phone_Call__c = 0;
        }
        for(Team_Structure__c eachTeam : teamMap.values()){
            eachTeam.Call_Report__c = 0;
            eachTeam.Call_Report_Customer_Port__c = 0;
            eachTeam.Call_Report_Customer_Pool__c = 0;
            eachTeam.Call_Report_Customer_Others__c = 0;
            eachTeam.Call_Report_for_Sales__c = 0;
            eachTeam.Call_Report_for_Relationship__c = 0;
            eachTeam.Face_to_Face__c = 0;
            eachTeam.Phone_Call__c = 0;
        }
        return this;
    }
    global SME_Performance_Batch noFlagMonthly(){
        //set everything to zero;
        completeStatementMonthly = '';
        resetStatement = true;
        return this;
    }
    global SME_Performance_Batch noMontly(){
        shouldRunMontly = false;
        return this;
    }
    global SME_Performance_Batch runSummaryAtTheEnd(){
        runSummaryAtTheEnd = true;
        return this;
    }
    global SME_Performance_Batch setResetStatement(Boolean resetStatement){
        this.resetStatement = resetStatement;
        return this;
    }

    global SME_Performance_Batch runMontly(Boolean initial){
        initialMonthly = initial;
        //set everything to zero;
        runMontly = true;
        if(initial) resetStatement = true;
        //if(!initial)
        monthlyMap = new Map<String,Monthly_Performance__c>();
            
        monthlyStart = Date.newInstance(todayDateFromNow.year(),1,1);
        monthlyEnd = todayDateFromNow;

        this.query += ' AND Actual_Visit_Date__c >= :monthlyStart AND Actual_Visit_Date__c <= :monthlyEnd';
        if(!initial) this.completeStatementMonthly += ' AND Complete_Monthly__c=false';

        this.completeStatement = '';
        Integer numberOfDays = Date.daysInMonth(todayDateFromNow.year(), todayDateFromNow.month());
        String exKey;
        String teamKey;
        for(User_Extension__c eachExt : userExMap.values()){
            if(eachExt.User__r.isActive || initial || resetStatement){
                exKey = eachExt.User__r.Employee_Id__c + ' ' + todayDateFromNow.month() + ' ' + currentYear;
                teamKey = eachExt.User__r.RC_Code__c + ' ' + todayDateFromNow.month() + ' ' + currentYear;
                if(!monthlyMap.containsKey(exKey)){
                    monthlyMap.put(exKey,new Monthly_Performance__c(
                        External_ID__c = exKey,
                        Name = monthList.get(todayDateFromNow.month()-1) +' '+currentYear,
                        User__c = eachExt.Id,
                        //Team__c = eachExt.Id.Team_Structure__c,
                        Call_Report__c = 0,
                        Call_Report_Customer_Port__c = 0,
                        Call_Report_Customer_Pool__c = 0,
                        Call_Report_Customer_Others__c = 0,
                        Call_Report_for_Sales__c = 0,
                        Call_Report_for_Relationship__c = 0,
                        Face_to_Face__c = 0,
                        Phone_Call__c = 0,
                        Total_visited_Customer__c = 0,
                        //Total_Call_Report__c = 0,
                        //Total_Face_to_Face_Call__c = 0,
                        //Total_Sales_Relationship__c = 0,
                        Contacted_Customer_Other__c = 0,
                        Contacted_Customer_Pool__c = 0,
                        Contacted_Customer_Port__c = 0,
                        Customer_Other__c = 0,
                        Customer_Pool__c = 0,
                        Customer_Port__c = 0,
                        Contacted_Customer_Other_My_Penetrate__c = 0,
                        Contacted_Customer_Pool_My_Penetrate__c = 0,
                        Contacted_Customer_Port_My_Penetrate__c = 0,
                        //Total_Contacted_Customer_Port_Pool_Other__c = 0,
                        //Total_Customer__c = 0,
                        Date__c = Date.newInstance(todayDateFromNow.year(), todayDateFromNow.month(), numberOfDays)
                        //Months__c = todayDateFromNow.month()
                    ));
                }
                if(!monthlyMap.containsKey(teamKey)){
                    monthlyMap.put(teamKey,new Monthly_Performance__c(
                        External_ID__c = teamKey,
                        Name = monthList.get(todayDateFromNow.month()-1) +' '+currentYear,
                        //User__c = eachExt.Id,
                        Team__c = eachExt.Team_Structure__c,
                        Call_Report__c = 0,
                        Call_Report_Customer_Port__c = 0,
                        Call_Report_Customer_Pool__c = 0,
                        Call_Report_Customer_Others__c = 0,
                        Call_Report_for_Sales__c = 0,
                        Call_Report_for_Relationship__c = 0,
                        Face_to_Face__c = 0,
                        Phone_Call__c = 0,
                        Total_visited_Customer__c = 0,
                        //Total_Call_Report__c = 0,
                        //Total_Face_to_Face_Call__c = 0,
                        //Total_Sales_Relationship__c = 0,
                        Contacted_Customer_Other__c = 0,
                        Contacted_Customer_Pool__c = 0,
                        Contacted_Customer_Port__c = 0,
                        Customer_Other__c = 0,
                        Customer_Pool__c = 0,
                        Customer_Port__c = 0,
                        Contacted_Customer_Other_My_Penetrate__c = 0,
                        Contacted_Customer_Pool_My_Penetrate__c = 0,
                        Contacted_Customer_Port_My_Penetrate__c = 0,
                        //Total_Contacted_Customer_Port_Pool_Other__c = 0,
                        //Total_Customer__c = 0,
                        Date__c = Date.newInstance(todayDateFromNow.year(), todayDateFromNow.month(), numberOfDays),
                        Months__c = todayDateFromNow.month()
                    ));
                }
            }
        }
        

        return this;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) { return Database.getQueryLocator(query+completeStatement +completeStatementMonthly); }
    
    global void execute(Database.BatchableContext BC, List<Call_Report__c> callreportList) {
        User_Extension__c userExtObj;
        Team_Structure__c teamStrucObj;

        String exKey;
        String teamKey;
        Integer numberOfDays;
        Integer currentInYear;
        for(Call_Report__c eachCallreport : callreportList){
            if(eachCallreport.Current_Owner_Extension__c!=null && userExMap.containsKey(eachCallreport.Current_Owner_Extension__c)){
                userExtObj = userExMap.get(eachCallreport.Current_Owner_Extension__c);
                teamStrucObj = teamMap.get(userExtObj.Team_Structure__c);
                //system.assertEquals('teamStrucObj',teamStrucObj+'');
                if(eachCallreport.Current_Owner_Extension__r.Team_Structure__c!=null){
                    if(runMontly && eachCallreport.Actual_Visit_Date__c!=null){
                        //if(!initialMonthly)
                            eachCallreport.Complete_Monthly__c = true;

                        currentInYear = (eachCallreport.Actual_Visit_Date__c.year()<2500)?eachCallreport.Actual_Visit_Date__c.year()+543:eachCallreport.Actual_Visit_Date__c.year();

                        exKey = eachCallreport.Current_Owner_Extension__r.User__r.Employee_Id__c + ' ' + eachCallreport.Actual_Visit_Date__c.month() + ' ' + currentInYear;

                        teamKey = teamStrucObj.RC_Code__c + ' ' + eachCallreport.Actual_Visit_Date__c.month() + ' ' + currentInYear;

                        numberOfDays = Date.daysInMonth(eachCallreport.Actual_Visit_Date__c.year(), eachCallreport.Actual_Visit_Date__c.month());
                        if(!monthlyMap.containsKey(exKey)){
                            monthlyMap.put(exKey,new Monthly_Performance__c(
                                External_ID__c = exKey,
                                Name = monthList.get(eachCallreport.Actual_Visit_Date__c.month()-1) +' '+currentInYear,
                                User__c = eachCallreport.Current_Owner_Extension__c,
                                //Team__c = eachCallreport.Current_Owner_Extension__c.Team_Structure__c,
                                Call_Report__c = 0,
                                Call_Report_Customer_Port__c = 0,
                                Call_Report_Customer_Pool__c = 0,
                                Call_Report_Customer_Others__c = 0,
                                Call_Report_for_Sales__c = 0,
                                Call_Report_for_Relationship__c = 0,
                                Face_to_Face__c = 0,
                                Phone_Call__c = 0,
                                Total_visited_Customer__c = 0,
                                //Total_Call_Report__c = 0,
                                //Total_Face_to_Face_Call__c = 0,
                                //Total_Sales_Relationship__c = 0,
                                Contacted_Customer_Other__c = 0,
                                Contacted_Customer_Pool__c = 0,
                                Contacted_Customer_Port__c = 0,
                                Customer_Other__c = 0,
                                Customer_Pool__c = 0,
                                Customer_Port__c = 0,
                                Contacted_Customer_Other_My_Penetrate__c = 0,
                                Contacted_Customer_Pool_My_Penetrate__c = 0,
                                Contacted_Customer_Port_My_Penetrate__c = 0,
                                //Total_Contacted_Customer_Port_Pool_Other__c = 0,
                                //Total_Customer__c = 0,
                                Date__c = Date.newInstance(eachCallreport.Actual_Visit_Date__c.year(), eachCallreport.Actual_Visit_Date__c.month(), numberOfDays)
                                //Months__c = eachCallreport.Actual_Visit_Date__c.month()
                            ));
                        }
                        if(!monthlyMap.containsKey(teamKey)){
                            monthlyMap.put(teamKey,new Monthly_Performance__c(
                                External_ID__c = teamKey,
                                Name = monthList.get(eachCallreport.Actual_Visit_Date__c.month()-1) +' '+currentInYear,
                                //User__c = eachCallreport.Current_Owner_Extension__c,
                                Team__c = eachCallreport.Current_Owner_Extension__r.Team_Structure__c,
                                Call_Report__c = 0,
                                Call_Report_Customer_Port__c = 0,
                                Call_Report_Customer_Pool__c = 0,
                                Call_Report_Customer_Others__c = 0,
                                Call_Report_for_Sales__c = 0,
                                Call_Report_for_Relationship__c = 0,
                                Face_to_Face__c = 0,
                                Phone_Call__c = 0,
                                Total_visited_Customer__c = 0,
                                //Total_Call_Report__c = 0,
                                //Total_Face_to_Face_Call__c = 0,
                                //Total_Sales_Relationship__c = 0,
                                Contacted_Customer_Other__c = 0,
                                Contacted_Customer_Pool__c = 0,
                                Contacted_Customer_Port__c = 0,
                                Customer_Other__c = 0,
                                Customer_Pool__c = 0,
                                Customer_Port__c = 0,
                                Contacted_Customer_Other_My_Penetrate__c = 0,
                                Contacted_Customer_Pool_My_Penetrate__c = 0,
                                Contacted_Customer_Port_My_Penetrate__c = 0,
                                //Total_Contacted_Customer_Port_Pool_Other__c = 0,
                                //Total_Customer__c = 0,
                                Date__c = Date.newInstance(eachCallreport.Actual_Visit_Date__c.year(), eachCallreport.Actual_Visit_Date__c.month(), numberOfDays),
                                Months__c = eachCallreport.Actual_Visit_Date__c.month()
                            ));
                        }


                        //stamp by ext
                        if(monthlyMap.containsKey(exKey))
                            this.stampingMonthly(eachCallreport,monthlyMap.get(exKey));
                        //stamp by team
                        exKey = teamStrucObj.RC_Code__c + ' ' + eachCallreport.Actual_Visit_Date__c.month() + ' ' + currentInYear;
                        if(monthlyMap.containsKey(exKey))
                            this.stampingMonthly(eachCallreport,monthlyMap.get(exKey));

                        //team section
                        //loglist.add(new Application_Log__c(Source__c='SME_Performance_Batch',Message__c='teamStrucObj ' + teamStrucObj)); 
                        if(teamStrucObj.AH_Name__c!=null){
                            exKey = teamStrucObj.AH_RC_Code__c + ' ' + eachCallreport.Actual_Visit_Date__c.month() + ' ' + currentInYear;
                            //addLog('SME_Performance_Batch', 'exKey '+exKey);
                            //system.debug('ah exKey '+exKey);
                            if(!monthlyMap.containsKey(exKey)){
                                monthlyMap.put(exKey,new Monthly_Performance__c(
                                    External_ID__c = exKey,
                                    Name = monthList.get(eachCallreport.Actual_Visit_Date__c.month()-1) +' '+currentInYear,
                                    //User__c = eachCallreport.Current_Owner_Extension__c,
                                    Team__c = teamStrucObj.AH_Name__c,
                                    Call_Report__c = 0,
                                    Call_Report_Customer_Port__c = 0,
                                    Call_Report_Customer_Pool__c = 0,
                                    Call_Report_Customer_Others__c = 0,
                                    Call_Report_for_Sales__c = 0,
                                    Call_Report_for_Relationship__c = 0,
                                    Face_to_Face__c = 0,
                                    Phone_Call__c = 0,
                                    Total_visited_Customer__c = 0,
                                    Contacted_Customer_Other__c = 0,
                                    Contacted_Customer_Pool__c = 0,
                                    Contacted_Customer_Port__c = 0,
                                    Customer_Other__c = 0,
                                    Customer_Pool__c = 0,
                                    Customer_Port__c = 0,
                                    Contacted_Customer_Other_My_Penetrate__c = 0,
                                    Contacted_Customer_Pool_My_Penetrate__c = 0,
                                    Contacted_Customer_Port_My_Penetrate__c = 0,
                                    Date__c = Date.newInstance(eachCallreport.Actual_Visit_Date__c.year(), eachCallreport.Actual_Visit_Date__c.month(), numberOfDays),
                                    Months__c = eachCallreport.Actual_Visit_Date__c.month()
                                ));
                            }
                            if(monthlyMap.containsKey(exKey))
                                this.stampingMonthly(eachCallreport,monthlyMap.get(exKey));
                        }

                        if(teamStrucObj.NH_Name__c!=null){
                            exKey = teamStrucObj.NH_RC_Code__c + ' ' + eachCallreport.Actual_Visit_Date__c.month() + ' ' + currentInYear;

                            if(!monthlyMap.containsKey(exKey)){
                                monthlyMap.put(exKey,new Monthly_Performance__c(
                                    External_ID__c = exKey,
                                    Name = monthList.get(eachCallreport.Actual_Visit_Date__c.month()-1) +' '+currentInYear,
                                    //User__c = eachCallreport.Current_Owner_Extension__c,
                                    Team__c = teamStrucObj.NH_Name__c,
                                    Call_Report__c = 0,
                                    Call_Report_Customer_Port__c = 0,
                                    Call_Report_Customer_Pool__c = 0,
                                    Call_Report_Customer_Others__c = 0,
                                    Call_Report_for_Sales__c = 0,
                                    Call_Report_for_Relationship__c = 0,
                                    Face_to_Face__c = 0,
                                    Phone_Call__c = 0,
                                    Total_visited_Customer__c = 0,
                                    Contacted_Customer_Other__c = 0,
                                    Contacted_Customer_Pool__c = 0,
                                    Contacted_Customer_Port__c = 0,
                                    Customer_Other__c = 0,
                                    Customer_Pool__c = 0,
                                    Customer_Port__c = 0,
                                    Contacted_Customer_Other_My_Penetrate__c = 0,
                                    Contacted_Customer_Pool_My_Penetrate__c = 0,
                                    Contacted_Customer_Port_My_Penetrate__c = 0,
                                    Date__c = Date.newInstance(eachCallreport.Actual_Visit_Date__c.year(), eachCallreport.Actual_Visit_Date__c.month(), numberOfDays),
                                    Months__c = eachCallreport.Actual_Visit_Date__c.month()
                                ));
                            }
                            
                            if(monthlyMap.containsKey(exKey))
                                this.stampingMonthly(eachCallreport,monthlyMap.get(exKey));
                        }

                    }else{
                        eachCallreport.Completed__c = true; // flag
                        userExtObj.Call_Report__c = (userExtObj.Call_Report__c!=null)?userExtObj.Call_Report__c+1:1;
                        teamStrucObj.Call_Report__c = (teamStrucObj.Call_Report__c!=null)?teamStrucObj.Call_Report__c+1:1;

                        if(eachCallreport.Port_Pool__c == 'Port'){
                            userExtObj.Call_Report_Customer_Port__c = (userExtObj.Call_Report_Customer_Port__c!=null)?userExtObj.Call_Report_Customer_Port__c+1:1;
                            teamStrucObj.Call_Report_Customer_Port__c = (teamStrucObj.Call_Report_Customer_Port__c!=null)?teamStrucObj.Call_Report_Customer_Port__c+1:1;
                            
                        }else if(eachCallreport.Port_Pool__c == 'Pool'){
                            userExtObj.Call_Report_Customer_Pool__c = (userExtObj.Call_Report_Customer_Pool__c!=null)?userExtObj.Call_Report_Customer_Pool__c+1:1;
                            teamStrucObj.Call_Report_Customer_Pool__c = (teamStrucObj.Call_Report_Customer_Pool__c!=null)?teamStrucObj.Call_Report_Customer_Pool__c+1:1;
                            
                        }else if(eachCallreport.Port_Pool__c == null && (eachCallreport.Ownership__c==null || eachCallreport.Ownership__c=='' || eachCallreport.Ownership__c=='Temporary')){
                            userExtObj.Call_Report_Customer_Others__c = (userExtObj.Call_Report_Customer_Others__c!=null)?userExtObj.Call_Report_Customer_Others__c+1:1;
                            teamStrucObj.Call_Report_Customer_Others__c = (teamStrucObj.Call_Report_Customer_Others__c!=null)?teamStrucObj.Call_Report_Customer_Others__c+1:1;
                        }

                        //if(eachCallreport.Visit_Objective__c=='Sell'){
                        if(eachCallreport.Offer_Credit_Product__c || eachCallreport.Collect_Documents__c || eachCallreport.Negotiation__c){

                            userExtObj.Call_Report_for_Sales__c = (userExtObj.Call_Report_for_Sales__c!=null)?userExtObj.Call_Report_for_Sales__c+1:1;
                            teamStrucObj.Call_Report_for_Sales__c = (teamStrucObj.Call_Report_for_Sales__c!=null)?teamStrucObj.Call_Report_for_Sales__c+1:1;
                          
                        //}else if(eachCallreport.Visit_Objective__c=='Relationship'){
                        }
                        else if(eachCallreport.Pain__c || eachCallreport.Servicing__c || eachCallreport.Customer_Insight__c || eachCallreport.Non_Credit__c || eachCallreport.No_Change__c){
                            userExtObj.Call_Report_for_Relationship__c = (userExtObj.Call_Report_for_Relationship__c!=null)?userExtObj.Call_Report_for_Relationship__c+1:1;
                            teamStrucObj.Call_Report_for_Relationship__c = (teamStrucObj.Call_Report_for_Relationship__c!=null)?teamStrucObj.Call_Report_for_Relationship__c+1:1;
                        }
                        
                        if(eachCallreport.Contact_Channel__c=='Face to Face'){
                            userExtObj.Face_to_Face__c = (userExtObj.Face_to_Face__c!=null)?userExtObj.Face_to_Face__c+1:1;
                            teamStrucObj.Face_to_Face__c = (teamStrucObj.Face_to_Face__c!=null)?teamStrucObj.Face_to_Face__c+1:1;
                        }else if(eachCallreport.Contact_Channel__c=='Phone Call'){
                            userExtObj.Phone_Call__c = (userExtObj.Phone_Call__c!=null)?userExtObj.Phone_Call__c+1:1;
                            teamStrucObj.Phone_Call__c = (teamStrucObj.Phone_Call__c!=null)?teamStrucObj.Phone_Call__c+1:1;
                        }
                    }
                }
            }
        }

        if(!initialMonthly){
            
            TriggerHandler.bypass('CallReportTriggerHandler');
            update callreportList;
        }
    }
    private void stampingMonthly(Call_Report__c callReport,Monthly_Performance__c monthlyObj){
        monthlyObj.Call_Report__c++;
        if(callReport.Port_Pool__c == 'Port'){
            monthlyObj.Call_Report_Customer_Port__c += 1;
        }else if(callReport.Port_Pool__c == 'Pool'){
            monthlyObj.Call_Report_Customer_Pool__c += 1;
        }else if(callReport.Port_Pool__c == null && (callReport.Ownership__c==null || callReport.Ownership__c=='' || callReport.Ownership__c=='Temporary')){
            monthlyObj.Call_Report_Customer_Others__c += 1;
        }

        //if(callReport.Visit_Objective__c=='Sell'){
        if(callReport.Offer_Credit_Product__c || callReport.Collect_Documents__c || callReport.Negotiation__c){
            monthlyObj.Call_Report_for_Sales__c += 1;
        //}else if(callReport.Visit_Objective__c=='Relationship'){
        }
        else if(callReport.Pain__c || callReport.Servicing__c || callReport.Customer_Insight__c || callReport.Non_Credit__c || callReport.No_Change__c){
            monthlyObj.Call_Report_for_Relationship__c += 1;
        }
        
        if(callReport.Contact_Channel__c=='Face to Face'){
            monthlyObj.Face_to_Face__c += 1;
        }else if(callReport.Contact_Channel__c=='Phone Call'){
            monthlyObj.Phone_Call__c += 1;
        }
    }
    global void finish(Database.BatchableContext BC) {
        if(runMontly){
            String exKey;
            String teamKey;
            for(User_Extension__c eachExt : userExMap.values()){
                exKey = eachExt.User__r.Employee_Id__c + ' ' + todayDateFromNow.month() + ' ' + currentYear;
                teamKey = eachExt.User__r.RC_Code__c + ' ' + todayDateFromNow.month() + ' ' + currentYear;
                if(monthlyMap.containsKey(exKey)){
                    monthlyMap.get(exKey).Number_of_RM_under_Team__c = eachExt.Number_of_RM_under_Team__c;
                }
                if(monthlyMap.containsKey(teamKey))
                    monthlyMap.get(teamKey).Number_of_RM_under_Team__c = eachExt.Number_of_RM_under_Team__c;
            }
            //upsert monthlyMap.values() External_ID__c;
        }else{
            for(Team_Structure__c eachTeam : teamMap.values()){
                if(eachTeam.NH_Name__c!=null){
                    teamMap.get(eachTeam.NH_Name__c).Call_Report__c = 0;
                    teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Port__c = 0;
                    teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Pool__c = 0;
                    teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Others__c = 0;
                    teamMap.get(eachTeam.NH_Name__c).Call_Report_for_Sales__c = 0;
                    teamMap.get(eachTeam.NH_Name__c).Call_Report_for_Relationship__c = 0;
                    teamMap.get(eachTeam.NH_Name__c).Face_to_Face__c = 0;
                    teamMap.get(eachTeam.NH_Name__c).Phone_Call__c = 0;
                }
                if(eachTeam.AH_Name__c!=null){
                    teamMap.get(eachTeam.AH_Name__c).Call_Report__c = 0;
                    teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Port__c = 0;
                    teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Pool__c = 0;
                    teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Others__c = 0;
                    teamMap.get(eachTeam.AH_Name__c).Call_Report_for_Sales__c = 0;
                    teamMap.get(eachTeam.AH_Name__c).Call_Report_for_Relationship__c = 0;
                    teamMap.get(eachTeam.AH_Name__c).Face_to_Face__c = 0;
                    teamMap.get(eachTeam.AH_Name__c).Phone_Call__c = 0;
                }
            }
            for(Team_Structure__c eachTeam : teamMap.values()){
                if(eachTeam.NH_Name__c!=null){
                    teamMap.get(eachTeam.NH_Name__c).Call_Report__c = (teamMap.get(eachTeam.NH_Name__c).Call_Report__c!=null)?teamMap.get(eachTeam.NH_Name__c).Call_Report__c+eachTeam.Call_Report__c:1;
                    teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Port__c = (teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Port__c!=null)?teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Port__c+eachTeam.Call_Report_Customer_Port__c:1;
                    teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Pool__c = (teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Pool__c!=null)?teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Pool__c+eachTeam.Call_Report_Customer_Pool__c:1;
                    teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Others__c = (teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Others__c!=null)?teamMap.get(eachTeam.NH_Name__c).Call_Report_Customer_Others__c+eachTeam.Call_Report_Customer_Others__c:1;
                    teamMap.get(eachTeam.NH_Name__c).Call_Report_for_Sales__c = (teamMap.get(eachTeam.NH_Name__c).Call_Report_for_Sales__c!=null)?teamMap.get(eachTeam.NH_Name__c).Call_Report_for_Sales__c+eachTeam.Call_Report_for_Sales__c:1;
                    teamMap.get(eachTeam.NH_Name__c).Call_Report_for_Relationship__c = (teamMap.get(eachTeam.NH_Name__c).Call_Report_for_Relationship__c!=null)?teamMap.get(eachTeam.NH_Name__c).Call_Report_for_Relationship__c+eachTeam.Call_Report_for_Relationship__c:1;
                    teamMap.get(eachTeam.NH_Name__c).Face_to_Face__c = (teamMap.get(eachTeam.NH_Name__c).Face_to_Face__c!=null)?teamMap.get(eachTeam.NH_Name__c).Face_to_Face__c+eachTeam.Face_to_Face__c:1;
                    teamMap.get(eachTeam.NH_Name__c).Phone_Call__c = (teamMap.get(eachTeam.NH_Name__c).Phone_Call__c!=null)?teamMap.get(eachTeam.NH_Name__c).Phone_Call__c+eachTeam.Phone_Call__c:1;
                }
            }

            for(Team_Structure__c eachTeam : teamMap.values()){
                if(eachTeam.AH_Name__c!=null){
                    teamMap.get(eachTeam.AH_Name__c).Call_Report__c = (teamMap.get(eachTeam.AH_Name__c).Call_Report__c!=null)?teamMap.get(eachTeam.AH_Name__c).Call_Report__c+eachTeam.Call_Report__c:1;
                    teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Port__c = (teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Port__c!=null)?teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Port__c+eachTeam.Call_Report_Customer_Port__c:1;
                    teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Pool__c = (teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Pool__c!=null)?teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Pool__c+eachTeam.Call_Report_Customer_Pool__c:1;
                    teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Others__c = (teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Others__c!=null)?teamMap.get(eachTeam.AH_Name__c).Call_Report_Customer_Others__c+eachTeam.Call_Report_Customer_Others__c:1;
                    teamMap.get(eachTeam.AH_Name__c).Call_Report_for_Sales__c = (teamMap.get(eachTeam.AH_Name__c).Call_Report_for_Sales__c!=null)?teamMap.get(eachTeam.AH_Name__c).Call_Report_for_Sales__c+eachTeam.Call_Report_for_Sales__c:1;
                    teamMap.get(eachTeam.AH_Name__c).Call_Report_for_Relationship__c = (teamMap.get(eachTeam.AH_Name__c).Call_Report_for_Relationship__c!=null)?teamMap.get(eachTeam.AH_Name__c).Call_Report_for_Relationship__c+eachTeam.Call_Report_for_Relationship__c:1;
                    teamMap.get(eachTeam.AH_Name__c).Face_to_Face__c = (teamMap.get(eachTeam.AH_Name__c).Face_to_Face__c!=null)?teamMap.get(eachTeam.AH_Name__c).Face_to_Face__c+eachTeam.Face_to_Face__c:1;
                    teamMap.get(eachTeam.AH_Name__c).Phone_Call__c = (teamMap.get(eachTeam.AH_Name__c).Phone_Call__c!=null)?teamMap.get(eachTeam.AH_Name__c).Phone_Call__c+eachTeam.Phone_Call__c:1;
                }
            }


            update userExMap.values();
            update teamMap.values();//need change
        }

        if(!runMontly && shouldRunMontly){
            Performance_Config__c perfConfig = Performance_Config__c.getOrgDefaults();
                //specific day
            
            if((perfConfig.Date__c != null && todayDateFromNow.day() == perfConfig.Date__c) || 
                (perfConfig.Date__c==null && todayDateFromNow.day() == todayDateFromNow.addMonths(1).toStartofMonth().addDays(-1).day()))
                Database.executeBatch(new SME_Performance_Batch().setResetStatement(resetStatement).runMontly(false).runSummaryAtTheEnd());
            else Database.executeBatch(new SME_Performance_All_Batch());
        }
        if(runSummaryAtTheEnd) Database.executeBatch(new SME_Performance_All_Batch().runMontly(monthlyMap,resetStatement,initialMonthly));
    }
}