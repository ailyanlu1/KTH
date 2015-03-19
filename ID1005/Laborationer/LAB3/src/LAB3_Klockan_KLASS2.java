//Klass 2 i LAB3_Klockan

public class LAB3_Klockan_KLASS2 
{
	private int timme;
	private int minut;
	private int sekund;
	
	public void setTid(int h, int m, int s) 
	//dessa int �r a,b,c i main
	{
		timme =  ( (h >= 0 && h < 24) ? h : 0);
		minut =  ( (m >= 0 && m < 60) ? m : 0);  
		sekund = ( (s >= 0 && s < 60) ? s : 0);
		//om v�rderna h, m, s �r emellan v�rdena anv�nds str�ngarna (modulurn '?' anv�nds)
		//annars f�rblir str�ngarna null
	}
	
	public String vanligTid()
	{
		
		return String.format("%02d: %02d: %02d", timme, minut, sekund); 
		//formaterar str�ngen 
		//visar str�ngarna  timme, minut, sekund efter tv� decimaler och adderar komma
	}
	
	public void nyTid() //printar ut tid p� dygnet beroende p� v�rdet p� timme
	{		
		if(timme < 10 && timme > 4)
		{
			System.out.print("- Det �r morgon!");
		}
		
		 if (timme < 12 &&  timme > 9)
		{
			System.out.print("- Det �r f�rmiddag!");
		}
		
		 if (timme < 19 &&  timme > 13)
		{
			System.out.print("- Det �r eftermiddag!");
		}
		
		 if (timme < 23 &&  timme > 18)
		{
			System.out.print("- Det �r kv�ll!");
		}
		
		 if (timme < 25 &&  timme > 22) 
		{
			System.out.print("- Det �r natt!");
		}
		 
		 if(timme < 5 &&  timme > -1)
		{
			System.out.print("- Det �r natt!");
		}
		

	}
	
	
	
		
}