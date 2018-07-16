// Copyright 2014 Techila Technologies Ltd.

import java.io.FileInputStream;
import java.io.DataInputStream;

import java.util.List;
import java.util.Vector;

import fi.techila.user.TechilaManagerFactory;
import fi.techila.user.TechilaManager;
import fi.techila.user.Peach;
import fi.techila.user.Support;


public class RunParameters {

    public List<Integer> runParameters(int multip, int amount) {
        Vector<Integer> result = new Vector<Integer>();

        TechilaManager techila = TechilaManagerFactory.getTechilaManager();

        try {

            techila.initFile();

            Peach peach = techila.newPeach("parameters_dist");

            peach.setMessages(true);

            peach.addExeFile("classfile", "ParametersDist.class");
            peach.setJavaExecutable();
            peach.putExeExtras("Parameters", "ParametersDist %P(multip) %P(jobidx)");
            peach.setJobs(amount);
            peach.putProjectParam("multip", Integer.toString(multip));

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
        List<Integer> result = runParameters(2, 5);

        System.out.println(result);
    }

    public static void main(String[] args) {
        RunParameters rd = new RunParameters();
        rd.run();
    }
}
