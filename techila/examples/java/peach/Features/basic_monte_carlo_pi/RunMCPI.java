/*
 * Copyright (C) 2008-2014 Techila Technologies Ltd.
 */

// before compiling/running this, make sure the sdk/lib/techila.jar
// is in the CLASSPATH environment variable.
// also compile MCPIDist.java before running this example

import java.util.Hashtable;

import java.io.FileInputStream;
import java.io.DataInputStream;

import fi.techila.user.TechilaManagerFactory;
import fi.techila.user.TechilaManager;
import fi.techila.user.Peach;
import fi.techila.user.Support;


/**
 * Techila User Interface usage example with peach.
 */
public class RunMCPI {
    public static final String NAME = "mcpi";

    private TechilaManager techila;

    public void runmcpi() throws Exception {
        int statuscode;

        // instantiate the required objects...
        techila = TechilaManagerFactory.getTechilaManager();

        try {
            // initialize the management library
            // loadconfiguration from the techila_settins.ini file
            // the config file is automatically searched
            statuscode = techila.initFile();
            checkStatus(statuscode);

            Peach peach = techila.newPeach(NAME);

            peach.setMessages(true);

            peach.addExeFile("file1", "MCPIDist.class");
            peach.setJavaExecutable();
            peach.putExeExtras("Parameters", "MCPIDist %P(jobidx) %P(loops) %O(output)");

            peach.setJobs(10);
            peach.putProjectParam("loops", "20000000");

            peach.execute();

            long totalin = 0;
            long totalloops = 0;

            // read the results
            String file;
            while ((file = peach.nextFile()) != null) {
                FileInputStream fis = new FileInputStream(file);
                DataInputStream dis = new DataInputStream(fis);

                int in = dis.readInt();
                int loops = dis.readInt();

                totalin += in;
                totalloops += loops;

                dis.close();
                fis.close();
            }

            peach.done();

            // print out the result
            System.out.println("==== ==== ==== ====");
            System.out.println("total in = " + totalin);
            System.out.println("total loops = " + totalloops);
            System.out.println("value of PI is approx. "
                               + (((double)totalin / totalloops) * 4));
            System.out.println("==== ==== ==== ====");

        } catch (Exception e) {
            System.err.println("Exception in example: " + e);
            e.printStackTrace();
            throw e;
        } finally {
            // unload the management library and remove the
            // temporary directory
            techila.unload(true);
        }
    }

    public static void main(String[] args) {
        RunMCPI rm = new RunMCPI();

        try {
            rm.runmcpi();
        } catch (Exception e) {
            System.err.println("Exception: " + e);
        }
    }

    /**
     * Check the given status code, throw exception if status code is
     * not OK.
     * @param statuscode the status code
     * @throws Exception on error
     */
    private void checkStatus(int statuscode) throws Exception {
        String desc = techila.support().describeStatusCode(statuscode);
        System.out.println("statuscode = " + statuscode + " \"" + desc + "\"");
        if (statuscode != Support.OK) {
            System.out.println("last error = " + techila.support().getLastErrorMessage());
            throw new Exception(desc);
        }
    }

}
