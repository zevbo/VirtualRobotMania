# VirtualRobotMania

### Getting Started
1. Download DrRacket here: https://download.racket-lang.org/ and go ahead and install it
2. Go to https://github.com/zevbo/VirtualRobotMania and click on the green button on the upper right that says "clone or download", and then click on the "download ZIP" button that shows up below.
3. Unpack the zip file (double-clicking in it should get that started)
4. Open DrRacket
5. In DrRacket, click file -> open (on the top) and navigate to VirtualRobotMania/manias/.
6. Open up any of the example files in the manias folder
7. Press run in the top right!

### How to start making the robot do stuff!
- Firstly, make sure you know the basics of Racket. This isn't enough room here for a tutorial, but here are a couple of nice ones: https://docs.racket-lang.org/plait/Tutorial.html, https://docs.racket-lang.org/quick/. If you have substantial experience programming, the main 2 things you need to know are that the language is based on the format: (function arguments ...), and to use the amazing racket docs which can be found in Help -> Racket Documentation (on the top)
- At the top of any example mania file, there should be a section called "BASICS" which will have some simple functionality from Racket. There will also be a section called "STUFF TO TRY" which will have functions specific to robot mania. Read through the comments to get a feel of what you can do
- You can write stuff in the body of the "on-tick" function. On-tick is called every tick, and can be thought almost of as the "master function"
- Also you can edit the call to "make-robot" to customize the look (or sometimes functionality) of your robot
