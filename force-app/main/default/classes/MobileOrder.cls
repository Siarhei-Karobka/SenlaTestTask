public with sharing class MobileOrder {
    public String sfId;
	public String name;
	public String rtNumber;
	public String email;
	public Integer amount;

	public static MobileOrder parse(String json) {
		return (MobileOrder) System.JSON.deserialize(json, MobileOrder.class);
	}
}