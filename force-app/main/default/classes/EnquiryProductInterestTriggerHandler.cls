public with sharing class EnquiryProductInterestTriggerHandler {

    public static void afterInsert(
    List<Enquiry_Product__c> newRecords
) {
    Set<Id> enquiryIds = new Set<Id>();

    for (Enquiry_Product__c record : newRecords) {
        if (record.Enquiry__c != null) {
            enquiryIds.add(record.Enquiry__c);
        }
    }

    recalculateCounts(enquiryIds);
}

    public static void afterUpdate(
    List<Enquiry_Product__c> newRecords,
    Map<Id, Enquiry_Product__c> oldRecordsById
) {
    Set<Id> enquiryIds = new Set<Id>();

    for (Enquiry_Product__c newRecord : newRecords) {
        Enquiry_Product__c oldRecord =
            oldRecordsById.get(newRecord.Id);

        if (oldRecord != null &&
            oldRecord.Enquiry__c != newRecord.Enquiry__c) {

            if (oldRecord.Enquiry__c != null) {
                enquiryIds.add(oldRecord.Enquiry__c);
            }

            if (newRecord.Enquiry__c != null) {
                enquiryIds.add(newRecord.Enquiry__c);
            }
        }
    }

    recalculateCounts(enquiryIds);
}

    public static void afterDelete(
    List<Enquiry_Product__c> oldRecords
) {
    Set<Id> enquiryIds = new Set<Id>();

    for (Enquiry_Product__c record : oldRecords) {
        if (record.Enquiry__c != null) {
            enquiryIds.add(record.Enquiry__c);
        }
    }

    recalculateCounts(enquiryIds);
}

    public static void afterUndelete(
    List<Enquiry_Product__c> restoredRecords
) {
    Set<Id> enquiryIds = new Set<Id>();

    for (Enquiry_Product__c record : restoredRecords) {
        if (record.Enquiry__c != null) {
            enquiryIds.add(record.Enquiry__c);
        }
    }

    recalculateCounts(enquiryIds);
}

    private static void recalculateCounts(Set<Id> enquiryIds) {
    if (enquiryIds.isEmpty()) {
        return;
    }

    // Initialize all affected Enquiries to zero.
    Map<Id, Integer> productCounts = new Map<Id, Integer>();

    for (Id enquiryId : enquiryIds) {
        productCounts.put(enquiryId, 0);
    }

    // Count interest records for each Enquiry.
    for (AggregateResult result : [
        SELECT Enquiry__c enquiryId, COUNT(Id) total
        FROM Enquiry_Product__c
        WHERE Enquiry__c IN :enquiryIds
        GROUP BY Enquiry__c
    ]) {
        productCounts.put(
            (Id) result.get('enquiryId'),
            (Integer) result.get('total')
        );
    }

    // Retrieve affected Enquiries.
    List<Enquiry__c> enquiriesToUpdate = [
        SELECT Id, Total_Products_Interested__c
        FROM Enquiry__c
        WHERE Id IN :enquiryIds
    ];

    // Update the count on each Enquiry.
    for (Enquiry__c enquiry : enquiriesToUpdate) {
        enquiry.Total_Products_Interested__c =
            productCounts.get(enquiry.Id);
    }

    if (!enquiriesToUpdate.isEmpty()) {
        update enquiriesToUpdate;
    }
}
}