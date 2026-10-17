
trigger EnquiryTrigger on Enquiry__c (
    before insert,
    before update,
    after insert
) {
    TriggerDispatcher.dispatch(
        Trigger.new,
        Trigger.isUpdate ? Trigger.oldMap : null
    );
}
