@IsTest
public class MobileOrderTest {

	static testMethod void testParse() {
		String json = '{'+
		'    \"sfId\" : \"0066800000BZfwQAAT\",'+
		'    \"name\": \"Test Opp New\",'+
		'    \"rtNumber\" : \"RT-101\",'+
		'    \"email\": \"testOppEmail@testOpp.com\",'+
		'    \"amount\": 1000    '+
		'}';
		MobileOrder obj = MobileOrder.parse(json);
		System.assert(obj != null);
	}
}