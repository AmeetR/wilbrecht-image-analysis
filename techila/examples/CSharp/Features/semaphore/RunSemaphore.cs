using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Techila.Management;
using System.Threading;

namespace Semaphoretest
{
    class Program
    {
        static void Main(string[] args)
        {
            // Create a new TechilaProject object.
            TechilaProject tp = new TechilaProject();
            
            // Create a Project-specific semaphore named 'examplesema'.
            // This semaphore will have two tokens, meaning the maximum number
            // of tokens that can be received by Jobs is two.
            tp.CreateSemaphore("examplesema",2);

            // Create four Jobs in the Project
            for (int i = 0; i < 4; i++)
            {
                tp.Add(new SemaphoreDist());
            }

            // Create the Project.
            tp.Execute();

            // Print the results.
            for (int x = 0; x < tp.Count; x++)
            {
                Console.WriteLine("Results from Job #{0}:", x);
                List<String> res = ((SemaphoreDist)tp.Get(x)).reslist;
                foreach (String pres in res) 
                {
                    Console.WriteLine(pres);
                }
            }

        }
    }

    // Mark the class as serializable
    [Serializable]
    class SemaphoreDist : TechilaThread // Extend the TechilaThread class
    {
        // Mark the result of the Job (output) as public.
        public List<String> reslist = new List<String>();
        
        // Override the 'Execute' method in the 'TechilaThread' class with code that we want to execute.
        public override void Execute()
        {
            // Get current timestamp.
            DateTime jobStart = DateTime.UtcNow;
            
            // The following using-block will only be executed when this Job has reserved a token from the Project-specific 'examplesema' semaphore.
            // When the using-block is completed, the semaphore token will be automatically released.
            using (new TechilaSemaphore("examplesema")) { 
                DateTime start = DateTime.UtcNow; // Get current timestamp
                generateLoad(start, 30); // Generate CPU load for 30 seconds
                
                // Calculate when the CPU load was generated relative to the start of the Job.
                double twindowstart = Math.Round((start - jobStart).TotalSeconds, 0);
                double twindowend = Math.Round((DateTime.UtcNow - jobStart).TotalSeconds,0);
                
                // Build a result string that contains the time window.
                String resultproject = "Project-specific semaphore reserved successfully for the following time window: " + twindowstart  + "-" + twindowend;
                reslist.Add(resultproject);
            }

            // The following using-statement attempts to reserve a token from the global semaphore 'globalsema'
            // The status of the semaphore reservation process will be stored 'ts' object.
            using (TechilaSemaphore ts = new TechilaSemaphore("globalsema", true, 10, true)) {
                String resultglobal;
                if (ts.IsOk()) { // This block will be executed if the semaphore was reserved ok.
                    DateTime start2 = DateTime.UtcNow;
                    generateLoad(start2, 5);
                    double twindowstart2 = Math.Round((start2 - jobStart).TotalSeconds, 0);
                    double twindowend2 = Math.Round((DateTime.UtcNow - jobStart).TotalSeconds, 0);
                    resultglobal = "Global semaphore reserved successfully for the following time window: " + twindowstart2  + "-" + twindowend2;
                    reslist.Add(resultglobal);
                }
                else if (!ts.IsOk()) { // This block will be executed a semaphore token could not be reserved (can happen e.g. if the semaphore does not exist)
                    resultglobal = "Error when using global semaphore.";
                    reslist.Add(resultglobal);
                }
            }
        }

        // Simple method for generating CPU load for X seconds.
        public void generateLoad(DateTime start, int seconds)
        {
            
            Random r = new Random();
            while ((DateTime.UtcNow - start).TotalSeconds < seconds)
            {
                r.Next();
            }

        }

    }
}
