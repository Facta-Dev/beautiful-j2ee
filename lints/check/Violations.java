package check;

import java.util.*;

// Deliberate violations for the CI harness. Do not copy this file.
public final class Violations {
    public int magic() {
        return 42;
    }

    public boolean same(String left, String right) {
        if (left == right) return true;
        return false;
    }

    // TODO: implement this before shipping
    public void empty() {
    }
}
