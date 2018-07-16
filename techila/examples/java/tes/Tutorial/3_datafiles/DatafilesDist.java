// Copyright 2017 Techila Technologies Ltd.

// Import required classes
import java.io.Serializable;
import java.util.concurrent.Callable;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Scanner;
import java.util.Vector;

public class DatafilesDist implements Callable, Serializable {
    // DatafilesDist objects will be serialized and sent to Techila Workers.
    private int index;

    public DatafilesDist(int index) {
        this.index = index;
    }

    public Integer call() throws Exception {
        // Code inside this call method will be executed in each
        // computational Job

        // Each Job will process one file, determined by the value of
        // the input argument.
        String filename = "TechilaExampleFile"
            + Integer.toString(index) + ".txt";
        Path filePath = Paths.get(filename);
        Scanner scanner = new Scanner(filePath);
        Vector<Integer> integers = new Vector<Integer>();
        int result = 0;
        while (scanner.hasNext()) {
            if (scanner.hasNextInt()) {
                result = result + scanner.nextInt();
            } else {
                scanner.next();
            }
        }
        return result;
    }
}
