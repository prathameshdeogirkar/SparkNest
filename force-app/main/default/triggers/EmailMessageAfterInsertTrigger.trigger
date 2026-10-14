trigger EmailMessageAfterInsertTrigger on EmailMessage (after insert) {
    EmailMessageAfterInsertHandler.handleAfterInsert(
        Trigger.new
    );
}