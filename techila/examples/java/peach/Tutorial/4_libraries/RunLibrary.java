// Copyright 2014 Techila Technologies Ltd.

import java.io.FileInputStream;
import java.io.DataInputStream;

import java.util.List;
import java.util.Vector;

import fi.techila.user.TechilaManagerFactory;
import fi.techila.user.TechilaManager;
import fi.techila.user.Peach;
import fi.techila.user.Support;


public class RunLibrary {

    public List<Integer> runLibrary(int amount) {
        Vector<Integer> result = new Vector<Integer>();

        TechilaManager techila = TechilaManagerFactory.getTechilaManager();

        try {

            techila.initFile();

            Peach peach = techila.newPeach("library_dist");

            peach.setMessages(true);

            // add the worker code to the Executor Bundle
            peach.addExeFile("classfile", "LibraryDist.class");

            // also add the library.jar to the Executor Bundle
            peach.addExeFile("jarfile", "library.jar");

            peach.setJavaExecutable();
            peach.putExeExtras("Parameters", "LibraryDist %P(jobidx)");

            // set environment on the workers so that the library.jar can be found
            peach.putExeExtras("Environment", "CLASSPATH;value=library.jar:.;osname=Linux,CLASSPATH;value=library.jar\\;.;osname=Windows"); // different path separator character for each OS
            peach.setJobs(amount);

            peach.execute();

            String file;
            while((file = peach.nextFile()) != null) {
                FileInputStream fis = new FileInputStream(file);
                DataInputStream dis = new DataInputStream(fis);

                result.add(dis.readInt());

                dis.close();
                fis.close();
            }

            peach.done();

        } catch (Exception e) {
            System.err.println("Exception: " + e);
        } finally {
            techila.unload(true, true);
        }

        return result;
    }

    public void run() {
        List<Integer> result = runLibrary(5);

        System.out.println(result);
    }

    public static void main(String[] args) {
        RunLibrary rd = new RunLibrary();
        rd.run();
    }
}
