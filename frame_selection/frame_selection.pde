import java.util.Arrays;

color bgColor = color(0, 0, 0);
color fgColor = color(255, 255, 255);

final int frameWidth = 14;
final int frameHeight = frameWidth;
final int frameGap = (int) (0.75*frameWidth);

final int pageReferences [] = 
  new int [] { 7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2, 1, 2, 0, 1, 7, 0, 1 };

final PageFrameSets pageFrameSets = leastRecentlyUsed(3, pageReferences);
final int freePageFrame = -1;


void
draw() {

  background(bgColor);
  stroke(fgColor);
  
  drawPageReferences(10, 10, pageReferences);
  drawPageFrameSets(10, 25, pageFrameSets);
  }
  

void
drawPageFrameSet(int ulx, int uly, int pageFrameSet[]) {

  final int n = pageFrameSet.length;
  fill(bgColor);
  rect(ulx, uly, frameWidth, n*frameHeight);

  for (int i = 1; i < n; ++i) {
    final int y = uly + i*frameHeight;
    line(ulx, y, ulx + frameWidth, y);
    }

  drawPageNumbers(ulx, uly, pageFrameSet);
  }
    

void
drawPageFrameSets(int ulx, int uly, PageFrameSets pageFrameSets) {
  
  int lastPageFrameSet[] = pageFrameSets.get(0);
  drawPageFrameSet(ulx, uly, lastPageFrameSet);
  for (int i = 1; i < pageFrameSets.size(); ++i) {
    final int pageFrameSet[] = pageFrameSets.get(i);
    ulx += frameGap + frameWidth;
    if (pageFrameSet != lastPageFrameSet)
      drawPageFrameSet(ulx, uly, pageFrameSets.get(i));
    lastPageFrameSet = pageFrameSet;
    }
  }


void
drawPageNumbers(int ulx, int uly, int pageFrameSet[]) {

  //

  final int x = ulx + frameWidth/2;

  textSize(frameHeight - 2);
  textAlign(CENTER, BOTTOM);
  fill(fgColor);

  for (int i = 0; i < pageFrameSet.length; ++i) 
    if (pageFrameSet[i] != freePageFrame)
      text(pageFrameSet[i], x, uly + frameHeight*(i + 1) + 1);
  }


void
drawPageReferences(int ulx, int uly, int pageRefs[]) {

  // Draw this page-reference sequence assuming the origin point is given by
  // (ulx, uly).

  textSize(frameHeight);
  textAlign(CENTER, BOTTOM);
  fill(fgColor);

  uly = uly + frameHeight;

  for (int i = 0; i < pageRefs.length; ++i) 
    text(pageRefs[i], ulx + frameWidth*(i + 1) + frameGap*(i + 0.5), uly);
  }


int
findClosestAfter(int pageRef, int pageRefIndex, int pageReferences[]) {

  // Return the index to the given page ref in the given page-reference
  // sequence that is strictly to the right of and closest to the given
  // page-reference index, or -1 if there's no such index.

  while (++pageRefIndex < pageReferences.length)
    if (pageReferences[pageRefIndex] == pageRef)
      return pageRefIndex;

  return -1;
  }


int
findClosestBefore(int pageRef, int pageRefIndex, int pageReferences[]) {

  // Return the index to the given page ref in the given page-reference
  // sequence that is strictly to the left of and closest to the given
  // page-reference index, or -1 if there's no such index.

  while ((--pageRefIndex >= 0) && (pageReferences[pageRefIndex] != pageRef)) ;

  return pageRefIndex;
  }


int
findPage(int pageFrameSet[], int pageRef) { 

  // Look for the given page reference in the given page-frame set.  Return the
  // page-frame index if found, -1 otherwise.

  for (int i = pageFrameSet.length - 1; i > -1; --i)
    if (pageFrameSet[i] == pageRef)
      return i;

  return -1;
  }


PageFrameSets
leastRecentlyUsed(int pageFrameSetSize, int pageReferences[]) {

  // Return a sequence of page-frame sets, each of which has the given size in
  // page frames, that have been managed by the lru-page selection algorithm
  // for the given page-reference sequence.

  final PageFrameSets pageFrames = new PageFrameSets(pageFrameSetSize);

  for (int pageRefIndex = 0; pageRefIndex < pageReferences.length; ++pageRefIndex) {
    final int pageRef = pageReferences[pageRefIndex];
    if (!referencePage(pageRef, pageFrames)) {
      final int lastFrameSet [] = pageFrames.addCopy();
      lastFrameSet[lruPick(pageRefIndex, lastFrameSet, pageReferences)] = 
        pageRef;
      }
    }

  return pageFrames;
  }


int
lruPick(final int pageRefIndex, int pageFrames[], int pageReferences[]) {

  // Return the index of the lru page to eject from the given page-frame set
  // when the incoming page is at the given index in the given page-reference
  // sequence.

  int pageFrameIndex = 0;
  int replacementIndex = 
    findClosestBefore(
      pageFrames[pageFrameIndex], pageRefIndex, pageReferences);
  if (replacementIndex < 0)
    return pageFrameIndex;

  for (int pfi = 1; pfi < pageFrames.length; ++pfi) {
    final int ri = 
      findClosestBefore(pageFrames[pfi], pageRefIndex, pageReferences);
    if (ri < 0)
      return pfi;
    if (ri < replacementIndex) {
      pageFrameIndex = pfi;
      replacementIndex = ri;
      }
    }

  return pageFrameIndex;
  }


PageFrameSets
optimal(int pageFrameSetSize, int pageReferences[]) {

  // Return a sequence of page-frame sets, each of which has the given size in
  // page frames, that have been managed by the optimal-page selection
  // algorithm for the given page-reference sequence.

  final PageFrameSets pageFrames = new PageFrameSets(pageFrameSetSize);

  for (int pageRefIndex = 0; pageRefIndex < pageReferences.length; ++pageRefIndex) {
    final int pageRef = pageReferences[pageRefIndex];
    if (!referencePage(pageRef, pageFrames)) {
      final int lastFrameSet [] = pageFrames.addCopy();
      lastFrameSet[optimalPick(pageRefIndex, lastFrameSet, pageReferences)] = 
        pageRef;
      }
    }

  return pageFrames;
  }


int
optimalPick(final int pageRefIndex, int pageFrames[], int pageReferences[]) {

  // Return the index of the optimal page to eject from the given page-frame
  // set when the incoming page is at the given index in the given
  // page-reference sequence.

  int pageFrameIndex = 0;
  int replacementIndex = 
    findClosestAfter(pageFrames[pageFrameIndex], pageRefIndex, pageReferences);
  if (replacementIndex < 0)
    return pageFrameIndex;

  for (int pfi = 1; pfi < pageFrames.length; ++pfi) {
    final int ri = 
      findClosestAfter(pageFrames[pfi], pageRefIndex, pageReferences);
    if (ri < 0)
      return pfi;
    if (ri > replacementIndex) {
      pageFrameIndex = pfi;
      replacementIndex = ri;
      }
    }

  return pageFrameIndex;
  }


boolean
referencePage(int pageRef, PageFrameSets pageFrames) {

  int lastFrameSet[] = pageFrames.tail();

  if (findPage(lastFrameSet, pageRef) > -1) {
    pageFrames.add(lastFrameSet);
    return true;
    }

  final int i = findPage(lastFrameSet, freePageFrame);
  if (i > -1) {
    pageFrames.addCopy()[i] = pageRef;
    return true;
    }

  return false;
  }


void
setup() {
  size(640, 480);
  }


class
PageFrameSets {

  // A sequence of page-frame sets.


  int []
  add(int pageFrameSet[]) {
    
    // Add the given page-frame set to the end of this sequence.  Return the
    // given page-frame set.

    pageFrameSets.add(pageFrameSet);
    return pageFrameSet;
    }


  int []
  addCopy() {

    // Add a copy of this sequence's tail to the end of this sequence.  Return
    // the new tail.

    final int pageFrameSet[] = tail();
    return add(Arrays.copyOf(pageFrameSet, pageFrameSet.length));
    }


  int []
  get(int i) {
    return pageFrameSets.get(i);
    }


  PageFrameSets(int pfs) {
    pageFrameSets = new ArrayList<int []>();
    pageFrameSetSize = pfs;
    final int pageFrames[] = new int [pageFrameSetSize];
    Arrays.fill(pageFrames, freePageFrame);
    pageFrameSets.add(pageFrames);
    }


  int
  size() {
    return pageFrameSets.size();
    }


  int []
  tail() {
    return pageFrameSets.get(pageFrameSets.size() - 1);
    }


  private final ArrayList<int []> pageFrameSets;
  private final int pageFrameSetSize;
  }