// Copyright 2017 Techila Technologies Ltd.
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.io.FileInputStream;
import java.io.DataInputStream;
import java.util.List;
import java.util.Vector;

import fi.techila.user.Support;
import fi.techila.user.TechilaExecutorCompletionService;
import fi.techila.user.TechilaExecutorService;
import fi.techila.user.TechilaFutureTask;
import fi.techila.user.TechilaManagerFactory;
import fi.techila.user.TechilaManager;

public class RunLibrary {

    public void runLibrary(int jobs) {
        // Method for creating the computational Project. In this
        // example, functionlity in a separate JAR file will be used
        // on Techila Workers by adding the JAR file as a dependency.

        // Create a TechilaManager object, which will be used for
        // initializing the network connection / authentication.
        TechilaManager tm = TechilaManagerFactory.getTechilaManager();

        try {
            // Initialize a connection to the Techila Server
            int status = tm.initFile();


            // Print the status of initialization attempt
            Support sp = tm.support();
            String codedesc = sp.describeStatusCode(status);
            System.out.println("Status: " + codedesc);

            // Create required TES objects.
            TechilaExecutorService<LibraryDist> tes =
                new TechilaExecutorService<LibraryDist>(tm,
                                                        "ParametersTutorial");
            TechilaExecutorCompletionService<LibraryDist, Integer> cs =
                new TechilaExecutorCompletionService<LibraryDist, Integer>(tes);

            // Enable messages.
            tes.getPeach().setMessages(true);

            // Create Jobs. Each Job will get a different input
            // argument, which will later be passed as input argument
            // to a method in the separate JAR file.
            for (int i = 0; i < jobs; i++) {
                cs.submit(new LibraryDist(i));
            }

            // Add file 'library.jar' as a dependency.
            tes.addJarFile("library.jar");

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

                    System.out.println("Result at index " + index
                                       + ": " + jobresult);
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
        runLibrary(3);
    }

    public static void main(String[] args) {
        RunLibrary rl = new RunLibrary();
        rl.run();
    }
}
