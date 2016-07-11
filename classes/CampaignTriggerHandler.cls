/**
* @author chutiwat.s@beryl8.com
* @31/08/2015 Created Date
* @11/01/2016 Change expired and stamp account lead to batch
* @20/01/2016 Clean Code / Add Sent Email to External User
* @27/01/2016 Add condition after update to check delta field Type__c and Status for stamp account
* @04/02/2016 Move check filteredCampaignList for stamp Account in after update to before update
* @05/02/2016 Create Start and End Event for each New Event
* @09/02/2016 Fixed bug : remove not met criteria in updated campaign (eventUpdateMapCampaign)
* @10/03/2016 Delete stamp account logic
*/
public class CampaignTriggerHandler extends TriggerHandler {
    private static final String START_NEW_EVENT = 'Start New Event';
    private static final String END_NEW_EVENT = 'End New Event';

    private Map<String,List<Event>> eventInsertMapCampaign;
    private Map<String,List<Event>> eventUpdateMapCampaign;
    private Map<Id, String> teamEmailMapCampaign;
    private Set<String> teamNameSet;

    //private Map<String,List<Event>> eventExistingMapByCampaign;
    private Map<String,Set<Id>> userIdMapByCampaign;
    private Map<String,Id> eventRelationMapEventAndRelation;
    private Map<Id,User> userMap;
    private Set<Id> eventDeleteSet;
    private static Set<Id> accountDeletedCampIds;
    private static Set<Id> updateCampaignExpiredSet;
    private enum EventContext{E_CREATE, E_UPDATE, E_DELETE}
    public override void beforeUpdate() {
        Campaign oldRecord;
        updateCampaignExpiredSet = new Set<Id>();

        for (Campaign eachCampaign : (List<Campaign>)Trigger.new) {
            oldRecord = (Campaign) Trigger.oldMap.get(eachCampaign.Id);
            eachCampaign.Previous_Dress_Code__c = oldRecord.Dress_Code__c;
            eachCampaign.Previous_End_Date_Time__c = oldRecord.End_Date_Time__c;
            eachCampaign.Previous_Food__c = oldRecord.Food__c;
            eachCampaign.Previous_Name__c = oldRecord.Name;
            eachCampaign.Previous_Start_Date_Time__c = oldRecord.Start_Date_Time__c;
            eachCampaign.Previous_Venue__c = oldRecord.Venue__c;

            if(eachCampaign.Status != null && eachCampaign.Status == GlobalConstants.EXPIRE_PROCESS || eachCampaign.Status == GlobalConstants.CANCEL_PROCESS) {
                if(eachCampaign.Status != oldRecord.Status) {
                    updateCampaignExpiredSet.add(eachCampaign.Id);
                }
            }
        }
    }

    public override void afterInsert() {
        //Set<Id> filteredCampList = new Set<Id>();
        Set<Id> newExpiredCampList = new Set<Id>();
        for (Campaign eachCampaign : (List<Campaign>) Trigger.new) {
            if(eachCampaign.Status != null && eachCampaign.Status == GlobalConstants.EXPIRE_PROCESS && eachCampaign.Status == GlobalConstants.CANCEL_PROCESS) {
                newExpiredCampList.add(eachCampaign.Id);
            }
        }
        if(!newExpiredCampList.isEmpty()) setExpiredTargetList(newExpiredCampList);
    }

    public override void afterUpdate() {
        if(!updateCampaignExpiredSet.isEmpty()) setExpiredTargetList(updateCampaignExpiredSet);

        if(!GlobalUtility.runOnce) {
            Campaign oldCamp;
                
            //event here
            eventInsertMapCampaign = new Map<String,List<Event>>();
            eventUpdateMapCampaign = new Map<String,List<Event>>();
            eventRelationMapEventAndRelation = new Map<String,Id>();
            eventDeleteSet = new Set<Id>();
            teamEmailMapCampaign = new Map<Id, String>();
            teamNameSet = new Set<String>();

            List<Event> eventExistingList = new List<Event>();
            List<EventRelation> eventRelationExistingList = new List<EventRelation>();
            List<CampaignShare> campaignShareList = new List<CampaignShare>();

            //eventExistingMapByCampaign = new Map<String,List<Event>>();
            userIdMapByCampaign = new Map<String,Set<Id>>();

            eventExistingList = [SELECT Id,WhatID,Subject FROM Event WHERE WhatID in:Trigger.newMap.keySet() AND ischild = false];
            eventRelationExistingList = [SELECT Id,RelationId,EventId,Event.WhatID FROM EventRelation WHERE Event.WhatID in:Trigger.newMap.keySet()];
            campaignShareList = [SELECT Id,UserOrGroupId,CampaignId FROM CampaignShare WHERE CampaignId in:Trigger.newMap.keySet() AND (RowCause='Manual' OR RowCause='Rule')];

            Set<Id> tmpUserSet = new Set<Id>();
            Set<Id> userSet = new Set<Id>();
            for(CampaignShare eachCampaignShare : campaignShareList){
                if(!userIdMapByCampaign.containsKey(eachCampaignShare.CampaignId))
                    userIdMapByCampaign.put(eachCampaignShare.CampaignId,new Set<Id>());

                tmpUserSet = UserRoleUtils.GetUserIdsFromGroup(new Set<Id>{eachCampaignShare.UserOrGroupId});
                if(tmpUserSet!=null && tmpUserSet.size() > 0){
                    userIdMapByCampaign.get(eachCampaignShare.CampaignId).addAll(tmpUserSet);
                    userSet.addAll(tmpUserSet);
                }
            }
            if(tmpUserSet.size() > 0){
                userMap = new Map<Id,User>([SELECT Id,FirstName,LastName FROM User WHERE Id in:userSet]);
            }else userMap = new Map<Id,User>();

            for(Event eachEvent : eventExistingList){
                if(!eventUpdateMapCampaign.containsKey(eachEvent.WhatID))
                    eventUpdateMapCampaign.put(eachEvent.WhatID,new List<Event>());
                eventUpdateMapCampaign.get(eachEvent.WhatID).add(eachEvent);
            }
            
            for(EventRelation eachEventRelation : eventRelationExistingList){
                if(!eventRelationMapEventAndRelation.containsKey(eachEventRelation.EventId+''+eachEventRelation.RelationId))
                    eventRelationMapEventAndRelation.put(eachEventRelation.EventId+''+eachEventRelation.RelationId,eachEventRelation.Id);
            }

            Map<String, Id> recordTypeMapByDevName = GlobalUtility.getRecordTypeMapByDevNameFromSObject('Campaign');
            String eventRecordTypeId = recordTypeMapByDevName.containsKey(GlobalConstants.SME_EVENT_DEVNAME) ? recordTypeMapByDevName.get(GlobalConstants.SME_EVENT) : '';
            String nonRecordTypeId = recordTypeMapByDevName.containsKey(GlobalConstants.SME_EVENT_NON_TARGET_DEVNAME) ? recordTypeMapByDevName.get(GlobalConstants.SME_EVENT_NON_TARGET_DEVNAME) : '';
            String leadRecordTypeId = recordTypeMapByDevName.containsKey(GlobalConstants.SME_LEAD_CAMPAIGN_DEVNAME) ? recordTypeMapByDevName.get(GlobalConstants.SME_LEAD_CAMPAIGN_DEVNAME) : '';

            Set<Id> activeLeadIds = new Set<Id>();
            Campaign oldRecord;
            for (Campaign eachCampaign : (List<Campaign>) Trigger.new) {
                oldRecord = (Campaign) Trigger.oldMap.get(eachCampaign.Id);
                if(eachCampaign.RecordTypeId == eventRecordTypeId || eachCampaign.RecordTypeId == nonRecordTypeId) {
                    if(eachCampaign.Status==GlobalConstants.ACTIVE && ((eachCampaign.Status==GlobalConstants.ACTIVE && oldRecord.Status!=GlobalConstants.ACTIVE) || (oldRecord.Venue__c != eachCampaign.Venue__c || oldRecord.End_Date_Time__c != eachCampaign.End_Date_Time__c || oldRecord.Start_Date_Time__c != eachCampaign.Start_Date_Time__c))){
                        if(!eventUpdateMapCampaign.containsKey(eachCampaign.Id)){//INSERT CASE
                            this.handlerEvent(eachCampaign, null, EventContext.E_CREATE);
                            if(eachCampaign.Sent_Email_to_Team__c != null) {
                                teamNameSet.addAll(new Set<String>(eachCampaign.Sent_Email_to_Team__c.split(';')));
                                teamEmailMapCampaign.put(eachCampaign.Id, String.valueOf(EventContext.E_CREATE));
                            }
                        }else {
                            this.handlerEvent(eachCampaign, eventUpdateMapCampaign.get(eachCampaign.Id), EventContext.E_UPDATE);
                            if(eachCampaign.Sent_Email_to_Team__c != null) {
                                teamNameSet.addAll(new Set<String>(eachCampaign.Sent_Email_to_Team__c.split(';')));
                                teamEmailMapCampaign.put(eachCampaign.Id, String.valueOf(EventContext.E_UPDATE));
                            }
                        }

                    }else if (eachCampaign.Status == GlobalConstants.CANCEL) {
                        if(eventUpdateMapCampaign.containsKey(eachCampaign.Id)){
                            for(Event eachEvent : eventUpdateMapCampaign.get(eachCampaign.Id)){
                                eventDeleteSet.add(eachEvent.Id);
                                if(eachCampaign.Sent_Email_to_Team__c != null) {
                                    teamNameSet.addAll(new Set<String>(eachCampaign.Sent_Email_to_Team__c.split(';')));
                                    teamEmailMapCampaign.put(eachCampaign.Id, String.valueOf(EventContext.E_DELETE));
                                }
                            }
                        }
                    } else if (eachCampaign.Status == GlobalConstants.ACTIVE && eachCampaign.Sent_Email_to_Team__c != oldRecord.Sent_Email_to_Team__c) {
                        if(eachCampaign.Sent_Email_to_Team__c != null) {
                            teamNameSet.addAll(new Set<String>(eachCampaign.Sent_Email_to_Team__c.split(';')));
                            teamEmailMapCampaign.put(eachCampaign.Id, String.valueOf(EventContext.E_CREATE));
                        }
                        if(eventUpdateMapCampaign.containsKey(eachCampaign.Id)) {
                            eventUpdateMapCampaign.remove(eachCampaign.Id);
                        }
                    } else {
                        if(eventUpdateMapCampaign.containsKey(eachCampaign.Id)) {
                            eventUpdateMapCampaign.remove(eachCampaign.Id);
                        }
                    }
                } else if(eachCampaign.RecordTypeId == leadRecordTypeId) {
                    if (eachCampaign.Status == GlobalConstants.ACTIVE) {
                        activeLeadIds.add(eachCampaign.Id);
                    }
                }
            }

            if(!activeLeadIds.isEmpty()) {
                List<Target_List__c> targetList = new List<Target_List__c>();
                targetList = [SELECT Id, CIS_ID_Prospect_Name__c FROM Target_List__c WHERE Lead_Campaign__c IN :activeLeadIds];
                if(!targetList.isEmpty())
                    CampaignTriggerHandlerService.updateTargetlistStatusFromLatestOpp(targetList);
            }
        }
    }

    private List<Messaging.SingleEmailMessage> emailToSend;
    private List<EventRelation> eventRelationList;
    public override void afterUpdateFinally(){
        if(!GlobalUtility.runOnce){
        GlobalUtility.runOnce = true;
        eventRelationList = new List<EventRelation>();
        emailToSend = new List<Messaging.SingleEmailMessage>();

        EmailTemplate emailNewEventTemplate = [SELECT Id,Body,Subject FROM EmailTemplate WHERE DeveloperName = :GlobalConstants.SME_EMAIL_TEMPLATE_NEW_EVENT LIMIT 1];
        EmailTemplate emailModifyTemplate = [SELECT Id,Body,Subject FROM EmailTemplate WHERE DeveloperName = :GlobalConstants.SME_EMAIL_TEMPLATE_MODIFIED_EVENT LIMIT 1];
        EmailTemplate emailCancelTemplate = [SELECT Id,Body,Subject FROM EmailTemplate WHERE DeveloperName = :GlobalConstants.SME_EMAIL_TEMPLATE_CANCEL_EVENT LIMIT 1];
        EmailTemplate emailNewExternalTemplate = [SELECT Id,Body,Subject FROM EmailTemplate WHERE DeveloperName = :GlobalConstants.SME_EMAIL_TEMPLATE_NEW_EVENT_EXTERNAL LIMIT 1];
        EmailTemplate emailModifyExternalTemplate = [SELECT Id,Body,Subject FROM EmailTemplate WHERE DeveloperName = :GlobalConstants.SME_EMAIL_TEMPLATE_MODIFIED_EVENT_EXTERNAL LIMIT 1];
        EmailTemplate emailCancelExternalTemplate = [SELECT Id,Body,Subject FROM EmailTemplate WHERE DeveloperName = :GlobalConstants.SME_EMAIL_TEMPLATE_CANCEL_EVENT_EXTERNAL LIMIT 1];

        Map<String, List<Event_External_User__c>> teamMemberAddressMap = new Map<String, List<Event_External_User__c>>();
        List<Event_External_User__c> teamMemberAddressList = new List<Event_External_User__c>();
        teamMemberAddressList = [SELECT Id, Name__c, Team__c, Email__c FROM Event_External_User__c WHERE Team__c IN :teamNameSet];
        for(Event_External_User__c eachTeamMember : teamMemberAddressList) {
            if(teamMemberAddressMap.containsKey(eachTeamMember.Team__c)) {
                teamMemberAddressMap.get(eachTeamMember.Team__c).add(eachTeamMember);    
            } else {
                teamMemberAddressMap.put(eachTeamMember.Team__c, new List<Event_External_User__c>{eachTeamMember});
            }
        }

        if(teamEmailMapCampaign.size() > 0) {
            String emailSubject;
            String emailBody;
            Campaign tempCampaign;
            Campaign oldRecord;
            Set<String> oldTeamNameSet = new Set<String>();
            Set<String> teamsSet;
            List<Event_External_User__c> membersToSentList;
            for(Id campaignId : teamEmailMapCampaign.keySet()) {
                if(teamEmailMapCampaign.get(campaignId) == String.valueOf(EventContext.E_UPDATE)) {
                    emailSubject = emailModifyExternalTemplate.Subject.replace('{!Campaign.Name}', ((Campaign)Trigger.newMap.get(campaignId)).Name);
                    emailBody = emailModifyExternalTemplate.Body;
                } else if(teamEmailMapCampaign.get(campaignId) == String.valueOf(EventContext.E_CREATE)) {
                    emailSubject = emailNewExternalTemplate.Subject.replace('{!Campaign.Name}', ((Campaign)Trigger.newMap.get(campaignId)).Name);
                    emailBody = emailNewExternalTemplate.Body;
                }else if(teamEmailMapCampaign.get(campaignId) == String.valueOf(EventContext.E_DELETE)) {
                    emailSubject = emailCancelExternalTemplate.Subject.replace('{!Campaign.Name}', ((Campaign)Trigger.newMap.get(campaignId)).Name);
                    emailBody = emailCancelExternalTemplate.Body;
                }
                tempCampaign = (Campaign)Trigger.newMap.get(campaignId);
                oldRecord = (Campaign) Trigger.oldMap.get(campaignId);
                teamsSet = new Set<String>(((String)tempCampaign.Sent_Email_to_Team__c).split(';'));
                if(tempCampaign.Sent_Email_to_Team__c != oldRecord.Sent_Email_to_Team__c && oldRecord.Sent_Email_to_Team__c != null) {
                    oldTeamNameSet.addAll(new Set<String>(oldRecord.Sent_Email_to_Team__c.split(';')));
                }
                teamsSet.removeAll(oldTeamNameSet);
                membersToSentList = new List<Event_External_User__c>();
                for(String eachTeam : teamsSet) {
                    if(teamMemberAddressMap.containsKey(eachTeam))
                        membersToSentList.addAll(teamMemberAddressMap.get(eachTeam));
                }
                this.sentEmailToTeam(emailSubject, emailBody, tempCampaign, membersToSentList);
            }

        }

        if(eventInsertMapCampaign.size() > 0){
            this.syncRelation(eventInsertMapCampaign, emailNewEventTemplate.Body,emailNewEventTemplate.Subject);
        }
        if(eventUpdateMapCampaign.size() > 0){
            this.syncRelation(eventUpdateMapCampaign, emailModifyTemplate.Body,emailModifyTemplate.Subject);
        }
        List<EventRelation> eventRelationDeleteList = new List<EventRelation>();
        if(eventDeleteSet.size() > 0) {
            eventRelationDeleteList = [SELECT Id,RelationId,Event.WhatID FROM EventRelation WHERE EventId in : eventDeleteSet AND Event.Subject LIKE 'Start New Event%'];
            for(EventRelation eachRelation : eventRelationDeleteList){
                this.addEmail(emailCancelTemplate.Subject.replace('{!Campaign.Name}',((Campaign)Trigger.newMap.get(eachRelation.Event.WhatID)).Name),emailCancelTemplate.Body, eachRelation.RelationId, (Campaign)Trigger.newMap.get(eachRelation.Event.WhatID));
            }
        }
        if(eventRelationMapEventAndRelation.size() > 0){
            //delete remain unused relation
            delete [SELECT Id FROM EventRelation WHERE Id in:eventRelationMapEventAndRelation.values()];
        }
        if(eventDeleteSet.size() > 0) {
            delete [SELECT Id FROM Event WHERE Id in:eventDeleteSet];
        }
        if(eventRelationList.size() > 0) upsert eventRelationList;

        if(emailToSend.size() > 0){
            Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailToSend);
            for(Messaging.SendEmailResult eachResult : emailResults){
                if(!eachResult.IsSuccess())
                {
                    throw new CampaignException(eachResult.getErrors()+'');
                }
            }
        }
    }
    }
    
    private void sentEmailToTeam(String emailSubject, String emailBody, Campaign campaignObj, List<Event_External_User__c> membersToSent) {
        Messaging.SingleEmailMessage emailObj;
        String campaignEmailBody = setAllCampaignTemplateBody(campaignObj , emailBody);
        for (Event_External_User__c eachExternal : membersToSent) {
            emailObj = new Messaging.SingleEmailMessage();

            string fullTemplateBody = setAllUserTemplateBody(eachExternal, campaignEmailBody);

            emailObj.setPlainTextBody(fullTemplateBody);
            emailObj.setToAddresses(new List<String>{eachExternal.Email__c});
            emailObj.setSubject(emailSubject);
            emailObj.setUseSignature(false);
            emailObj.setBccSender(false);
            emailObj.setSaveAsActivity(false);

            emailToSend.add(emailObj);
        }
    }

    private void syncRelation(Map<String,List<Event>> eventByCampaignMap,String templateBody,String templateSubject){
        
        for(String campaignId : eventByCampaignMap.keySet()){
            upsert eventByCampaignMap.get(campaignId);
            if(userIdMapByCampaign.containsKey(campaignId)){//have member

                for(Event eachEventInCampaign : eventByCampaignMap.get(campaignId)){
                    if(!eventDeleteSet.contains(eachEventInCampaign.Id)){
                        for(Id eachUserToShare : userIdMapByCampaign.get(campaignId)){
                            if(eachUserToShare!=Trigger.newMap.get(campaignId).get('OwnerId')){
                                if(!eventRelationMapEventAndRelation.containsKey(eachEventInCampaign.Id+''+eachUserToShare)){
                                    eventRelationList.add(new EventRelation(
                                        EventId = eachEventInCampaign.Id,
                                        RelationId = eachUserToShare
                                    ));
                                }else eventRelationMapEventAndRelation.remove(eachEventInCampaign.Id+''+eachUserToShare);// have event relation 
                                if(eachEventInCampaign.Subject.startsWith(START_NEW_EVENT))
                                this.addEmail(templateSubject.replace('{!Campaign.Name}',((Campaign)Trigger.newMap.get(campaignId)).Name),templateBody, eachUserToShare, (Campaign)Trigger.newMap.get(campaignId));
                            }
                        }
                    }
                }
            }
        }
    }
    private void addEmail(String emailSubject,String emailBody,String userId,Campaign campaignObj){
        Messaging.SingleEmailMessage emailObj;
        emailObj = new Messaging.SingleEmailMessage();
        //emailObj.setTemplateId(templateId);
        string fullTemplateBody = setAllUserTemplateBody(userMap.get(userId),setAllCampaignTemplateBody(campaignObj , emailBody));
        emailObj.setPlainTextBody(fullTemplateBody);
        emailObj.setTargetObjectId(userId);
        emailObj.setSubject(emailSubject);
        //emailObj.setWhatId(whatId);
        emailObj.setUseSignature(false);
        emailObj.setBccSender(false);
        emailObj.setSaveAsActivity(false);
        emailToSend.add(emailObj);
    }
    private string setAllUserTemplateBody(Event_External_User__c externalUser, String templateBody){
        
        String fullTemplateBody = templateBody;
        String target = '{!User.FirstName}';
        if(fullTemplateBody.contains(target)){
            fullTemplateBody = fullTemplateBody.replace(target, externalUser.Name__c);
        }

        target = '{!User.LastName}';
        if(fullTemplateBody.contains(target)){
            fullTemplateBody = fullTemplateBody.replace(target, '');
        }
        
        return fullTemplateBody;
    }
    private String setAllUserTemplateBody(User e, String templateBody){
        String fullTemplateBody = templateBody;
        Map<String, Schema.SObjectField> userFields = Schema.SObjectType.User.fields.getMap();
        
        for(Schema.SObjectField fieldName : userFields.values()) {
            String str = '{!User.'+String.valueOf(fieldName)+'}';
            if(fullTemplateBody.contains(str)){
                integer index = fullTemplateBody.indexOf(str);
                String target = fullTemplateBody.substring(index, (index+str.length()));
                if(str == '{!User.Id}' && e != null && String.valueOf(e.get('Id')) != null){
                    String link = URL.getSalesforceBaseUrl().toExternalForm() + '/' + e.Id;
                    fullTemplateBody = fullTemplateBody.replace(target,link);
                }else if(e != null && String.valueOf(e.get(fieldName)) != null){
                    fullTemplateBody = fullTemplateBody.replace(target, String.valueOf(e.get(fieldName)));
                }else{
                    fullTemplateBody = fullTemplateBody.replace(target, '');
                }
            }
        }
        
        return fullTemplateBody;
    }
    private string setAllCampaignTemplateBody(Campaign e, String templateBody){
        String fullTemplateBody = templateBody;
        Map<String, Schema.SObjectField> campaignFields = Schema.SObjectType.Campaign.fields.getMap();
        
        for(Schema.SObjectField fieldName : campaignFields.values()) {
            String str = '{!Campaign.'+String.valueOf(fieldName)+'}';
            if(fullTemplateBody.contains(str)){
                integer index = fullTemplateBody.indexOf(str);
                String target = fullTemplateBody.substring(index, (index+str.length()));
                if(String.valueOf(fieldName) == 'Start_Date_Time__c' && string.valueOf(e.get(String.valueOf(fieldName))) != null){
                    Datetime eventDateTime = e.Start_Date_Time__c;
                    String eventTime = eventDateTime.format('yyyy-MM-dd HH:mm');
                    list<string> lstTimStr = eventTime.split(' ');
                    string etime = lstTimStr[1];
                    string edate = lstTimStr[0];
                    fullTemplateBody = fullTemplateBody.replace(target,edate+' '+etime);
                }else if(String.valueOf(fieldName) == 'End_Date_Time__c' && string.valueOf(e.get(String.valueOf(fieldName))) != null){
                    Datetime eventDateTime = e.End_Date_Time__c;
                    String eventTime = eventDateTime.format('yyyy-MM-dd HH:mm');
                    list<string> lstTimStr = eventTime.split(' ');
                    string etime = lstTimStr[1];
                    string edate = lstTimStr[0];
                    fullTemplateBody = fullTemplateBody.replace(target,edate+' '+etime);
                }else if(String.valueOf(fieldName) == 'Previous_Start_Date_Time__c' && string.valueOf(e.get(String.valueOf(fieldName))) != null){
                    Datetime eventDateTime = e.Previous_Start_Date_Time__c;
                    String eventTime = eventDateTime.format('yyyy-MM-dd HH:mm');
                    list<string> lstTimStr = eventTime.split(' ');
                    string etime = lstTimStr[1];
                    string edate = lstTimStr[0];
                    fullTemplateBody = fullTemplateBody.replace(target,edate+' '+etime);
                }else if(String.valueOf(fieldName) == 'Previous_End_Date_Time__c' && string.valueOf(e.get(String.valueOf(fieldName))) != null){
                    Datetime eventDateTime = e.Previous_End_Date_Time__c;
                    String eventTime = eventDateTime.format('yyyy-MM-dd HH:mm');
                    list<string> lstTimStr = eventTime.split(' ');
                    string etime = lstTimStr[1];
                    string edate = lstTimStr[0];
                    fullTemplateBody = fullTemplateBody.replace(target,edate+' '+etime);
                }else if(String.valueOf(fieldName) == 'Attendee_Confirmation_Date__c' && string.valueOf(e.get(String.valueOf(fieldName))) != null){
                    Datetime eventDateTime = e.Attendee_Confirmation_Date__c;
                    String eventTime = eventDateTime.format('yyyy-MM-dd HH:mm');
                    list<string> lstTimStr = eventTime.split(' ');
                    string etime = lstTimStr[1];
                    string edate = lstTimStr[0];
                    fullTemplateBody = fullTemplateBody.replace(target,edate+' '+etime);
                }else if(str == '{!Campaign.Id}' && string.valueOf(e.get('Id')) != null){
                    string link = URL.getSalesforceBaseUrl().toExternalForm() + '/' + e.Id;
                    fullTemplateBody = fullTemplateBody.replace(target,link);
                }else if(string.valueOf(e.get(fieldName)) != null){
                    fullTemplateBody = fullTemplateBody.replace(target,string.valueOf(e.get(fieldName)));
                }else{
                    fullTemplateBody = fullTemplateBody.replace(target,'');
                }
            }
        }
        fullTemplateBody = fullTemplateBody.replace('{!Campaign.Link}',URL.getSalesforceBaseUrl().toExternalForm() + '/' + e.Id);
        
        return fullTemplateBody;
    }
    private void handlerEvent(Campaign campaignEvent, List<Event> eventList,EventContext ec){
        if(ec == EventContext.E_CREATE){
            if(!eventInsertMapCampaign.containsKey(campaignEvent.Id))
                eventInsertMapCampaign.put(campaignEvent.Id,new List<Event>());

            eventInsertMapCampaign.get(campaignEvent.Id).add(new Event(
                StartDateTime = campaignEvent.Start_Date_Time__c,
                EndDateTime= campaignEvent.Start_Date_Time__c,
                Subject = START_NEW_EVENT,
                WhatID = campaignEvent.Id,
                OwnerId = campaignEvent.OwnerId
            ));

            eventInsertMapCampaign.get(campaignEvent.Id).add(new Event(
                StartDateTime = campaignEvent.End_Date_Time__c,
                EndDateTime= campaignEvent.End_Date_Time__c,
                Subject = END_NEW_EVENT,
                WhatID = campaignEvent.Id,
                OwnerId = campaignEvent.OwnerId
            ));

            eventInsertMapCampaign.get(campaignEvent.Id).add(new Event(
                StartDateTime = campaignEvent.Attendee_Confirmation_Date__c,
                EndDateTime= campaignEvent.Attendee_Confirmation_Date__c,
                Subject = 'Confirmation Date',
                WhatID = campaignEvent.Id,
                OwnerId = campaignEvent.OwnerId
            ));
        }
        else if(ec == EventContext.E_UPDATE && eventList!=null && eventList.size() > 0){

            for(Event eachEvent : eventList){
                if(eachEvent.Subject.startsWith(START_NEW_EVENT)){
                    eachEvent.StartDateTime = campaignEvent.Start_Date_Time__c;
                    eachEvent.EndDateTime = campaignEvent.Start_Date_Time__c;
                } else if(eachEvent.Subject.startsWith(END_NEW_EVENT)){
                    eachEvent.StartDateTime = campaignEvent.End_Date_Time__c;
                    eachEvent.EndDateTime = campaignEvent.End_Date_Time__c;
                } else {
                    eachEvent.StartDateTime = campaignEvent.Attendee_Confirmation_Date__c;
                    eachEvent.EndDateTime = campaignEvent.Attendee_Confirmation_Date__c;
                }
            }
        }
        else if(ec == EventContext.E_DELETE){
            eventDeleteSet.add(campaignEvent.Id);
        }
    }

    public Boolean setExpiredTargetList(Set<Id> campaignTriggerIds) {
        Database.executeBatch(new CampaignChangeStatus_Batch(campaignTriggerIds));
        return true;
    }

    public override void beforeDelete() {
        Set<Id> filteredCampList = new Set<Id>();
        for (Campaign eachCamp : (List<Campaign>)Trigger.old) {
            if(eachCamp.IsActive) {
                filteredCampList.add(eachCamp.Id);
            }
        }

        List<Target_List__c> firstTargetList = new List<Target_List__c>();
        firstTargetList = [SELECT CIS_ID_Prospect_Name__c FROM Target_List__c WHERE Lead_Campaign__c IN :filteredCampList];

        accountDeletedCampIds = new Set<Id>();
        for (Target_List__c eachTarget : firstTargetList) {
            if(eachTarget.CIS_ID_Prospect_Name__c!=null) accountDeletedCampIds.add(eachTarget.CIS_ID_Prospect_Name__c);
        }
    }

    public class CampaignException extends Exception {}
}