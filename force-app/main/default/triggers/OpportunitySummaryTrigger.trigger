trigger OpportunitySummaryTrigger on Opportunity (
    after insert,
    after update,
    after delete
) {
    OpportunitySummaryTriggerHandler.handle(
        Trigger.new,
        Trigger.old,
        Trigger.newMap,
        Trigger.oldMap,
        Trigger.isInsert,
        Trigger.isUpdate,
        Trigger.isDelete
    );
}