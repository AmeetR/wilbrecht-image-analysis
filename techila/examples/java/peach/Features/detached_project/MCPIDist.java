/*
 * Copyright (C) 2008, 2014 Techila Technologies Ltd.
 */
import java.util.Random;
import java.io.FileOutputStream;
import java.io.DataOutputStream;

/**
 * Client program for Monte Carlo Pi calculation.
 */
public final class MCPIDist {

    private MCPIDist() {
    }

    public static void main(String[] args) {

        // input parameters
        int i = 0;
        int jobidx = Integer.parseInt(args[i++]);
        int loops = Integer.parseInt(args[i++]);
        String outputfile = args[i++];

        // calculate
        Random random = new Random(jobidx + 934837584);
        int in = 0;

        for (i = 0; i < loops; i++) {
            double x = random.nextDouble();
            double y = random.nextDouble();

            double r = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));

            if (r <= 1) {
                in++;
            }

        }

        // write output
        try {
            FileOutputStream fos = new FileOutputStream(outputfile);
            DataOutputStream dos = new DataOutputStream(fos);

            dos.writeInt(in);
            dos.writeInt(loops);

            dos.close();
            fos.close();
        } catch (Exception e) {
            System.err.println("Exception: " + e);
            System.exit(1);
        }
    }
}
