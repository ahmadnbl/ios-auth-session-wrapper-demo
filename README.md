# ios-auth-session-wrapper-demo

The demo how to handle Apple's Authentication Session service on app that still handle minimum iOS version 11.0.
Apple introduce `SFAuthenticationSession` on iOS 11.0, but suddenly deprecating it on iOS 12.0. Beside that, Apple introduce new `ASWebAuthenticationSession` on iOS 12.0. And on iOS 13.0 Apple adding new API called `Presentation Context` that developers need to define it when using `ASWebAuthenticationSession` on iOS 13.0.

With this wrapper, we hope it can help developer to handle that condition when still maintaining iOS 11.0, but want to use the new API on newer iOS version.
