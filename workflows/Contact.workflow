<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Clear_Value</fullName>
        <field>FirstName</field>
        <formula>&quot; &quot;</formula>
        <name>Clear Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Customer_Preference_Modified_By</fullName>
        <field>Contact_Preference_Last_Modified_By__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp;  $User.LastName</formula>
        <name>Update Customer Preference Modified By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Customer_Preference_Modified_Date</fullName>
        <field>Contact_Preference_Last_Modified_Date__c</field>
        <formula>Now()</formula>
        <name>Update Customer Preference Modified Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Customer Preference Last Modified By%2FDate</fullName>
        <actions>
            <name>Update_Customer_Preference_Modified_By</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Customer_Preference_Modified_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR( ISCHANGED(  Character__c  ),  ISCHANGED( Other_Info_about_Character__c ),   ISCHANGED( Life_Style__c ),  ISCHANGED( Life_Style_Details__c ),    ISCHANGED(  Other_Life_Style_Detail__c  ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
