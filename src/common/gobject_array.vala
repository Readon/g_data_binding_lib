using GData;

namespace GData
{
	/**
	 * GObjectArray is holding list of non generic objects and emits signals 
	 * when objects are added or removed.
	 * 
	 * Second trade it provides is also guarantee of unique objects in list if
	 * specified on creation.
	 * 
	 * Due to the fact that it implements GLib.ListModel it is automatically
	 * usable as model for Gtk.ListBox or Gtk.FlowBox
	 * 
	 * @since 0.1
	 */ 
	public class GObjectArray : Object, ListModel
	{
		/**
		 * This method is GLib.ListModel implementation requirement and resolves
		 * item at specified position
		 * 
		 * @since 0.1
		 * 
		 * @param position Element position that needs to be returned
		 * @return Object reference is element exists, null if not
		 */ 
		public Object? get_item (uint position)
		{
			return (((position < 0) || (position >= length)) ? null : (Object?) data[position]);
		}

		/**
		 * This method is GLib.ListModel implementation requirement and resolves
		 * type of stored items
		 * 
		 * @since 0.1
		 * 
		 * @return Object type that is stored in ObjectArray
		 */ 
		public Type get_item_type ()
		{
			return (typeof(Object));
		}
		
		/**
		 * This method is GLib.ListModel implementation requirement and resolves
		 * number of items in ObjectArray
		 * 
		 * @since 0.1
		 * 
		 * @return Number of stored items in ObjectArray
		 */ 
		public uint get_n_items()
		{
			return ((uint) length);
		}
		
		private bool _dont_dispatch_signals = false;

		/**
		 * Specifies if ObjectArray was created with specification of unique
		 * objects or not
		 * 
		 * @since 0.1
		 */ 
		public bool force_unique { get; private set; default = false; }
		
		private GLib.Array<Object>? _array = new GLib.Array<Object>();
		/**
		 * Returns reference to internally use GLib.Array
		 * 
		 * @since 0.1
		 */
		public GLib.Array<Object> array {
			get { return (_array); }
		}

		/**
		 * Returns reference to data array
		 * 
		 * @since 0.1
		 */
		public Object[] data {
			get { return (_array.data); }
		}

		/**
		 * Returns number of elements in ObjectArray same as get_n_items
		 *
		 * @since 0.1
		 */
		public int length {
			get { return ((int) _array.length); }
		}

		/**
		 * Swaps two items at specified indexes
		 * 
		 * @since 0.1
		 *
		 * @param index1 First index
		 * @param index2 Second index
		 */
		public void swap (int index1, int index2)
		{
			if ((index1 < 0) || (index1 >= length))
				return;
			if ((index2 < 0) || (index2 >= length))
				return;
			Object? tmp = _array.data[index1];
			_array.data[index1] = _array.data[index2];
			_array.data[index2] = tmp;
		}

		/**
		 * Searches array for specified object and returns its index
		 * 
		 * @since 0.1
		 * 
		 * @return Index of specified element or -1 if not found
		 */
		public int find (Object object)
		{
			for (int i=0; i<_array.length; i++)
				if (_array.data[i] == object)
					return (i);
			return (-1);
		}

		/**
		 * Searches array for specified object and returns its index, same as
		 * find(), except search is done by using specified delegate method
		 * 
		 * @since 0.1
		 * 
		 * @param func Search function that is used for comparison 
		 * @return Index of specified element or -1 if not found
		 */
/*		public int search_for (FindObjectDelegate<T> func)
		{
			for (int i=0; i<length; i++)
				if (func(data[i]) == true)
					return (i);
			return (-1);
		}*/

		/**
		 * Adds new element in ObjectArray and emits element_added signal. If
		 * ObjectArray was created with force_unique then element is only added
		 * if it doesn't exists yet.
		 * 
		 * @since 0.1
		 * 
		 * @param object Object being added into ObjectArray
		 */
		public void add (Object object)
		{
			if (force_unique == true) {
				add_unique (object);
				if (_dont_dispatch_signals == false)
					element_added (object);
			}
			else {
				_array.append_val (object);
				items_changed (length-1, 0, 1);
				if (_dont_dispatch_signals == false)
					element_added (object);
			}
		}

		/**
		 * Adds new element in ObjectArray and emits element_added signal. If
		 * ObjectArray was created with force_unique then element is only added
		 * if it doesn't exists yet.
		 * 
		 * This is same as add() with one exception that unique is guaranteed.
		 * Note that this can be called even if ObjectArray does not specify
		 * force_unique 
		 * 
		 * @since 0.1
		 * 
		 * @param object Object being added into ObjectArray
		 * @return If object exists, existing is returned, if not then it
		 *         returns the newly added object
		 */
		public Object add_unique (Object object, bool nosearch = false)
		{
			if (nosearch == false) {
				int i = find (object);
				if (i >= 0)
					return (data[i]);
			}
			_array.append_val (object);
			items_changed (length-1, 0, 1);
			if (_dont_dispatch_signals == false)
				element_added (object);
			return (object);
		}

		/**
		 * Prepends new element in ObjectArray and emits element_added signal. 
		 * If ObjectArray was created with force_unique then element is only 
		 * added if it doesn't exists yet.
		 * 
		 * @since 0.1
		 * 
		 * @param object Object being added into ObjectArray
		 */
		public void prepend (Object object)
		{
			if (force_unique == true) {
				prepend_unique (object);
				if (_dont_dispatch_signals == false)
					element_added (object);
			}
			else {
				_array.prepend_val (object);
				items_changed (0, 0, 1);
				if (_dont_dispatch_signals == false)
					element_added (object);
			}
		}


		/**
		 * Prepends new element in ObjectArray and emits element_added signal. 
		 * If ObjectArray was created with force_unique then element is only 
		 * added if it doesn't exists yet.
		 * 
		 * This is same as add() with one exception that unique is guaranteed.
		 * Note that this can be called even if ObjectArray does not specify
		 * force_unique 
		 * 
		 * @since 0.1
		 * 
		 * @param object Object being added into ObjectArray
		 * @return If object exists, existing is returned, if not then it
		 *         returns the newly added object
		 */
		public Object prepend_unique (Object object, bool nosearch = false)
		{
			if (nosearch == false) {
				int i = find (object);
				if (i >= 0)
					return (data[i]);
			}
			_array.prepend_val (object);
			items_changed (0, 0, 1);
			if (_dont_dispatch_signals == false)
				element_added (object);
			return (object);
		}

		/**
		 * Removes specified object from ObjectArray
		 * 
		 * @since 0.1
		 * 
		 * @param object Object being removed
		 */
		public void remove (Object object)
		{
			int i = find(object);
			if (i >= 0)
				remove_at_index(i);
		}

		/**
		 * Removes object at specified index from ObjectArray
		 * 
		 * @since 0.1
		 * 
		 * @param index Index of object being removed
		 */
		public void remove_at_index (int index)
		{
			if ((index < 0) || (index >= length))
				return;
			Object? element = _array.data[index];
			if (_dont_dispatch_signals == false)
				before_removing_element (element, index);
			items_changed (index, 1, 0);
			_array.remove_index (index);
			if (_dont_dispatch_signals == false)
				element_removed (element);
			if (length == 0)
				array_cleared();
		}

		/**
		 * Clears ObjectArray
		 * 
		 * @since 0.1
		 */
		public void clear()
		{
			_dont_dispatch_signals = true;
			while (length > 0)
				remove_at_index(length-1);
			_dont_dispatch_signals = false;

			array_cleared();
		}

		/**
		 * Sorts ObjectArray based on specified compare delegate
		 * 
		 * @since 0.1
		 */
/*		public void sort()
		{
			custom_sort (_compare_delegate);
		}*/

		/**
		 * Sorts ObjectArray based on custom specified compare delegate
		 * 
		 * @since 0.1
		 * 
		 * @param func Compare delegate used for sorting
		 */
/*		public void custom_sort (CompareFunc func)
		{
			_array.sort (func);
			array_sorted();
		}*/

		/**
		 * Iterates across whole list by passing their reference to specified
		 * function (note that this is intentionally not thread-safe)
		 * 
		 * @since 0.1
		 * 
		 * @param func Method being called for each object in ObjectArray
		 * @param backwards Specifies if iteration is from last to first or not
		 */
		public void foreach (ObjectIterationFunc func, bool backwards = false)
		{
			if (backwards == true) {
				for (int i=(length-1); i>=0; i++)
					func (data[i]);
			}
			else {
				for (int i=0; i<length; i++)
					func (data[i]);
			}
		}

/*		private CompareFunc<T> _compare_delegate;

		private static int compare___by_reference (T object1, T object2)
		{
			return ((object1 == object2) ? 0 : -1);
		}

		private static int compare___by_properties (T object1, T object2)
		{
			return (((UniqueByProperies) object1).compare_to ((UniqueByProperies) object2));
		}*/

		/**
		 * Signal being emited when new element is added to the list
		 * 
		 * @since 0.1
		 * 
		 * @param element New element that was added
		 */
		public signal void element_added (Object element);

		/**
		 * Signal being emited before element is removed from the list
		 * 
		 * @since 0.1
		 * 
		 * @param element Element that will be removed
		 * @param index Position of removedelement in ObjectArray 
		 */
		public signal void before_removing_element (Object element, int index);

		/**
		 * Signal being emited after element is removed from the list
		 * 
		 * @since 0.1
		 * 
		 * @param element Element that was removed
		 */
		public signal void element_removed (Object element);

		/**
		 * Signal being emited after ObjectArray was cleared of all elements.
		 * Same signal is also emited if element that was removed was the last
		 * element in ObjectArray
		 * 
		 * @since 0.1
		 */
		public signal void array_cleared();

		/**
		 * Signal being emited after sorting of elements in ObjectArray
		 * 
		 * @since 0.1
		 */
		public signal void array_sorted();

		/**
		 * Creates new ObjectArray that is defined with force_unique.
		 * 
		 * @since 0.1
		 * 
		 * @param compare_by Specifies how elements are compared for uniqueness
		 * @param compare_method Method being used to compare elements
		 */
		public GObjectArray.unique ()
		{
			this ();
			force_unique = true;
		}

		/**
		 * Creates new ObjectArray
		 * 
		 * @since 0.1
		 * 
		 * @param compare_by Specifies how elements are compared for uniqueness
		 * @param compare_method Method being used to compare elements
		 */
		public GObjectArray ()
		{
			this.element_added.connect (() => { notify_property("length"); });
			this.element_removed.connect (() => { notify_property("length"); });
			this.array_cleared.connect (() => { notify_property("length"); });
		}
	}
}
