using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Techila.Management;

namespace RunJobToJob
{
    class Program
    {
        static void Main(string[] args)
        {
            // Create a new TechilaProject object.
            TechilaProject tp = new TechilaProject();
            
            // Create two Jobs in the Project
            tp.Add(new JobToJob());
            tp.Add(new JobToJob());
            
            // Uncomment the below line to only allow Workers in Worker Group 
            // 'IC Group 1' to participate.
            //tp.GetPeach().PutProjectParam("techila_worker_group", "IC Group 1");
            
            // Create the Project
            tp.Execute();
            
            // Display the results
            for (int i = 0; i < 2; i++)
            {
                JobToJob jtj = (JobToJob)tp.Get(i);
                int jobidx = jtj.GetJobId();
                Console.WriteLine("Result from Job #" + jobidx + ": " + jtj.result);
            }
        }
    }

    // Mark the class as serializable
    [Serializable]
    class JobToJob : TechilaThread // Extend the TechilaThread class
    {
        // Define 'Result' as public so it can be accessed when Job results are retrieved from 'tp'.
        public string result = "";
        
        // Override the 'Execute' method in the 'TechilaThread' class with code that we want to execute.
        public override void Execute()
        {
            // Create a TechilaConn object, which contains the interconnect methods.
            TechilaConn tc = new TechilaConn(this);
            
            // Check which Job is being processed.
            int jobidx = GetJobId();
            
            // Container for data that will be transferred using interconnect functions.
            string dataToSend;
            if (jobidx == 1) // This code block will be executed by Job #1.
            {
                dataToSend = "Hi from Job #1";
                // Send data from Job #1 to Job #2.
                tc.SendDataToJob<string>(2, dataToSend);
                // Receive data from Job #2.
                result = tc.ReceiveDataFromJob<string>(2);
            }
            else if (jobidx == 2) // This code block will be executed by Job #2.
            {
                dataToSend = "Hi from Job #2";
                
                // Receive data from Job #1.
                result = tc.ReceiveDataFromJob<string>(1);
                // Send data from Job #2 to Job #1.
                tc.SendDataToJob<string>(1, dataToSend);
            }
            
            // Wait until all Jobs have reached this point before continuing
            tc.WaitForOthers();
        }
    }

}
