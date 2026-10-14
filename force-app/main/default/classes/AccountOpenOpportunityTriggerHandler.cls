
public class AccountOpenOpportunityTriggerHandler {

    public static void recalculateCounts(
        List<Opportunity> newList,
        List<Opportunity> oldList
    ) {
        Set<Id> accountIds = new Set<Id>();

        if (newList != null) {
            for (Opportunity opp : newList) {
                if (opp.AccountId != null) {
                    accountIds.add(opp.AccountId);
                }
            }
        }

        if (oldList != null) {
            for (Opportunity opp : oldList) {
                if (opp.AccountId != null) {
                    accountIds.add(opp.AccountId);
                }
            }
        }

        if (accountIds.isEmpty()) {
            return;
        }

        Map<Id, Integer> openCounts = new Map<Id, Integer>();

        for (AggregateResult result : [
            SELECT AccountId accountId, COUNT(Id) total
            FROM Opportunity
            WHERE AccountId IN :accountIds
            AND IsClosed = false
            GROUP BY AccountId
        ]) {
            openCounts.put(
                (Id) result.get('accountId'),
                (Integer) result.get('total')
            );
        }

        List<Account> accountsToUpdate = new List<Account>();

        for (Account acc : [
            SELECT Id, Total_Open_Opportunities__c
            FROM Account
            WHERE Id IN :accountIds
        ]) {
            Integer countValue = openCounts.containsKey(acc.Id)
                ? openCounts.get(acc.Id)
                : 0;

            acc.Total_Open_Opportunities__c = countValue;
            accountsToUpdate.add(acc);
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}
