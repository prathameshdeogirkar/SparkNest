public class LeadTriggerHandler {

    public static void handleBeforeInsert(List<Lead> leads) {

        for (Lead lead : leads) {

            if (lead.LeadSource == 'Web') {
                lead.Rating = 'Cold';
            }
            else {
                lead.Rating = 'Hot';
            }

        }

    }

}