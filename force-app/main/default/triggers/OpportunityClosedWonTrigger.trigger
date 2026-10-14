trigger OpportunityClosedWonTrigger on Opportunity (after update) {
    OpportunityClosedWonTriggerHandler.handleAfterUpdate(
        Trigger.new,
        Trigger.oldMap
    );
}