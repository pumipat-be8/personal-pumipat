<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Cancellation_Notification_CEM_Exective_accompanied</fullName>
        <description>Cancellation Notification CEM/Exective accompanied</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>TM_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SME_Email_Templates/Cancellation_CEM_Exective_accompanied</template>
    </alerts>
    <alerts>
        <fullName>Notification_CEM_Exective_accompanied</fullName>
        <description>Notification CEM/Exective accompanied</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>TM_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SME_Email_Templates/Notification_CEM_Exective_accompanied</template>
    </alerts>
    <fieldUpdates>
        <fullName>Change_Record_Type_to_Call_Plan</fullName>
        <field>RecordTypeId</field>
        <lookupValue>CallPlan</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change Record Type to Call Plan</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_as_completed</fullName>
        <description>Once the visit date is filled, Complete field will be checked</description>
        <field>Completed__c</field>
        <literalValue>1</literalValue>
        <name>Mark as completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Accompanied_Executive_Name</fullName>
        <field>Accompanied_Executive_Name__c</field>
        <formula>Accompanied_by_Executive__r.FirstName  &amp; &quot; &quot; &amp;  Accompanied_by_Executive__r.LastName</formula>
        <name>Update Accompanied Executive Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CEM_MS_Accompanied_by_Date_Time</fullName>
        <field>Updated_Date_Time_by_CEM_MS__c</field>
        <formula>NOW()</formula>
        <name>Update CEM/MS Accompanied by Date/Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CEM_MS_Accompanied_by_ID</fullName>
        <field>Updated_by_CEM_MS_ID__c</field>
        <formula>$User.Id</formula>
        <name>Update CEM/MS Accompanied by ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CEM_MS_Accompanied_by_Name</fullName>
        <field>Updated_by_CEM_MS__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp;  $User.LastName</formula>
        <name>Update CEM/MS Accompanied by Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CEM_MS_User_Contact_Information</fullName>
        <field>CEM_MS_Contact_Information__c</field>
        <formula>If (ISBLANK($User.Phone), &quot;Phone: - / Email: &quot;  &amp;  $User.Email,
&quot;Phone: &quot; &amp; $User.Phone &amp; &quot; / Email: &quot; &amp;   $User.Email)</formula>
        <name>Update CEM/MS User Contact Information</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CallReport_Opty_Last_Updated_Date</fullName>
        <field>Last_CallReprt_Opty_Updated_Date__c</field>
        <formula>NOW()</formula>
        <name>Update CallReport/Opty Last Updated Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>CIS_ID__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Call_Plan_Record_Type_to_Closed</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ClosedCancelledCallPlan</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Call Plan Record Type to Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Call_Plan_to_Cancel</fullName>
        <field>Status__c</field>
        <literalValue>Cancel</literalValue>
        <name>Update Call Plan to Cancel</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Cancel_Call_Plan_Flag</fullName>
        <field>Cancel_Call_Plan__c</field>
        <literalValue>1</literalValue>
        <name>Update Cancel Call Plan Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Customer_Owner_to_SME_Admin</fullName>
        <field>OwnerId</field>
        <lookupValue>smeadmin@kasikornbank.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Update Customer Owner to SME-Admin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <targetObject>CIS_ID__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Type_to_Closed_Editable</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Closed_Contacted_Call_Report_No_Plan_Editable</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type to Closed Editable</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Type_to_Closed_with_Plan</fullName>
        <description>Update Record Type to Closed Call Report (Editable)</description>
        <field>RecordTypeId</field>
        <lookupValue>Closed_Contacted_Call_Report_Editable_Lead</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type to Closed with Plan</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Type_to_Secondary_Closed</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Closed_Contacted_Secondary_Call_Report_Main_Borrower_No_plan</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type to Secondary Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Contact</fullName>
        <field>Status__c</field>
        <literalValue>Contacted</literalValue>
        <name>Update Status to Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_TM_Email_Address</fullName>
        <field>TM_Email_Address__c</field>
        <formula>CreatedBy.Manager.Email</formula>
        <name>Update TM Email Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_field_Is_Report_This_Year</fullName>
        <field>Is_Call_Report_This_Year__c</field>
        <literalValue>1</literalValue>
        <name>Update field &quot;Is Report This Year&quot;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Cancellation Notification CEM%2FExective accompanied</fullName>
        <actions>
            <name>Cancellation_Notification_CEM_Exective_accompanied</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email Notify RM/TM when Accompanied by CEM/MS or Executive is changed</description>
        <formula>NOT(ISNEW()) &amp;&amp; (ISCHANGED( Accompanied_by_CEM_MS__c ) &amp;&amp; NOT(Accompanied_by_CEM_MS__c)) || (ISCHANGED(  Accompanied_by_Executive__c  ) &amp;&amp; ISBLANK(Accompanied_by_Executive__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Display CEM Section after Save Call Plan</fullName>
        <actions>
            <name>Change_Record_Type_to_Call_Plan</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call_Report__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>New Call Plan</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Is Call Report This Year</fullName>
        <actions>
            <name>Update_field_Is_Report_This_Year</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call_Report__c.Actual_Visit__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Mark Call Plan as Cancelled SF1</fullName>
        <actions>
            <name>Update_Call_Plan_Record_Type_to_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Call_Plan_to_Cancel</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call_Report__c.Cancel_Call_Plan__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Call_Report__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Call Plan</value>
        </criteriaItems>
        <description>Once the Cancel Call Plan is checked, update record type to Closed / Cancelled Call Plan</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Mark Call Plan as Completed SF1</fullName>
        <actions>
            <name>Update_Record_Type_to_Closed_with_Plan</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Status_to_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call_Report__c.Actual_Visit_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Call_Report__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Call Plan</value>
        </criteriaItems>
        <description>Once the Call Report with Plan, Actual Visit Date is filled, mark Completed flag to TRUE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Mark Call Report %28No Plan%29 as Completed</fullName>
        <actions>
            <name>Update_Record_Type_to_Closed_Editable</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call_Report__c.Actual_Visit_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Call_Report__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Call Report (No Plan)</value>
        </criteriaItems>
        <description>Once the Call Report (No Plan), Actual Visit Date is filled, mark Completed flag to TRUE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Mark Call Report with Plan as Completed</fullName>
        <actions>
            <name>Update_Record_Type_to_Closed_with_Plan</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call_Report__c.Actual_Visit_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Call_Report__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Call Report</value>
        </criteriaItems>
        <description>Once the Call Report with Plan, Actual Visit Date is filled, mark Completed flag to TRUE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Mark Secondary Call Report %28No Plan%29 as Completed</fullName>
        <actions>
            <name>Update_Record_Type_to_Secondary_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call_Report__c.Actual_Visit_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Call_Report__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Secondary Call Report Main Borrower (No plan)</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notification CEM%2FExective accompanied</fullName>
        <actions>
            <name>Notification_CEM_Exective_accompanied</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 or 2) and 3</booleanFilter>
        <criteriaItems>
            <field>Call_Report__c.Accompanied_by_CEM_MS__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Call_Report__c.Accompanied_by_Executive__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Call_Report__c.Accompanied_By_Names__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Email Notify RM/TM when Accompanied by CEM/MS or executive is entered</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Reminder Task for Call Report</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Call_Report__c.Offer_Interest__c</field>
            <operation>equals</operation>
            <value>Interest with condition</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Accompanied by CEM%2FMS or Executive</fullName>
        <actions>
            <name>Update_Accompanied_Executive_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_CEM_MS_Accompanied_by_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_CEM_MS_Accompanied_by_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_CEM_MS_Accompanied_by_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_CEM_MS_User_Contact_Information</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Call_Report__c.Accompanied_by_CEM_MS__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Call_Report__c.Accompanied_by_Executive__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update Accompanied by CEM/MS or Executive information (Name, timestamp, ID, CEM contact information)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Last Call Report%2FOpty Updated Date</fullName>
        <actions>
            <name>Update_CallReport_Opty_Last_Updated_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call_Report__c.Status__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update Account.Last CallReprt/Opty Updated Date whenever call plan/call report is created or updated</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update TM Email Address</fullName>
        <actions>
            <name>Update_TM_Email_Address</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call_Report__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update TM email address for sending notification email to TM</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
