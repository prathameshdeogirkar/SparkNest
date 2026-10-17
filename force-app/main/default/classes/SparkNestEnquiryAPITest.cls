
@IsTest
private class SparkNestEnquiryAPITest {

    private static void prepareRestContext(String requestBody) {
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/sparknest/enquiries/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(requestBody);

        RestContext.request = request;
        RestContext.response = new RestResponse();
    }

    @IsTest
    static void testNewCustomerCreatesContactAndEnquiry() {
        String email = 'newcustomer@sparknest.test';

        prepareRestContext(JSON.serialize(new Map<String, Object>{
            'firstName' => 'Aarav',
            'lastName' => 'Sharma',
            'email' => email,
            'subject' => 'Smart Home Enquiry',
            'enquiryType' => 'Product Enquiry',
            'customerBudget' => 5000,
            'priority' => 'Medium',
            'source' => 'Website'
        }));

        Test.startTest();
        SparkNestEnquiryAPI.EnquiryResponse result =
            SparkNestEnquiryAPI.createEnquiry();
        Test.stopTest();

        System.assertEquals(true, result.success);
        System.assertEquals(201, RestContext.response.statusCode);
        System.assertNotEquals(null, result.contactId);
        System.assertNotEquals(null, result.enquiryId);

        Contact customer = [
            SELECT Id, Email, LastName
            FROM Contact
            WHERE Id = :result.contactId
        ];
        System.assertEquals(email, customer.Email);
        System.assertEquals('Sharma', customer.LastName);

        Enquiry__c enquiry = [
            SELECT Id, Subject__c, Contact__c, Status__c
            FROM Enquiry__c
            WHERE Id = :result.enquiryId
        ];
        System.assertEquals('Smart Home Enquiry', enquiry.Subject__c);
        System.assertEquals(customer.Id, enquiry.Contact__c);
        System.assertEquals('New', enquiry.Status__c);
    }

    @IsTest
    static void testExistingCustomerIsReused() {
        String email = 'existingcustomer@sparknest.test';

        Contact existing = new Contact(
            FirstName = 'Mira',
            LastName = 'Patel',
            Email = email
        );
        insert existing;

        prepareRestContext(JSON.serialize(new Map<String, Object>{
            'firstName' => 'Mira',
            'lastName' => 'Patel',
            'email' => email,
            'subject' => 'Annual Care Plan',
            'enquiryType' => 'Care Plan Enquiry',
            'customerBudget' => 2500,
            'source' => 'Website'
        }));

        Test.startTest();
        SparkNestEnquiryAPI.EnquiryResponse result =
            SparkNestEnquiryAPI.createEnquiry();
        Test.stopTest();

        System.assertEquals(true, result.success);
        System.assertEquals(201, RestContext.response.statusCode);
        System.assertEquals(existing.Id, result.contactId);

        Integer contactCount = [
            SELECT COUNT()
            FROM Contact
            WHERE Email = :email
        ];
        System.assertEquals(
            1,
            contactCount,
            'The API must reuse the existing Contact.'
        );

        Enquiry__c enquiry = [
            SELECT Id, Contact__c, Enquiry_Type__c
            FROM Enquiry__c
            WHERE Id = :result.enquiryId
        ];
        System.assertEquals(existing.Id, enquiry.Contact__c);
        System.assertEquals('Care Plan Enquiry', enquiry.Enquiry_Type__c);
    }

    @IsTest
    static void testMissingEmailReturnsBadRequest() {
        prepareRestContext(JSON.serialize(new Map<String, Object>{
            'firstName' => 'Riya',
            'lastName' => 'Desai',
            'subject' => 'Product Enquiry'
        }));

        Test.startTest();
        SparkNestEnquiryAPI.EnquiryResponse result =
            SparkNestEnquiryAPI.createEnquiry();
        Test.stopTest();

        System.assertEquals(false, result.success);
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals('Email is required.', result.message);
        System.assertEquals(null, result.contactId);
        System.assertEquals(null, result.enquiryId);
    }
}
