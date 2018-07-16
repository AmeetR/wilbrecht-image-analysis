// Copyright 2017 Techila Technologies Ltd.

import java.net.Socket;

import java.io.Serializable;
import java.util.List;
import java.util.concurrent.Callable;

import fi.techila.user.workerutils.TechilaConn;
//import fi.techila.user.workerutils.Func;

public class IntermediateDist implements Callable, Serializable {

    private int input;

    public IntermediateDist(int input) {
        this.input = input;
    }

    public Integer call() throws Exception {

        // Create a TechilaConn object so we can get information about the Job
        TechilaConn conn = new TechilaConn();

        // Get the Job's index, will range from 1 to the number of Jobs
        int index = conn.getJobId();

        int result = input + index;

        // Send data from the Job to the End-User's computer
        conn.sendIMData(result);

        Thread.sleep(5000);
        // Wait and receive intermediate data from the End-User's computer. If no data is received, the command will return null.
        Integer finalResult = (Integer)conn.loadIMData(30000);

        // Handle possible null return values
        if (finalResult == null) {
            // If we didnt get intermediate data, something went wrong
            return -1;
        } else {
            // Otherwise return the final result
            return finalResult;
        }
    }
}
