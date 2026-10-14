public class OpportunityTriggerHandler {

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
}