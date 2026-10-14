trigger CasePriorityTrigger on Case (before insert) {
    CasePriorityTriggerHandler.handleBeforeInsert(Trigger.new);
}