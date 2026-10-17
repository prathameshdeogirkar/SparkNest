
@RestResource(urlMapping='/sparknest/enquiries/*')
global with sharing class SparkNestEnquiryAPI {

    global class EnquiryRequest {
        public String firstName;
        public String lastName;
        public String email;
        public String subject;
        public String enquiryType;
        public Decimal customerBudget;
        public String priority;
        public String source;
    }

    global class EnquiryResponse {
        public Boolean success;
        public String message;
        public Id contactId;
        public Id enquiryId;

        global EnquiryResponse(
            Boolean success,
            String message,
            Id contactId,
            Id enquiryId
        ) {
            this.success = success;
            this.message = message;
            this.contactId = contactId;
            this.enquiryId = enquiryId;
        }
    }

    @HttpPost
    global static EnquiryResponse createEnquiry() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            EnquiryRequest input = (EnquiryRequest) JSON.deserialize(
                req.requestBody.toString(),
                EnquiryRequest.class
            );

            if (input == null || String.isBlank(input.email)) {
                res.statusCode = 400;
                return new EnquiryResponse(
                    false,
                    'Email is required.',
                    null,
                    null
                );
            }

            if (String.isBlank(input.lastName)) {
                res.statusCode = 400;
                return new EnquiryResponse(
                    false,
                    'Last name is required.',
                    null,
                    null
                );
            }

            List<Contact> matches = [
                SELECT Id, FirstName, LastName, Email
                FROM Contact
                WHERE Email = :input.email
                LIMIT 1
            ];

            Contact customer;
            if (!matches.isEmpty()) {
                customer = matches[0];
            } else {
                customer = new Contact(
                    FirstName = input.firstName,
                    LastName = input.lastName,
                    Email = input.email
                );
                insert customer;
            }

            Enquiry__c enquiry = new Enquiry__c(
                Subject__c = input.subject,
                Contact__c = customer.Id,
                Enquiry_Type__c = String.isBlank(input.enquiryType)
                    ? 'Product Enquiry'
                    : input.enquiryType,
                Customer_Budget__c = input.customerBudget,
                Priority__c = String.isBlank(input.priority)
                    ? 'Medium'
                    : input.priority,
                Source__c = String.isBlank(input.source)
                    ? 'Website'
                    : input.source
            );
            insert enquiry;

            res.statusCode = 201;
            return new EnquiryResponse(
                true,
                matches.isEmpty()
                    ? 'Contact and Enquiry created successfully.'
                    : 'Existing Contact found and Enquiry created successfully.',
                customer.Id,
                enquiry.Id
            );

        } catch (Exception e) {
            res.statusCode = 400;
            return new EnquiryResponse(
                false,
                'Unable to create enquiry: ' + e.getMessage(),
                null,
                null
            );
        }
    }
}
