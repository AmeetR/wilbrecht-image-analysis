import java.io.FileOutputStream;
import java.io.DataOutputStream;

public class DistributionDist {

    private String outputfile = "techila_peach_result.dat";

    public int distributionDist() {
        return 1 + 2;
    }

    public void run() {
        int result = distributionDist();

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
        DistributionDist dd = new DistributionDist();
        dd.run();
    }
}
