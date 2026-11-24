import Toybox.Lang;

//! The blank you replace in every koan. It's a String on purpose:
//! it can never accidentally equal a number, a boolean or null.
const FILL_ME_IN = "<fill me in>";

//! True when actual holds exactly the characters in expected.
//! Compare String contents with equals(): == on Strings compares identity, as in Java.
function sameText(actual as String or Null, expected as String) as Boolean {
    if (actual != null) {
        return actual.equals(expected);
    }
    return false;
}
