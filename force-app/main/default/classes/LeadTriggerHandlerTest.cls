@isTest
public class LeadTriggerHandlerTest {

    @isTest
    static void testLeadRatingAutomation() {

        // Create Web Lead
        Lead webLead = new Lead(
            FirstName = 'Test',
            LastName = 'Web Lead',
            Company = 'SparkNest Test',
            LeadSource = 'Web'
        );

        // Create non-Web Lead
        Lead referralLead = new Lead(
            FirstName = 'Test',
            LastName = 'Referral Lead',
            Company = 'SparkNest Test',
            LeadSource = 'Referral'
        );

        Test.startTest();

        insert new List<Lead>{ webLead, referralLead };

        Test.stopTest();

        // Query the records after trigger execution
        List<Lead> insertedLeads = [
            SELECT Id, LeadSource, Rating
            FROM Lead
            WHERE Id IN :new Set<Id>{webLead.Id, referralLead.Id}
        ];

        // Verify Web → Cold
        for (Lead lead : insertedLeads) {

            if (lead.LeadSource == 'Web') {
                System.assertEquals(
                    'Cold',
                    lead.Rating,
                    'Web Lead should have Rating = Cold'
                );
            }
            else {
                System.assertEquals(
                    'Hot',
                    lead.Rating,
                    'Non-Web Lead should have Rating = Hot'
                );
            }
        }
    }


    @isTest
    static void testLeadRatingBulk() {

        List<Lead> leads = new List<Lead>();

        // Create 200 Leads
        for (Integer i = 0; i < 200; i++) {

            Lead lead = new Lead(
                FirstName = 'Bulk',
                LastName = 'Lead ' + i,
                Company = 'SparkNest Bulk Test',
                LeadSource = (Math.mod(i, 2) == 0) ? 'Web' : 'Referral'
            );

            leads.add(lead);
        }

        Test.startTest();

        insert leads;

        Test.stopTest();

        // Verify all 200 Leads
        List<Lead> insertedLeads = [
            SELECT Id, LeadSource, Rating
            FROM Lead
            WHERE Id IN :leads
        ];

        System.assertEquals(
            200,
            insertedLeads.size(),
            'Exactly 200 Leads should have been inserted'
        );

        for (Lead lead : insertedLeads) {

            if (lead.LeadSource == 'Web') {

                System.assertEquals(
                    'Cold',
                    lead.Rating,
                    'Web Lead should have Rating = Cold'
                );

            }
            else {

                System.assertEquals(
                    'Hot',
                    lead.Rating,
                    'Non-Web Lead should have Rating = Hot'
                );
            }
        }
    }
}