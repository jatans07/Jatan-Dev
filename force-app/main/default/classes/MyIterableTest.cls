@IsTest
public class MyIterableTest {
    
	@IsTest
    public static void testIterableForLoop(){
        List<String> strings = new List<String>{'Hello','World'};
        for (String str : new MyIterable(strings)) {
   			System.debug(str);
		}

    }
}