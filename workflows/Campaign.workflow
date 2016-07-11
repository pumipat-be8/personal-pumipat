<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Check_Non_Targeted_Event_Flag</fullName>
        <field>Non_Targeted_Event__c</field>
        <literalValue>1</literalValue>
        <name>Check Non-Targeted Event Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Checkbox_Active</fullName>
        <field>IsActive</field>
        <literalValue>1</literalValue>
        <name>Checkbox Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Event_Update_to_Active</fullName>
        <field>IsActive</field>
        <literalValue>1</literalValue>
        <name>Event - Update to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Active_Campaign</fullName>
        <field>IsActive</field>
        <literalValue>0</literalValue>
        <name>Uncheck Active Campaign</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Non_Targeted_Event_Flag</fullName>
        <field>Non_Targeted_Event__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Non-Targeted Event Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Active_Field_to_False</fullName>
        <field>IsActive</field>
        <literalValue>0</literalValue>
        <name>Update Active Field to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Campaign_Status_To_Active</fullName>
        <field>Status</field>
        <literalValue>Active</literalValue>
        <name>Update Campaign Status To Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Campaign_Status_To_Expired</fullName>
        <field>Status</field>
        <literalValue>Expired</literalValue>
        <name>Update Campaign Status To Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Campaign_Status_to_Cancel</fullName>
        <field>Status</field>
        <literalValue>Cancel</literalValue>
        <name>Update Campaign Status to Cancel</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Campaign_to_Expired</fullName>
        <field>Status</field>
        <literalValue>Expiry Process</literalValue>
        <name>Update Campaign to Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Event_End_Date</fullName>
        <field>EndDate</field>
        <formula>DATEVALUE(End_Date_Time__c)</formula>
        <name>Update Event End Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Event_Start_Date</fullName>
        <field>StartDate</field>
        <formula>DATEVALUE(Start_Date_Time__c)</formula>
        <name>Update Event Start Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status</fullName>
        <field>Status</field>
        <literalValue>Active</literalValue>
        <name>Update Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Cancel Campaign</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>SME- Lead / Campaign</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Status</field>
            <operation>notEqual</operation>
            <value>Cancel</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Cancellation_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Active_Field_to_False</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Campaign_Status_to_Cancel</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Campaign.Cancellation_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Change status to Active</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>SME- Lead / Campaign</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Status</field>
            <operation>equals</operation>
            <value>Planned</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.StartDate</field>
            <operation>greaterThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>Once Campaign is reached to start date, the system will automatically change status to &quot;Active&quot; and checkbox Active</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Checkbox_Active</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Campaign_Status_To_Active</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Campaign.StartDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Change status to Active now</fullName>
        <actions>
            <name>Checkbox_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Campaign_Status_To_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>SME- Lead / Campaign</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Status</field>
            <operation>equals</operation>
            <value>Planned</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.StartDate</field>
            <operation>lessOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.StartDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Once Campaign is reached to start date, which is greater or equals today, the system will automatically change status to &quot;Active&quot; and checkbox Active immediately</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change status to Cancel</fullName>
        <actions>
            <name>Uncheck_Active_Campaign</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Campaign.Status</field>
            <operation>equals</operation>
            <value>Cancel</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change status to Expired</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>SME- Lead / Campaign</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Status</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <description>Once Campaign is reached to End Date, the system will automatically change status to &quot;Expired&quot; and uncheck &quot;Active&quot; checkbox</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Uncheck_Active_Campaign</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Campaign_to_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Campaign.EndDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Check Non-Targeted Event Flag</fullName>
        <actions>
            <name>Check_Non_Targeted_Event_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>SME-Event (Non-Targeted)</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Event - Update to Active</fullName>
        <actions>
            <name>Event_Update_to_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.IsActive</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Status</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <description>Update Active = True when status = active</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead%2FCampaign%2FEvent - Update to Inactive %28Cancelled%29</fullName>
        <actions>
            <name>Update_Active_Field_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Status</field>
            <operation>equals</operation>
            <value>Cancel</value>
        </criteriaItems>
        <description>When it was update the status to &quot;Cancel&quot;, then uncheck &quot;Active&quot; checkbox</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Uncheck Non-Targeted Event Flag</fullName>
        <actions>
            <name>Uncheck_Non_Targeted_Event_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>SME-Event,SME- Lead / Campaign</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Standard Start%2FEnd Date of Event</fullName>
        <actions>
            <name>Update_Event_End_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Event_Start_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>RecordType.DeveloperName = &apos;SME_Event&apos; &amp;&amp; (ISCHANGED(Start_Date_Time__c) || ISCHANGED(End_Date_Time__c) || ISNEW())</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
