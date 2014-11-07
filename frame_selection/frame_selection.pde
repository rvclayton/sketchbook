import java.util.Arrays;

color bgColor = color(0, 0, 0);
color fgColor = color(255, 255, 255);

final int frameWidth = 14;
final int frameHeight = frameWidth;
final int frameGap = (int) (0.75*frameWidth);

final ArrayList<PageFrameSet> frames = new ArrayList<PageFrameSet>();

final PageReferenceSequence pageReferences = 
  new OptimalPageReferenceSequence(
    new int [] { 7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2, 1, 2, 0, 1, 7, 0, 1 });


void
draw() {

  background(bgColor);
  stroke(fgColor);
  
  pageReferences.draw(10, 10);

  int x = 10;
  final int y = 25;
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
  for (int i = 0; i < pageReferences.size(); ++i)
    frames.add(pages = pages.pageRef(i));
  }
  

class
OptimalPageReferenceSequence 
extends PageReferenceSequence {

  int
  ejectPage(int pageRefIndex, int pages[]) {

    int nextRefIndex = findForward(pageRefIndex, pages[0]);
    if (nextRefIndex < 0)
      return 0;
    int pageFrameIndex = 0;

    for (int j = pages.length - 1; j > 0; --j) {
      final int k = findForward(pageRefIndex, pages[j]);
      if (k < 0)
        return j;
      if (k > nextRefIndex) {
        nextRefIndex = k;
        pageFrameIndex = j;
        }
      }

    return pageFrameIndex;
    }


  private int
  findForward(int pageRefIndex, int pageNumber) {

    for ( ; pageRefIndex < pages.length; ++pageRefIndex)
      if (pages[pageRefIndex] == pageNumber)
        return pageRefIndex;

    return -1;
    }


  OptimalPageReferenceSequence(int pages[]) {
    super(pages);
    }
  }


class
LRUPageReferenceSequence 
extends PageReferenceSequence {

  int
  ejectPage(int pageRefIndex, int pages[]) {

    int prevRefIndex = findBackward(pageRefIndex, pages[0]);
    if (prevRefIndex < 0)
      return 0;
    int pageFrameIndex = 0;

    for (int j = pages.length - 1; j > 0; --j) {
      final int k = findBackward(pageRefIndex, pages[j]);
      if (k < 0)
        return j;
      if (k < prevRefIndex) {
        prevRefIndex = k;
        pageFrameIndex = j;
        }
      }

    return pageFrameIndex;
    }


  private int
  findBackward(int pageRefIndex, int pageNumber) {

    while (--pageRefIndex > -1)
      if (pages[pageRefIndex] == pageNumber)
        break;

    return pageRefIndex;
    }


  LRUPageReferenceSequence(int pages[]) {
    super(pages);
    }
  }


class
PageFrameSet {
  

  // An immutable set of primary-store page frames.


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
    

  private PageFrameSet
  pageAdd(int pageIndex) {

    // Add the page at the given index to a frame in this page-frame set.
    // Return a copy of this page-frame set containing the page.

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

       i = pageSequence.ejectPage(pageIndex, frames);
       newPageFrameSet.frames[i] = pageNo;

    return newPageFrameSet;
    }


  public
  PageFrameSet(int c, PageReferenceSequence pages) {

    // Create a new empty imutable set of page frames.

    assert c > 0;
    frames = new int [c];
    Arrays.fill(frames, freePageFrame);
    pageSequence = pages;
    }
    

  private
  PageFrameSet(PageFrameSet pageFrames) {

    // Create a copy of the given page-frame set.

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



abstract class
PageReferenceSequence {


  // An immutable sequence of page references.  Similar to what might be
  // produced by an execuing process, except redundant page references are
  // scrubbed.


  void
  draw(int ulx, int uly) {

    // Draw this page-reference sequence assuming the origin point is given by
    // (ulx, uly).

    textSize(frameHeight);
    textAlign(CENTER, BOTTOM);
    fill(fgColor);

    uly = uly + frameHeight;

    for (int i = 0; i < pages.length; ++i) 
      text(pages[i], ulx + frameWidth*(i + 1) + frameGap*(i + 0.5), uly);
    }


  abstract int ejectPage(int pageRefIndex, int pages[]);

    // Select a page for replacement.


  int
  get(int i) {

    // Return the page reference associated with the given index.

    return pages[i];
    }


  PageReferenceSequence(int p[]) {

    // Create a new page-reference sequence based on the given page references.

    pages = Arrays.copyOf(p, p.length);
    }


  int
  size() {

    // Return the size of this page-reference sequence in page referecnes.

    return pages.length;
    }


  protected final int pages[];
  }


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