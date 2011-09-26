package com.trickplay.gameservice.exception;

@SuppressWarnings("serial")
public class AuthenticationException extends Exception {

  public AuthenticationException() {
    super();
  }

  public AuthenticationException(String string) {
    super(string);
  }

  public AuthenticationException(String string, Throwable throwable) {
    super(string, throwable);
  }

  public AuthenticationException(Throwable throwable) {
    super(throwable);
  }
}
