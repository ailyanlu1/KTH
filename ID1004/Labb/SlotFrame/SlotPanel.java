import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.*;
import javax.swing.*;

/**
 * The SlotPanel holds the major GUI components of the slot machine display.
 * @author fki@kth.se
 *
 */
public class SlotPanel extends JPanel
	implements ActionListener
{
	/**
	 * The messageQueue holds the messages that we deliver to the
	 * application via the SlotControl.getNextEvent() method.
	 */
	protected LinkedList<String> messageQueue = new LinkedList<String>();
	
	/**
	 * The WheelPanel shows the symbol wheels.
	 */
	private WheelPanel wp = null;
	
	/**
	 * The ButtonsPanel shows and holds the user interaction components.
	 */
	private ButtonsPanel bup = null;
	
	/**
	 * For interface SlotControl, we defer to the WheelPanel to return
	 * the model.
	 * 
	 * @return The wheel model of the simulator.
	 */
	public int [][] getWheelModel() {
		return wp.getWheelModel();
	}
	
	/**
	 * Returns the next event from this simulator. If there are no events
	 * waiting, the call blocks until an event is delivered. This implementation
	 * only delivers two events, "creditbutton" and "rollbutton".
	 * 
	 * @return A string describing the next event.
	 */
	public String getNextEvent() {
		String msg = null;
		synchronized (messageQueue) {
			while (messageQueue.isEmpty()) {
				try {
					messageQueue.wait();
				}
				catch (InterruptedException iex) {
					iex.printStackTrace();
				}
			}
			msg = messageQueue.remove(0);
		}
		return msg;
	}
	
	/**
	 * This method places a message on the message queue and notifies
	 * a thread waiting on the message queue.
	 * 
	 * @param msg The message to send to the application.
	 */
	protected void sendMessage (String msg) {
		synchronized (messageQueue) {
			messageQueue.add(msg);
			messageQueue.notify();
		}
	}
	
	/**
	 * This method is our listener for the credit and roll buttons in
	 * the ButtonPanel. The method translates the button clicks into
	 * application messages and sends the messages.
	 * 
	 * The reason for this is to protect the Event Dispatch Thread from
	 * the application. In particular, the simulation can not be animated
	 * from within the EDT; that must come from some other thread.
	 */
	public void actionPerformed(ActionEvent e) {
		String cmd = e.getActionCommand();
		if (cmd.equals("credit")) {
			sendMessage("creditbutton");
		}
		else if (cmd.equals("roll")) {
			sendMessage("rollbutton");
		}
	}
		
	/**
	 * Sets the player credit display. We defer to the ButtonPanel to
	 * do it.
	 * 
	 * @param n The new credit amount.
	 */
	public void setCredit(int n) {
		bup.setCredit(n);
	}
	
	/**
	 * Activates or deactivates the win light. We defer to the ButtonPanel
	 * to do that.
	 * 
	 * @param amount Zero to disable, positive to enable the win light.
	 */
	public void win(int amount) {
		bup.win(amount);
	}
	
	/**
	 * Animate and roll the symbol wheels.
	 * We turn off the win light and then ask the WheelPanel to perform
	 * the animation.
	 * 
	 * @param ar The desired symbols to show on the payline.
	 */
	public void roll(final int [] ar) {
		win(0);
		wp.animate(ar);
	}

	/**
	 * Creates a new SlotPanel.
	 */
	public SlotPanel(boolean fallBackMode) {
		
		// The BorderLayout has five regions, but we only use CENTER and
		// SOUTH (see below).
		setLayout(new BorderLayout());
		
		
		// The JLayeredPane is needed so that we can have a static graphic
		// in front of the wheels.
		JLayeredPane wheelArea = new JLayeredPane();
		
		// Create a BlingPanel to show an image of a painted border and payline
		BlingPanel bp = new BlingPanel(fallBackMode);
		
		// The image is fixed size, so adjust the layered pane to match in size.
		Dimension bpSize = bp.getSize();
		wheelArea.setPreferredSize(bpSize);
		
		// Create the WheelPanel and tell it to match size to the image.
		wp = new WheelPanel(bpSize);
		
		// Add wheels and bling to the layered pane, in separate layers
		wheelArea.add(wp, JLayeredPane.DEFAULT_LAYER);
		wheelArea.add(bp, JLayeredPane.PALETTE_LAYER);
		
		// Put the layered pane in our CENTER layout area.
		add(wheelArea, BorderLayout.CENTER);
		
		
		// Create a ButtonsPanel
		bup = new ButtonsPanel();
		
		// We add ourself as the action listener of the button panel.
		bup.addListener(this);
		
		// Put the ButtonsPanel in our SOUTH layout area.
		add(bup, BorderLayout.SOUTH);
	}

}
