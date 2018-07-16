// Copyright 2014 Techila Technologies Ltd.

import java.util.List;
import java.util.Vector;

public class LocalFunction {

    public List<Integer> localFunction(int amount) {
        Vector<Integer> result = new Vector<Integer>();
        for (int i = 0; i < amount; i++) {
            result.add(1 + 1);
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
