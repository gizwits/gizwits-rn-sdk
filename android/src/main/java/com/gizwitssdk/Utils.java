
package com.gizwitssdk;

public class  Utils {

	private static Integer sn = 1000;
  protected synchronized static int getSn() {
		if (sn == null) {
			sn = 1;
		} else {
			sn++;
		}
		return sn;
	}
}