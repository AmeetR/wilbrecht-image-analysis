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

            // Define how many Jobs will be created.
            int jobs = 4;
            
            // Create four Jobs.
            for (int x = 0; x < jobs; x++)
            {
                tp.Add(new AllToAll());
            }

            // Uncomment the below line to only allow Workers in Worker Group 
            // 'IC Group 1' to participate.
            //tp.GetPeach().PutProjectParam("techila_worker_group", "IC Group 1");
            
            // Create the Project.
            tp.Execute();

            // Print the results
            for (int i = 0; i < jobs; i++)
            {
                Console.WriteLine(((AllToAll)tp.Get(i)).result);
            }

        }
    }

    // Mark the class as serializable
    [Serializable]
    class AllToAll : TechilaThread // Extend the TechilaThread class
    {
        // Define 'Result' as public so it can be accessed when Job results are retrieved from 'tp'.
        public string result = "";

        // Override the 'Execute' method in the 'TechilaThread' class with code that we want to execute.
        public override void Execute()
        {
            // Create a TechilaConn object, which contains the interconnect methods.
            TechilaConn tc = new TechilaConn(this);

            // Get the Job's index number
            int jobidx = GetJobId();

            string msg;
            string recvdata;
            
            // Build a simple message string, which contains the Job's index number.
            msg = "Hello from Job #" + GetJobId();
            int src;
            int dst;
            
            // Build the result string, which will be used to store all messages received by this Job.
            result = "Messages received in Job #" + jobidx + ": ";
            
            // Transfer the message string from each Job to all other Jobs in the Project.
            for (src = 1; src <= tc.GetJobCount(); src++) 
                {
                for (dst = 1; dst <= tc.GetJobCount(); dst++)     
                    {

                    if (src == jobidx && dst != jobidx)
                        {
                            tc.SendDataToJob<string>(dst,msg);
                        }
                    else if (src != jobidx && dst == jobidx)
                        {
                            recvdata = tc.ReceiveDataFromJob<string>(src);
                            result += recvdata + ", ";
                        }
                    }
                }
            // Remove the trailing comma and whitespace from the result string
            char [] charsToTrim = {',',' '};
            result = result.TrimEnd(charsToTrim);
            
            // Wait until all Jobs have reached this point before continuing
            tc.WaitForOthers();

        }
        
    }

}
