public with sharing class LeadOwnerAssignmentTriggerHandler {

    public static void handleBeforeInsert(List<Lead> leads) {

        User salesUser = [
    SELECT Id
    FROM User
    WHERE FirstName = 'Arjun'
    AND LastName = 'Sharma'
    AND IsActive = true
    LIMIT 1
];

for (Lead lead : leads) {

    if (lead.LeadSource == 'Web') {
        lead.OwnerId = salesUser.Id;
    }
}

    
    }
}