
@IsTest
private class EnquiryStatusLookupActionTest {

    @TestSetup
    static void setupData() {
        Contact customer = new Contact(
            FirstName = 'Aarav',
            LastName = 'StatusTest',
            Email = 'aarav.status.test@example.com'
        );
        insert customer;

        insert new List<Enquiry__c>{
            new Enquiry__c(
                Subject__c = 'Older Enquiry',
                Contact__c = customer.Id,
                Enquiry_Type__c = 'Product Enquiry',
                Customer_Budget__c = 2000,
                Priority__c = 'Medium',
                Source__c = 'Website',
                Status__c = 'Closed',
                Closed_Date__c = Date.today().addDays(-2)
            ),
            new Enquiry__c(
                Subject__c = 'Latest Enquiry',
                Contact__c = customer.Id,
                Enquiry_Type__c = 'Product Enquiry',
                Customer_Budget__c = 3000,
                Priority__c = 'High',
                Source__c = 'Website',
                Status__c = 'In Progress'
            )
        };
    }

    @IsTest
    static void findsLatestEnquiry() {
        EnquiryStatusLookupAction.Request req =
            new EnquiryStatusLookupAction.Request();
        req.emailAddress = 'aarav.status.test@example.com';

        Test.startTest();
        List<EnquiryStatusLookupAction.Response> results =
            EnquiryStatusLookupAction.lookupLatestEnquiry(
                new List<EnquiryStatusLookupAction.Request>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].found);
        System.assertEquals('In Progress', results[0].enquiryStatus);
        System.assertEquals('Latest Enquiry', results[0].enquirySubject);
        System.assertEquals(null, results[0].closedDate);
    }

    @IsTest
    static void handlesUnknownEmail() {
        EnquiryStatusLookupAction.Request req =
            new EnquiryStatusLookupAction.Request();
        req.emailAddress = 'unknown.status.test@example.com';

        List<EnquiryStatusLookupAction.Response> results =
            EnquiryStatusLookupAction.lookupLatestEnquiry(
                new List<EnquiryStatusLookupAction.Request>{ req }
            );

        System.assertEquals(false, results[0].found);
        System.assert(results[0].message.contains('No customer'));
    }

    @IsTest
    static void handlesMissingEmail() {
        EnquiryStatusLookupAction.Request req =
            new EnquiryStatusLookupAction.Request();

        List<EnquiryStatusLookupAction.Response> results =
            EnquiryStatusLookupAction.lookupLatestEnquiry(
                new List<EnquiryStatusLookupAction.Request>{ req }
            );

        System.assertEquals(false, results[0].found);
        System.assertEquals(
            'Please provide your email address.',
            results[0].message
        );
    }
}
