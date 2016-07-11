global with sharing class SME_Performance_Util {
    private List<Call_Report__c> callReportList;
    private Map<String,String> callReportMapOwner;
    private Map<String,List<String>> userExIdMapTeam;
    private Map<String,User_Extension__c> userExMap;
    private Map<String,Team_Structure__c> teamMap;
    private Map<String,User_Extension__c> userMapExt;
    private Map<String,Monthly_Performance__c> monthlyMap;
    private Boolean runMontly = false;

    private Date todayDateFromNow;
    private Integer currentYear;

    global SME_Performance_Util(Map<String,User_Extension__c> userExMap,Map<String,Team_Structure__c> teamMap){
        this.callReportMapOwner = new Map<String,String>();
        this.userExMap = userExMap;
        this.teamMap = teamMap;
        //this.mappingTeam();
        this.mappingUser();
        this.initialValue();

        DateTime dT = System.now();
        todayDateFromNow = date.newinstance(dT.year(), dT.month(), dT.day());
        currentYear = (todayDateFromNow.year()<2500)?todayDateFromNow.year()+543:todayDateFromNow.year();
    }
    private void mappingUser(){
        userMapExt = new Map<String,User_Extension__c>();
        for(User_Extension__c eachExt : userExMap.values()){
            userMapExt.put(eachExt.User__c, eachExt);
        }
    }
    private void initialValue(){
        
        for(User_Extension__c eachExt : userExMap.values()){
            eachExt.Contacted_Customer_Other__c = 0;
            eachExt.Contacted_Customer_Pool__c = 0;
            eachExt.Contacted_Customer_Port__c = 0;
            eachExt.Customer_Other__c = 0;
            eachExt.Customer_Pool__c = 0;
            eachExt.Customer_Port__c = 0;
            eachExt.Total_visited_Customer__c = 0;
            eachExt.Contacted_Customer_Other_My_Penetrate__c = 0;
            eachExt.Contacted_Customer_Pool_My_Penetrate__c = 0;
            eachExt.Contacted_Customer_Port_My_Penetrate__c = 0;
        }
        for(Team_Structure__c eachStructure : teamMap.values()){
            eachStructure.Contacted_Customer_Other__c = 0;
            eachStructure.Contacted_Customer_Pool__c = 0;
            eachStructure.Contacted_Customer_Port__c = 0;
            eachStructure.Customer_Other__c = 0;
            eachStructure.Customer_Pool__c = 0;
            eachStructure.Customer_Port__c = 0;
            eachStructure.Total_visited_Customer__c = 0;
            eachStructure.Contacted_Customer_Other_My_Penetrate__c = 0;
            eachStructure.Contacted_Customer_Pool_My_Penetrate__c = 0;
            eachStructure.Contacted_Customer_Port_My_Penetrate__c = 0;
        }
    }
    public void setCallReportList(List<Call_Report__c> callReportList){
        this.callReportList = callReportList;
        this.mappingOwner();
    }
    public void setMonthlyMap(Map<String,Monthly_Performance__c> monthly_Map){
        this.runMontly = true;
        this.monthlyMap = monthly_Map;
        String exKey;
        for(Team_Structure__c eachStructure : teamMap.values()){
            exKey = eachStructure.RC_Code__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;
            if(monthlyMap.containsKey(exKey)){
                monthlyMap.get(exKey).Contacted_Customer_Other__c = 0;
                monthlyMap.get(exKey).Contacted_Customer_Pool__c = 0;
                monthlyMap.get(exKey).Contacted_Customer_Port__c = 0;
                monthlyMap.get(exKey).Customer_Other__c = 0;
                monthlyMap.get(exKey).Customer_Pool__c = 0;
                monthlyMap.get(exKey).Customer_Port__c = 0;
                monthlyMap.get(exKey).Total_visited_Customer__c = 0;
                monthlyMap.get(exKey).Contacted_Customer_Other_My_Penetrate__c = 0;
                monthlyMap.get(exKey).Contacted_Customer_Pool_My_Penetrate__c = 0;
                monthlyMap.get(exKey).Contacted_Customer_Port_My_Penetrate__c = 0;
            }

            if(eachStructure.AH_Name__c!=null){
                exKey = eachStructure.AH_Name__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;
                if(monthlyMap.containsKey(exKey)){
                    monthlyMap.get(exKey).Contacted_Customer_Other__c = 0;
                    monthlyMap.get(exKey).Contacted_Customer_Pool__c = 0;
                    monthlyMap.get(exKey).Contacted_Customer_Port__c = 0;
                    monthlyMap.get(exKey).Customer_Other__c = 0;
                    monthlyMap.get(exKey).Customer_Pool__c = 0;
                    monthlyMap.get(exKey).Customer_Port__c = 0;
                    monthlyMap.get(exKey).Total_visited_Customer__c = 0;
                    monthlyMap.get(exKey).Contacted_Customer_Other_My_Penetrate__c = 0;
                    monthlyMap.get(exKey).Contacted_Customer_Pool_My_Penetrate__c = 0;
                    monthlyMap.get(exKey).Contacted_Customer_Port_My_Penetrate__c = 0;
                }
            }
            if(eachStructure.NH_Name__c!=null){
                exKey = eachStructure.NH_Name__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;
                if(monthlyMap.containsKey(exKey)){
                    monthlyMap.get(exKey).Contacted_Customer_Other__c = 0;
                    monthlyMap.get(exKey).Contacted_Customer_Pool__c = 0;
                    monthlyMap.get(exKey).Contacted_Customer_Port__c = 0;
                    monthlyMap.get(exKey).Customer_Other__c = 0;
                    monthlyMap.get(exKey).Customer_Pool__c = 0;
                    monthlyMap.get(exKey).Customer_Port__c = 0;
                    monthlyMap.get(exKey).Total_visited_Customer__c = 0;
                    monthlyMap.get(exKey).Contacted_Customer_Other_My_Penetrate__c = 0;
                    monthlyMap.get(exKey).Contacted_Customer_Pool_My_Penetrate__c = 0;
                    monthlyMap.get(exKey).Contacted_Customer_Port_My_Penetrate__c = 0;
                }
                
            }
        }
    }
    public Map<String,User_Extension__c> getUserExt(){
        return this.userMapExt;
    }
    public List<User_Extension__c> getFinalUserExt(){
        return this.userMapExt.values();
    }
    public List<Team_Structure__c> getFinalTeam(){
        return this.teamMap.values();
    }
    public List<Monthly_Performance__c> getMonthly(){
        return this.monthlyMap.values();
    }
    private void mappingOwner(){
        for(Call_Report__c eachCallReport : callReportList){
            if(eachCallReport.CIS_ID__c!=null && eachCallReport.CIS_ID__r.OwnerId==eachCallReport.Current_Owner_Extension__r.User__c && !callReportMapOwner.containsKey(eachCallReport.CIS_ID__c+''+eachCallReport.CIS_ID__r.OwnerId+''+eachCallReport.Current_Owner_Extension__c))
                callReportMapOwner.put(eachCallReport.CIS_ID__c+''+eachCallReport.CIS_ID__r.OwnerId+''+eachCallReport.Current_Owner_Extension__c,'');
        }
    }
    private void mappingTeam(){
        userExIdMapTeam = new Map<String,List<String>>();
        for(User_Extension__c eachExt : userExMap.values()){
            if(!userExIdMapTeam.containsKey(eachExt.Team_Structure__c))
                userExIdMapTeam.put(eachExt.Team_Structure__c,new List<String>());
            userExIdMapTeam.get(eachExt.Team_Structure__c).add(eachExt.Id);

            if(teamMap.get(eachExt.Team_Structure__c).AH_Name__c!=null){
                if(! userExIdMapTeam.containsKey(teamMap.get(eachExt.Team_Structure__c).AH_Name__c))
                    userExIdMapTeam.put(teamMap.get(eachExt.Team_Structure__c).AH_Name__c,new List<String>());
            
                userExIdMapTeam.get(teamMap.get(eachExt.Team_Structure__c).AH_Name__c).add(eachExt.Id);
            }

            if(teamMap.get(eachExt.Team_Structure__c).NH_Name__c!=null){
                if(! userExIdMapTeam.containsKey(teamMap.get(eachExt.Team_Structure__c).NH_Name__c))
                    userExIdMapTeam.put(teamMap.get(eachExt.Team_Structure__c).NH_Name__c,new List<String>());
            
                userExIdMapTeam.get(teamMap.get(eachExt.Team_Structure__c).NH_Name__c).add(eachExt.Id);
            }
            
        }
    }

    public void executeAccount(Account accountObj,Boolean runMontly){
        String exKey;
        User_Extension__c userExtObj;
        Team_Structure__c teamStrucObj;
        userExtObj = userMapExt.get(accountObj.OwnerId);
        teamStrucObj = teamMap.get(userExtObj.Team_Structure__c);
                
        if(runMontly){
            exKey = userExtObj.User__r.Employee_Id__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;

            if(monthlyMap.containsKey(exKey) && monthlyMap.get(exKey).User__c!=null){
                if(accountObj.Service_RM__c!=null && accountObj.Service_RM__c!=accountObj.OwnerId && (accountObj.Service_RM__r.RC_Code__c==accountObj.Owner.RC_Code__c || accountObj.Owner.Profile.Name==GlobalConstants.SME_AH || accountObj.Owner.Profile.Name==GlobalConstants.SME_NH) && accountObj.Owner.Profile.Name!=GlobalConstants.SME_RM)
                    this.stampingMonthly(accountObj,monthlyMap.get(exKey),monthlyMap.get(userMapExt.get(accountObj.Service_RM__c).User__r.Employee_Id__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear));
                else this.stampingMonthly(accountObj,monthlyMap.get(exKey),null);
            }
        }

  //          if(accountObj.Service_RM__c!=null && accountObj.Service_RM__c!=accountObj.OwnerId && (accountObj.Service_RM__r.RC_Code__c==accountObj.Owner.RC_Code__c || accountObj.Owner.Profile.Name==GlobalConstants.SME_AH || accountObj.Owner.Profile.Name==GlobalConstants.SME_NH)){
  //            exKey = teamMap.get(userMapExt.get(accountObj.Service_RM__c).Team_Structure__c).RC_Code__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;
  //            if(monthlyMap.containsKey(exKey))
  //                  this.stampingMonthly(accountObj,monthlyMap.get(exKey),null);

  //                  if(teamMap.get(userMapExt.get(accountObj.Service_RM__c).Team_Structure__c).AH_Name__c!=null){
  //                      exKey = teamMap.get(userMapExt.get(accountObj.Service_RM__c).Team_Structure__c).AH_RC_Code__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;
  //                      if(monthlyMap.containsKey(exKey))
  //                          this.stampingMonthly(accountObj,monthlyMap.get(exKey),null);
  //                  }

  //                  if(teamMap.get(userMapExt.get(accountObj.Service_RM__c).Team_Structure__c).NH_Name__c!=null){
  //                      exKey = teamMap.get(userMapExt.get(accountObj.Service_RM__c).Team_Structure__c).NH_RC_Code__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;
  //                      if(monthlyMap.containsKey(exKey))
  //                          this.stampingMonthly(accountObj,monthlyMap.get(exKey),null);
  //                  }
                
  //          }else{
  //              exKey = teamStrucObj.RC_Code__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;
  //              if(monthlyMap.containsKey(exKey))
  //                  this.stampingMonthly(accountObj,monthlyMap.get(exKey),null);

  //                  if(teamStrucObj.AH_Name__c!=null){
  //                      exKey = teamStrucObj.AH_RC_Code__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;
  //                      if(monthlyMap.containsKey(exKey))
  //                          this.stampingMonthly(accountObj,monthlyMap.get(exKey),null);
  //                  }

  //                  if(teamStrucObj.NH_Name__c!=null){
  //                      exKey = teamStrucObj.NH_RC_Code__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;
  //                      if(monthlyMap.containsKey(exKey))
  //                          this.stampingMonthly(accountObj,monthlyMap.get(exKey),null);
  //                  }
                
  //          }
        //}

        if(accountObj.Count_Contacted_Call_Report__c > 0 && accountObj.Number_of_Visited__c!=null && accountObj.Number_of_Visited__c > 0){
            userExtObj.Total_visited_Customer__c++;
            teamStrucObj.Total_visited_Customer__c++;
        }

        if(accountObj.Port_Pool__c=='Port' && accountObj.Ownership__c=='Permanent'){
            userExtObj.Customer_Port__c++;
            teamStrucObj.Customer_Port__c++;
            if(accountObj.Count_Contacted_Call_Report__c > 0){
                userExtObj.Contacted_Customer_Port__c++;
                teamStrucObj.Contacted_Customer_Port__c++;

                if(callReportMapOwner.containsKey(accountObj.Id+''+accountObj.OwnerId+''+userExtObj.Id)){
                    userExtObj.Contacted_Customer_Port_My_Penetrate__c++;
                    teamStrucObj.Contacted_Customer_Port_My_Penetrate__c++;
                }
            }
        }
        //if(accountObj.Port_Pool__c=='Pool' && ((accountObj.Owner.Profile.Name==GlobalConstants.SME_TM && accountObj.Service_RM__c!=null && accountObj.Service_RM__r.Profile.Name==GlobalConstants.SME_RM && accountObj.Ownership__c=='Permanent') || ((accountObj.Owner.Profile.Name==GlobalConstants.SME_RM || accountObj.Owner.Profile.Name==GlobalConstants.SME_TM) && accountObj.Ownership__c=='Temporary'))){
        if(accountObj.Port_Pool__c=='Pool' && (accountObj.Owner.Profile.Name==GlobalConstants.SME_TM || accountObj.Owner.Profile.Name==GlobalConstants.SME_AH || accountObj.Owner.Profile.Name==GlobalConstants.SME_NH || (accountObj.Owner.Profile.Name==GlobalConstants.SME_RM && accountObj.Ownership__c=='Temporary'))){
            
            if(accountObj.Service_RM__c!=null && accountObj.Service_RM__c!=accountObj.OwnerId && (accountObj.Service_RM__r.RC_Code__c==accountObj.Owner.RC_Code__c || accountObj.Owner.Profile.Name==GlobalConstants.SME_AH || accountObj.Owner.Profile.Name==GlobalConstants.SME_NH) && accountObj.Owner.Profile.Name!=GlobalConstants.SME_RM){
                userMapExt.get(accountObj.Service_RM__c).Customer_Pool__c++;
                teamMap.get(userMapExt.get(accountObj.Service_RM__c).Team_Structure__c).Customer_Pool__c++;
            }else {
                userExtObj.Customer_Pool__c++;
                teamStrucObj.Customer_Pool__c++;
            }

            if(accountObj.Count_Contacted_Call_Report__c > 0){
                //if(userMapExt.get(accountObj.Service_RM__c)==null && accountObj.Count_Call_Report_RM__c == 0){
    //                userExtObj.Contacted_Customer_Pool__c++;
    //              teamStrucObj.Contacted_Customer_Pool__c++;
    //            }

    //            if(callReportMapOwner.containsKey(accountObj.Id+''+accountObj.OwnerId+''+userExtObj.Id) && accountObj.Count_Call_Report_RM__c == 0){
    //                userExtObj.Contacted_Customer_Pool_My_Penetrate__c++;
    //                teamStrucObj.Contacted_Customer_Pool_My_Penetrate__c++;
    //            }

    //            if(accountObj.Service_RM__c!=null && accountObj.Service_RM__c!=accountObj.OwnerId && (accountObj.Service_RM__r.RC_Code__c==accountObj.Owner.RC_Code__c || accountObj.Owner.Profile.Name==GlobalConstants.SME_AH || accountObj.Owner.Profile.Name==GlobalConstants.SME_NH) && accountObj.Count_Call_Report_RM__c > 0){
                //  userMapExt.get(accountObj.Service_RM__c).Contacted_Customer_Pool__c++;
                //  teamMap.get(userMapExt.get(accountObj.Service_RM__c).Team_Structure__c).Contacted_Customer_Pool__c++;
                    
    //                if(callReportMapOwner.containsKey(accountObj.Id+''+accountObj.OwnerId+''+userExtObj.Id)){
    //                    userMapExt.get(accountObj.Service_RM__c).Contacted_Customer_Pool_My_Penetrate__c++;
    //                    teamMap.get(userMapExt.get(accountObj.Service_RM__c).Team_Structure__c).Contacted_Customer_Pool_My_Penetrate__c++;
    //                }
                //}else{
    //                userExtObj.Contacted_Customer_Pool__c++;
    //                teamStrucObj.Contacted_Customer_Pool__c++;
    //            }



                if(accountObj.Service_RM__c!=null && accountObj.Service_RM__c!=accountObj.OwnerId && (accountObj.Service_RM__r.RC_Code__c==accountObj.Owner.RC_Code__c || accountObj.Owner.Profile.Name==GlobalConstants.SME_AH || accountObj.Owner.Profile.Name==GlobalConstants.SME_NH) && accountObj.Count_Call_Report_RM__c > 0 && accountObj.Owner.Profile.Name!=GlobalConstants.SME_RM){
                    userMapExt.get(accountObj.Service_RM__c).Contacted_Customer_Pool__c++;
                    teamMap.get(userMapExt.get(accountObj.Service_RM__c).Team_Structure__c).Contacted_Customer_Pool__c++;
                }else {
                    userExtObj.Contacted_Customer_Pool__c++;
                    teamStrucObj.Contacted_Customer_Pool__c++;
                }
                    if(callReportMapOwner.containsKey(accountObj.Id+''+accountObj.OwnerId+''+userExtObj.Id)){
                        if(accountObj.Service_RM__c!=null && accountObj.Service_RM__c!=accountObj.OwnerId && (accountObj.Service_RM__r.RC_Code__c==accountObj.Owner.RC_Code__c || accountObj.Owner.Profile.Name==GlobalConstants.SME_AH || accountObj.Owner.Profile.Name==GlobalConstants.SME_NH) && accountObj.Count_Call_Report_RM__c > 0 && accountObj.Owner.Profile.Name!=GlobalConstants.SME_RM){
                            userMapExt.get(accountObj.Service_RM__c).Contacted_Customer_Pool_My_Penetrate__c++;
                            teamMap.get(userMapExt.get(accountObj.Service_RM__c).Team_Structure__c).Contacted_Customer_Pool_My_Penetrate__c++;
                        }
                        else{
                            //monthlyObj.Contacted_Customer_Pool_My_Penetrate__c++;
                            userExtObj.Contacted_Customer_Pool_My_Penetrate__c++;
                            teamStrucObj.Contacted_Customer_Pool_My_Penetrate__c++;
                        }
                    }
                    
                
            }
        }
        if(accountObj.Port_Pool__c==null && ((accountObj.Ownership__c==null) || (accountObj.Ownership__c=='Temporary'))){
            userExtObj.Customer_Other__c++;
            teamStrucObj.Customer_Other__c++;
            if(accountObj.Count_Contacted_Call_Report__c > 0){
                userExtObj.Contacted_Customer_Other__c++;
                teamStrucObj.Contacted_Customer_Other__c++;

                if(callReportMapOwner.containsKey(accountObj.Id+''+accountObj.OwnerId+''+userExtObj.Id)){
                    userExtObj.Contacted_Customer_Other_My_Penetrate__c++;
                    teamStrucObj.Contacted_Customer_Other_My_Penetrate__c++;
                }
            }
        }
    }
    public void finalTeamTask(){
        
        for(Team_Structure__c eachTeam : teamMap.values()){
            if(eachTeam.NH_Name__c!=null){
                teamMap.get(eachTeam.NH_Name__c).Contacted_Customer_Other__c += eachTeam.Contacted_Customer_Other__c;
                teamMap.get(eachTeam.NH_Name__c).Contacted_Customer_Pool__c += eachTeam.Contacted_Customer_Pool__c;
                teamMap.get(eachTeam.NH_Name__c).Contacted_Customer_Port__c += eachTeam.Contacted_Customer_Port__c;
                teamMap.get(eachTeam.NH_Name__c).Customer_Other__c += eachTeam.Customer_Other__c;
                teamMap.get(eachTeam.NH_Name__c).Customer_Pool__c += eachTeam.Customer_Pool__c;
                teamMap.get(eachTeam.NH_Name__c).Customer_Port__c += eachTeam.Customer_Port__c;
                teamMap.get(eachTeam.NH_Name__c).Total_visited_Customer__c += eachTeam.Total_visited_Customer__c;
                teamMap.get(eachTeam.NH_Name__c).Contacted_Customer_Other_My_Penetrate__c += eachTeam.Contacted_Customer_Other_My_Penetrate__c;
                teamMap.get(eachTeam.NH_Name__c).Contacted_Customer_Pool_My_Penetrate__c += eachTeam.Contacted_Customer_Pool_My_Penetrate__c;
                teamMap.get(eachTeam.NH_Name__c).Contacted_Customer_Port_My_Penetrate__c += eachTeam.Contacted_Customer_Port_My_Penetrate__c;
            }
        }
        for(Team_Structure__c eachTeam : teamMap.values()){
            if(eachTeam.AH_Name__c!=null){
                teamMap.get(eachTeam.AH_Name__c).Contacted_Customer_Other__c += eachTeam.Contacted_Customer_Other__c;
                teamMap.get(eachTeam.AH_Name__c).Contacted_Customer_Pool__c += eachTeam.Contacted_Customer_Pool__c;
                teamMap.get(eachTeam.AH_Name__c).Contacted_Customer_Port__c += eachTeam.Contacted_Customer_Port__c;
                teamMap.get(eachTeam.AH_Name__c).Customer_Other__c += eachTeam.Customer_Other__c;
                teamMap.get(eachTeam.AH_Name__c).Customer_Pool__c += eachTeam.Customer_Pool__c;
                teamMap.get(eachTeam.AH_Name__c).Customer_Port__c += eachTeam.Customer_Port__c;
                teamMap.get(eachTeam.AH_Name__c).Total_visited_Customer__c += eachTeam.Total_visited_Customer__c;
                teamMap.get(eachTeam.AH_Name__c).Contacted_Customer_Other_My_Penetrate__c += eachTeam.Contacted_Customer_Other_My_Penetrate__c;
                teamMap.get(eachTeam.AH_Name__c).Contacted_Customer_Pool_My_Penetrate__c += eachTeam.Contacted_Customer_Pool_My_Penetrate__c;
                teamMap.get(eachTeam.AH_Name__c).Contacted_Customer_Port_My_Penetrate__c += eachTeam.Contacted_Customer_Port_My_Penetrate__c;
            }
        }



        if(runMontly){
            String exKey;
            for(Team_Structure__c eachTeam : teamMap.values()){
                exKey = eachTeam.RC_Code__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;
                if(monthlyMap.containsKey(exKey) && monthlyMap.get(exKey).Team__c!=null){
                    monthlyMap.get(exKey).Contacted_Customer_Other__c = eachTeam.Contacted_Customer_Other__c;
                    monthlyMap.get(exKey).Contacted_Customer_Pool__c = eachTeam.Contacted_Customer_Pool__c;
                    monthlyMap.get(exKey).Contacted_Customer_Port__c = eachTeam.Contacted_Customer_Port__c;
                    monthlyMap.get(exKey).Customer_Other__c = eachTeam.Customer_Other__c;
                    monthlyMap.get(exKey).Customer_Pool__c = eachTeam.Customer_Pool__c;
                    monthlyMap.get(exKey).Customer_Port__c = eachTeam.Customer_Port__c;
                    monthlyMap.get(exKey).Total_visited_Customer__c = eachTeam.Total_visited_Customer__c;
                    monthlyMap.get(exKey).Contacted_Customer_Other_My_Penetrate__c = eachTeam.Contacted_Customer_Other_My_Penetrate__c;
                    monthlyMap.get(exKey).Contacted_Customer_Pool_My_Penetrate__c = eachTeam.Contacted_Customer_Pool_My_Penetrate__c;
                    monthlyMap.get(exKey).Contacted_Customer_Port_My_Penetrate__c = eachTeam.Contacted_Customer_Port_My_Penetrate__c;
                }
            }
            //exKey = userExtObj.User__r.Employee_Id__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;

            //if(monthlyMap.containsKey(exKey)){
            //    if(accountObj.Service_RM__c!=null && accountObj.Service_RM__c!=accountObj.OwnerId && (accountObj.Service_RM__r.RC_Code__c==accountObj.Owner.RC_Code__c || accountObj.Owner.Profile.Name==GlobalConstants.SME_AH || accountObj.Owner.Profile.Name==GlobalConstants.SME_NH))
            //        this.stampingMonthly(accountObj,monthlyMap.get(exKey),monthlyMap.get(userMapExt.get(accountObj.Service_RM__c).User__r.Employee_Id__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear));
            //    else this.stampingMonthly(accountObj,monthlyMap.get(exKey),null);
            //}

            //if(accountObj.Service_RM__c!=null && accountObj.Service_RM__c!=accountObj.OwnerId && (accountObj.Service_RM__r.RC_Code__c==accountObj.Owner.RC_Code__c || accountObj.Owner.Profile.Name==GlobalConstants.SME_AH || accountObj.Owner.Profile.Name==GlobalConstants.SME_NH)){
            //    exKey = teamMap.get(userMapExt.get(accountObj.Service_RM__c).Team_Structure__c).RC_Code__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;
            //    if(monthlyMap.containsKey(exKey))
            //        this.stampingMonthly(accountObj,monthlyMap.get(exKey),null);

            //        if(teamMap.get(userMapExt.get(accountObj.Service_RM__c).Team_Structure__c).AH_Name__c!=null){
            //            exKey = teamMap.get(userMapExt.get(accountObj.Service_RM__c).Team_Structure__c).AH_RC_Code__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;
            //            if(monthlyMap.containsKey(exKey))
            //                this.stampingMonthly(accountObj,monthlyMap.get(exKey),null);
            //        }

            //        if(teamMap.get(userMapExt.get(accountObj.Service_RM__c).Team_Structure__c).NH_Name__c!=null){
            //            exKey = teamMap.get(userMapExt.get(accountObj.Service_RM__c).Team_Structure__c).NH_RC_Code__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;
            //            if(monthlyMap.containsKey(exKey))
            //                this.stampingMonthly(accountObj,monthlyMap.get(exKey),null);
            //        }
                
            //}else{
            //    exKey = teamStrucObj.RC_Code__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;
            //    if(monthlyMap.containsKey(exKey))
            //        this.stampingMonthly(accountObj,monthlyMap.get(exKey),null);

            //        if(teamStrucObj.AH_Name__c!=null){
            //            exKey = teamStrucObj.AH_RC_Code__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;
            //            if(monthlyMap.containsKey(exKey))
            //                this.stampingMonthly(accountObj,monthlyMap.get(exKey),null);
            //        }

            //        if(teamStrucObj.NH_Name__c!=null){
            //            exKey = teamStrucObj.NH_RC_Code__c + ' ' + todayDateFromNow.month()+ ' ' + currentYear;
            //            if(monthlyMap.containsKey(exKey))
            //                this.stampingMonthly(accountObj,monthlyMap.get(exKey),null);
            //        }
                
            //}
        }
    }
    public void stampingMonthly(Account accountObj,Monthly_Performance__c monthlyObj,Monthly_Performance__c monthlyServiceObj){
        //monthlyObj.Total_Customer__c ++;
                
        //if(accountObj.Count_Contacted_Call_Report__c > 0)
        //  monthlyObj.Total_Contacted_Customer_Port_Pool_Other__c++;
        if(accountObj.Count_Contacted_Call_Report__c > 0 && accountObj.Number_of_Visited__c!=null && accountObj.Number_of_Visited__c > 0)
            monthlyObj.Total_visited_Customer__c++;

        if(accountObj.Port_Pool__c=='Port' && accountObj.Ownership__c=='Permanent'){
            monthlyObj.Customer_Port__c++;
            if(accountObj.Count_Contacted_Call_Report__c > 0){
                monthlyObj.Contacted_Customer_Port__c++;

                if(monthlyObj.User__c!=null){
                    if(callReportMapOwner.containsKey(accountObj.Id+''+accountObj.OwnerId+''+monthlyObj.User__c))
                        monthlyObj.Contacted_Customer_Port_My_Penetrate__c++;
                }else{
                    
                    // if(userExIdMapTeam.containsKey(monthlyObj.Team__c)){//system.assertEquals('ssd'+callReportMapOwner,'sd');
                    //     for(String eachUserExt: userExIdMapTeam.get(monthlyObj.Team__c)){
                    //         if(callReportMapOwner.containsKey(accountObj.Id+''+accountObj.OwnerId+''+eachUserExt)){
                    //             monthlyObj.Contacted_Customer_Port_My_Penetrate__c++;
                    //             break;
                    //         }
                    //     }
                    // }
                }
            }
        }
        if(accountObj.Port_Pool__c=='Pool' && (accountObj.Owner.Profile.Name==GlobalConstants.SME_TM || accountObj.Owner.Profile.Name==GlobalConstants.SME_AH || accountObj.Owner.Profile.Name==GlobalConstants.SME_NH || (accountObj.Owner.Profile.Name==GlobalConstants.SME_RM && accountObj.Ownership__c=='Temporary'))){

            if(monthlyServiceObj!=null){
                monthlyServiceObj.Customer_Pool__c++;
            }else monthlyObj.Customer_Pool__c++;

            if(accountObj.Count_Contacted_Call_Report__c > 0){
                
                if(monthlyServiceObj!=null && accountObj.Count_Call_Report_RM__c > 0){
                    monthlyServiceObj.Contacted_Customer_Pool__c++;
                }else {
                    monthlyObj.Contacted_Customer_Pool__c++;
                }
                if(monthlyObj.User__c!=null ){
                    if(callReportMapOwner.containsKey(accountObj.Id+''+accountObj.OwnerId+''+monthlyObj.User__c)){
                        if(monthlyServiceObj!=null && accountObj.Count_Call_Report_RM__c > 0) monthlyServiceObj.Contacted_Customer_Pool_My_Penetrate__c++;
                        else monthlyObj.Contacted_Customer_Pool_My_Penetrate__c++;
                    }
                }else{
                    
                    // if(userExIdMapTeam.containsKey(monthlyObj.Team__c)){
                    //     //if(monthlyObj.Team__c=='a0mN00000038Ln6IAE'){
                    //     //    system.debug(userExIdMapTeam.get(monthlyObj.Team__c)+'');
                    //     //    system.assertEquals('sd','ee');
                    //     //}
                    //     for(String eachUserExt: userExIdMapTeam.get(monthlyObj.Team__c)){
                    //         if(callReportMapOwner.containsKey(accountObj.Id+''+accountObj.OwnerId+''+eachUserExt) && accountObj.Count_Call_Report_RM__c == 0){
                    //             monthlyObj.Contacted_Customer_Pool_My_Penetrate__c++;
                    //             break;
                    //         }
                    //     }
                    // }
                }
            }
        }
        if(accountObj.Port_Pool__c==null && ((accountObj.Ownership__c==null) || (accountObj.Ownership__c=='Temporary'))){
            monthlyObj.Customer_Other__c++;
            if(accountObj.Count_Contacted_Call_Report__c > 0){
                monthlyObj.Contacted_Customer_Other__c++;

                if(monthlyObj.User__c!=null){
                    if(callReportMapOwner.containsKey(accountObj.Id+''+accountObj.OwnerId+''+monthlyObj.User__c))
                        monthlyObj.Contacted_Customer_Other_My_Penetrate__c++;
                }else{
                    
                    // if(userExIdMapTeam.containsKey(monthlyObj.Team__c)){
                    //     for(String eachUserExt: userExIdMapTeam.get(monthlyObj.Team__c)){
                    //         if(callReportMapOwner.containsKey(accountObj.Id+''+accountObj.OwnerId+''+eachUserExt)){
                    //             monthlyObj.Contacted_Customer_Other_My_Penetrate__c++;
                    //             break;
                    //         }
                    //     }
                    // }
                }
            }
        }
    }    
}