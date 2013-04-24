package events;

import events.chx.UUID;


class EventSystem {
		
	public var event_queue : Hash<EventObject>;
	public var event_connections : Hash<EventConnection>; //event id, connect
	public var event_slots : Hash<Array<EventConnection> >; //event name, array of connections
	public var event_schedules : Hash< haxe.Timer >; //event id, timer

	public function new() {

			//create the queue, lists and map
		event_connections = new Hash<EventConnection>();
		event_slots = new Hash< Array<EventConnection> >();
		event_queue = new Hash<EventObject>();
		event_schedules = new Hash< haxe.Timer >();

	} //constructor

		//Bind a signal (listener) to a slot (event_name)
			//event_name : The event id
			//listener : A function handler that should get called on event firing
	public function connect( event_name : String, listener : Dynamic -> Void ):String {

			//we need an ID and a connection to store
		var id : String = UUID.get();
		var connection : EventConnection = new EventConnection( id, event_name, listener );

			//now we store it in the hash		
		event_connections.set( id, connection );

			//also store the listener inside the slots
		if(!event_slots.exists(event_name)) {
				//no slot exists yet? make one!
			event_slots.set(event_name, new Array<EventConnection>() );			
		}

			//it should exist by now, lets store the connection by event name
		event_slots.get(event_name).push( connection );

			//return the id for disconnecting
		return id;

	} //connect

		//Disconnect a vound signal
			//event connection id, returned from connect()
			//returns true if the event existed and was removed
	public function disconnect( event_id : String ) : Bool {
		
		if(event_connections.exists(event_id)) {

			var connection = event_connections.get(event_id);				
			var event_slot = event_slots.get(connection.event_name);

				event_slot.remove(connection);

			return true;

		} else {
			return false;
		}

	} //disconnect

		//Queue an event in the next update loop
			//event_name : The event (register listeners with connect())
			//properties : A dynamic pass-through value to hand off data
			//	-- Returns a String, the ID of the event
	public function queue( event_name : String, properties : Dynamic = null ) : String {

		var id : String = UUID.get();

				//store it in case we want to manipulate it
			var event:EventObject = new EventObject(id, event_name, properties);

				//stash it away
			event_queue.set(id, event);

			//return the user the id
		return id;
	} //queue

	public function dequeue( event_id: String ) {
		
		if(event_queue.exists(event_id)) {
			
			var event = event_queue.get(event_id);
			event = null;
			event_queue.remove( event_id );
			return true;
		}

		return false;
	} //dequeue

	public function update() {

			//fire each event in the queue
		for(event in event_queue) {
			fire( event.name, event.properties );
		}

			//if we actually have any events, clear the queue
		if(event_queue.keys().hasNext()) {
				//clear out the queue
			event_queue = null;
			event_queue = new Hash<EventObject>();
		}

	} //update

		//Fire an event immediately, bypassing the queue. 
			//event_name : The event (register listeners with connect())
			//properties : A dynamic pass-through value to hand off data		
			//	-- Returns a Bool, true if event existed, false otherwise
	public function fire( event_name : String, properties : Dynamic = null ) : Bool {

		if(event_slots.exists( event_name )){
			
				//we have an event by this name
			var connections:Array<EventConnection> = event_slots.get(event_name);
				//call each listener
			for(connection in connections) {
				connection.listener( properties );
			}

		} else {
				//event not found
			return false;
		}

		return false;

	} //fire

		//Schedule and event in the future
			//event_name : The event (register listeners with connect())
			//properties : A dynamic pass-through value to hand off data
			//	-- Returns a String, the ID of the schedule (see unschedule)
	public function schedule( time:Float, event_name : String, properties : Dynamic = null) : String {
		var id : String = UUID.get();

			var _timer = haxe.Timer.delay(function(){
				fire( event_name, properties );
			}, Std.int(time*1000) );

			event_schedules.set( id, _timer );

		return id;

	} //schedule

		//Unschedule a previously scheduled event
			//schedule_id : The id of the schedule (returned from schedule)
			// -- Returns false if fails, or event doesn't exist
	public function unschedule( schedule_id : String ) : Bool {

		if(event_schedules.exists(schedule_id)) {
				//find the timer
			var timer = event_schedules.get(schedule_id);
				//kill it
			timer.stop();
				//remove it from the list
			event_schedules.remove(schedule_id);
				//done
			return true;
		}

		return false;

	} //unschedule


}

class EventConnection {
	
	public var listener : Dynamic -> Void;
	public var id : String;
	public var event_name : String;

	public function new( _id:String, _event_name:String, _listener : Dynamic -> Void ) {
		id = _id;
		listener = _listener;
		event_name = _event_name;
	}

}

class EventObject {

	public var id : String;
	public var name:String;
	public var properties : Dynamic;

	public function new(_id:String, _event_name:String, _event_properties:Dynamic) {
		id = _id;
		name = _event_name;
		properties = _event_properties;
	}
}