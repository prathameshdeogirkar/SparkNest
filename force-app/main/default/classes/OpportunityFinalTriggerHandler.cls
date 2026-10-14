public with sharing class OpportunityFinalTriggerHandler {

    // BEFORE UPDATE
    // Handles Opportunity fields


    public static void handleBeforeUpdate(
        List<Opportunity> newOpps,
        Map<Id, Opportunity> oldMap,
        Map<Id, Opportunity> newMap
    ) {

        for (Opportunity opp : newOpps) {

            Opportunity oldOpp = oldMap.get(opp.Id);
            Opportunity newOpp = newMap.get(opp.Id);

            if (
                newOpp.StageName == 'Closed Won' &&
                oldOpp.StageName != 'Closed Won'
            ) {

                newOpp.CloseDate = Date.today();
                newOpp.Type = 'New Customer';
            }
        }
    }


    // AFTER UPDATE
    // Handles Account + Opportunity Team
    

    public static void handleAfterUpdate(
        List<Opportunity> newOpps,
        Map<Id, Opportunity> oldMap,
        Map<Id, Opportunity> newMap
    ) {

        Set<Id> accountIds = new Set<Id>();

        List<Opportunity> closedWonOpportunities =
            new List<Opportunity>();


        // 1. Find Opportunities that became Closed Won

        for (Opportunity opp : newOpps) {

            Opportunity oldOpp = oldMap.get(opp.Id);
            Opportunity newOpp = newMap.get(opp.Id);

            if (
                newOpp.StageName == 'Closed Won' &&
                oldOpp.StageName != 'Closed Won'
            ) {

                if (newOpp.AccountId != null) {
                    accountIds.add(newOpp.AccountId);
                }

                closedWonOpportunities.add(newOpp);
            }
        }


        // Nothing became Closed Won

        if (closedWonOpportunities.isEmpty()) {
            return;
        }


        // 2. Calculate Opportunity Count and Amount

        Map<Id, Integer> opportunityCountByAccount =
            new Map<Id, Integer>();

        Map<Id, Decimal> opportunityAmountByAccount =
            new Map<Id, Decimal>();


        if (!accountIds.isEmpty()) {

            for (Opportunity opp : [
                SELECT Id, AccountId, Amount
                FROM Opportunity
                WHERE AccountId IN :accountIds
            ]) {

                if (
                    !opportunityCountByAccount.containsKey(
                        opp.AccountId
                    )
                ) {

                    opportunityCountByAccount.put(
                        opp.AccountId,
                        0
                    );

                    opportunityAmountByAccount.put(
                        opp.AccountId,
                        0
                    );
                }


                opportunityCountByAccount.put(
                    opp.AccountId,
                    opportunityCountByAccount.get(opp.AccountId) + 1
                );


                if (opp.Amount != null) {

                    opportunityAmountByAccount.put(
                        opp.AccountId,
                        opportunityAmountByAccount.get(opp.AccountId)
                        + opp.Amount
                    );
                }
            }
        }


        // 3. Update Accounts

        List<Account> accountsToUpdate =
            new List<Account>();


        if (!accountIds.isEmpty()) {

            for (Account acc : [
                SELECT Id,
                       Rating,
                       Total_Opportunity_Count__c,
                       Total_Opportunity_Amount__c
                FROM Account
                WHERE Id IN :accountIds
            ]) {

                acc.Rating = 'Hot';


                acc.Total_Opportunity_Count__c =
                    opportunityCountByAccount.containsKey(acc.Id)
                    ? opportunityCountByAccount.get(acc.Id)
                    : 0;


                acc.Total_Opportunity_Amount__c =
                    opportunityAmountByAccount.containsKey(acc.Id)
                    ? opportunityAmountByAccount.get(acc.Id)
                    : 0;


                accountsToUpdate.add(acc);
            }
        }


        // One Account DML

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }


        // 4. Find High-Value Opportunities

        List<Opportunity> highValueOpportunities =
            new List<Opportunity>();


        for (Opportunity opp : closedWonOpportunities) {

            if (
                opp.Amount != null &&
                opp.Amount > 5000000
            ) {

                highValueOpportunities.add(opp);
            }
        }


        if (highValueOpportunities.isEmpty()) {
            return;
        }


        // 5. Query Sales Manager once

        User salesManager = [
            SELECT Id
            FROM User
            WHERE FirstName = 'Prathamesh'
            AND LastName = 'Deogirkar'
            AND IsActive = true
            LIMIT 1
        ];


        // 6. Create Opportunity Team Members

        List<OpportunityTeamMember> teamMembers =
            new List<OpportunityTeamMember>();


        for (Opportunity opp : highValueOpportunities) {

            teamMembers.add(
                new OpportunityTeamMember(
                    OpportunityId = opp.Id,
                    UserId = salesManager.Id,
                    TeamMemberRole = 'Sales Manager'
                )
            );
        }


        // One Team Member DML

        if (!teamMembers.isEmpty()) {
            insert teamMembers;
        }
    }
}