public class EmailMessageAfterInsertHandler {

    public static void handleAfterInsert(
        List<EmailMessage> emailMessages
    ) {
        Map<Id, String> recipientsByCase = new Map<Id, String>();

        for (EmailMessage email : emailMessages) {
            if (email.Incoming == false &&
                email.ParentId != null &&
                email.ParentId.getSObjectType() == Case.SObjectType) {

                recipientsByCase.put(
                    email.ParentId,
                    email.ToAddress
                );
            }
        }

        if (recipientsByCase.isEmpty()) {
            return;
        }

        List<Case> cases = [
            SELECT Id, ContactId, Contact.Email, Status, EntitlementId
            FROM Case
            WHERE Id IN :recipientsByCase.keySet()
        ];

        List<Id> caseIdsToComplete = new List<Id>();

        for (Case c : cases) {
            String recipients = recipientsByCase.get(c.Id);

            if (c.ContactId != null &&
                c.Contact.Email != null &&
                recipients != null &&
                recipients.toLowerCase().contains(
                    c.Contact.Email.toLowerCase()
                ) &&
                c.Status == 'Working' &&
                c.EntitlementId != null) {

                caseIdsToComplete.add(c.Id);
            }
        }

        if (!caseIdsToComplete.isEmpty()) {
            MilestoneUtils.completeMilestone(
                caseIdsToComplete,
                'First Response to Customer',
                System.now()
            );
        }
    }
}