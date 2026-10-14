trigger EnquiryProductInterestTrigger on Enquiry_Product__c (after insert, after update, after delete, after undelete) {

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            EnquiryProductInterestTriggerHandler.afterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            EnquiryProductInterestTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            EnquiryProductInterestTriggerHandler.afterDelete(Trigger.old);
        }
        if (Trigger.isUndelete) {
            EnquiryProductInterestTriggerHandler.afterUndelete(Trigger.new);
        }
    }

}