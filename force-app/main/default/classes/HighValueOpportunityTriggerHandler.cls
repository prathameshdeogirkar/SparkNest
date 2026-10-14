public with sharing class HighValueOpportunityTriggerHandler {

    public static void handleAfterInsert(List<Opportunity> opportunities) {

        List<Opportunity> highValueOpportunities =
            new List<Opportunity>();

        for (Opportunity opp : opportunities) {

            if (opp.Amount != null && opp.Amount > 5000000) {
                highValueOpportunities.add(opp);
            }
        }

        if (highValueOpportunities.isEmpty()) {
            return;
        }

        User salesManager = [
            SELECT Id
            FROM User
            WHERE FirstName = 'Prathamesh'
            AND LastName = 'Deogirkar'
            AND IsActive = true
            LIMIT 1
        ];

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

        if (!teamMembers.isEmpty()) {
            insert teamMembers;
        }
    }
}