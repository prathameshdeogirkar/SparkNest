trigger LeadPhoneBeforeConvertTrigger on Lead (before update) {
    LeadPhoneBeforeConvertTriggerHandler.validatePhoneBeforeConversion(
        Trigger.new,
        Trigger.oldMap
    );
}