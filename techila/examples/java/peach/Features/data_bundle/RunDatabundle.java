// Copyright 2014 Techila Technologies Ltd.

import java.io.FileInputStream;
import java.io.DataInputStream;

import java.util.List;
import java.util.Vector;

import fi.techila.user.TechilaManagerFactory;
import fi.techila.user.TechilaManager;
import fi.techila.user.Peach;
import fi.techila.user.Support;


public class RunDatabundle {
    public List<String> runDatabundle() {
        Vector<String> result = new Vector<String>();

        TechilaManager techila = TechilaManagerFactory.getTechilaManager();

        try {

            techila.initFile();

            Peach peach = techila.newPeach("databundle_dist");

            peach.setMessages(true);

            peach.addExeFile("classfile", "DatabundleDist.class");
            peach.setJavaExecutable();
            peach.putExeExtras("Parameters", "DatabundleDist %P(jobidx)");

            peach.newDataBundle();
            peach.addDataFileWithDir("./storage/", "file1_bundle1");
            peach.addDataFileWithDir("./storage/", "file2_bundle1");
            peach.putDataExtras("ExpirationPeriod", "60 m");

            peach.newDataBundle();
            peach.addDataFile("file1_bundle2");
            peach.addDataFile("file2_bundle2");
            peach.putDataExtras("ExpirationPeriod", "30 m");

            peach.setJobs(1);

            peach.execute();

            String file;
            while((file = peach.nextFile()) != null) {
                FileInputStream fis = new FileInputStream(file);
                DataInputStream dis = new DataInputStream(fis);

                result.add(dis.readUTF());

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
        List<String> result = runDatabundle();

        System.out.println(result);
    }

    public static void main(String[] args) {
        RunDatabundle rd = new RunDatabundle();
        rd.run();
    }

}
