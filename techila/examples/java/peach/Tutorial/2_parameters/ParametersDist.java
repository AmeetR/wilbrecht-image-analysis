// Copyright 2014 Techila Technologies Ltd.

import java.io.FileOutputStream;
import java.io.DataOutputStream;

public class ParametersDist {

    private String outputfile = "techila_peach_result.dat";

    public int parametersDist(int multip, int jobidx) {
        return multip * jobidx;
    }

    public void run(int multip, int jobidx) {
        int result = parametersDist(multip, jobidx);

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
        int multip = Integer.parseInt(args[0]);
        int jobidx = Integer.parseInt(args[1]);

        ParametersDist pd = new ParametersDist();
        pd.run(multip, jobidx);
    }
}
