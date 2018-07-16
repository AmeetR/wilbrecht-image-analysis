using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Techila.Management;
using System.Threading;

namespace RunDatafiles
{
    class RunDatafiles
    {
        static void Main()
        {
            // Will be used to define the number of Jobs
            int jobs = 4;

            // Will be used to define the size of the random number array
            int arraySize = 5;

            // Create text files containing sample values
            for (int i = 0; i < jobs; i++) // For each file
            {
                // Create reproducible randoms
                Random rand = new Random(i);

                // Array for storing random numbers
                int[] rngArray = new int[arraySize];

                // Define name of file that will created
                string fname = "file" + i + ".txt";

                // Create object for writing to file
                System.IO.StreamWriter file = new System.IO.StreamWriter(fname);

                // Generate 5 random values and store in file
                for (int j = 0; j < arraySize; j++)
                {
                    int rngValue = rand.Next(0, 101);
                    string rngValueStr = rngValue.ToString();
                    file.WriteLine(rngValueStr);
                }

                // Close the file
                file.Close();
            }

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
            TechilaProject tp = new TechilaProject(tm, "Datafiles Tutorial");

            // Enable messages
            tp.GetPeach().Messages = true;

            // Create Bundle for transferring files to Workers
            tp.GetPeach().NewDataBundle();

            // Add following 4 files to the Bundle
            tp.GetPeach().AddDataFile("file0.txt");
            tp.GetPeach().AddDataFile("file1.txt");
            tp.GetPeach().AddDataFile("file2.txt");
            tp.GetPeach().AddDataFile("file3.txt");

            // Create 5 jobs, each job will execute the class with a different input argument
            for (int i = 0; i < jobs; i++)
            {
                tp.Add(new DatafilesDist(i));
            }

            // Create and start the Project. Execution will continue after all Jobs have been completed.
            // Job results will be stored in the 'tp' object.
            tp.Execute();

            for (int i = 0; i < jobs; i++)
            {
                // Retrieve one Job result from 'tp'
                int jobresult = ((DatafilesDist)tp.Get(i)).Result;

                // Display the value generated in the Job
                Console.WriteLine("Result of Job {0}: {1}", i + 1, jobresult);
            }

            // Uninitialize and remove the session
            tm.Unload(true);
        }

        // Mark the class as serializable
        [Serializable]
        class DatafilesDist : TechilaThread // Extend the TechilaThread class
        {
            // Define type of input argument
            int Jobidx;

            // Define 'Result' as public so it can be accessed when Job results are retrieved from the 'tp' list.
            public int Result;

            // Define constructor that takes one input argument
            public DatafilesDist(int jobidx)
            {
                this.Jobidx = jobidx;
            }

            // Override the 'Execute' method in the 'TechilaThread' class with code that we want to execute
            public override void Execute()
            {
                // Choose file that will be read during one Job
                string fname = "file" + Jobidx + ".txt";
                string line;

                // Initialize the result counter to 0.
                Result = 0;

                // Create object for reading from file
                System.IO.StreamReader file = new System.IO.StreamReader(fname);

                while ((line = file.ReadLine()) != null) // Sum values on lines
                {
                    // Increase summation result by the value of one random value read from file
                    Result = Result + Convert.ToInt32(line);
                }

                // Close the file
                file.Close();

            }

        }

    }
}
