<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_AllAfterTrigger_to_True</fullName>
        <field>TriggerExecuted__c</field>
        <literalValue>1</literalValue>
        <name>Update AllAfterTrigger to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CIS_ID_Unique_key</fullName>
        <field>CIS__c</field>
        <formula>Name</formula>
        <name>Update CIS ID Unique key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CIS_Unique_Key_Alphabetical</fullName>
        <field>CIS__c</field>
        <formula>Name+Surname_TH_Prospect__c</formula>
        <name>Update CIS Unique Key(Alphabetical)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CustomerOwnerReleaseFlag_to_True</fullName>
        <field>Customer_Owner_Release_Flag__c</field>
        <literalValue>1</literalValue>
        <name>Update CustomerOwnerReleaseFlag to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Customer_Insight_Last_Modified_DT</fullName>
        <field>Customer_Insight_Updated_Date__c</field>
        <formula>Now()</formula>
        <name>Update Customer Insight Last Modified DT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Customer_Insight_Updated_By_T</fullName>
        <field>Customer_Insight_Last_Modified_By__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp;  $User.LastName</formula>
        <name>Update Customer Insight Last Modified By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Customer_Owner_Changed_Date</fullName>
        <field>Customer_Owner_Changed_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Customer Owner Changed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Delete_Flag</fullName>
        <description>Account.Delete Flag = TRUE</description>
        <field>Delete_Flag__c</field>
        <literalValue>1</literalValue>
        <name>Update Delete Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_OwnerChangeExecutedByTrigger_to_F</fullName>
        <field>OwnerChangeExecutedByTrigger__c</field>
        <literalValue>0</literalValue>
        <name>Update OwnerChangeExecutedByTrigger to F</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_OwnerChangeExecutedFrUI_to_F</fullName>
        <field>OwnerChangeExecutedFrUI__c</field>
        <literalValue>0</literalValue>
        <name>Update OwnerChangeExecutedFrUI to F</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_OwnerChangeExecutedFrUI_to_T</fullName>
        <field>OwnerChangeExecutedFrUI__c</field>
        <literalValue>1</literalValue>
        <name>Update OwnerChangeExecutedFrUI to T</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Owner_to_SME_Admin</fullName>
        <field>OwnerId</field>
        <lookupValue>smeadmin@kasikornbank.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Update Owner to SME-Admin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Delete Prospect</fullName>
        <active>true</active>
        <description>Delete Prospect owned by profile = SME-Admin for 90 days, then update Account.Delete Flag = True</description>
        <formula>RecordType.DeveloperName = &quot;SME_Prospect&quot; &amp;&amp; Owner.Profile.Name = &quot;SME-Admin&quot; &amp;&amp; ( ISBLANK(Temp_Owner_Changed_Date__c) || Temp_Owner_Changed_Date__c = Today() || Temp_Owner_Changed_Date__c + 90 = Today())</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Delete_Flag</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Release Customer Ownership for Call Plan %2F Call Report %28ME%29</fullName>
        <active>true</active>
        <description>If there is no updates for call plan/call report or opportunity for the customer for 90 Days (ME)</description>
        <formula>RecordType.DeveloperName = &quot;SME_Customer&quot; &amp;&amp;  Owner.Segment__c = &quot;ME&quot; &amp;&amp;  (Owner.Profile.Name = &quot;SME-RM&quot; || Owner.Profile.Name = &quot;SME-TM&quot;)  &amp;&amp;  Port_Pool__c &lt;&gt; &quot;Port&quot; &amp;&amp;  (DATEVALUE( Last_CallReprt_Opty_Updated_Date__c ) = Today() ||  DATEVALUE(Last_CallReprt_Opty_Updated_Date__c ) + 1 = Today())</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_CustomerOwnerReleaseFlag_to_True</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Account.Last_CallReprt_Opty_Updated_Date__c</offsetFromField>
            <timeLength>90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Release Customer Ownership for Call Plan %2F Call Report %28SE%29</fullName>
        <active>true</active>
        <description>If there is no updates for call plan/call report or opportunity for the customer for 90 Days (SE)</description>
        <formula>RecordType.DeveloperName = &quot;SME_Customer&quot; &amp;&amp;  Owner.Segment__c = &quot;SE&quot; &amp;&amp;  (Owner.Profile.Name = &quot;SME-RM&quot; || Owner.Profile.Name = &quot;SME-TM&quot;) &amp;&amp;  Port_Pool__c &lt;&gt; &quot;Port&quot; &amp;&amp;  (DATEVALUE( Last_CallReprt_Opty_Updated_Date__c ) = Today() ||  DATEVALUE(Last_CallReprt_Opty_Updated_Date__c ) + 1 = Today())</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_CustomerOwnerReleaseFlag_to_True</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Account.Last_CallReprt_Opty_Updated_Date__c</offsetFromField>
            <timeLength>90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Release Prospect Ownership %28ME%29 - Create</fullName>
        <active>true</active>
        <description>If there is no call plan created for the prospect for 90 days (ME)</description>
        <formula>RecordType.DeveloperName = &quot;SME_Prospect&quot; &amp;&amp; Owner.Segment__c = &quot;ME&quot; &amp;&amp; Number_of_Opp__c  = 0 &amp;&amp;   Number_of_Call_Plan_Call_Report__c  =0</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Owner_to_SME_Admin</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Release Prospect Ownership %28SE%29 - Create</fullName>
        <active>true</active>
        <description>If there is no call plan created for the prospect for 90 days (SE)</description>
        <formula>Owner.Segment__c = &quot;SE&quot; &amp;&amp; Number_of_Call_Plan_Call_Report__c =0 &amp;&amp; Number_of_Opp__c = 0</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Owner_to_SME_Admin</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Release Prospect Ownership for Call Plan %2F Call Report %28ME%29</fullName>
        <active>true</active>
        <description>If there is no updates for call plan/call report or opportunity for the prospect for 90 Days (ME)</description>
        <formula>RecordType.DeveloperName = &quot;SME_Prospect&quot; &amp;&amp;  Owner.Segment__c = &quot;ME&quot; &amp;&amp;  (Owner.Profile.Name = &quot;SME-RM&quot; || Owner.Profile.Name = &quot;SME-TM&quot;) &amp;&amp; (DATEVALUE( Last_CallReprt_Opty_Updated_Date__c ) = Today() ||  DATEVALUE(Last_CallReprt_Opty_Updated_Date__c ) + 1 = Today())</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_CustomerOwnerReleaseFlag_to_True</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Account.Last_CallReprt_Opty_Updated_Date__c</offsetFromField>
            <timeLength>90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Release Prospect Ownership for Call Plan %2F Call Report %28SE%29</fullName>
        <active>true</active>
        <description>If there is no updates for call plan/call report or opportunity for the prospect for 90 days (SE)</description>
        <formula>RecordType.DeveloperName = &quot;SME_Prospect&quot; &amp;&amp;  Owner.Segment__c = &quot;SE&quot; &amp;&amp;  (Owner.Profile.Name = &quot;SME-RM&quot; || Owner.Profile.Name = &quot;SME-TM&quot;) &amp;&amp;  (DATEVALUE( Last_CallReprt_Opty_Updated_Date__c ) = Today() ||  DATEVALUE(Last_CallReprt_Opty_Updated_Date__c ) + 1 = Today())</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_CustomerOwnerReleaseFlag_to_True</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Account.Last_CallReprt_Opty_Updated_Date__c</offsetFromField>
            <timeLength>90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update AllAfterTrigger to True</fullName>
        <actions>
            <name>Update_AllAfterTrigger_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.OwnerId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update CIS ID Unique key</fullName>
        <actions>
            <name>Update_CIS_ID_Unique_key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Account Name as CIS ID for prospect if Name contains all number</description>
        <formula>AND (RecordType.DeveloperName = &quot;SME_Prospect&quot;,  ISNUMBER(Name) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update CIS Unique Key%28Alphabetical%29</fullName>
        <actions>
            <name>Update_CIS_Unique_Key_Alphabetical</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND (RecordType.DeveloperName = &quot;SME_Prospect&quot;, NOT(ISNUMBER(Name)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Customer Insight Updated By%2FTime</fullName>
        <actions>
            <name>Update_Customer_Insight_Last_Modified_DT</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Customer_Insight_Updated_By_T</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>SME-Customer</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>SME-Network,SME-CEM/MS,SME-RM,SME-Event</value>
        </criteriaItems>
        <description>Update the User Name and TimeStamp when the fields for Customer Insight is updated</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update OwnerChangeExecutedByTrigger to FALSE</fullName>
        <actions>
            <name>Update_OwnerChangeExecutedByTrigger_to_F</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_OwnerChangeExecutedFrUI_to_T</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(OwnerID_Text__c)&amp;&amp;  OwnerChangeExecutedByTrigger__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update OwnerChangeExecutedFrUI to FALSE</fullName>
        <actions>
            <name>Update_OwnerChangeExecutedFrUI_to_F</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OwnerChangeExecutedFrUI__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Service RM-Update Customer Owner Changed Date</fullName>
        <actions>
            <name>Update_Customer_Owner_Changed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Change on Service RM required to update the Customer Owner Change Date and to be updated in VLINK</description>
        <formula>ISCHANGED( Service_RM__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
