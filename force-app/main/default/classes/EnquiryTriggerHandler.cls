
public class EnquiryTriggerHandler {

    public static void beforeInsert(List<Enquiry__c> newRecords) {
        EnquiryService.handleBeforeInsert(newRecords);
    }

    public static void beforeUpdate(
        List<Enquiry__c> newRecords,
        Map<Id, Enquiry__c> oldMap
    ) {
        EnquiryService.handleBeforeUpdate(newRecords, oldMap);
    }

    public static void afterInsert(List<Enquiry__c> newRecords) {
        EnquiryService.handleAfterInsert(newRecords);
    }
}
