using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;

// Import the Techila library functions.
// Included in Techila SDK 'techila/lib/TechilaManagement.dll'
using Techila.Management;

namespace RunParameters
{
    class RunParameters
    {
        static void Main()
        {
            // Create TechilaManager instance
            TechilaManager tm = TechilaManagerFactory.TechilaManager;

            // Test the connection to the Techila Server by creating a session.
            // Returns value 0 if session was created successfully.
            int status = tm.InitFile();

            // Create Support instance
            Support sp = tm.Support();

            // Get the status code description.
            string codedesc = sp.DescribeStatusCode(status);

            // Print the status code description
            Console.WriteLine("Status: " + codedesc);

            // Create a TechilaProject instance and link it with the 'tm' object created earlier
            TechilaProject tp = new TechilaProject(tm, "Parameters Tutorial");

            // Enable messages
            tp.GetPeach().Messages = true;

            // Set the value of the jobs variable to 5. Will be used to define the number of Jobs that will be created.
            int jobs = 5;

            // Fixed value used in the multiplication
            int multip = 2;

            // Add five instances of the ParametersDist class to the job list in 'tp'
            for (int i = 0; i < jobs; i++)
            {
                tp.Add(new ParametersDist(multip,i));
            }

            // Create and start the Project. Execution will continue after all Jobs have been completed.
            // Job results will be stored in the 'tp' object.
            tp.Execute();

            // Retrieve the values returned from the Jobs.
            for (int i = 0; i < jobs; i++)
            {
                // Retrieve one Job result from 'tp'
                int jobresult = ((ParametersDist)tp.Get(i)).Result;

                // Display the value generated in the Job
                System.Console.WriteLine("Result of Job {0}: {1}", i + 1, jobresult);

            }

            // Uninitialize and remove the session
            tm.Unload(true);
        }

        // Mark the class as serializable
        [Serializable]
        class ParametersDist : TechilaThread // Extend the TechilaThread class
        {
            public int Multip;
            public int Index;

            // Define constructor that takes two input arguments
            public ParametersDist(int multip, int index)
            {
                this.Multip = multip;
                this.Index = index;
            }

            // Define 'Result' as public so it can be accessed when Job results are retrieved from the 'tp' list.
            public int Result;

            // Override the 'Execute' method in the 'TechilaThread' class with code that we want to execute.
            public override void Execute()
            {
                Result = Multip * Index;
            }
        }

    }
}
