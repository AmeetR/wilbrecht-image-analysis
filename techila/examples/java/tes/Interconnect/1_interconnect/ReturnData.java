// Copyright 2017 Techila Technologies Ltd.

import java.io.Serializable;

public class ReturnData implements Serializable{
    // Class used to return result data from the Job to the End-User.
    private String broadcastResult;
    private int cloudOpResult;
    private String jobToJobResult;
    
    
    public ReturnData(String broadcastResult, int cloudOpResult, String jobToJobResult) {
            this.broadcastResult = broadcastResult;
            this.cloudOpResult = cloudOpResult;
            this.jobToJobResult = jobToJobResult;
    }

    // Get methods so we can access the result data easily on the End-User's computer.
    public String getBroadcastResult(){
        return this.broadcastResult;
    }

        public int getCloudOpResult(){
        return this.cloudOpResult;
    }

        public String getJobToJobResult(){
        return this.jobToJobResult;
    }
}