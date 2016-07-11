global class SME_Monthly_DML_Batch implements Database.Batchable<Monthly_Performance__c> ,Database.Stateful{
    private List<Monthly_Performance__c> dmlList;
    global SME_Monthly_DML_Batch(List<Monthly_Performance__c> dmlList) {
    	this.dmlList = dmlList;
    }
    global List<Monthly_Performance__c> start(Database.BatchableContext bc) {
    	return dmlList;
    }
    
    global void execute(Database.BatchableContext BC, list<Monthly_Performance__c> partialList) {
    	upsert partialList External_ID__c;
    }

    global void finish(Database.BatchableContext BC) {
    	Database.executeBatch(new SME_MonthlyReorder_Batch());
    }
}