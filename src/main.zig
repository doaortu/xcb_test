const c = @cImport({
    @cInclude("xcb/xcb.h");
});

const stdout = @import("std").io.getStdOut().writer();
const span = @import("std").mem.span;
const os = @import("std").os;

pub fn main() !void {
    if (os.argv.len < 2) {
        try stdout.print("Usage: {s} <window-class>\n", .{os.argv[0]});
        return;
    }

    const windowClass = span(os.argv[1]);
    const conn = c.xcb_connect(null, null);

    // Get window tree of root window
    const cookie = c.xcb_query_tree(conn, c.xcb_setup_roots_iterator(c.xcb_get_setup(conn)).data.*.root);
    const tree_reply = c.xcb_query_tree_reply(conn, cookie, null);
    const children = c.xcb_query_tree_children(tree_reply);

    const contains = @import("std").mem.containsAtLeast;

    for (0..@intCast(c.xcb_query_tree_children_length(tree_reply))) |i| {
        const child = children[i];
        const class_req = c.xcb_get_property(conn, 0, child, c.XCB_ATOM_WM_CLASS, c.XCB_ATOM_STRING, 0, 100);
        const class_rep = c.xcb_get_property_reply(conn, class_req, null);
        const class = c.xcb_get_property_value(class_rep);
        const class_len = c.xcb_get_property_value_length(class_rep);
        const class_str = @as([*]u8, @ptrCast(class))[0..@intCast(class_len)];
        if (!contains(u8, class_str, 1, windowClass)) {
            continue;
        }
        const cookie_a = c.xcb_get_window_attributes(conn, child);
        const attrs = c.xcb_get_window_attributes_reply(conn, cookie_a, null);
        // Check visibility based on map state
        if (attrs.*.map_state == c.XCB_MAP_STATE_VIEWABLE) {
            try stdout.print("true", .{});
            break;
        } else {
            try stdout.print("false", .{});
            break;
        }
    }

    // Disconnect from X server
    c.xcb_disconnect(conn);
}
