
global class CloseStaleEnquiriesBatch
    implements Database.Batchable<SObject> {

    global Database.QueryLocator start(
        Database.BatchableContext bc
    ) {
        Date cutoffDate = Date.today().addDays(-30);

        return Database.getQueryLocator([
            SELECT Id, Status__c, CreatedDate, LastActivityDate
            FROM Enquiry__c
            WHERE Status__c = 'In Progress'
            AND CreatedDate < :cutoffDate
            AND (
                LastActivityDate = null
                OR LastActivityDate < :cutoffDate
            )
        ]);
    }

    global void execute(
        Database.BatchableContext bc,
        List<Enquiry__c> scope
    ) {
        for (Enquiry__c enquiry : scope) {
            enquiry.Status__c = 'Closed';
        }

        if (!scope.isEmpty()) {
            update scope;
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Batch completed.
    }
}
