// Copyright 2014 Techila Technologies Ltd.
import java.io.Serializable;
import java.util.concurrent.Callable;
import java.io.FileOutputStream;
import java.io.DataOutputStream;

public class LibraryDist implements Callable, Serializable {
    // LibraryDist objects will be serialized and sent to Techila Workers.

    private int index;

    public LibraryDist(int index) {
        this.index = index;
    }

    public Integer call() throws Exception {
        // Code inside this call method will be executed in each
        // computational Job.

        // Call the libraryFunction method, which is located in the
        // separate JAR file.
        Library lib = new Library();
        int result = lib.libraryFunction(index);

        return result;
    }
}
