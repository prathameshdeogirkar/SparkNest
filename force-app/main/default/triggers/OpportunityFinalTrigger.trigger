trigger OpportunityFinalTrigger on Opportunity (
    before update,
    after update
) {
    
    if (Trigger.isBefore && Trigger.isUpdate) {
        
        OpportunityFinalTriggerHandler.handleBeforeUpdate(
            Trigger.new,
            Trigger.oldMap,
            Trigger.newMap
        );
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        
        OpportunityFinalTriggerHandler.handleAfterUpdate(
            Trigger.new,
            Trigger.oldMap,
            Trigger.newMap
        );
    }
}