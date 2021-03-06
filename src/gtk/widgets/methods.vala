using GData;

namespace GDataGtk
{
	internal string[] resolve_type_layout (Type class_type, string[] layout)
	{
		if (layout == null)
			return (new string[0]);
		if (layout.length == 0)
			return (TypeInformation.get_instance().get_all_type_property_names(class_type));
		return (layout);
	}

	internal string[] resolve_object_layout (Type class_type, string[] layout)
	{
		if (layout == null)
			return (new string[0]);
		if (layout.length == 0)
			return (TypeInformation.get_instance().get_all_type_property_names(class_type));
		return (layout);
	}

	internal string convert_to_type_name (string str)
	{
		string res = "";
		for (int i=0; i<str.length; i++) {
			string p = str.substring(i, 1);
			if ((res != "") && (p == p.up()) && ((res.length > 1) &&(res.substring(res.length-2,1) != "_")))
				res += "_" + p;
			else
				res += p.up();
		}
		return (res + "_");
	}

	internal string _get_presentable_str (string str)
	{
		if ((str == null) || (str.length == 0))
			return ("");
		if (str.length == 1)
			return (str.up());
		string s = str.substring(0,1).up() + str.substring(1);
		return (s.replace("-", " ").replace("_", " "));
	}

	public string change_str_case (string str, CharacterCaseMode ccase)
	{
		if (ccase == CharacterCaseMode.UPCASE)
			return (str.up());
		else if (ccase == CharacterCaseMode.LOCASE)
			return (str.down());
		else if (ccase == CharacterCaseMode.PRESENTABLE)
			return (_get_presentable_str(str));
		return (str);
	}

	internal string __get_enum_value_str (EnumValue? val, EnumFlagsMode mode)
	{
		if (mode == EnumFlagsMode.NUMBER)
			return ("%lu".printf(val.value));
		if (mode == EnumFlagsMode.NAME)
			return (val.value_name);
		if (mode == EnumFlagsMode.NICK)
			return (val.value_nick);
		return ("unhandled mode");
	}

	internal string _get_enum_value_str (EnumValue? val, EnumFlagsMode mode, CharacterCaseMode ccase)
	{
		return (change_str_case (__get_enum_value_str (val, mode), ccase));
	}

	internal string __get_flags_value_str (FlagsValue? val, EnumFlagsMode mode)
	{
		if (mode == EnumFlagsMode.NUMBER)
			return ("%lu".printf(val.value));
		if (mode == EnumFlagsMode.NAME)
			return (val.value_name);
		if (mode == EnumFlagsMode.NICK)
			return (val.value_nick);
		return ("unhandled mode");
	}

	internal string _get_flags_value_str (FlagsValue? val, EnumFlagsMode mode, CharacterCaseMode ccase)
	{
		return (change_str_case (__get_flags_value_str (val, mode), ccase));
	}

	public static void set_height_margins (Gtk.Widget? widget, int margin)
	{
		if (widget == null)
			return;
		widget.margin_bottom = margin;
		widget.margin_top = margin;
	}

	public static void set_side_margins (Gtk.Widget? widget, int margin)
	{
		if (widget == null)
			return;
		widget.margin_left = margin;
		widget.margin_right = margin;
	}

	public static Gdk.Pixbuf? load_pixbuf (string name, Gtk.StyleContext? context = null, bool? load_symbolic = null, int size = 16, Gtk.IconLookupFlags flags = Gtk.IconLookupFlags.FORCE_SIZE | Gtk.IconLookupFlags.GENERIC_FALLBACK)
	{
		Gdk.Pixbuf? pix = null;
		bool sym = ((load_symbolic == true) || ((load_symbolic == null) && (WidgetDefaults.get_default().use_symbolic_icons == true)));
		if ((context != null) && (sym == true)) {
			Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();
			try {
				Gtk.IconInfo? icon_info = icon_theme.lookup_icon (name, size, 0);
				assert (icon_info != null);
				bool was = (name.contains("symbolic") == true);
				pix = icon_info.load_symbolic_for_context (context, out was);
			} catch (Error e) {
				warning (e.message);
			}
		}
		else 
			try {
				pix = WidgetDefaults.get_default().theme.load_icon (name, size, flags);
			} catch (GLib.Error e) { stderr.printf ("%s\n".printf(e.message)); }
		if (pix == null)
			stderr.printf ("Loading icon \"%s\":%i failed!\n", name, size);
		return (pix);
	}

	public Gtk.Image create_image_from_icon (string resource_icon, Gtk.StyleContext? context = null, bool? use_symbolic = null, int icon_size = 24, bool can_focus = false)
	{
		Gtk.Image image = null;
		if (context != null)
			image = new Gtk.Image.from_pixbuf (load_pixbuf (resource_icon, context, use_symbolic, icon_size));
		else {
			image = new Gtk.Image();
			image.pixbuf = load_pixbuf (resource_icon, image.get_style_context(), use_symbolic, icon_size);
		}
		image.visible = true;
		image.can_focus = can_focus;
		return (image);
	}

	public Gtk.Image assign_image_from_icon (Gtk.Image image, string resource_icon, Gtk.StyleContext? context = null, bool? use_symbolic = null, int icon_size = 24, bool can_focus = false)
	{
		if (context != null)
			image.pixbuf = load_pixbuf (resource_icon, context, use_symbolic, icon_size);
		else {
			image.pixbuf = load_pixbuf (resource_icon, image.get_style_context(), use_symbolic, icon_size);
		}
		return (image);
	}

	public Gtk.CssProvider? assign_css (Gtk.Widget? widget, string css_content)
		requires (widget != null)
	{
		if (css_content == "")
			return (null);
		Gtk.CssProvider provider = new Gtk.CssProvider();
		try {
			provider.load_from_data(css_content, css_content.length);
			Gtk.StyleContext style = widget.get_style_context();
			style.add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
		}
		catch (Error e) { print ("Could not load CSS. %s\n", e.message); }
		return (provider);
	}

	public void assign_builder_css (Gtk.Builder ui_builder, string widget_name, string css)
	{
		string wname = widget_name;
		Gtk.Widget w = (Gtk.Widget) ui_builder.get_object (wname);
		while (w != null) {
			assign_css (w, css);
			wname += "_";
			w = (Gtk.Widget) ui_builder.get_object (wname);
		}
		wname = widget_name + "=";
		w = (Gtk.Widget) ui_builder.get_object (wname);
		while (w != null) {
			assign_css (w, css);
			wname += "=";
			w = (Gtk.Widget) ui_builder.get_object (wname);
		}
	}
}

