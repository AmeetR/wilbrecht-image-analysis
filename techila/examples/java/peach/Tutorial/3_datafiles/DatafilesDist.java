// Copyright 2014 Techila Technologies Ltd.

import java.io.BufferedReader;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.DataOutputStream;


import java.util.StringTokenizer;

public class DatafilesDist {

    private String outputfile = "techila_peach_result.dat";

    public int datafilesDist(int jobidx) {
        int rowValue = 0;

        try {
            FileReader fr = new FileReader("datafile.txt");
            BufferedReader br = new BufferedReader(fr);

            for (int i = 0; i < jobidx; i++) {
                rowValue = 0;
                String row = br.readLine();

                StringTokenizer st = new StringTokenizer(row, " ");
                while (st.hasMoreElements()) {
                    String token = st.nextToken();
                    int value = Integer.parseInt(token);
                    rowValue += value;
                }
            }

            br.close();
            fr.close();

        } catch (Exception e) {
            System.err.println("Exception: " + e);
        }
        return rowValue;
    }

    public void run(int jobidx) {
        int result = datafilesDist(jobidx);

        try {
            FileOutputStream fos = new FileOutputStream(outputfile);
            DataOutputStream dos = new DataOutputStream(fos);

            dos.writeInt(result);

            dos.close();
            fos.close();
        } catch (Exception e) {
            System.err.println("Exception: " + e);
            System.exit(1);
        }
    }

    public static void main(String[] args) {
        int jobidx = Integer.parseInt(args[0]);

        DatafilesDist dd = new DatafilesDist();
        dd.run(jobidx);
    }
}
