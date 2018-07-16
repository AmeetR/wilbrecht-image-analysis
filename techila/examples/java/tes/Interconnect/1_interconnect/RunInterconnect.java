// Copyright 2017 Techila Technologies Ltd.

import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

import fi.techila.user.Support;
import fi.techila.user.TechilaExecutorCompletionService;
import fi.techila.user.TechilaExecutorService;
import fi.techila.user.TechilaFutureTask;
import fi.techila.user.TechilaManagerFactory;
import fi.techila.user.TechilaManager;

public class RunInterconnect {

    public void runInterconnect(int amount) {

        // Method for creating the computational Project.

        // Create a TechilaManager object, which will be used for
        // initializing the network connection / authentication
        TechilaManager tm = TechilaManagerFactory.getTechilaManager();

        try {

            // Initialize a connection to the Techila Server
            int status = tm.initFile();

            // Print the status of initialization attempt
            Support sp = tm.support();
            String codedesc = sp.describeStatusCode(status);
            System.out.println("Status: " + codedesc);

            // Create required TES objects.
            TechilaExecutorService<InterconnectDist> tes = new TechilaExecutorService<InterconnectDist>(tm, "InterconnectTutorial");
            TechilaExecutorCompletionService<InterconnectDist, ReturnData> cs = new TechilaExecutorCompletionService<InterconnectDist, ReturnData>(tes);

            // Enable messages.
            tes.getPeach().setMessages(true);

            // Add objects to a list. Each list object will correspond
            // to one Job in the TDCE environment.
            for (int i = 0; i < amount; i++) {
                cs.submit(new InterconnectDist());
            }

            // Start the computational Project. Also starts a local
            // thread that will automatically download the results as
            // soon as they are available.
            tes.start();

            // Access and print the results.
            for (int i = 0; i < amount; i++) {
                try {
                    TechilaFutureTask<ReturnData> f = cs.take();

                    int index = f.getIndex();
                    ReturnData jobresult = f.get();

                    System.out.println("Result of task " + i + ": " + jobresult.getBroadcastResult());
                    System.out.println("Result of task " + i + ": " + Integer.toString(jobresult.getCloudOpResult()));
                    System.out.println("Result of task " + i + ": " + jobresult.getJobToJobResult());

                } catch (ExecutionException ee) {
                    System.err.println("Task failed: " + ee.getMessage());
                }
            }

            // Allow 10 seconds for the local thread to terminate.
            tes.awaitTermination(10, TimeUnit.SECONDS);

        } catch (Throwable e) {
            System.err.println("Exception: " + e);
            e.printStackTrace();
        } finally {
            tm.unload(true, true);
        }
    }

    public void run() {
        runInterconnect(2);
    }

    public static void main(String[] args) {
        RunInterconnect rd = new RunInterconnect();
        rd.run();
    }
}
