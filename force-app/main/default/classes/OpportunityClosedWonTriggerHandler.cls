public class OpportunityClosedWonTriggerHandler {

    public static void handleAfterUpdate(
        List<Opportunity> newOpportunities,
        Map<Id, Opportunity> oldMap
    ) {
        List<Task> tasksToCreate = new List<Task>();

        for (Opportunity opp : newOpportunities) {
            Opportunity oldOpp = oldMap.get(opp.Id);

            if (opp.StageName == 'Closed Won' &&
                oldOpp.StageName != 'Closed Won') {

                Task followUpTask = new Task(
                    Subject = 'Post-Sale Check-In',
                    WhatId = opp.Id,
                    OwnerId = opp.OwnerId,
                    ActivityDate = Date.today().addDays(7)
                );

                tasksToCreate.add(followUpTask);
            }
        }

        if (!tasksToCreate.isEmpty()) {
            insert tasksToCreate;
        }
    }
}