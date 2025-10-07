# Razorpay configuration
-keepclassmembers class com.razorpay.** {
    *;
}

-keep class com.razorpay.** {*;}

# Suppress all warnings from Razorpay including deprecation warnings
-dontwarn com.razorpay.**

# Suppress general deprecation warnings for third-party libraries
-dontwarn javax.annotation.**
-dontwarn org.jetbrains.annotations.**

# Additional rules to handle common deprecation issues
-dontwarn java.lang.invoke.**
-dontwarn android.support.**

# Keep payment related classes to avoid runtime issues
-keep class * extends java.util.ListResourceBundle {
    protected java.lang.Object[][] getContents();
}