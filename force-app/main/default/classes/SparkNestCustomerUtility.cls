public with sharing class SparkNestCustomerUtility {
    
    public static void processCustomerData() {
        
        String companyName = 'SparkNest';
        Integer customerCount = 5;
        Boolean isActive = true;
        
        
        System.debug('Company Name: ' + companyName);
        System.debug('Customer Count: ' + customerCount);
        System.debug('Is Active: ' + isActive);
        
        
        // List stores customer names and allows duplicate values
        
        List<String> customerNames = new List<String>();
        customerNames.add('Rahul Sharma');
        customerNames.add('Aman Verma');
        customerNames.add('Priya Singh');
        customerNames.add('Neha Kapoor');
        customerNames.add('Rahul Sharma');
        
        System.debug('CustomerNames: ' + customerNames);
        
        for(String customerName : customerNames) {
            System.debug('Customer Name: ' + customerName);
        }
        
        
        // Set stores unique customer names and does not allow duplicate values
        Set<String> customerEmails = new Set<String>();
        
        customerEmails.add('rahul@gmail.com');
        customerEmails.add('aman@gmail.com');
        customerEmails.add('priya@gmail.com');
        customerEmails.add('rahul@gmail.com');
        customerEmails.add('neha@gmail.com');
        
        
        System.debug('Unique Emails: ' + customerEmails);
        
        
        // Map stores data in key value format and each key shouldb be unique
        Map<Integer, String> storeMap = new Map<Integer, String>();
        
        storeMap.put(101, 'Hyderabad');
        storeMap.put(102, 'Bengaluru');
        storeMap.put(103, 'Mumbai');
        
        String storeCity = storeMap.get(102);
        System.debug('Store 102 City: ' + storeCity);
        
        Map<String, Decimal> productPrices = new Map<String, Decimal>();
        
        productPrices.put('SparkNest Phone X1', 45000);
        productPrices.put('SparkNest Smart Speaker', 8000);
        productPrices.put('SparkNest Laptop Pro', 75000);

        Decimal laptopPrice = productPrices.get('SparkNest Laptop Pro');
        System.debug('SparkNest Laptop Pro Price: ' + laptopPrice);
        
        

        
    }
    
    
    public static Decimal calculateOrderValue(Integer quantity, Decimal unitPrice) {
        
        Decimal totalOrderValue = quantity * unitPrice;
        return totalOrderValue;
        
        
    }
    
}