import java.util.Arrays;

color bgColor = color(0, 0, 0);
color fgColor = color(255, 255, 255);

final int frameWidth = 14;
final int frameHeight = frameWidth;
final int frameGap = (int) (0.75*frameWidth);

final int pageReferences [] = 
  new int [] { 7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2, 1, 2, 0, 1, 7, 0, 1 };

final ArrayList<int []> pageFrameSets = optimal(3, pageReferences);
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
drawPageFrameSets(int ulx, int uly, ArrayList<int []> pageFrameSets) {

  
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

  //

  while (++pageRefIndex < pageReferences.length)
    if (pageReferences[pageRefIndex] == pageRef)
      return pageRefIndex;

  return -1;
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


ArrayList<int []>
optimal(int pageFrameSetSize, int pageReferences[]) {

  final ArrayList<int []> pageFrames = new ArrayList<int []>();

  int lastFrameSet [] = new int [pageFrameSetSize];
  Arrays.fill(lastFrameSet, freePageFrame);
  pageFrames.add(lastFrameSet);

  for (int pageRefIndex = 0; pageRefIndex < pageReferences.length; ++pageRefIndex) {
    final int pageRef = pageReferences[pageRefIndex];
    if (findPage(lastFrameSet, pageRef) < 0) {
      lastFrameSet = Arrays.copyOf(lastFrameSet, lastFrameSet.length);
      int i = findPage(lastFrameSet, freePageFrame);
      if (i < 0)
        i = optimalPick(pageRefIndex, lastFrameSet, pageReferences);
      lastFrameSet[i] = pageRef;
      }
    pageFrames.add(lastFrameSet);
    }

  return pageFrames;
  }


int
optimalPick(final int pageRefIndex, int pageFrames[], int pageReferences[]) {

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


void
setup() {
  size(640, 480);
  }
