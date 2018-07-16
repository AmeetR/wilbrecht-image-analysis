import fi.techila.user.TechilaExecutorService;
import fi.techila.user.TechilaExecutorServiceCallback;
import fi.techila.user.TechilaFutureTask;

public class Callback implements TechilaExecutorServiceCallback<IntermediateDist> {

    // Mandatory method. Executed once when a task is completed.
    public void taskCompleted(TechilaFutureTask<IntermediateDist> task) {
        System.out.println("callback: task completed");
    }
    // Mandatory method. Executed once if the Project is completed successfully.
    public void projectCompleted(TechilaExecutorService<IntermediateDist> tes) {
        System.out.println("callback: project completed");
    }

    // Mandatory method. Executed once if the Project fails.
    public void projectFailed(TechilaExecutorService<IntermediateDist> tes) {
        System.out.println("callback: project failed");
    }

    // Mandatory method. Executed when intermediate data is received from a Job.
    public void intermediateDataReceived(TechilaExecutorService<IntermediateDist> tes, long jobid, Object o) {
        // Get the Job's index number. This will range from 1 to the total number of Jobs.
        long jobidx = jobid & 0xffff;
        System.out.println("Received intermediate data from Job #" + jobidx);
        System.out.println("Value of received variable is: " + Integer.toString((Integer)o));
        // Cast the intermediate data that was received to an integer and 
        // increase the value by 10 so we know it has been modified here.
        int dataToJob = (Integer)o  + 10;
        System.out.println("Increased value of variable to: " + dataToJob);
        System.out.println("Sending updated value of variable as intermediate data to Job #" + jobidx);
        // Send the updated value back to the same Job that sent the data.
        tes.sendIMData(jobid, dataToJob);
        System.out.println("Finished sending intermediate data to Job #" + jobidx);
    }

    // Mandatory method. 
    public boolean intermediateEnabled() {
        // Return true to enable intermediate data callback method. 
        // If modified to return false, the intermediate data callback function 
        // would not be executed.
        return true;
    }
}
