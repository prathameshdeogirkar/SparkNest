trigger CaseResolutionTimeTrigger on Case (before update) {
    CaseResolutionTimeTriggerHandler.calculateResolutionTime(
        Trigger.new,
        Trigger.oldMap
    );
}