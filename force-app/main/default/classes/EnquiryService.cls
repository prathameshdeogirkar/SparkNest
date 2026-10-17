
public class EnquiryService {

    // Before Insert: set default Status and validate budget.
    public static void handleBeforeInsert(
        List<Enquiry__c> newRecords
    ) {
        for (Enquiry__c enquiry : newRecords) {

            if (String.isBlank(enquiry.Status__c)) {
                enquiry.Status__c = 'New';
            }

            if (
                enquiry.Customer_Budget__c != null &&
                enquiry.Customer_Budget__c < 1000
            ) {
                enquiry.addError(
                    'Customer budget must be at least ₹1,000'
                );
            }
        }
    }

    // Before Update: set Closed Date when Status changes to Closed.
    public static void handleBeforeUpdate(
        List<Enquiry__c> newRecords,
        Map<Id, Enquiry__c> oldMap
    ) {
        for (Enquiry__c enquiry : newRecords) {

            Enquiry__c oldEnquiry = oldMap.get(enquiry.Id);

            if (
                enquiry.Status__c == 'Closed' &&
                oldEnquiry.Status__c != 'Closed'
            ) {
                enquiry.Closed_Date__c = Date.today();
            }
        }
    }

    // After Insert: create a follow-up Task for each Enquiry.
    public static void handleAfterInsert(
        List<Enquiry__c> newRecords
    ) {
        List<Task> tasksToInsert = new List<Task>();

        for (Enquiry__c enquiry : newRecords) {
            tasksToInsert.add(new Task(
                Subject = 'Follow up: ' + enquiry.Subject__c,
                ActivityDate = Date.today().addDays(3),
                OwnerId = enquiry.OwnerId,
                WhatId = enquiry.Id,
                Status = 'Not Started',
                Priority = 'Normal'
            ));
        }

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
}
