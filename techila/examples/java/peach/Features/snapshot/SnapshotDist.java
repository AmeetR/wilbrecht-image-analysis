/*
 * Copyright (C) 2008, 2014 Techila Technologies Ltd.
 */
import java.util.Random;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;

 /**
 * Client program for Monte Carlo Pi calculation with snapshot.
 */
public final class SnapshotDist {

    private static final String snapshotFilename = "snapshot.dat";

    private SnapshotDist() {
    }

    public static int[] loadSnapshot() {
        int i = 0;
        int in = 0;
        try {
            FileInputStream fis = new FileInputStream(snapshotFilename);
            DataInputStream dis = new DataInputStream(fis);

            i = dis.readInt();
            in = dis.readInt();

            dis.close();
            fis.close();

        } catch (Exception e) {
            // ignore
        }

        return new int[] {i, in};
    }

    public static void saveSnapshot(int i, int in) {
        try {
            FileOutputStream fos = new FileOutputStream(snapshotFilename);
            DataOutputStream dos = new DataOutputStream(fos);

            dos.writeInt(i);
            dos.writeInt(in);

            dos.close();
            fos.close();
        } catch (Exception e) {
            // ignore
        }
    }

    public static void main(String[] args) {
        // input parameters
        int jobidx = Integer.parseInt(args[0]);
        int loops = Integer.parseInt(args[1]);
        String outputfile = args[2];

        // load snapshot
        int i = 0;
        int in = 0;

        int[] snapshotData = loadSnapshot();
        i = snapshotData[0];
        in = snapshotData[1];

        // calculate
        Random random = new Random(jobidx + 934837584);

        for (; i < loops; i++) {
            double x = random.nextDouble();
            double y = random.nextDouble();

            double r = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));

            if (r <= 1) {
                in++;
            }

            if (i > 0 && i % 100000000 == 0) {
                saveSnapshot(i, in);
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
