trigger LeadTrigger on Lead (before insert) {

    LeadTriggerHandler.handleBeforeInsert(Trigger.new);

}