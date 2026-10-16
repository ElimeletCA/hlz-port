import java.io.File;
import java.lang.reflect.Method;
import javax.imageio.ImageIO;
import javax.microedition.lcdui.Image;
import javax.microedition.lcdui.Graphics;

public class DumpAssets {
    public static void main(String[] args) {
        try {
            System.out.println("Starting DumpAssets with reflection...");
            
            // Set dq.b
            for (java.lang.reflect.Field f : dq.class.getFields()) {
                if (f.getName().equals("b") && f.getType() == byte.class) {
                    f.setByte(null, (byte)2); // Class 2 = Assassin
                }
            }
            
            // Also initialize dq.a (player dg instance)
            dg hero = dg.a((byte)2);
            dq.a = hero;
            
            // Find rpg.c.a() that returns l
            Method getHeroModel = null;
            for (Method m : rpg.c.class.getMethods()) {
                if (m.getName().equals("a") && m.getParameterCount() == 0 && m.getReturnType() == l.class) {
                    getHeroModel = m;
                    break;
                }
            }
            
            if (getHeroModel == null) {
                System.out.println("Could not find rpg.c.a() returning l!");
                return;
            }
            
            l heroModel = (l) getHeroModel.invoke(null);
            System.out.println("Hero model loaded: " + heroModel);
            
            // Create J2ME image and graphics
            Image img = Image.createImage(64, 64);
            Graphics g = img.getGraphics();
            rpg.a.a = new cr(g);
            
            // Draw hero idle frame facing south: anim 0, dir 1, frame 0, at (32, 48)
            heroModel.a((byte)0, (byte)1, 0, 32, 48);
            
            // Save to disk
            java.awt.image.BufferedImage bimg = img.getCanvas();
            File out = new File("tools/lucian_java_dump.png");
            ImageIO.write(bimg, "PNG", out);
            System.out.println("Saved tools/lucian_java_dump.png successfully!");
        } catch (Throwable t) {
            t.printStackTrace();
        }
    }
}
