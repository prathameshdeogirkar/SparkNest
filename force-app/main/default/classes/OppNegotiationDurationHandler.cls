public class OppNegotiationDurationHandler {

    public static void trackNegotiationDuration(
        List<Opportunity> newOpportunities,
        Map<Id, Opportunity> oldMap
    ) {
        for (Opportunity opp : newOpportunities) {
            if (opp.StageName == 'Negotiation/Review' &&
                (oldMap == null ||
                 oldMap.get(opp.Id).StageName != 'Negotiation/Review')) {

                opp.Negotiation_Start_Date__c = Date.today();
            }

            if (oldMap != null) {
                Opportunity oldOpp = oldMap.get(opp.Id);

                if (oldOpp.StageName == 'Negotiation/Review' &&
                    opp.StageName != 'Negotiation/Review' &&
                    oldOpp.Negotiation_Start_Date__c != null) {

                    opp.Negotiation_Duration_Days__c =
    oldOpp.Negotiation_Start_Date__c.daysBetween(Date.today());
                }
            }
        }
    }
}