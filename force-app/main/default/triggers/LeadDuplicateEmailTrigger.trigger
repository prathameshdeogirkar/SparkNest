
trigger LeadDuplicateEmailTrigger on Lead (before insert) {
    LeadDuplicateEmailTriggerHandler.checkDuplicateEmails(
        Trigger.new
    );
}
