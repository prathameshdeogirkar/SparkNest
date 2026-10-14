
public class LeadDuplicateEmailTriggerHandler {

    public static void checkDuplicateEmails(List<Lead> newLeads) {
        Set<String> emails = new Set<String>();

        for (Lead leadRecord : newLeads) {
            if (String.isNotBlank(leadRecord.Email)) {
                emails.add(leadRecord.Email.trim().toLowerCase());
            }
        }

        if (emails.isEmpty()) {
            return;
        }

        Set<String> existingEmails = new Set<String>();

        for (Lead existingLead : [
            SELECT Email
            FROM Lead
            WHERE Email IN :emails
        ]) {
            existingEmails.add(existingLead.Email.toLowerCase());
        }

        for (Lead leadRecord : newLeads) {
            if (String.isNotBlank(leadRecord.Email) &&
                existingEmails.contains(
                    leadRecord.Email.trim().toLowerCase()
                )) {
                leadRecord.addError(
                    'A Lead with this email already exists.'
                );
            }
        }
    }
}