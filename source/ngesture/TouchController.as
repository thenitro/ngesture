package ngesture {
    import flash.utils.Dictionary;

    import starling.display.DisplayObject;
    import starling.events.Event;
    import starling.events.EventDispatcher;
    import starling.events.TouchEvent;

    public class TouchController extends EventDispatcher {
        public static const CHANGE:String = '_change';

        private var _target:DisplayObject;

        private var _activeGestures:Vector.<String>;
        private var _gestures:Dictionary;

        public function TouchController() {
            super();

            _gestures = new Dictionary();
        };

        public function add(pGesture:AbstractGesture):void {
            if (_gestures.hasOwnProperty(pGesture.id)) {
                return;
            }

            pGesture.setTarget(_target);
            pGesture.addEventListener(Event.CHANGE,
                                      gestureChangeEventHandler);
            pGesture.addEventListener(Event.COMPLETE,
                                      gestureCompleteEventHandler);

            _gestures[pGesture.id] = pGesture;
        };

        public function getGesture(pID:String):AbstractGesture {
            return _gestures[pID];
        };

        public function setActiveGestures(pGesturesIDs:Vector.<String>):void {
            _activeGestures = pGesturesIDs;
        };

        public function setTarget(pTarget:DisplayObject):void {
            removeTarget();

            _target = pTarget;
            _target.addEventListener(TouchEvent.TOUCH, touchEventHandler);

            for each (var gesture:AbstractGesture in _gestures) {
                gesture.setTarget(_target);
            }
        };

        public function removeTarget():void {
            if (!_target) {
                return;
            }

            _target.removeEventListener(TouchEvent.TOUCH, touchEventHandler);
            _target = null;
        };

        private function isGestureActive(pGesture:AbstractGesture):Boolean {
            if (_activeGestures && _activeGestures.indexOf(pGesture.id) == -1) {
                return false
            }

            return true;
        };

        private function touchEventHandler(pEvent:TouchEvent):void {
            var gesture:AbstractGesture;
            var gesturesByPriority:Array = [];

            for each (gesture in _gestures) {
                gesturesByPriority.push(gesture);
            }

            gesturesByPriority.sortOn('priority', Array.DESCENDING | Array.NUMERIC);

            for (var i:int = 0; i < gesturesByPriority.length; i++) {
                gesture = gesturesByPriority[i] as AbstractGesture;

                if (!isGestureActive(gesture)) {
                    continue;
                }

                if (!gesture.validate(pEvent)) {
                    continue;
                }

                if (gesture.process(pEvent)) {
                    return;
                }
            }
        };

        private function gestureCompleteEventHandler(pEvent:Event):void {
            var gesture:AbstractGesture = pEvent.target as AbstractGesture;
            if (!isGestureActive(gesture)) {
                return;
            }

            dispatchEventWith(gesture.id, false, gesture);
        };

        private function gestureChangeEventHandler(pEvent:Event):void {
            var gesture:AbstractGesture = pEvent.target as AbstractGesture;
            if (!isGestureActive(gesture)) {
                return;
            }

            dispatchEventWith(gesture.id + CHANGE, false, gesture);
        };
    };
}
