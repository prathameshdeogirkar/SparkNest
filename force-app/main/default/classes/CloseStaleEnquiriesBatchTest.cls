
@IsTest
private class CloseStaleEnquiriesBatchTest {

    @IsTest
    static void testClosesStaleEnquiry() {
        Enquiry__c stale = new Enquiry__c(
            Subject__c = 'Stale Enquiry',
            Status__c = 'In Progress',
            Customer_Budget__c = 2000,
            Enquiry_Type__c = 'Product Enquiry'
        );
        insert stale;

        Test.setCreatedDate(
            stale.Id,
            DateTime.now().addDays(-45)
        );

        // No completed activity is created for this Enquiry.
        Test.startTest();
        Database.executeBatch(
            new CloseStaleEnquiriesBatch(),
            200
        );
        Test.stopTest();

        Enquiry__c result = [
            SELECT Status__c, Closed_Date__c
            FROM Enquiry__c
            WHERE Id = :stale.Id
        ];

        System.assertEquals(
            'Closed',
            result.Status__c,
            'A stale Enquiry should be closed.'
        );
        System.assertEquals(
            Date.today(),
            result.Closed_Date__c,
            'Closing the Enquiry should set Closed Date.'
        );
    }

    @IsTest
    static void testDoesNotCloseRecentEnquiry() {
        Enquiry__c recent = new Enquiry__c(
            Subject__c = 'Recent Enquiry',
            Status__c = 'In Progress',
            Customer_Budget__c = 2000,
            Enquiry_Type__c = 'Product Enquiry'
        );
        insert recent;

        Test.startTest();
        Database.executeBatch(
            new CloseStaleEnquiriesBatch(),
            200
        );
        Test.stopTest();

        Enquiry__c result = [
            SELECT Status__c
            FROM Enquiry__c
            WHERE Id = :recent.Id
        ];

        System.assertEquals(
            'In Progress',
            result.Status__c,
            'A recent Enquiry must remain open.'
        );
    }
}
