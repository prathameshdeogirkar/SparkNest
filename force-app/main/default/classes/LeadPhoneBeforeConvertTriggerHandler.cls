public class LeadPhoneBeforeConvertTriggerHandler {

    public static void validatePhoneBeforeConversion(
        List<Lead> newLeads,
        Map<Id, Lead> oldMap
    ) {
        for (Lead leadRecord : newLeads) {
            Lead oldLead = oldMap.get(leadRecord.Id);

            if (leadRecord.IsConverted &&
                !oldLead.IsConverted &&
                String.isBlank(leadRecord.Phone)) {

                leadRecord.addError(
                    'Enter a Phone number before converting this Lead.'
                );
            }
        }
    }
}