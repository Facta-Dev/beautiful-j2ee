package check;

import java.util.List;

public final class Clean {
    private static final int LIMIT = 10;

    public int size(List<String> values) {
        if (values == null) {
            return 0;
        }
        return Math.min(values.size(), LIMIT);
    }
}
