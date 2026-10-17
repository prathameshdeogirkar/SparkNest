EnquiryStatusLookupAction.Request req =
    new EnquiryStatusLookupAction.Request();

req.emailAddress = 'aarav.sharma.demo@example.com';

List<EnquiryStatusLookupAction.Response> results =
    EnquiryStatusLookupAction.lookupLatestEnquiry(
        new List<EnquiryStatusLookupAction.Request>{ req }
    );

System.debug('ACTION RESULT: ' + JSON.serialize(results));