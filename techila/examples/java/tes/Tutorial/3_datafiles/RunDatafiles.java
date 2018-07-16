// Copyright 2017 Techila Technologies Ltd.

import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.io.PrintWriter;
import java.io.IOException;
import java.util.Vector;

import java.util.Random;

import fi.techila.user.Support;
import fi.techila.user.TechilaExecutorCompletionService;
import fi.techila.user.TechilaExecutorService;
import fi.techila.user.TechilaFutureTask;
import fi.techila.user.TechilaManagerFactory;
import fi.techila.user.TechilaManager;

public class RunDatafiles {

    public void runDatafiles(int jobs) {
        // Method for creating the computational Project. In this
        // example, a set of input files will be transferred from your
        // computer to the Techila Workers.

        // Create a TechilaManager object, which will be used for
        // initializing the network connection / authentication
        TechilaManager tm = TechilaManagerFactory.getTechilaManager();

        try {
            // Generate some input files
            Vector<String> fileList = new Vector<String>();
            Random rand = new Random();
            for (int i = 0;i < jobs;i++) {
                try{
                    // Each file will be given a unique name.
                    String filename = "TechilaExampleFile"
                        + Integer.toString(i) + ".txt";
                    PrintWriter filewriter = new PrintWriter(filename, "UTF-8");
                    int randomNum;
                    // Each file will contain five rows, each row will
                    // contain a random number.
                    for (int j=0; j < 6; j++) {
                        randomNum = rand.nextInt(101);
                        filewriter.println(Integer.toString(randomNum));
                    }
                    filewriter.close();

                    // Store file name to 'fileList'
                    fileList.add(filename);
                } catch (IOException ee) {
                    System.err.println("Exception: " + ee);
                    ee.printStackTrace();
                }
            }

            // Initialize a connection to the Techila Server
            int status = tm.initFile();

            // Print the status of initialization attempt
            Support sp = tm.support();
            String codedesc = sp.describeStatusCode(status);
            System.out.println("Status: " + codedesc);

            // Create required TES objects.
            TechilaExecutorService<DatafilesDist> tes =
                new TechilaExecutorService<DatafilesDist>(tm,
                                                          "DatafilesTutorial");
            TechilaExecutorCompletionService<DatafilesDist, Integer> cs =
                new TechilaExecutorCompletionService<DatafilesDist, Integer>(tes);

            // Enable messages.
            tes.getPeach().setMessages(true);

            // Create Bundle for transferring files to Techila Workers
            tes.getPeach().newDataBundle();

            // Add files to the Bundle
            for (String fname : fileList) {
                tes.getPeach().addDataFile(fname);
            }

            // Create Jobs. Each DatafilesDist object will be
            // contructed by a different input argument. This input
            // argument will be used to determine which input file
            // should be processed.
            for (int i = 0; i < jobs; i++) {
                cs.submit(new DatafilesDist(i));
            }

            // Start the computational Project. Also starts a local
            // thread that will automatically download the results as
            // soon as they are available.
            tes.start();

            // Access and print the results.
            for (int i = 0; i < jobs; i++) {
                try {
                    TechilaFutureTask<Integer> f = cs.take();

                    int index = f.getIndex();
                    int jobresult = f.get();

                    System.out.println("Result of summation at index "
                                       + index + ": " + jobresult);
                } catch (ExecutionException ee) {
                    System.err.println("Task failed: " + ee.getMessage());
                }
            }

            // Allow 10 seconds for the local thread to terminate.
            tes.awaitTermination(10, TimeUnit.SECONDS);

        } catch (Exception e) {
            System.err.println("Exception: " + e);
            e.printStackTrace();
        } finally {
            tm.unload(true, true);
        }
    }

    public void run() {
        runDatafiles(4);
    }

    public static void main(String[] args) {
        RunDatafiles rd = new RunDatafiles();
        rd.run();
    }
}
