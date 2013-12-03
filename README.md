Simple event system
==========

A simple event (signal/slot) system for [Haxe](http://haxe.org/)

Simple Usage, connect listeners to an event : 

```haxe
class Example {

    function explain() {
        //connect listener function

        var id1 = events.connect( 'event1', function(e){ //first handler } );
        var id2 = events.connect( 'event1', function(e){ //second handler } );

            //disconnect handler 1
        events.disconnect(id1);

            //trigger the events at some time
        events.fire('event1', { somedata:'a message!'} );

            //you can schedule events in the future
        var sched = events.schedule( 10.0, 'event1', { somedata:'A message 10s from now!'} );

            //you can also queue events for the next events.update()
            //this can be used as an overall message queue but explicit control
    }
}
```

