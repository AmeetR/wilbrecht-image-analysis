// Copyright 2014 Techila Technologies Ltd.

import java.io.FileReader;
import java.io.BufferedReader;

import java.util.List;
import java.util.StringTokenizer;
import java.util.Vector;

public class LocalFunction {

    public List<Integer> localFunction() {
        Vector<Integer> result = new Vector<Integer>();

        try {

            FileReader fr = new FileReader("datafile.txt");
            BufferedReader br = new BufferedReader(fr);

            for (int i = 0; i < 4; i++) {
                int rowValue = 0;
                String row = br.readLine();

                StringTokenizer st = new StringTokenizer(row, " ");
                while (st.hasMoreElements()) {
                    String token = st.nextToken();
                    int value = Integer.parseInt(token);
                    rowValue += value;
                }
                result.add(rowValue);
            }

            br.close();
            fr.close();

        } catch (Exception e) {
            System.err.println("Exception: " + e);
        }

        return result;
    }

    public void run() {

        List<Integer> result = localFunction();

        System.out.println(result);
    }

    public static void main(String[] args) {
        LocalFunction lf = new LocalFunction();

        lf.run();
    }
}
