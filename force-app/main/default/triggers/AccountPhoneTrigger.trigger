trigger AccountPhoneTrigger on Account (after update) {
    AccountPhoneTriggerHandler.handleAfterUpdate(
        Trigger.new,
        Trigger.oldMap,
        Trigger.newMap
    );
}