import com.sun.security.auth.UnixNumericGroupPrincipal;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

abstract class Schema {
    protected Map<String, Number> numerics;
    protected Map<String, String> strings;

    protected void setSchema(Map<String, Number> numerics, Map<String, String> strings){
        this.numerics = numerics;
        this.strings = strings;
    }
}

class SchemaWrapper {
    public Map<String, Number> numeric = new HashMap<>();
    public Map<String, String> strings = new HashMap<>();
    public Map<String, Date> dates = new HashMap<>();
}

class CustomerSchema extends Schema {


    /**
    ** The schema is expressed in | separated format
    ** For example, Customer Schema is: " Registry | DOB |Email | Phone|Whatever|" ---> Composite is too heavy
    ** --> Lookup table
     * You can also specify a field in a subschema like this: "Registry.first_name". If you do not, all the fields are
     * taken into consideration.
     */

    private Map<String,Number> numericsTable = new HashMap<>();

    CustomerSchema(String schemaExpr){
        numericsTable.put("Registry.marital_status", new Short("-1"));
        numericsTable.put("Registry.marital_status", new Short("-1"));
        numericsTable.put("Registry.marital_status", new Short("-1"));
        numericsTable.put("Registry.marital_status", new Short("-1"));
        numericsTable.put("Registry.marital_status", new Short("-1"));

        // -------------------------------------------------------------
        SchemaWrapper res = parser(schemaExpr);
        setSchema(res.numeric, res.strings);

    }
    SchemaWrapper parser(String schemaExpr){
        SchemaWrapper res = new SchemaWrapper();
        for( String field : schemaExpr.split("|") )
        {
            field = field.trim().toLowerCase();
            Number type = numericsTable.get(field);
            if(type != null)
                res.numeric.put(field, type);
            else
                res.strings.put(field, new String());
        }

        return res;
    }

}
