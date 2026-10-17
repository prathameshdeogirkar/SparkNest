
public class TriggerDispatcher {

    public static void dispatch(
        List<Enquiry__c> newRecords,
        Map<Id, Enquiry__c> oldMap
    ) {
        if (Trigger.isBefore && Trigger.isInsert) {
            EnquiryTriggerHandler.beforeInsert(newRecords);
        }

        if (Trigger.isBefore && Trigger.isUpdate) {
            EnquiryTriggerHandler.beforeUpdate(newRecords, oldMap);
        }

        if (Trigger.isAfter && Trigger.isInsert) {
            EnquiryTriggerHandler.afterInsert(newRecords);
        }
    }
}
