/*LABB 4. PROGRAM 2: LAB4_Flera_Konstruktorer
 *
 *  Innefattar:
 *
 *   -  Flera objekt och konstruktorer med referenser till andra objekt
 *     
 * I detta program demonstreras m�nga objekt som printar klockan, i form av digitaltid */

import java.util.*;

public class LAB4_Flera_Konstruktorer 
{
	public static void main(String[] args)
	{
		Scanner read = new Scanner (System.in);
		
		System.out.println("---------------------PROGRAM: Flera Konstruktorer--------------------------------\n");
		System.out.println("Skriv timme:");
		int a = read.nextInt();
		
		System.out.println("Skriv minut:");
		int b = read.nextInt();
		
		System.out.println("Skriv sekund:");
		int c = read.nextInt();
		
		LAB4_Flera_Konstruktorer_KLASS2 objekt1 = new LAB4_Flera_Konstruktorer_KLASS2();
		LAB4_Flera_Konstruktorer_KLASS2 objekt2 = new LAB4_Flera_Konstruktorer_KLASS2(a);
		LAB4_Flera_Konstruktorer_KLASS2 objekt3 = new LAB4_Flera_Konstruktorer_KLASS2(a,b);
		LAB4_Flera_Konstruktorer_KLASS2 objekt4 = new LAB4_Flera_Konstruktorer_KLASS2(a,b,c);
		//dessa kommer anv�nda konstruktorn f�r lika m�nga argument som instoppat
		
	
		System.out.printf("%s \n", objekt1.digitalTid());
		System.out.printf("%s \n", objekt2.digitalTid());
		System.out.printf("%s \n", objekt3.digitalTid());
		System.out.printf("%s \n", objekt4.digitalTid());
		//skickar objekten till metoden digitalTid
	}

}
