public class OpportunitySummaryTriggerHandler {

    public static void handle(
        List<Opportunity> newOpps,
        List<Opportunity> oldOpps,
        Map<Id, Opportunity> newMap,
        Map<Id, Opportunity> oldMap,
        Boolean isInsert,
        Boolean isUpdate,
        Boolean isDelete
    ) {

        Set<Id> accountIds = new Set<Id>();

        // Insert / Update
        if (isInsert || isUpdate) {
            for (Opportunity opp : newOpps) {
                if (opp.AccountId != null) {
                    accountIds.add(opp.AccountId);
                }
            }
        }

        // Delete / Old Account during Update
        if (isDelete || isUpdate) {
            for (Opportunity opp : oldOpps) {
                if (opp.AccountId != null) {
                    accountIds.add(opp.AccountId);
                }
            }
        }

        if (accountIds.isEmpty()) {
            return;
        }

        // Get all Opportunities for affected Accounts
        List<Opportunity> opportunities = [
            SELECT Id, AccountId, Amount
            FROM Opportunity
            WHERE AccountId IN :accountIds
        ];

        Map<Id, Integer> countByAccountId = new Map<Id, Integer>();
        Map<Id, Decimal> amountByAccountId = new Map<Id, Decimal>();

        for (Opportunity opp : opportunities) {

            if (!countByAccountId.containsKey(opp.AccountId)) {
                countByAccountId.put(opp.AccountId, 0);
                amountByAccountId.put(opp.AccountId, 0);
            }

            countByAccountId.put(
                opp.AccountId,
                countByAccountId.get(opp.AccountId) + 1
            );

            if (opp.Amount != null) {
                amountByAccountId.put(
                    opp.AccountId,
                    amountByAccountId.get(opp.AccountId) + opp.Amount
                );
            }
        }

        // Get affected Accounts
        List<Account> accountsToUpdate = [
            SELECT Id,
                   Total_Opportunity_Count__c,
                   Total_Opportunity_Amount__c
            FROM Account
            WHERE Id IN :accountIds
        ];

        for (Account acc : accountsToUpdate) {

            Integer opportunityCount =
                countByAccountId.containsKey(acc.Id)
                ? countByAccountId.get(acc.Id)
                : 0;

            Decimal opportunityAmount =
                amountByAccountId.containsKey(acc.Id)
                ? amountByAccountId.get(acc.Id)
                : 0;

            acc.Total_Opportunity_Count__c = opportunityCount;
            acc.Total_Opportunity_Amount__c = opportunityAmount;
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}