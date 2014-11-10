package ngesture.gestures {
    import ngesture.AbstractGesture;

    import nmath.vectors.Vector2D;

    import starling.events.Touch;
    import starling.events.TouchEvent;

    public class ZoomGesture extends AbstractGesture {
        public static const ID:String = 'zoom_gesture';

        private var _distance:Number;
        private var _scale:Number;

        private var _began:Array;
        private var _moved:Array;
        private var _ended:Array;

        public function ZoomGesture() {
            super(ID);

            _began = [];
            _moved = [];
            _ended = [];

            _distance = 0;
        };

        public function get scale():Number {
            return _scale;
        };

        override public function validate(pEvent:TouchEvent):Boolean {
            if (pEvent.touches.length != 2) {
                return false;
            }

            return true;
        };

        override protected function processBeganPhase(pTouch:Touch):Boolean {
            _began[pTouch.id] = pTouch;

            if (_began.length == 2) {
                var fingerA:Vector2D = Vector2D.fromPoint((_began[0] as Touch).getLocation(target));
                var fingerB:Vector2D = Vector2D.fromPoint((_began[1] as Touch).getLocation(target));

                _distance = fingerA.distanceTo(fingerB);
                _scale    = 0;

                _pool.put(fingerA);
                _pool.put(fingerB);

                _began.length = 0;
            }

            return false;
        };

        override protected function processMovedPhase(pTouch:Touch):Boolean {
            trace('ZoomGesture.processMovedPhase:', pTouch.id);
            _moved[pTouch.id] = pTouch;

            if (_moved.length == 2) {
                trace('ZoomGesture.processMovedPhase:', _distance);

                if (!_distance) {
                    return false;
                }

                var fingerA:Vector2D = Vector2D.fromPoint((_moved[0] as Touch).getLocation(target));
                var fingerB:Vector2D = Vector2D.fromPoint((_moved[1] as Touch).getLocation(target));

                var newDistance:Number = fingerA.distanceTo(fingerB);

                _scale = newDistance / _distance;

                trace('ZoomGesture.processMovedPhase:', _scale);

                _pool.put(fingerA);
                _pool.put(fingerB);

                _moved.length = 0;

                changed();
            }

            return false;
        };


        override protected function processEndedPhase(pTouch:Touch):Boolean {
            trace('ZoomGesture.processEndedPhase:', pTouch.id);
            _ended[pTouch.id] = pTouch;

            if (_ended.length == 2) {
                _distance = 0;
                _scale    = 0;

                _began.length = 0;
                _moved.length = 0;
                _ended.length = 0;

                completed();

                return true;
            }

            return false;
        };
    }
}
