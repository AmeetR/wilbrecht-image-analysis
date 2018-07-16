using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ExampleLibrary
{
    public class SumClass
    {
        // Define the 'Sum' method that sums the values of two integers.
        // This method will be called from the locally executable program
        // and the from the distributed version.
        // returns the value of the summation.
        public static int Sum(int a, int b)
        {
            return(a + b);
        }

    }

}
