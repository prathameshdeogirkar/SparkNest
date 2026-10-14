trigger OpportunityRatingTrigger on Opportunity (after update) {

    OpportunityRatingTriggerHandler.handleAfterUpdate(
        Trigger.new,
        Trigger.oldMap,
        Trigger.newMap
    );
}