// Copyright 2017 Techila Technologies Ltd.

import java.net.Socket;

import java.io.Serializable;
import java.util.List;
import java.util.Vector;
import java.util.concurrent.Callable;

import fi.techila.user.workerutils.TechilaConn;
import fi.techila.user.workerutils.Func;

public class InterconnectDist implements Callable, Serializable {

    public ReturnData call() throws Exception {
        
        // Set up the interconnect network
        TechilaConn conn = new TechilaConn();
        conn.initInterconnection(30000);
        // Get the Job's id number
        int myjobid = conn.getJobId();
        
        // Send data between two Jobs in the Project
        String jobToJobResult = null;
        if (myjobid == 1) {                                 // Job #1 will execute this code block
            conn.sendDataToJob(2, "Hi from Job #1");        // Send message to Job #2
            jobToJobResult = conn.receiveDataFromJob(2);    // Receive message from Job #2
        }
        if (myjobid == 2) {                                 // Job #2 will execute this code block
            jobToJobResult = conn.receiveDataFromJob(1);    // Receive message from Job #1 
            conn.sendDataToJob(1, "Hi from Job #2");        // Send message to Job #1
        }
        conn.waitForOthers();  // Syncronize
        
        
        // Perform a broadcast operation
        String dataToTransfer = "Broadcasted hello from Job " + Integer.toString(myjobid); // One Job says hello to all other Jobs
        int sourceJob = 2;
        String broadcastResult = conn.cloudBc(sourceJob, dataToTransfer); // Broadcast data from Job #2.
        conn.waitForOthers();  // Syncronize
        
        
        // Perform a cloud op operation using the 'Sum' method.
        int cloudOpResult = conn.cloudOp(new Sum(), myjobid);
        conn.waitForOthers(); 
        
        conn.waitForOthers();  // Syncronize
       
        // Build and return the data in an object.
        ReturnData retData = new ReturnData(broadcastResult, cloudOpResult, jobToJobResult);
        return(retData);
        
        
    }
    
    // Class implementing the Func interface. Will be called during the cloudOp-operation.  
    public class Sum implements Func<Integer> {
        public Integer op(Integer num1, Integer num2) {
            return num1 + num2;
        }
    }
    

}
