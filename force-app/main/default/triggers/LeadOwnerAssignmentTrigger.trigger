trigger LeadOwnerAssignmentTrigger on Lead (before insert) {

    LeadOwnerAssignmentTriggerHandler.handleBeforeInsert(
        Trigger.new
    );
}