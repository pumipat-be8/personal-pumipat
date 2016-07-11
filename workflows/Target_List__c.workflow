<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Change_Record_Type_Value_Chain</fullName>
        <field>RecordTypeId</field>
        <lookupValue>value_chain</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change Record Type Value Chain</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Expire_Not_Register_Targetlist</fullName>
        <field>Status__c</field>
        <literalValue>Lead Expired</literalValue>
        <name>Expire Not Register Targetlist</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Status_to_Not_Register</fullName>
        <field>Status__c</field>
        <literalValue>Not interested</literalValue>
        <name>Update Lead Status to Not Register</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Interested_Not_Register</fullName>
        <field>Status__c</field>
        <literalValue>Interested but not register</literalValue>
        <name>Update Status to Interested Not Register</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Register</fullName>
        <field>Status__c</field>
        <literalValue>Registered</literalValue>
        <name>Update Status to Register</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Change Record Type Value Chain</fullName>
        <actions>
            <name>Change_Record_Type_Value_Chain</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Sub_Type__c</field>
            <operation>equals</operation>
            <value>Value Chain</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Expire Targetlist in Campaign Thankyou</fullName>
        <active>false</active>
        <formula>AND( Lead_Campaign__r.Lead_Campaign_Event_Code__c =  $Setup.Campaign_Setting__c.ThankYou_Code__c ,   NOT( OR( ISPICKVAL(Status__c, &quot;Registered&quot;), ISPICKVAL(Status__c, &quot;Lead Expired&quot;))))</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Expire_Not_Register_Targetlist</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Target_List__c.CreatedDate</offsetFromField>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Expire Targetlist in Campaign Thankyou - 90Days</fullName>
        <active>true</active>
        <formula>AND( Lead_Campaign__r.Lead_Campaign_Event_Code__c =  $Setup.Campaign_Setting__c.ThankYou_Code__c ,   NOT( OR( ISPICKVAL(Status__c, &quot;Registered&quot;), ISPICKVAL(Status__c, &quot;Lead Expired&quot;))))</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Expire_Not_Register_Targetlist</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Target_List__c.CreatedDate</offsetFromField>
            <timeLength>90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Campaign Lead to Interested not Register SF1</fullName>
        <actions>
            <name>Update_Status_to_Interested_Not_Register</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Target_List__c.Campaign_Lead_Status__c</field>
            <operation>equals</operation>
            <value>Not Interested This Time</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Campaign Lead to Not Register SF1</fullName>
        <actions>
            <name>Update_Lead_Status_to_Not_Register</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Target_List__c.Campaign_Lead_Status__c</field>
            <operation>equals</operation>
            <value>Not Register</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Campaign Lead to Register SF1</fullName>
        <actions>
            <name>Update_Status_to_Register</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Target_List__c.Campaign_Lead_Status__c</field>
            <operation>equals</operation>
            <value>Register</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
