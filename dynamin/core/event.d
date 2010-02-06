// Written in the D programming language
// www.digitalmars.com/d/

/*
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is the Dynamin library.
 *
 * The Initial Developer of the Original Code is Jordan Miner.
 * Portions created by the Initial Developer are Copyright (C) 2006-2009
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Jordan Miner <jminer7@gmail.com>
 *
 */

module dynamin.core.event;

import tango.io.Stdout;
import dynamin.core.global;
import tango.core.Exception;
public import tango.core.Traits;

/**
 * A struct used to notify handlers of an event. It is similar to .NET's events.
 * Here is an example of its usage:
 * -----
 * class Control {
 * public {
 *     protected void whenPainting(PaintingEventArgs e) {
 *         /+ painting code goes here +/
 *     }
 *     Event!(whenPainting) painting;
 *     this() {
 *         painting.mainHandler = &whenPainting;
 *     }
 * }
 * }
 * -----
 * Then to add a handler to it:
 * -----
 * Control control = new Control();
 * control.painting += (PaintingEventArgs e) {
 *     /+ painting code goes here +/
 * };
 * -----
 * And fire it in the Control like this:
 * -----
 * painting(new PaintingEventArgs());
 * -----
 * Not as easy to use as I would like, but still much better than Java's
 * event handling.
 * When the event is fired, all the handlers are called first, followed
 * by the delegate passed into the constructor.
 */
struct Event(alias mainHandler_) {
	alias ParameterTupleOf!(mainHandler_)[0] ArgsType;
	/// void delegate(ArgsType e)
	public alias void delegate(ArgsType e) Handler;
	/// void delegate(ArgsType e)
	public alias void delegate(ArgsType e) Dispatcher;

	Handler[] handlers;
	private void* ptr;
	private void function(ArgsType e) mainHandler;
	private void function(ArgsType e) dispatcher;

	void setUp(Handler mainHandler, Dispatcher dispatcher = null) {
		if(mainHandler.ptr != dispatcher.ptr && dispatcher.ptr != null)
			throw new Exception("mainHandler.ptr must equal dispatcher.ptr");
		ptr = mainHandler.ptr;
		this.mainHandler = mainHandler.funcptr;
		this.dispatcher = dispatcher.funcptr;
	}

	void defaultDispatch(ArgsType e) {
		callHandlers(e);
		callMainHandler(e);
	}

	/**
	 * Calls all the handlers added to this event, passing e to them.
	 */
	void opCall(ArgsType e) {
		if(e is null)
			Stdout("Warning: EventArgs null").newline;
		if(!dispatcher) {
			defaultDispatch(e);
			return;
		}
		Dispatcher dg;
		dg.ptr = ptr;
		dg.funcptr = dispatcher;
		dg(e);
	}
	/**
	 * Adds the specified handler to this event. The handler will be called
	 * when the event is fired.
	 */
	void opAddAssign(Handler handler) {
		if(!handler.funcptr) throw new Exception("handler cannot be null");
		handlers.length = handlers.length + 1;
		handlers[length-1] = handler;
		// TODO: use a list?
		//handlers.add(handler);
	}
	/// ditto
	void opAddAssign(void delegate() handler) {
		struct Foo {
			void delegate() handler;
			void wrapper(ArgsType e) { handler(); }
		}
		Foo* f = new Foo;
		f.handler = handler;
		*this += &f.wrapper;
		// I really wish D could do this:
		//this += (ArgsType e) { handler(); };
	}
	/// TODO: implement this method
	void opSubAssign(Handler handler) {
		throw new Exception("removing handlers not yet implemented");
	}
	/**
	 * Calls the handlers (not including the main handler) added to this event.
	 * Only use this method from a method that does custom dispatching.
	 */
	void callHandlers(ArgsType e) {
		foreach(handler; handlers)
			handler(e);
	}
	/**
	 * Calls the main handler unless the StopEventArgs.stopped has been
	 * set to true.
	 * Only use this method from a method that does custom dispatching.
	 */
	void callMainHandler(ArgsType e) {
		auto stopEventArgs = cast(StopEventArgs)e;
		// if e is an instance of StopEventArgs, then check if it is stopped
		if(stopEventArgs is null || !stopEventArgs.stopped) {
			Handler dg;
			dg.ptr = ptr;
			dg.funcptr = mainHandler;
			dg(e);
		}
	}
}

// usage: mixin Event!(whenMoved) moved;
//        mixin Event!(whenMoved, dispatchMoved) moved;
template Event2(alias mainHandler, alias dispatcher) {
private:
	alias ParameterTupleOf!(mainHandler)[0] ArgsType;
	/// void delegate(ArgsType e)
	public alias void delegate(ArgsType e) Handler;
	/// void delegate(ArgsType e)
	public alias void delegate(ArgsType e) Dispatcher;

	// TODO: use a list-like struct?
	Handler[] handlers;
public:

	/**
	 * Calls all the handlers added to this event, passing e to them.
	 */
	void opCall(ArgsType e) {
		if(e is null)
			Stdout("Warning: EventArgs null").newline;
		dispatcher(e);
	}
	/**
	 * Adds the specified handler to this event. The handler will be called
	 * when the event is fired.
	 */
	void opAddAssign(Handler handler) {
		if(!handler.funcptr) throw new Exception("handler cannot be null");
		handlers.length = handlers.length + 1;
		handlers[length-1] = handler;
		// TODO: use a list?
		//handlers.add(handler);
	}
	/// ditto
	void opAddAssign(void delegate() handler) {
		struct Foo {
			void delegate() handler;
			void wrapper(ArgsType e) { handler(); }
		}
		Foo* f = new Foo;
		f.handler = handler;
		this += &f.wrapper;
		// I really wish D could do this:
		//this += (ArgsType e) { handler(); };
	}
	/// TODO: implement this method
	void opSubAssign(Handler handler) {
		throw new Exception("removing handlers not yet implemented");
	}
	/**
	 * Calls the handlers (not including the main handler) added to this event.
	 * Only use this method from a method that does custom dispatching.
	 */
	void callHandlers(ArgsType e) {
		foreach(handler; handlers)
			handler(e);
	}
	/**
	 * Calls the main handler unless the StopEventArgs.stopped has been
	 * set to true.
	 * Only use this method from a method that does custom dispatching.
	 */
	void callMainHandler(ArgsType e) {
		auto stopEventArgs = cast(StopEventArgs)e;
		// if e is an instance of StopEventArgs, then check if it is stopped
		if(stopEventArgs is null || !stopEventArgs.stopped)
			mainHandler(e);
	}
}

template Event2(alias mainHandler) {
	alias ParameterTupleOf!(mainHandler)[0] ArgsType;
	void defaultDispatch(ArgsType e) {
		callHandlers(e);
		callMainHandler(e);
	}
	mixin Event2!(mainHandler, defaultDispatch);
}

/// The base class for passing arguments to event handlers.
// TODO: shorter name?
class EventArgs {
}
///
class StopEventArgs : EventArgs {
	/**
	 * If stopped is set to true, then the Control will not respond to
	 * the event. For instance, if a key is typed while a text box is focused,
	 * but a handler sets stopped to true, the text box will not
	 * respond to the key.
	 */
	bool stopped = false;
}
