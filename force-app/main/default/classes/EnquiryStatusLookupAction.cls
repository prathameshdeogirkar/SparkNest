
public with sharing class EnquiryStatusLookupAction {

    public class Request {
        @InvocableVariable(
            label='Customer Email'
            description='Email address used to identify the customer'
            required=true
        )
        public String emailAddress;
    }

    public class Response {
        @InvocableVariable(label='Found')
        public Boolean found;

        @InvocableVariable(label='Customer Name')
        public String customerName;

        @InvocableVariable(label='Enquiry Number')
        public String enquiryNumber;

        @InvocableVariable(label='Enquiry Subject')
        public String enquirySubject;

        @InvocableVariable(label='Enquiry Status')
        public String enquiryStatus;

        @InvocableVariable(label='Closed Date')
        public Date closedDate;

        @InvocableVariable(label='Message')
        public String message;
    }

    @InvocableMethod(
        label='Look Up Latest Enquiry by Email'
        description='Finds a customer by email and returns their latest enquiry status.'
    )
    public static List<Response> lookupLatestEnquiry(List<Request> requests) {
        List<Response> responses = new List<Response>();
        Set<String> emails = new Set<String>();

        for (Request req : requests) {
            if (req != null && !String.isBlank(req.emailAddress)) {
                emails.add(req.emailAddress.trim().toLowerCase());
            }
        }

        System.debug(
            LoggingLevel.ERROR,
            'LOOKUP INPUT EMAILS: ' + emails
        );

        Map<String, Contact> contactsByEmail = new Map<String, Contact>();

        if (!emails.isEmpty()) {
            for (Contact c : [
                SELECT Id, FirstName, LastName, Email
                FROM Contact
                WHERE Email IN :emails
            ]) {
                System.debug(
                    LoggingLevel.ERROR,
                    'CONTACT MATCH: ' + c.Email + ' | ' + c.Id
                );

                String key = c.Email == null
                    ? null
                    : c.Email.trim().toLowerCase();

                if (key != null && !contactsByEmail.containsKey(key)) {
                    contactsByEmail.put(key, c);
                }
            }
        }

        System.debug(
            LoggingLevel.ERROR,
            'CONTACTS FOUND: ' + contactsByEmail.keySet()
        );

        Set<Id> contactIds = new Set<Id>();

        for (Contact c : contactsByEmail.values()) {
            contactIds.add(c.Id);
        }

        Map<Id, Enquiry__c> latestByContact =
            new Map<Id, Enquiry__c>();

        if (!contactIds.isEmpty()) {
            for (Enquiry__c e : [
                SELECT Id, Name, Subject__c, Status__c,
                       Closed_Date__c, Contact__c, CreatedDate
                FROM Enquiry__c
                WHERE Contact__c IN :contactIds
                ORDER BY CreatedDate DESC, Id DESC
            ]) {
                if (!latestByContact.containsKey(e.Contact__c)) {
                    latestByContact.put(e.Contact__c, e);
                }
            }
        }

        System.debug(
            LoggingLevel.ERROR,
            'LATEST ENQUIRIES BY CONTACT: ' + latestByContact
        );

        for (Request req : requests) {
            Response out = new Response();
            out.found = false;

            if (req == null || String.isBlank(req.emailAddress)) {
                out.message = 'Please provide your email address.';
                responses.add(out);
                continue;
            }

            String normalizedEmail =
                req.emailAddress.trim().toLowerCase();

            Contact customer = contactsByEmail.get(normalizedEmail);

            System.debug(
                LoggingLevel.ERROR,
                'CUSTOMER LOOKUP FOR ' + normalizedEmail +
                ': ' + (customer == null ? 'NOT FOUND' : customer.Id)
            );

            if (customer == null) {
                out.message =
                    'No customer was found for that email address.';
                responses.add(out);
                continue;
            }

            Enquiry__c enquiry = latestByContact.get(customer.Id);

            if (enquiry == null) {
                out.message = 'No enquiry was found for this customer.';
                responses.add(out);
                continue;
            }

            out.found = true;
            out.customerName = String.isBlank(customer.FirstName)
                ? customer.LastName
                : customer.FirstName + ' ' + customer.LastName;
            out.enquiryNumber = enquiry.Name;
            out.enquirySubject = enquiry.Subject__c;
            out.enquiryStatus = enquiry.Status__c;
            out.closedDate = enquiry.Closed_Date__c;
            out.message = 'Latest enquiry found.';

            responses.add(out);
        }

        return responses;
    }
}
