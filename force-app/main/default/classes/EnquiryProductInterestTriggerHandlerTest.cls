
@IsTest
private class EnquiryProductInterestTriggerHandlerTest {

    @TestSetup
    static void createTestData() {
        // Create a Product for the lookup on Enquiry_Product__c.
        Product2 product = new Product2(
    Name = 'Test SparkNest Product',
    SKU__c = 'TEST-SKU-001',    
    IsActive = true
);
        insert product;

        // Create two Enquiries for lookup/count tests.
        List<Enquiry__c> enquiries = new List<Enquiry__c>{
            new Enquiry__c(
                Subject__c = 'Test Enquiry One',
                Enquiry_Type__c = 'Product Enquiry',
                Customer_Budget__c = 1000
            ),
            new Enquiry__c(
                Subject__c = 'Test Enquiry Two',
                Enquiry_Type__c = 'Product Enquiry',
                Customer_Budget__c = 1000
            )
        };
        insert enquiries;
    }

    @IsTest
    static void testInsertDeleteAndUndelete() {
        List<Enquiry__c> enquiries = [
            SELECT Id, Total_Products_Interested__c
            FROM Enquiry__c
            ORDER BY CreatedDate ASC
        ];

        Product2 product = [
            SELECT Id FROM Product2
            WHERE Name = 'Test SparkNest Product'
            LIMIT 1
        ];

        Enquiry_Product__c interest = new Enquiry_Product__c(
            Enquiry__c = enquiries[0].Id,
            Product__c = product.Id,
            Quantity_Interested__c = 1
        );

        Test.startTest();
        insert interest;
        Test.stopTest();

        Enquiry__c afterInsert = [
            SELECT Total_Products_Interested__c
            FROM Enquiry__c WHERE Id = :enquiries[0].Id
        ];
        System.assertEquals(
            1,
            afterInsert.Total_Products_Interested__c,
            'Count should increase after insert.'
        );

        delete interest;

        Enquiry__c afterDelete = [
            SELECT Total_Products_Interested__c
            FROM Enquiry__c WHERE Id = :enquiries[0].Id
        ];
        System.assertEquals(
            0,
            afterDelete.Total_Products_Interested__c,
            'Count should return to zero after delete.'
        );

        undelete interest;

        Enquiry__c afterUndelete = [
            SELECT Total_Products_Interested__c
            FROM Enquiry__c WHERE Id = :enquiries[0].Id
        ];
        System.assertEquals(
            1,
            afterUndelete.Total_Products_Interested__c,
            'Count should increase after undelete.'
        );
    }

    @IsTest
    static void testChangingEnquiryLookup() {
        List<Enquiry__c> enquiries = [
            SELECT Id, Total_Products_Interested__c
            FROM Enquiry__c
            ORDER BY CreatedDate ASC
        ];

        Product2 product = [
            SELECT Id FROM Product2
            WHERE Name = 'Test SparkNest Product'
            LIMIT 1
        ];

        Enquiry_Product__c interest = new Enquiry_Product__c(
            Enquiry__c = enquiries[0].Id,
            Product__c = product.Id
        );
        insert interest;

        interest.Enquiry__c = enquiries[1].Id;
        update interest;

        Map<Id, Enquiry__c> refreshed = new Map<Id, Enquiry__c>([
            SELECT Id, Total_Products_Interested__c
            FROM Enquiry__c
            WHERE Id IN :new Set<Id>{enquiries[0].Id, enquiries[1].Id}
        ]);

        System.assertEquals(
            0,
            refreshed.get(enquiries[0].Id).Total_Products_Interested__c,
            'Original Enquiry count should decrease.'
        );
        System.assertEquals(
            1,
            refreshed.get(enquiries[1].Id).Total_Products_Interested__c,
            'Destination Enquiry count should increase.'
        );
    }
}
