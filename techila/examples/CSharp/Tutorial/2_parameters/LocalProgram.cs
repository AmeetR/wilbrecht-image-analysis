using System;
using System.Collections.Generic;


namespace LocalProgram
{
    class LocalProgram
    {
        static void Main()
        {
            // Define fixed variables
            int iterations = 5;
            int multip = 2;

            // Define variable to store the result
            int result;

            for (int i = 0; i < iterations; i++)
            {
                // Create new class instance with desired input arguments
                ParametersDist pd = new ParametersDist(multip,i);

                // Call the execute method that performs the multiplication operation
                result = pd.Execute();

                // Print the result of the multiplication on the standard out
                System.Console.WriteLine("Result of iteration {0}: {1}",i + 1, result);
            }


        }



    }
    class ParametersDist // Class containing some executable code
    {
        // Define type of variables that will be used
        int Index;
        int Multip;


        // Define constructor that takes two input arguments
        public ParametersDist(int multip, int index) {
            this.Index=index;
            this.Multip=multip;
        }

        // Define type of 'Result' variable, which will be returned from the 'Execute' method
        int Result;

        // Define an 'Execute' method containing the code that will be executed
        public int Execute()
        {
            // Do simple arithmetic operation
            Result = Multip * Index;

            // Return the result
            return (Result);
        }

    }
}
