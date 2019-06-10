/*It's an object factory and facade... both*/
/* Future work:
        -JPA
        -What's the output of Hibernate ? Can it be connected to a GraphDB like Neo4j?! Need an adapter? How complext it is?
*/
public interface DataAbstractionFacade {
    public static Dao<Sale> getInstance();
    public static Dao<Customer> getInstance();
    public static Dao<Employee> getInstance();
}
