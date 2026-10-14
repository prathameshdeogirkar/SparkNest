trigger HighValueOpportunityTrigger on Opportunity (after insert) {

    HighValueOpportunityTriggerHandler.handleAfterInsert(
        Trigger.new
    );
}