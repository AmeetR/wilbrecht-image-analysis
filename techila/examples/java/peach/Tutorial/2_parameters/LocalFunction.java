// Copyright 2014 Techila Technologies Ltd.

import java.util.List;
import java.util.Vector;

public class LocalFunction {

    public List<Integer> localFunction(int multip, int amount) {
        Vector<Integer> result = new Vector<Integer>();
        for (int i = 1; i < amount + 1; i++) {
            result.add(multip * i);
        }
        return result;
    }

    public void run() {

        List<Integer> result = localFunction(2, 5);

        System.out.println(result);
    }

    public static void main(String[] args) {
        LocalFunction lf = new LocalFunction();

        lf.run();
    }
}
