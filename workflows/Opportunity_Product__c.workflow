<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Credit is setup</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity_Product__c.Status__c</field>
            <operation>equals</operation>
            <value>Setup</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
