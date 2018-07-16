using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Techila.Management;
using System.Linq.Expressions;

namespace RunCloudop
{
    class Program
    {
        static void Main(string[] args)
        {
            // Define how many Jobs will be created.
            int jobs = 4;
            
            // Create a new TechilaProject object.
            TechilaProject tp = new TechilaProject();
            
            // Create four Jobs.
            for (int x = 0; x < jobs; x++)
            {
                tp.Add(new CloudOp());
            }
            
            // Uncomment the below line to only allow Workers in Worker Group 
            // 'IC Group 1' to participate.
            //tp.GetPeach().PutProjectParam("techila_worker_group", "IC Group 1");
            
            // Create the Project.
            tp.Execute();
            
            // Print the results
            for (int x = 0; x < jobs; x++)
            {
                string jobres = ((CloudOp)tp.Get(x)).result;
                Console.WriteLine(jobres);
            }
        }
    }
    // Mark the class as serializable
    [Serializable]
    class CloudOp : TechilaThread // Extend the TechilaThread class
    {
        // Define 'Result' as public so it can be accessed when Job results are retrieved from 'tp'.
        public string result = "";
        
        // Override the 'Execute' method in the 'TechilaThread' class with code that we want to execute.
        public override void Execute()
        {
            // Create a TechilaConn object, which contains the interconnect methods.
            TechilaConn tc = new TechilaConn(this);
            
            // Get the Job's index number.
            int input = GetJobId();
            
            // Execute the 'Multiply' method across all Jobs with the input data defined in 'input'.
            // Result of the operation will be stored in 'res' in all Jobs.
            int res = tc.CloudOp(Multiply, input);
            
            // Build the result string, which contains the Job's index number and the result of the 
            // tc.CloudOp-call.
            result = "Value of 'res' in Job #" + GetJobId() + ": " + res;
            
            // Wait until all Jobs have reached this point before continuing
            tc.WaitForOthers();
        }
        
        // Define a simple multiplication method, which will be executed using CloudOp.
        public int Multiply(int a, int b)
        {
            return (a * b);
        }
    }

}


