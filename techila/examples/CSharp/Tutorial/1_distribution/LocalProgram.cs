using System;
using System.Collections.Generic;


namespace LocalProgram
{
    class LocalProgram
    {
        static void Main()
        {
            // Set 'iterations' to 5. Will be used to define the number of iterations later.
            int iterations = 5;

            // Do 5 iterations.
            for (int i = 0; i < iterations; i++)
            {
                // Create new instance of 'DistributionDist'
                DistributionDist dd = new DistributionDist();

                // Call the 'Execute' method and store result variable in 'res'
                int res = dd.Execute();

                // Print the value of the 'res' variable.
                System.Console.WriteLine("Result of iteration {0}: {1}",i + 1, res);
            }


        }



    }
    class DistributionDist // Class containing some executable code
    {
        // Define type of variable that will be returned
        int Result;

        // Define an 'Execute' method containing the code that will be executed
        public int Execute()
        {
            // Do simple arithmetic operation
            Result = 1 + 1;

            // Return the result
            return (Result);
        }

    }
}
