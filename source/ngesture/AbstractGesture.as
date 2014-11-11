package ngesture {
    import npooling.Pool;

    import starling.display.DisplayObject;
    import starling.events.Event;
    import starling.events.EventDispatcher;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    public class AbstractGesture extends EventDispatcher {
        protected static var _pool:Pool = Pool.getInstance();

        public var priority:int = 0;

        private var _id:String;
        private var _target:DisplayObject;

        public function AbstractGesture(pID:String) {
            _id = pID;

            super();
        };

        public function get id():String {
            return _id;
        };

        public function get target():DisplayObject {
            return _target;
        };

        public function setTarget(pTarget:DisplayObject):void {
            _target = pTarget;
        };

        public function validate(pEvent:TouchEvent):Boolean {
            if (!_target) {
                return false;
            }

            return true;
        };

        public final function process(pEvent:TouchEvent):Boolean {
            var result:Boolean = false;

            for (var i:int = 0; i < pEvent.touches.length; i++) {
                var touch:Touch = getTouch(pEvent, i);
                if (!touch) {
                    continue;
                }

                if (touch.phase == TouchPhase.BEGAN) {
                    if (processBeganPhase(touch)) {
                        result = true;
                        break;
                    }
                }

                if (touch.phase == TouchPhase.MOVED) {
                    if (processMovedPhase(touch)) {
                        result = true;
                        break;
                    }
                }

                if (touch.phase == TouchPhase.ENDED) {
                    if (processEndedPhase(touch)) {
                        result = true;
                        break;
                    }
                }
            }

            return result;
        };

        protected function processBeganPhase(pTouch:Touch):Boolean {
            return false;
        };

        protected function processMovedPhase(pTouch:Touch):Boolean {
            return false;
        };

        protected function processEndedPhase(pTouch:Touch):Boolean {
            return false;
        };

        protected final function getTouch(pEvent:TouchEvent,
                                          pNo:int = 0):Touch {
            if (!target) {
                return pEvent.touches[pNo];
            }

            if (pEvent.getTouches(target).length <= pNo) {
                return null;
            }

            return pEvent.getTouches(target)[pNo];
        };

        protected final function completed():void {
            dispatchEventWith(Event.COMPLETE);
        };

        protected final function changed():void {
            dispatchEventWith(Event.CHANGE);
        };
    }
}
