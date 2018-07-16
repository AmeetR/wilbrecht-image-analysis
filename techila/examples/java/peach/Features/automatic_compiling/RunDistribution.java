import java.io.FileInputStream;
import java.io.DataInputStream;

import java.util.List;
import java.util.Vector;

import fi.techila.user.TechilaManagerFactory;
import fi.techila.user.TechilaManager;
import fi.techila.user.Peach;
import fi.techila.user.Support;


public class RunDistribution {

    public List<Integer> runDistribution(int amount) {
        Vector<Integer> result = new Vector<Integer>();

        TechilaManager techila = TechilaManagerFactory.getTechilaManager();

        try {

            techila.initFile();

            Peach peach = techila.newPeach("distribution_dist");

            peach.addSourceFile("DistributionDist.java");

            if (peach.sourcesChanged()) {
                System.out.println("Compiling source files");
                com.sun.tools.javac.Main javac = new com.sun.tools.javac.Main();
                String[] options = new String[] {
                    "DistributionDist.java",
                };
                javac.compile(options);
            }


            peach.setMessages(true);

            peach.addExeFile("classfile", "DistributionDist.class");
            peach.setJavaExecutable();
            peach.putExeExtras("Parameters", "DistributionDist");
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
        List<Integer> result = runDistribution(5);

        System.out.println(result);
    }

    public static void main(String[] args) {
        RunDistribution rd = new RunDistribution();
        rd.run();
    }
}
