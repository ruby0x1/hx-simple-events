
//SEE TRACE OUTPUT!

import nme.display.Sprite;
import nme.events.Event;
import nme.events.KeyboardEvent;

import nme.Assets;
import nme.Lib;

import events.EventSystem;

class Game extends Sprite {

    public var events : EventSystem;

    public function new () {
        
        super ();
        addEventListener (Event.ADDED_TO_STAGE, construct );       

    } //new

    private function construct(event:Event) : Void {

            //remove ourselves from the added message
        removeEventListener(Event.ADDED_TO_STAGE, construct );

        events = new EventSystem();

        var event_id = events.connect('debug:event1', function(e) { trace('event listener 1 : ' + e); });
        events.connect('debug:event1', function(e) { trace('event listener 2 : ' +e); });
        events.connect('debug:event1', function(e) { trace('event listener 3 : ' + e); });

        trace('registered debug:event1 ' + event_id); 

        events.fire('debug:event1', {
            name : 'test event',
            date : Date.now()
        });

            //remove one of them
        events.disconnect( event_id );

            //now only two listeners
        events.fire('debug:event1', {
            name : 'test event',
            date : Date.now()
        });

            //fire next frame
        events.queue('debug:event1');
            
            //fire two seconds
        events.schedule( 2.0 , 'debug:event1');


            //manual step, since we aren't looping
        events.update();

    } //construct
   
    public static function main () {
        
        Lib.current.addChild(new Game());

    } //main
    
}

/*
expected output (or similar)
Game.hx:33: registered debug:event1 b8a8a70b-db79-a554-384b-4967fb2c144c
Game.hx:29: event listener 1 : { date => 2013-04-24 03:22:22, name => test event }
Game.hx:30: event listener 2 : { date => 2013-04-24 03:22:22, name => test event }
Game.hx:31: event listener 3 : { date => 2013-04-24 03:22:22, name => test event }
Game.hx:30: event listener 2 : { date => 2013-04-24 03:22:22, name => test event }
Game.hx:31: event listener 3 : { date => 2013-04-24 03:22:22, name => test event }
Game.hx:30: event listener 2 : null
Game.hx:31: event listener 3 : null
Game.hx:30: event listener 2 : null
Game.hx:31: event listener 3 : null
*/
