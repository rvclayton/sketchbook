int ht = 200;
int wd = ht;

boolean dragging = false;
float fixedX, fixedY, draggedX, draggedY;

class LineSegment {
  final float x1, y1, x2, y2;

  boolean
  intersects(LineSegment ls) {
    return straddles(ls) && ls.straddles(this);
    }

  LineSegment(float x1, float y1, float x2, float y2) {
    if (y1 < y2) {
      this.x1 = x1;
      this.y1 = y1;
      this.x2 = x2;
      this.y2 = y2;
      }
    else if (y2 < y1) {
      this.x1 = x2;
      this.y1 = y2;
      this.x2 = x1;
      this.y2 = y1;
      }
    else if (x2 < x1) {
      this.x1 = x2;
      this.y1 = y2;
      this.x2 = x1;
      this.y2 = y1;
      }
    else {
      this.x1 = x1;
      this.y1 = y1;
      this.x2 = x2;
      this.y2 = y2;
      };
    }

  private boolean
  straddles(LineSegment ls) {
    return ls.whichSide(x1, y1)*ls.whichSide(x2, y2) < 0;
    }

  private float
  whichSide(float x, float y) {
    return x*(y1 - y2) + y*(x2 - x1) + (x1*y2 - x2*y1);
    }
  }

LineSegment radii[];

void
draw() {
  background(255);

  final LineSegment draggedLine = 
    new LineSegment(fixedX, fixedY, draggedX, draggedY);

  for (LineSegment ls : radii) {
    stroke(dragging && draggedLine.intersects(ls) ? #ff0000 : #000000);
    line(ls.x1, ls.y1, ls.x2, ls.y2);
    }
  if (dragging) {
    stroke(#000000);
    line(fixedX, fixedY, draggedX, draggedY);
    }
  }

void
mouseDragged() {
  draggedX = mouseX;
  draggedY = mouseY;
  }

void
mousePressed() {
  dragging = true;
  draggedX = fixedX = mouseX;
  draggedY = fixedY = mouseY;
  }

void
mouseReleased() {
  dragging = false;
  }

void
setup() {

  size(ht, wd);

  final int n = 10;
  final int outerRadius = 70;
  final int innerRadius = 10;
  final float deltaA = 2*3.1415/n;

  radii = new LineSegment[n];

  for (int i = 0; i < 10; ++i)
    radii[i] = new LineSegment(
      wd/2 + innerRadius*cos(i*deltaA),
      ht/2 + innerRadius*sin(i*deltaA),
      wd/2 + outerRadius*cos(i*deltaA),
      ht/2 + outerRadius*sin(i*deltaA));
  }