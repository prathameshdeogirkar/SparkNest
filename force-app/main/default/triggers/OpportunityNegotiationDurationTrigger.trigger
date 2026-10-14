trigger OpportunityNegotiationDurationTrigger on Opportunity (
    before insert,
    before update
) {
    OppNegotiationDurationHandler.trackNegotiationDuration(
        Trigger.new,
        Trigger.isUpdate ? Trigger.oldMap : null
    );
}