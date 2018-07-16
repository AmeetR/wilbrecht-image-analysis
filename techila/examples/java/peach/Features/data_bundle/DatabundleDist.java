// Copyright 2014 Techila Technologies Ltd.

import java.io.BufferedReader;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.DataOutputStream;


import java.util.StringTokenizer;

public class DatabundleDist {

    private String outputfile = "techila_peach_result.dat";

    public String read(String filename) {
        String str = "";

        try {
            FileReader fr = new FileReader(filename);
            BufferedReader br = new BufferedReader(fr);

            str = br.readLine();

            br.close();
            fr.close();

        } catch (Exception e) {
            System.err.println("Exception: " + e);
        }

        return str;
    }

    public String databundleDist(int jobidx) {
        String str = "";

        str += "\"";
        str += read("file1_bundle1");
        str += "\", \"";
        str += read("file2_bundle1");
        str += "\", \"";
        str += read("file1_bundle2");
        str += "\", \"";
        str += read("file2_bundle2");
        str += "\"";

        return str;
    }

    public void run(int jobidx) {
        String result = databundleDist(jobidx);

        try {
            FileOutputStream fos = new FileOutputStream(outputfile);
            DataOutputStream dos = new DataOutputStream(fos);

            dos.writeUTF(result);

            dos.close();
            fos.close();
        } catch (Exception e) {
            System.err.println("Exception: " + e);
            System.exit(1);
        }
    }

    public static void main(String[] args) {
        int jobidx = Integer.parseInt(args[0]);

        DatabundleDist dd = new DatabundleDist();
        dd.run(jobidx);
    }
}
