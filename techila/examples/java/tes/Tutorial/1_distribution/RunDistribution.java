// Copyright 2017 Techila Technologies Ltd.

// Import required standard Java classes
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

// Import required TDCE classes
import fi.techila.user.Support;
import fi.techila.user.TechilaExecutorCompletionService;
import fi.techila.user.TechilaExecutorService;
import fi.techila.user.TechilaFutureTask;
import fi.techila.user.TechilaManagerFactory;
import fi.techila.user.TechilaManager;

public class RunDistribution {

    public void runDistribution(int jobs) {
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
            TechilaExecutorService<DistributionDist> tes =
                new TechilaExecutorService<DistributionDist>(tm, "DistributionTutorial");
            TechilaExecutorCompletionService<DistributionDist, Integer> cs =
                new TechilaExecutorCompletionService<DistributionDist, Integer>(tes);

            // Enable messages.
            tes.getPeach().setMessages(true);

            // Add objects to a list. Each list object will correspond
            // to one Job in the TDCE environment.
            for (int i = 0; i < jobs; i++) {
                cs.submit(new DistributionDist());
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

                    System.out.println("Result at index "
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
        runDistribution(5);
    }

    public static void main(String[] args) {
        RunDistribution rd = new RunDistribution();
        rd.run();
    }
}
