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
public class RunDetached {
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

            peach.setJobs(20);
            peach.putProjectParam("loops", "40000000");

            peach.execute();

            peach.setRemove(false);
            int pid = peach.getProjectId();

            peach.setMessages(false);

            peach.done();

            System.out.println("Project ID is: " + pid);

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
        RunDetached rd = new RunDetached();

        try {
            rd.runmcpi();
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
