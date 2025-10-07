public class SplitMultiSelect {
    @InvocableMethod(label='Split Multi-Select Values' description='Splits semicolon-separated string into a list')
    public static List<List<String>> splitValues(List<String> inputs) {
        List<List<String>> results = new List<List<String>>();
        for (String input : inputs) {
            results.add(input != null ? input.split(';') : new List<String>());
        }
        return results; 
    }
}