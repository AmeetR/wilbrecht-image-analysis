// Copyright 2014 Techila Technologies Ltd.

import java.util.List;
import java.util.Vector;

// Execute the library function on the local computer

public class LocalFunction {

    public List<Integer> localFunction(int amount) {
        Library lib = new Library();

        Vector<Integer> result = new Vector<Integer>();
        for (int i = 1; i < amount + 1; i++) {
            result.add(lib.libraryFunction(i));
        }
        return result;
    }

    public void run() {
        List<Integer> result = localFunction(5);

        System.out.println(result);
    }

    public static void main(String[] args) {
        LocalFunction lf = new LocalFunction();

        lf.run();
    }
}
