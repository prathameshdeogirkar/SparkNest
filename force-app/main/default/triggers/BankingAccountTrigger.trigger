trigger BankingAccountTrigger on Account (after insert) {
    BankingAccountTriggerHandler.handleAfterInsert(Trigger.new);
}