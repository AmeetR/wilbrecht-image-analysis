// Copyright 2017 Techila Technologies Ltd.

// Import required classes
import java.io.Serializable;
import java.util.concurrent.Callable;

public class DistributionDist implements Callable, Serializable {
    // DistributionDist objects will be serialized and sent to Techila Workers.

    public Integer call() throws Exception {
        // Code inside this call method will be executed in each computational
        // Job.
        int result = 1 + 1;
        return result;
    }
}
