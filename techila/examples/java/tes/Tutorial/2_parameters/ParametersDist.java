// Copyright 2017 Techila Technologies Ltd.

// Import required classes
import java.io.Serializable;
import java.util.concurrent.Callable;

public class ParametersDist implements Callable, Serializable {
    // ParametersDist objects will be serialized and sent to Techila Workers.
    private int multip;
    private int index;

    public ParametersDist(int multip, int index) {
        this.multip = multip;
        this.index = index;
    }

    public Integer call() throws Exception {
        // Code inside this call method will be executed in each
        // computational Job
        int result = multip * index;
        return result;
    }
}
