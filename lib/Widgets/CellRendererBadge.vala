// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*
 * Copyright (c) 2012-2013 Victor Eduardo <victoreduardm@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program; see the file COPYING.  If not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

public class Granite.Widgets.CellRendererBadge : Gtk.CellRenderer {

    public string text { get; set; default = ""; }

    private Pango.Rectangle text_logical_rect;
    private Pango.Layout text_layout;
    private Gtk.Border margin;
    private Gtk.Border padding;
    private Gtk.Border border;

    public CellRendererBadge () {
    }

    public override Gtk.SizeRequestMode get_request_mode () {
        return Gtk.SizeRequestMode.HEIGHT_FOR_WIDTH;
    }

    public override void get_preferred_width (Gtk.Widget widget,
                                              out int minimum_size,
                                              out int natural_size)
    {
        update_layout_properties (widget);

        int width = text_logical_rect.width;
        width += margin.left + margin.right;
        width += padding.left + padding.right;
        width += border.left + border.right;

        minimum_size = natural_size = width + 2 * (int) xpad;
    }

    public override void get_preferred_height_for_width (Gtk.Widget widget, int width,
                                                         out int minimum_height,
                                                         out int natural_height)
    {
        update_layout_properties (widget);

        int height = text_logical_rect.height;
        height += margin.top + margin.bottom;
        height += padding.top + padding.bottom;
        height += border.top + border.bottom;

        minimum_height = natural_height = height + 2 * (int) ypad;
    }

    private void update_layout_properties (Gtk.Widget widget) {
        var ctx = widget.get_style_context ();
        ctx.save ();

        // Add class before creating the pango layout and fetching paddings.
        // This is needed in order to fetch the proper style information.
        ctx.add_class (StyleClass.BADGE);

        var state = ctx.get_state ();

        margin = ctx.get_margin (state);
        padding = ctx.get_padding (state);
        border = ctx.get_border (state);

        text_layout = widget.create_pango_layout (text);
        text_layout.set_font_description (ctx.get_font (state));

        ctx.restore ();

        Pango.Rectangle ink_rect;
        text_layout.get_pixel_extents (out ink_rect, out text_logical_rect);
    }

    public override void render (Cairo.Context context, Gtk.Widget widget, Gdk.Rectangle bg_area,
                                 Gdk.Rectangle cell_area, Gtk.CellRendererState flags)
    {
        update_layout_properties (widget);

        Gdk.Rectangle aligned_area = get_aligned_area (widget, flags, cell_area);

        int x = aligned_area.x;
        int y = aligned_area.y;
        int width = aligned_area.width;
        int height = aligned_area.height;

        // Apply margin
        x += margin.right;
        y += margin.top;
        width -= margin.left + margin.right;
        height -= margin.top + margin.bottom;

        var ctx = widget.get_style_context ();
        ctx.add_class (StyleClass.BADGE);

        ctx.render_background (context, x, y, width, height);
        ctx.render_frame (context, x, y, width, height);

        // Apply border width and padding offsets
        x += border.right + padding.right;
        y += border.top + padding.top;
        width -= border.left + border.right + padding.left + padding.right;
        height -= border.top + border.bottom + padding.top + padding.bottom;

        // Center text
        x += text_logical_rect.x + (width - text_logical_rect.width) / 2;
        y += text_logical_rect.y + (height - text_logical_rect.height) / 2;

        ctx.render_layout (context, x, y, text_layout);
    }

    [Deprecated (replacement = "Gtk.CellRenderer.get_preferred_size", since = "")]
    public override void get_size (Gtk.Widget widget, Gdk.Rectangle? cell_area,
                                   out int x_offset, out int y_offset,
                                   out int width, out int height)
    {
        assert_not_reached ();
    }
}
