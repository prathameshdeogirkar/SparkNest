public class CaseResolutionTimeTriggerHandler {

    public static void calculateResolutionTime(
        List<Case> newCases,
        Map<Id, Case> oldMap
    ) {
        for (Case currentCase : newCases) {
            Case oldCase = oldMap.get(currentCase.Id);

            // Calculate only when Status changes to Closed
            if (currentCase.Status == 'Closed' &&
                oldCase.Status != 'Closed' &&
                currentCase.CreatedDate != null) {

                Long elapsedMilliseconds =
                    System.now().getTime() -
                    currentCase.CreatedDate.getTime();

                Decimal elapsedHours =
                    Decimal.valueOf(
                        String.valueOf(elapsedMilliseconds)
                    ) / 3600000;

                currentCase.Resolution_Time_Hours__c =
                    elapsedHours.setScale(2);
            }
        }
    }
}