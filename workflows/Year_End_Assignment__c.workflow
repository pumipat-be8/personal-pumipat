<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_CIS_ID_Unique_key</fullName>
        <field>CIS_ID_Unique__c</field>
        <formula>CIS_ID__r.Name</formula>
        <name>Update CIS ID Unique key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update CIS ID Unique key</fullName>
        <actions>
            <name>Update_CIS_ID_Unique_key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Year_End_Assignment__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
