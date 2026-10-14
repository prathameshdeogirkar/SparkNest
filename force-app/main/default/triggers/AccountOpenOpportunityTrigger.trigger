
trigger AccountOpenOpportunityTrigger on Opportunity (
    after insert,
    after update,
    after delete,
    after undelete
) {
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        AccountOpenOpportunityTriggerHandler.recalculateCounts(
            Trigger.new,
            Trigger.isUpdate ? Trigger.old : null
        );
    } else if (Trigger.isDelete) {
        AccountOpenOpportunityTriggerHandler.recalculateCounts(
            null,
            Trigger.old
        );
    }
}
