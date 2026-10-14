public with sharing class OpportunityRatingTriggerHandler {

    public static void handleAfterUpdate(
        List<Opportunity> newOpps,
        Map<Id, Opportunity> oldMap,
        Map<Id, Opportunity> newMap
    ) {

        Set<Id> accountIds = new Set<Id>();

        for (Opportunity opp : newOpps) {

            Opportunity oldOpp = oldMap.get(opp.Id);
            Opportunity newOpp = newMap.get(opp.Id);

            if (
                newOpp.StageName == 'Closed Won' &&
                oldOpp.StageName != 'Closed Won' &&
                newOpp.AccountId != null
            ) {
                accountIds.add(newOpp.AccountId);
            }
        }

        if (accountIds.isEmpty()) {
            return;
        }

        List<Account> accountsToUpdate = new List<Account>();

        for (Account acc : [
            SELECT Id, Rating
            FROM Account
            WHERE Id IN :accountIds
        ]) {
            acc.Rating = 'Hot';
            accountsToUpdate.add(acc);
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}