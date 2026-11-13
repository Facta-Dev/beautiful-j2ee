package example;

import java.util.Objects;

public final class WidgetService {
    public enum Status {
        READY,
        ARCHIVED
    }

    public record Widget(String id, String name, Status status) {
        public Widget {
            Objects.requireNonNull(id, "id");
            Objects.requireNonNull(name, "name");
            Objects.requireNonNull(status, "status");
        }
    }

    public Widget archive(Widget widget) {
        Objects.requireNonNull(widget, "widget");
        if (widget.status() == Status.ARCHIVED) {
            throw new IllegalStateException("widget is already archived");
        }
        return new Widget(widget.id(), widget.name(), Status.ARCHIVED);
    }
}
