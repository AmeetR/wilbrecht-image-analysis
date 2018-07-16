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

public class RunParameters {

    public void runParameters(int jobs) {
        // Method for creating the computational Project. In this
        // example, each Job in the Project will get a different set
        // of input arguments.

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
            TechilaExecutorService<ParametersDist> tes =
                new TechilaExecutorService<ParametersDist>(tm,
                                                           "ParametersTutorial");
            TechilaExecutorCompletionService<ParametersDist, Integer> cs =
                new TechilaExecutorCompletionService<ParametersDist, Integer>(tes);

            // Enable messages.
            tes.getPeach().setMessages(true);

            // Set value of multip. This will be used as an input
            // argument when processing the Jobs on Techila Workers.
            int multip = 2;

            // Create Jobs. Each Job will get a different set of input
            // arguments.
            for (int i = 0; i < jobs; i++) {
                cs.submit(new ParametersDist(multip, i));
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
        runParameters(5);
    }

    public static void main(String[] args) {
        RunParameters rp = new RunParameters();
        rp.run();
    }
}
