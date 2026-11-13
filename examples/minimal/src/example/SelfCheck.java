package example;

public final class SelfCheck {
    private SelfCheck() {
    }

    public static void main(String[] args) {
        WidgetService service = new WidgetService();
        WidgetService.Widget widget =
                new WidgetService.Widget("w1", "First", WidgetService.Status.READY);

        WidgetService.Widget archived = service.archive(widget);

        if (archived.status() != WidgetService.Status.ARCHIVED) {
            throw new AssertionError("archive did not change the status");
        }
        if (!archived.id().equals("w1")) {
            throw new AssertionError("archive changed the id");
        }
        if (!archived.name().equals("First")) {
            throw new AssertionError("archive changed the name");
        }
        System.out.println("self-check: OK");
    }
}
