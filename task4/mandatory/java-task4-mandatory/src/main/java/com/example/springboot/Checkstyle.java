package com.example.springboot;

/**
 * Checkstyle.
 */
public class Checkstyle {

  private void checkstyle() {
    String possiblyNullString = getPossiblyNullString();
    // This line will trigger a SpotBugs null pointer dereference warning
    System.out.println(possiblyNullString.length());
  }

  private static String getPossiblyNullString() {
    // Simulate a method that could return null
    return null;
  }
}
