// Copyright 2014 Techila Technologies Ltd.

import java.io.FileInputStream;
import java.io.DataInputStream;

import java.util.List;
import java.util.Vector;

import fi.techila.user.TechilaManagerFactory;
import fi.techila.user.TechilaManager;
import fi.techila.user.Peach;
import fi.techila.user.Support;


public class RunDistribution {

    public List<Integer> runDistribution(int amount) {
        Vector<Integer> result = new Vector<Integer>();

        // instantiate the main TechilaManager object
        TechilaManager techila = TechilaManagerFactory.getTechilaManager();

        try {

            // initialize Techila for use, read config from a file
            techila.initFile();

            // get a new peach object
            Peach peach = techila.newPeach("distribution_dist");

            // we wan't to see messages
            peach.setMessages(true);

            // add the class file to the executor bundle
            peach.addExeFile("classfile", "DistributionDist.class");

            // we are using java distributed with the workers as executable
            peach.setJavaExecutable();

            // parameters for the executable, the class name
            peach.putExeExtras("Parameters", "DistributionDist");

            // set the amount of jobs to be created
            peach.setJobs(amount);

            // run
            peach.execute();

            String file;

            // loop until no more result files
            while((file = peach.nextFile()) != null) {

                // open and process result file
                FileInputStream fis = new FileInputStream(file);
                DataInputStream dis = new DataInputStream(fis);

                result.add(dis.readInt());

                dis.close();
                fis.close();
            }

            // we are done
            peach.done();

        } catch (Exception e) {
            System.err.println("Exception: " + e);
        } finally {
            // unload the techila library, cleanup
            techila.unload(true, true);
        }

        return result;
    }

    public void run() {
        List<Integer> result = runDistribution(5);

        System.out.println(result);
    }

    public static void main(String[] args) {
        RunDistribution rd = new RunDistribution();
        rd.run();
    }
}
