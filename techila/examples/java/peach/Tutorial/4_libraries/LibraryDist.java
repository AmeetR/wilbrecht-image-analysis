// Copyright 2014 Techila Technologies Ltd.

import java.io.FileOutputStream;
import java.io.DataOutputStream;

// worker code that will call the library function

public class LibraryDist {

    private String outputfile = "techila_peach_result.dat";

    public int libraryDist(int x) {
        Library lib = new Library();
        return lib.libraryFunction(x);
    }

    public void run(int x) {
        int result = libraryDist(x);

        try {
            FileOutputStream fos = new FileOutputStream(outputfile);
            DataOutputStream dos = new DataOutputStream(fos);

            dos.writeInt(result);

            dos.close();
            fos.close();
        } catch (Exception e) {
            System.err.println("Exception: " + e);
            System.exit(1);
        }
    }

    public static void main(String[] args) {
        int x = Integer.parseInt(args[0]);

        LibraryDist dd = new LibraryDist();
        dd.run(x);
    }
}
