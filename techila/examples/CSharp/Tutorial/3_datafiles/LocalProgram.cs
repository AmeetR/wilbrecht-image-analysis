using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;



namespace LocalProgram
{
    class LocalProgram
    {
        static void Main()
        {

            int iterations = 4; // File count
            int arraySize = 5;  // Array size

            // Create text files containing sample values
            for (int i = 0; i < iterations; i++) // For each file
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



            for (int i = 0; i < iterations; i++) // For each file
            {

                DatafilesDist dd = new DatafilesDist(i);
                int res = dd.Execute();
                System.Console.WriteLine("Result of iteration {0}: {1}", i + 1, res);
            }

        }
    }
    class DatafilesDist
    {

        int Iteration;
        public DatafilesDist(int iteration)
        {
            this.Iteration = iteration;
        }


        public int Execute()
        {
            string fname = "file" + Iteration + ".txt";
            string line;
            int counter = 0;
            System.IO.StreamReader file = new System.IO.StreamReader(fname);

            while ((line = file.ReadLine()) != null) // Sum values on lines
            {
                counter = counter + Convert.ToInt32(line);
            }

            return (counter);
        }

    }
}
