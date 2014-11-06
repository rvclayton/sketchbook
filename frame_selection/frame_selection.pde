import java.util.Arrays;

color bgColor = color(0, 0, 0);
color fgColor = color(255, 255, 255);

final int frameWidth = 12;
final int frameHeight = frameWidth;
final int frameGap = frameWidth/2;

final ArrayList<PageFrameSet> frames = new ArrayList<PageFrameSet>();
final PageReferenceSequence pageReferences = new PageReferenceSequence(
  new int [] { 7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2, 1, 2, 0, 1, 7, 0, 1 });


void
draw() {

  background(bgColor);
  stroke(fgColor);
  
  pageReferences.draw(10, 10);

  int x = 10;
  final int y = 20;
  for (PageFrameSet f : frames) {
    f.draw(x, y);
    x += frameGap + frameWidth;
    }
  }
  

void
setup() {

  size(640, 480);

  PageFrameSet pages = new PageFrameSet(3, pageReferences);
  frames.add(pages);
  for (int i = 0; i < 3; ++i)
    frames.add(pages = pages.pageRef(i));
  }
  

/**
   An immutable set of primary-store page frames.
 */

class
PageFrameSet {
  
  /**
     Draw this page-frame set.

     @param ulx The minimal x value of the bounding box containing this
     page-frame set drawing.

     @param uly The minimal y vlaue of the bounding box containing this
     page-frame set drawing.
  */

  public void
  draw(int ulx, int uly) {
    fill(bgColor);
    rect(ulx, uly, frameWidth, frames.length*frameHeight);
    
    for (int i = 1; i < frames.length; ++i) {
      final int y = uly + i*frameHeight;
      line(ulx, y, ulx + frameWidth, y);
      }
      
    drawPageNumbers(ulx, uly);
    }
    

  /**
     Draw the page numbers contained in this page-frame set.

     @param ulx The minimal x value of the bounding box containing this
     page-frame set drawing.

     @param uly The minimal y vlaue of the bounding box containing this
     page-frame set drawing.
  */

  private void
  drawPageNumbers(int ulx, int uly) {

    final int x = ulx + frameWidth/2;

    textSize(frameHeight - 2);
    textAlign(CENTER, BOTTOM);
    fill(fgColor);

    for (int i = 0; i < frames.length; ++i) 
      if (frames[i] != freePageFrame)
        text(frames[i], x, uly + frameHeight*(i + 1) + 1);
    }
    

  /**
     Add a page to a frame in this page-frame set.

     @param pageNo The number of the page to add.

     @return A copy of this page-frame set in which the given page is in the
     set.
  */

  private PageFrameSet
  pageAdd(int pageIndex) {

    final PageFrameSet newPageFrameSet = new PageFrameSet(this);
    final int pageNo = pageSequence.get(pageIndex);
    int i;

    // If there's a free page frame, use that.

       for (i = 0; i < frames.length; ++i)
         if (frames[i] == freePageFrame) {
           newPageFrameSet.frames[i] = pageNo;
           return newPageFrameSet;
           }

    // Otherwise, eject a page based on some criteria and use the freed page
    // fame.

       i = pageSequence.ejectPage(frames);
       newPageFrameSet.frames[i] = pageNo;

    return newPageFrameSet;
    }


  /**
     Create a new empty imutable set of page frames.

     @param c The set size in page frames; must be positive.
  */

  public
  PageFrameSet(int c, PageReferenceSequence pages) {
    assert c > 0;
    frames = new int [c];
    Arrays.fill(frames, freePageFrame);
    pageSequence = pages;
    }
    

  /**
     Create a copy of a page-frame set.

     @param The page-frame set to copy.
  */

  private
  PageFrameSet(PageFrameSet pageFrames) {
    frames = Arrays.copyOf(pageFrames.frames, pageFrames.frames.length);
    pageSequence = pageFrames.pageSequence;
    }
    

  /**
     Reference a page using relative to this page-frame set.

     @param pageNo The page to reference.

     @return A copy of this page-frame set; the copy contains the given page.
     If this set contains the given page, the copy is the same as this set.
     Otherwise the copy conains one less free page than this set or, if this
     set has no free page frames, the given page has replaced a page in this
     set.
  */

  public PageFrameSet
  pageRef(int pageIndex) {

    final int pageNo = pageSequence.get(pageIndex);

    for (int i = 0; i < frames.length; ++i)
      if (frames[i] == pageNo)
        return new UnchangedPageFrameSet(this);
    
    return pageAdd(pageIndex);
    }


  protected final int frames[];
  private static final int freePageFrame = -1;
  private final PageReferenceSequence pageSequence;
  }


/**
   A sequence of page references.
 */

class
PageReferenceSequence {


  /**
   */

  void
  draw(int ulx, int uly) {

    textSize(frameHeight);
    textAlign(CENTER, BOTTOM);
    fill(fgColor);

    uly = uly + frameHeight;
    final int x = ulx + frameWidth/2;

    for (int i = 0; i < pages.length; ++i) 
      text(pages[i], x + frameWidth*(i + 1), uly);
    }


  /**
   */

  int
  ejectPage(int pages[]) {
    return 0;
    }


  /**
   */

  int
  get(int i) {
    return pages[i];
    }


  /**
   */

  PageReferenceSequence(int p[]) {
    pages = Arrays.copyOf(p, p.length);
    }


  private final int pages[];
  }


/**
   
*/

class 
UnchangedPageFrameSet 
extends PageFrameSet {

  /**
     (Don't) draw this page-frame set.

     @param ulx The minimal x value of the bounding box containing this
     page-frame set drawing.

     @param uly The minimal y vlaue of the bounding box containing this
     page-frame set drawing.
  */

  void
  draw(int ulx, int uly) {
    }


  UnchangedPageFrameSet(PageFrameSet pageFrames) {
    super(pageFrames);
    }
  }