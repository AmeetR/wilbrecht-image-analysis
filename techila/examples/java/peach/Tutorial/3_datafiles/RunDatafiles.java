// Copyright 2014 Techila Technologies Ltd.

import java.io.FileInputStream;
import java.io.DataInputStream;

import java.util.List;
import java.util.Vector;

import fi.techila.user.TechilaManagerFactory;
import fi.techila.user.TechilaManager;
import fi.techila.user.Peach;
import fi.techila.user.Support;


public class RunDatafiles {

    public List<Integer> runDatafiles() {
        Vector<Integer> result = new Vector<Integer>();

        TechilaManager techila = TechilaManagerFactory.getTechilaManager();

        try {

            techila.initFile();

            Peach peach = techila.newPeach("datafiles_dist");

            peach.setMessages(true);

            peach.addExeFile("classfile", "DatafilesDist.class");
            peach.setJavaExecutable();
            peach.putExeExtras("Parameters", "DatafilesDist %P(jobidx)");

            peach.addParamFile("datafile.txt");

            peach.setJobs(4);

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
            e.printStackTrace();
        } finally {
            techila.unload(true, true);
        }

        return result;
    }

    public void run() {
        List<Integer> result = runDatafiles();

        System.out.println(result);
    }

    public static void main(String[] args) {
        RunDatafiles rd = new RunDatafiles();
        rd.run();
    }
}
