package ngesture.gestures {
    import flash.geom.Point;

    import ngesture.AbstractGesture;

    import nmath.vectors.Vector2D;

    import starling.events.Touch;
    import starling.events.TouchEvent;

    public class TapGesture extends AbstractGesture {
        public static const ID:String = 'tap_gesture';

        private var _start:Vector2D;
        private var _calc:Vector2D;

        public function TapGesture() {
            super(ID);

            _start = Vector2D.ZERO;
            _calc  = Vector2D.ZERO;
        };

        public function get position():Vector2D {
            return _start;
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
            super.processMovedPhase(pTouch);

            var end:Vector2D   = Vector2D.fromPoint(pTouch.getLocation(pTouch.target));

            var offset:Vector2D = end.substract(_start, true);
                offset.inverse();
                offset.multiplyScalar(pTouch.target.scaleX);

            _calc.add(offset);

            _pool.put(end);
            _pool.put(offset);

            return false;
        };

        override protected function processEndedPhase(pTouch:Touch):Boolean {
            if (_calc.lengthSquared() < 10) {
                completed();
                return true;
            }

            return false;
        };
    }
}
