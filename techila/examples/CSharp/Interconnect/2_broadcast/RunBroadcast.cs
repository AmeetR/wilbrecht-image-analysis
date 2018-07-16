using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Techila.Management;

namespace RunBroadcast
{
    class Program
    {
        static void Main(string[] args)
        {
            // Create a new TechilaProject object.
            TechilaProject tp = new TechilaProject();

            // Define how many Jobs will be created.
            int jobs = 4;

            // Define which Job will broadcast the data. 
            int sourcejob = 2;
            
             // Create four Jobs in the Project
            for (int x = 0; x < jobs; x++)
            {
                // Pass the 'sourcejob' argument to the Broadcast constructor. 
                // The value of the 'sourcejob' argument will define which Job
                // will broadcast data.
                tp.Add(new Broadcast(sourcejob)); 
            }

            // Uncomment the below line to only allow Workers in Worker Group 
            // 'IC Group 1' to participate.
            //tp.GetPeach().PutProjectParam("techila_worker_group", "IC Group 1");
            
            // Create the Project.
            tp.Execute();

            // Print the results
            for (int i = 0; i < jobs; i++)
            {
                Console.WriteLine(((Broadcast)tp.Get(i)).result);
            }

        }
    }

    // Mark the class as serializable
    [Serializable]
    class Broadcast : TechilaThread // Extend the TechilaThread class
    {
        // Define 'Result' as public so it can be accessed when Job results are retrieved from 'tp'.
        public string result = "";
        private int sourcejob;

        // Define constructor which takes one input argument. 
        public Broadcast(int sourcejob)
        {
            this.sourcejob = sourcejob;
        }
        
        // Override the 'Execute' method in the 'TechilaThread' class with code that we want to execute.
        public override void Execute()
        {
            // Create a TechilaConn object, which contains the interconnect methods.
            TechilaConn tc = new TechilaConn(this);
            
            // Build a string that will be broadcasted.
            string bcstring = "Hello from Job #" + GetJobId();
            
            // Broadcast 'bcstring' from 'sourcejob' to all other Jobs in the Project.
            // With the default values in the example, Job #2 will broadcast the string 'Hello from Job #2' .
            result = "Value of 'bcstring' string in Job #" + GetJobId() + ": " + tc.CloudBc(sourcejob, bcstring);
            
            // Wait until all Jobs have reached this point before continuing
            tc.WaitForOthers();
        }
    }

}
