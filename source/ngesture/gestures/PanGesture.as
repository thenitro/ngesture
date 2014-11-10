package ngesture.gestures {
    import flash.geom.Point;

    import ngesture.AbstractGesture;

    import nmath.vectors.Vector2D;

    import starling.events.Touch;
    import starling.events.TouchEvent;

    public class PanGesture extends AbstractGesture {
        public static const ID:String = 'pan_gesture';

        private var _start:Vector2D;
        private var _calc:Vector2D;
        private var _offset:Vector2D;

        public var scale:Number = 1.0;

        public function PanGesture() {
            super(ID);

            _start  = Vector2D.ZERO;
            _calc   = Vector2D.ZERO;
        };

        public function get offset():Vector2D {
            return _offset;
        };

        override public function validate(pEvent:TouchEvent):Boolean {
            if (pEvent.touches.length != 1) {
                return false;
            }

            return true;
        };

        override protected function processBeganPhase(pTouch:Touch):Boolean {
            var location:Point = pTouch.getLocation(target);

            _start.fromPoint(location);
            _calc.zero();

            return false;
        };

        override protected function processMovedPhase(pTouch:Touch):Boolean {
            var end:Vector2D = Vector2D.fromPoint(pTouch.getLocation(target));

            _offset = end.substract(_start, true);
            _offset.inverse();
            _offset.multiplyScalar(scale);

            _calc.add(_offset);

            changed();

            _pool.put(end);
            _pool.put(_offset);

            return false;
        };

        override protected function processEndedPhase(pTouch:Touch):Boolean {
            if (_calc.lengthSquared() > 10) {
                completed();
                return true;
            }

            return false;
        };
    }
}
