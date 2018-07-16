using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Techila.Management;
using System.IO;
using System.Security.Principal;

namespace ADImpersonateTest
{
    class RunImpersonate
    {
        static void Main(string[] args)
        {
            
            TechilaProject tp = new TechilaProject();

            // Define how many Jobs will be created.
            int jobs = 1;

            // Create one Job in the Project.
            for (int i = 0; i < jobs; i++)
            {
                ImpersonateDist tt = new ImpersonateDist();
                
                // Enable partial Active Diretory impersonation
                tt.ImpersonateThread = TechilaThread.ImpersonateType.Partial;
                tp.Add(tt);
            }

            // Create the Project.
            tp.Execute();

            // Print results
            for (int i = 0; i < jobs; i++)
            {
                ImpersonateDist job = (ImpersonateDist)tp.Get(i);
                foreach (String line in job.Result) {
                    Console.WriteLine(line);
                }
            }
        }
    }

    // Mark the class as serializable
    [Serializable]
    class ImpersonateDist : TechilaThread // Extend the TechilaThread class
    {
        // Mark the result of the Job as public.
        public List<String> Result = new List<String>();

        // Override the 'Execute' method in the 'TechilaThread' class with code that we want to execute.
        public override void Execute()
        {
            using (new TechilaImpersonate(this)) // Create a new TechilaImpersonate object for the duration of the 'using'-statement.
            {   // Block 1
                // Code inside the 'using' block will be executed using 
                // the user's own AD user account.
                
                // Get information which Windows identity is currently used. This will return the End-User's own  user account.
                String b1 = "Block 1 executed under following user credentials: " 
                    + WindowsIdentity.GetCurrent().Name;
                Result.Add(b1);
            }
             
            // Block 2 start. Code outside the using block will be executed 
            // using the  Techila Worker's own user account.
            
            // Get information which Windows user account is currently used. This will return the Techila Worker's default user account.
            String b2 = "Block 2 executed under following user credentials: "
                    + WindowsIdentity.GetCurrent().Name;
            Result.Add(b2);
            // Block 2 end

            using (new TechilaImpersonate(this)) // Create a new TechilaImpersonate object for the duration of the 'using'-statement.
            {
                // Code inside the 'using' block will be executed using 
                // the user's own AD user account.
                
                // Get information which Windows identity is currently used. This will return the End-User's own  user account.
                String b3 = "Block 3 executed under following user credentials: "
                    + WindowsIdentity.GetCurrent().Name;
                Result.Add(b3);
            } // Block 3 ends
        }
    }
}
